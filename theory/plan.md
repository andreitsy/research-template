# Theory plan

Analytical calculations are split into small, independently checkable steps.
Each step lives in its own `stepN_*.md` file and should be verifiable against
the numerics in `../numerics/` (Fortran, Python, and Mathematica).

## Model

A single two-level system with the Hermitian off-diagonal coupling

$$
\hat H = \omega\,(\lvert{\uparrow}\rangle\langle{\downarrow}\rvert
       + \lvert{\downarrow}\rangle\langle{\uparrow}\rvert)
       = \omega\,\hat\sigma_x ,
\qquad \hbar = 1,
$$

with initial state $\lvert\psi(0)\rangle = \lvert{\uparrow}\rangle$.

Basis ordering: index 1 (or 0 in Python) $= \lvert{\uparrow}\rangle$,
index 2 (or 1) $= \lvert{\downarrow}\rangle$.

## Steps

- [x] [step1: exact propagator and Rabi solution](step1_exact_solution.md)
- [ ] step2: add a detuning term $(\Delta/2)\hat\sigma_z$ (extension exercise)
- [ ] step3: open-system version with a decay channel $\hat L = \sqrt{\kappa}\,\hat\sigma_-$

## Conventions

- Schr\"odinger equation in the form $\,i\,d\lvert\psi\rangle/dt = \hat H\lvert\psi\rangle$.
- Every nontrivial identity should carry a one-line numerical check (a `pytest`
  assertion, a Fortran `error stop` test, or a Mathematica `PASS/FAIL` line).
