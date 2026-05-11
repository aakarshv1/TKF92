# TKF92 Pair-HMM
### Partial implementation of a TKF92 pair-HMM for HW 3 (Probabilistic Modeling in Computational Biology, taught by Prof. Ian Holmes Spring 2026)

This repository contains a Hidden Markov Model of pairwise alignments according to the TKF92 Indel Model ([Thorne et al., 1991](https://link.springer.com/article/10.1007/BF02193625), [Thorne et al., 1992](https://link.springer.com/article/10.1007/BF00163848)). Currently it supports only DNA sequences but could be extended to arbitrary vocabularies with minimal adjustments. It implements the following functions:

1. Calculate $P(A, X, Y | \theta, t)$

The `log_likelihood` method of the `TKF92PairHMM` class takes in an allignment and a time `t` and outputs a log likelihood (more numerically stable than raw likelihood). One can define the alignment by passing in two strings to the `parse_alignment` method. They must be the same length, consisting of either "A", "C", "T", "G", or "-" (gap token).

2. Find $\hat{t} = \text{argmax}_t \text{ } P(A, X, Y | \theta, t)$

The `fit_time` method of `TKF92PairHMM` takes in an alignment and bounds on the optimal `t`. It then runs SciPy's `minimize_scalar` function, which uses Brent's method, to find $\hat{t}$

## Using the pair-HMM

The parameters of the model can be adjusted within `main.py`. Specifically, you can adjust the mortal link birth rate `lambda`, mortal link death rate `mu`, residue extension parameter `rho`, and a substitution rate. For simplicity, we constrain the substitution rate matrix $Q$ to be be parameterized by a single substitution rate that governs all nucleotide transitions, in accordance with the Jukes-Cantor model. This also means that $\pi$ is a uniform distribution over the nucleotide vocabulary. See `assignment` for a more detailed discussion of the pair-HMM construction and meaning of each of the parameters.

You can also specify the sequences, their alignment, and the time between them in `main.py`.

After ensuring you have `uv` installed, you can run the code with 
```bash
uv run main.py
```
This will output the log-likelihood of the alignment given a fixed $t$ and the $\hat{t}$ that maximizes log-likelihood.

