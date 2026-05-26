# Project template

A starting point for a new PhD sub-project. It bundles a LaTeX manuscript,
step-by-step theory notes, and cross-validated **Fortran**, **Python**, and
**Mathematica** numerics around one minimal worked example: a driven two-level
system.

## Worked example

A single qubit with the Hermitian off-diagonal coupling

```
H = omega ( |up><down| + |down><up| ) = omega * sigma_x      (hbar = 1)
```

starting from `|psi(0)> = |up>`. The exact (Rabi) solution is

```
|psi(t)> = cos(omega t) |up> - i sin(omega t) |down>
P_down(t)      = sin^2(omega t)
<sigma_z>(t)   = cos(2 omega t)
```

All three numerics stacks integrate the Schrodinger equation with RK4 and check
themselves against this closed form.

## Layout

```
_template/
  README.md  CLAUDE.md  LICENSE  .gitignore
  manuscript/                 # LaTeX paper (REVTeX / PRA)
    main.tex  biblio.bib  Makefile  figs/
  theory/                     # analytical derivation, one file per step
    plan.md  step1_exact_solution.md
  numerics/
    fortran/                  # fpm package `two_level`
      fpm.toml  src/  app/  test/  results/
    python/                   # package `two_level`
      pyproject.toml  parameters.ini  run.py  two_level/  tests/  results/
    mathematica/              # wolframscript verification
      two_level.wls
```

## Using it for a new project

This template is **standalone**: it is not a uv workspace member and not a git
submodule. To start a new project:

```bash
cp -r research-template projects/<new_project>
```

Then rename the packages (`two_level` / `two-level-template`), update titles in
`manuscript/main.tex` and `CLAUDE.md`, and replace the worked example with your
model.

## Prerequisites

Each stack is independent; install only the tools for the parts you use.

| Stack | Tools | Install (macOS / Homebrew) |
|---|---|---|
| Fortran | `fpm`, `gfortran` | `brew install fortran-lang/fortran/fpm gcc` |
| Python | `uv` (Python ≥ 3.14) | `brew install uv` |
| Mathematica | `wolframscript` | bundled with a Wolfram/Mathematica install |
| Manuscript | `latexmk` + a TeX distribution with REVTeX 4-2 | `brew install --cask mactex` |

## How to run

All commands are run from the stack's own directory. Each numerics stack solves
the same model and checks itself against the closed-form solution above, so any
one of them can be run on its own.

### Fortran (`numerics/fortran/`)

```bash
cd numerics/fortran
fpm test    # build + run unit test: RK4 vs analytic, max error ~1e-13, prints PASS
fpm run     # run the driver: integrates and writes results/two_level.dat
```

`fpm test` prints a `[PASS]`/`[FAIL]` line per check and exits non-zero on
failure. `fpm run` writes columns `t  P_up  P_down  <sigma_z>` to
`results/two_level.dat`.

### Python (`numerics/python/`)

```bash
cd numerics/python
uv sync                 # create .venv and install numpy/matplotlib/pytest
uv run pytest           # 4 tests: Hamiltonian, norm, observables, state vs analytic
uv run python run.py    # writes results/two_level.csv and results/two_level_dynamics.png
```

`run.py` reads `parameters.ini` (coupling `omega`, time grid), integrates with
RK4, saves the trajectory as CSV, produces a plot overlaying the numeric result
on the analytic Rabi curves, and copies that plot into `manuscript/figs/` so the
manuscript builds without a manual step.

### Mathematica (`numerics/mathematica/`)

```bash
cd numerics/mathematica
wolframscript -file two_level.wls   # symbolic propagator + NDSolve cross-check
```

Prints a `[PASS]`/`[FAIL]` line per check and exits non-zero on failure.

### Manuscript (`manuscript/`)

```bash
cd manuscript
make            # latexmk -> main.pdf
make clean      # remove LaTeX aux files (keep the PDF)
make distclean  # remove aux files and the PDF
```

`main.tex` includes `figs/two_level_dynamics.png`. A generated copy ships with
the template, so `make` works out of the box; re-run the Python driver to
refresh it:

```bash
( cd numerics/python && uv run python run.py )   # rewrites manuscript/figs/
cd manuscript && make
```

### End-to-end

```bash
# from the project root
( cd numerics/fortran     && fpm test )
( cd numerics/python      && uv sync && uv run pytest && uv run python run.py )
( cd numerics/mathematica && wolframscript -file two_level.wls )
( cd manuscript           && make )
```

Numerical output is written to each stack's `results/` directory, which is
gitignored (only `.gitkeep` is tracked).
