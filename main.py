from tkf92_hmm import TKF92PairHMM, jukes_cantor_params

if __name__ == "__main__":
    params = jukes_cantor_params(
        lam=0.03,
        mu=0.08,
        rho=0.25,
        subst_rate=0.5,
    )

    hmm = TKF92PairHMM(params)

    alignment = hmm.parse_alignment(
        "AC-GT",
        "A-TGT",
    )

    ll = hmm.log_likelihood(alignment, t=1.0)
    fit = hmm.fit_time(alignment, bounds=(0.0, 20.0))

    print("log P(A,X,Y | theta,t=1):", ll)
    print("best t:", fit.t)