from __future__ import annotations

from dataclasses import dataclass
from math import inf, log
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

import numpy as np
from scipy.linalg import expm
from scipy.optimize import minimize_scalar

Residue = str
Column = Tuple[Optional[Residue], Optional[Residue]]


@dataclass(frozen=True)
class TKF92Params:
    lam: float
    mu: float
    rho: float
    Q: np.ndarray
    pi: np.ndarray
    alphabet: Sequence[Residue]

    def __post_init__(self) -> None:
        Q = np.asarray(self.Q, dtype=float)
        pi = np.asarray(self.pi, dtype=float)
        object.__setattr__(self, "Q", Q)
        object.__setattr__(self, "pi", pi)
        if not (0 < self.lam < self.mu):
            raise ValueError("Require 0 < lambda < mu.")
        if not (0 <= self.rho < 1):
            raise ValueError("Require 0 <= rho < 1.")
        if len(set(self.alphabet)) != len(self.alphabet):
            raise ValueError("alphabet entries must be unique.")
        if Q.shape != (len(self.alphabet), len(self.alphabet)):
            raise ValueError("Q must be len(alphabet) x len(alphabet).")
        if pi.shape != (len(self.alphabet),):
            raise ValueError("pi must have length len(alphabet).")
        if not np.allclose(Q.sum(axis=1), 0.0, atol=1e-8):
            raise ValueError("Rows of Q must sum to zero.")
        if np.any(pi < 0) or not np.isclose(pi.sum(), 1.0, atol=1e-8):
            raise ValueError("pi must be a probability vector.")
        if not np.allclose(pi @ Q, 0.0, atol=1e-8):
            raise ValueError("pi must be stationary for Q: pi @ Q = 0.")


@dataclass(frozen=True)
class BranchLengthFit:
    t: float
    log_likelihood: float
    success: bool
    nfev: int


class TKF92PairHMM:
    states = ("S", "M", "I", "D", "E")

    def __init__(self, params: TKF92Params):
        self.params = params
        self.index: Dict[Residue, int] = {a: i for i, a in enumerate(params.alphabet)}

    def alpha_beta_gamma(self, t: float) -> Tuple[float, float, float]:
        if t < 0:
            raise ValueError("t must be nonnegative.")
        p = self.params
        delta = p.mu - p.lam
        e = np.exp(-delta * t)
        beta = p.lam * (-np.expm1(-delta * t)) / (p.mu - p.lam * e)
        alpha = np.exp(-p.mu * t)
        one_minus_alpha = -np.expm1(-p.mu * t)
        gamma = 0.0 if one_minus_alpha == 0 else 1.0 - (p.mu * beta) / (p.lam * one_minus_alpha)
        return float(alpha), float(np.clip(beta, 0.0, 1.0)), float(np.clip(gamma, 0.0, 1.0))

    def transition_matrix(self, t: float) -> np.ndarray:
        p = self.params
        a, b, g = self.alpha_beta_gamma(t)
        eta = p.lam / p.mu
        r = p.rho
        T = np.array([
            [0.0, (1-b)*eta*a,             b,             (1-b)*eta*(1-a),             (1-b)*(1-eta)],
            [0.0, r+(1-r)*(1-b)*eta*a,     (1-r)*b,       (1-r)*(1-b)*eta*(1-a),       (1-r)*(1-b)*(1-eta)],
            [0.0, (1-r)*(1-b)*eta*a,       r+(1-r)*b,     (1-r)*(1-b)*eta*(1-a),       (1-r)*(1-b)*(1-eta)],
            [0.0, (1-r)*(1-g)*eta*a,       (1-r)*g,       r+(1-r)*(1-g)*eta*(1-a),     (1-r)*(1-g)*(1-eta)],
            [0.0, 0.0,                     0.0,           0.0,                           1.0],
        ], dtype=float)
        return np.clip(T, 0.0, 1.0)

    def substitution_matrix(self, t: float) -> np.ndarray:
        return expm(self.params.Q * t)

    def emission_prob(self, state: str, column: Column, Psub: np.ndarray) -> float:
        x, y = column
        pi = self.params.pi
        if state == "M":
            if x is None or y is None:
                return 0.0
            return float(pi[self.index[x]] * Psub[self.index[x], self.index[y]])
        if state == "I":
            return 0.0 if y is None else float(pi[self.index[y]])
        if state == "D":
            return 0.0 if x is None else float(pi[self.index[x]])
        return 0.0

    def log_likelihood(self, alignment: Sequence[Column], t: float) -> float:
        T = self.transition_matrix(t)
        Psub = self.substitution_matrix(t)
        sidx = {s: i for i, s in enumerate(self.states)}
        total = 0.0
        prev = "S"

        if not alignment:
            return _safe_log(T[sidx["S"], sidx["E"]])

        for column in alignment:
            state = self._state_for_column(column)
            tr = T[sidx[prev], sidx[state]]
            em = self.emission_prob(state, column, Psub)
            if tr <= 0 or em <= 0:
                return -inf
            total += log(tr) + log(em)
            prev = state

        tr_end = T[sidx[prev], sidx["E"]]
        return -inf if tr_end <= 0 else total + log(tr_end)

    def fit_time(
        self,
        alignment: Sequence[Column],
        bounds: Tuple[float, float] = (0.0, 10.0),
        xatol: float = 1e-6,
    ) -> BranchLengthFit:
        lo, hi = bounds
        if lo < 0 or hi <= lo:
            raise ValueError("bounds must satisfy 0 <= lo < hi.")

        def objective(t: float) -> float:
            ll = self.log_likelihood(alignment, t)
            return inf if ll == -inf else -ll

        inner_lo = lo + 1e-12 if lo == 0 else lo
        res = minimize_scalar(objective, bounds=(inner_lo, hi), method="bounded", options={"xatol": xatol})
        candidates = [(lo, self.log_likelihood(alignment, lo)), (hi, self.log_likelihood(alignment, hi))]
        if res.success:
            candidates.append((float(res.x), -float(res.fun)))
        best_t, best_ll = max(candidates, key=lambda z: z[1])
        return BranchLengthFit(best_t, best_ll, bool(res.success), int(res.nfev))

    @staticmethod
    def parse_alignment(x_gapped: str, y_gapped: str, gap: str = "-") -> List[Column]:
        if len(x_gapped) != len(y_gapped):
            raise ValueError("Gapped strings must have the same length.")
        alignment: List[Column] = []
        for x, y in zip(x_gapped, y_gapped):
            col = (None if x == gap else x, None if y == gap else y)
            if col == (None, None):
                raise ValueError("Alignment cannot contain a double-gap column.")
            alignment.append(col)
        return alignment

    @staticmethod
    def _state_for_column(column: Column) -> str:
        x, y = column
        if x is None and y is None:
            raise ValueError("Double-gap column is invalid.")
        if x is None:
            return "I"
        if y is None:
            return "D"
        return "M"


def _safe_log(x: float) -> float:
    return -inf if x <= 0 else log(x)


def jukes_cantor_params(lam: float, mu: float, rho: float, subst_rate: float = 1.0) -> TKF92Params:
    alphabet = ("A", "C", "G", "T")
    pi = np.full(4, 0.25)
    Q = np.full((4, 4), subst_rate / 3.0)
    np.fill_diagonal(Q, -subst_rate)
    return TKF92Params(lam=lam, mu=mu, rho=rho, Q=Q, pi=pi, alphabet=alphabet)


if __name__ == "__main__":
    params = jukes_cantor_params(lam=0.03, mu=0.08, rho=0.25, subst_rate=0.5)
    hmm = TKF92PairHMM(params)
    aln = hmm.parse_alignment("AC-GT", "A-TGT")
    print("log P(A,X,Y | theta,t=1):", hmm.log_likelihood(aln, t=1.0))
    print("best t:", hmm.fit_time(aln, bounds=(0.0, 20.0)))
