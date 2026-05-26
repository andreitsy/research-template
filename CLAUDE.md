# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository. This is a **project template**; copy it to
`projects/<new_project>` to start a new sub-project, then adapt every section
below to the real model.

## Project Overview

A minimal, fully worked example: the real-time evolution of a driven two-level
system, solved analytically and cross-validated with three independent numerics
stacks (Fortran, Python, Mathematica) and written up as a short LaTeX
manuscript. It exists to be copied — replace the physics, keep the structure.

ALWAYS keep the analytics in `theory/` and the numerics in `numerics/` in sync:
every nontrivial formula should have a numerical check (a `pytest` assertion, a
Fortran `error stop` test, or a Mathematica `PASS/FAIL` line).

## Physics

The starting point is the off-diagonal coupling `omega |up><down|`. Its
Hermitian completion is the Hamiltonian (with `hbar = 1`)

```
H = omega ( |up><down| + |down><up| ) = omega * sigma_x
```

with `omega` a real coupling rate, integrated from the initial state
`|psi(0)> = |up>`. Because `H` is time independent and `sigma_x^2 = 1`,

```
exp(-i omega t sigma_x) = cos(omega t) I - i sin(omega t) sigma_x
```

so the exact solution and observables are

```
|psi(t)>     = cos(omega t) |up> - i sin(omega t) |down>
P_down(t)    = sin^2(omega t)
<sigma_z>(t) = P_up - P_down = cos(2 omega t)
<psi|psi>    = 1   (norm conserved)
```

i.e. Rabi oscillations at angular frequency `2 omega`. **Basis ordering:**
index 1 = `|up>`, index 2 = `|down>` (0 and 1 respectively in Python/NumPy).

All numerics integrate the Schrodinger equation in the form
`d|psi>/dt = -i H |psi>` with the classical 4th-order Runge-Kutta scheme
(`k1..k4`, weights `1,2,2,1`), the same algorithm in every language.

## Tech stack

- LaTeX (REVTeX 4-2, `aps`/`pra` options) for the manuscript; formulas in `.md`
  theory notes.
- Fortran (free-form, `real64`) built with `fpm` for the reference solver.
- Python (NumPy / Matplotlib, managed with `uv`, Python >= 3.14) for an
  independent solver, CSV output, and plotting.
- Mathematica (`wolframscript`) for symbolic verification.

## Directory layout

```
research-template/
  README.md  CLAUDE.md  LICENSE  .gitignore
  manuscript/                 # LaTeX paper (REVTeX / PRA)
    main.tex  biblio.bib  Makefile  figs/
  theory/                     # analytical derivation, one file per step
    plan.md  step1_exact_solution.md  two_level.nb
  numerics/
    fortran/                  # fpm package `two_level`
    python/                   # package `two_level`
    mathematica/              # wolframscript verification
```

## Theory (`theory/`)

Holds the analytical calculation split into small, independently checkable
steps (`stepN_*.md`), tracked from `theory/plan.md`. Do the main derivation
work here; `plan.md` also lists extension exercises (detuning term, open-system
decay channel). Each step ends with a "Numerical checks" section pointing at
the test that verifies it. `two_level.nb` is a Mathematica notebook companion
for interactive symbolic work (the scripted equivalent is
`numerics/mathematica/two_level.wls`).

## Numerics (`numerics/`)

### Fortran (`numerics/fortran/`) — `fpm` package `two_level`

| File | Role |
|---|---|
| `fpm.toml` | Package manifest (`auto-executables`/`auto-tests`, free-form source). |
| `src/two_level.f90` | Module `two_level`: `CI` (imaginary unit), `build_hamiltonian(omega, H)`, `schrodinger_rhs(psi, H, dim, dpsi)`, `rk4_step(psi, H, dim, dt)`. Dimension-agnostic (`dim` passed at runtime). |
| `app/main.f90` | Driver: builds `H`, sets `|psi(0)>=|up>`, integrates (`omega=1`, `t in [0,10]`, `10000` steps), writes `t P_up P_down <sigma_z>` to `results/two_level.dat`. |
| `test/check.f90` | Integrates with `omega=0.7`, compares `P_down`, `<sigma_z>`, and norm to the analytic solution; `report` subroutine prints `[PASS]/[FAIL]`; `error stop` on failure so `fpm test` exits non-zero. |

### Python (`numerics/python/`) — package `two_level`

| File | Role |
|---|---|
| `pyproject.toml` | Project metadata, deps (`numpy`, `matplotlib`), dev dep (`pytest`), `pytest` config. `package = false`. |
| `parameters.ini` | `[model] omega`, `[evolution] t_start/t_end/n_steps`. |
| `two_level/config.py` | `SimulationParams` dataclass (with `dt`, `times` properties) and `load_params(path)` INI loader (falls back to defaults). |
| `two_level/solver.py` | `hamiltonian(omega)`, RK4 (`_rhs`, `_rk4_step`), `evolve(params, psi0)` -> `(times, psi_t)`, plus `populations` and `sigma_z` helpers. |
| `two_level/analytic.py` | Closed form: `analytic_state`, `analytic_p_down`, `analytic_sigma_z`. |
| `two_level/plotting.py` | `plot_dynamics(...)`: numeric vs analytic `P_down` and `<sigma_z>`, saves PNG. |
| `run.py` | CLI: load params -> evolve -> save `results/two_level.csv` -> plot `results/two_level_dynamics.png` -> copy the plot into `../../manuscript/figs/`. |
| `tests/test_two_level.py` | 4 tests: Hamiltonian is Hermitian `omega sigma_x`; norm conserved; observables match analytic (`< 1e-6`); state matches analytic (`< 1e-6`). |

### Mathematica (`numerics/mathematica/`)

| File | Role |
|---|---|
| `two_level.wls` | `wolframscript` script: builds `H = omega sigma_x`, computes `MatrixExp[-i H t]|up>`, `FullSimplify`-checks it equals the closed form and that `P_down`, `<sigma_z>`, and norm match; an independent `NDSolve` run cross-checks `P_down` numerically. `report[]` prints `[PASS]/[FAIL]`; `Exit[1]` on failure. |

## Build & test

Run each from its own directory (see `README.md` for prerequisites and expected
output).

```bash
# Fortran
cd numerics/fortran && fpm test && fpm run

# Python
cd numerics/python && uv sync && uv run pytest && uv run python run.py

# Mathematica
cd numerics/mathematica && wolframscript -file two_level.wls

# Manuscript
cd manuscript && make            # latexmk -> main.pdf; `make clean` / `make distclean` to tidy
```

### Expected results

- Fortran test: `max_err ~ 1e-13` for `P_down`/`<sigma_z>`, `~1e-15` for norm.
- Python: 4 tests pass; observables/state agree with analytic to `< 1e-6`.
- Mathematica: all symbolic checks `PASS`; `NDSolve` `max_err ~ 7e-11`.
- Manuscript: `main.pdf` builds with no unresolved references or citations.

## Manuscript (`manuscript/`)

`main.tex` is a REVTeX two-column PRA document with abstract, numbered
sections, numbered equations, a figure, acknowledgments, and a `biblio.bib`
bibliography (cited so the reference list renders). It includes
`figs/two_level_dynamics.png`; a generated copy is committed so `make` works out
of the box, and `numerics/python/run.py` rewrites it. Build with `make` (wraps
`latexmk -pdf`).

## Conventions

- **Standalone project:** NOT a uv workspace member and NOT a git submodule of
  the monorepo. It carries its own `pyproject.toml` and `fpm.toml`, so
  `uv sync` and `fpm` work inside it without touching the parent workspace.
- Follow the Physical Review style guide in the repo-root `CLAUDE.md` for all
  `.tex` and `.md` files.
- Numerical output goes to each stack's `results/` directory (gitignored except
  `.gitkeep`). The manuscript figure in `manuscript/figs/` is committed (the
  Python driver rewrites it). Build artifacts (`build/`, `.venv/`, LaTeX aux)
  are gitignored.
- Same RK4 algorithm and basis ordering across all stacks so they can be
  cross-checked against each other and against the analytic solution.

## Adapting the template for a new project

1. `cp -r research-template projects/<new_project>`.
2. Rename packages: `two_level` (Fortran module + Python package + `fpm.toml`
   `name`) and `two-level-template` (Python `pyproject.toml` `name`).
3. Replace the model: edit `build_hamiltonian` / `hamiltonian`, the initial
   state, and `parameters.ini`; update `analytic.py` (or drop it if no closed
   form exists) and the tests' reference values.
4. Rewrite `theory/plan.md` + step files for the new derivation.
5. Update `manuscript/main.tex` (title, abstract, model, results) and
   `biblio.bib`.
6. Rewrite this `CLAUDE.md`'s Project Overview and Physics sections.
