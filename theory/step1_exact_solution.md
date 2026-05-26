# Step 1: Exact propagator and Rabi solution

## Goal

Solve $\,i\,d\lvert\psi\rangle/dt = \hat H\lvert\psi\rangle\,$ for
$\hat H = \omega\,\hat\sigma_x$, $\lvert\psi(0)\rangle = \lvert{\uparrow}\rangle$.

## Propagator

For a time-independent Hamiltonian the evolution is
$\lvert\psi(t)\rangle = e^{-i\hat H t}\lvert\psi(0)\rangle$. Using
$\hat\sigma_x^2 = \hat{\mathbb 1}$,

$$
e^{-i\omega t\,\hat\sigma_x}
  = \cos(\omega t)\,\hat{\mathbb 1} - i\sin(\omega t)\,\hat\sigma_x .
$$

## State and observables

Acting on $\lvert{\uparrow}\rangle$,

$$
\lvert\psi(t)\rangle
  = \cos(\omega t)\,\lvert{\uparrow}\rangle
  - i\sin(\omega t)\,\lvert{\downarrow}\rangle .
$$

Hence

$$
P_\downarrow(t) = \sin^2(\omega t),
\qquad
\langle\hat\sigma_z\rangle(t) = \cos(2\omega t),
\qquad
\langle\psi|\psi\rangle = 1 .
$$

## Numerical checks

- **Python:** `numerics/python/tests/test_two_level.py` asserts the RK4
  trajectory matches $\sin^2(\omega t)$ and $\cos(2\omega t)$ to $<10^{-6}$.
- **Fortran:** `numerics/fortran/test/check.f90` does the same and calls
  `error stop` on failure (`fpm test`).
- **Mathematica:** `numerics/mathematica/two_level.wls` verifies the
  closed-form propagator symbolically and via `NDSolve`.
