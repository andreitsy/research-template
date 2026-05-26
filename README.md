# Project template

A starting point for a new PhD sub-project. It bundles a LaTeX manuscript,
step-by-step theory notes, and cross-validated **Fortran**, **Python**, and
**Mathematica** numerics around one minimal worked example: a driven two-level
system. Copy it, replace the physics, keep the structure.

File-by-file roles, conventions, expected numerical tolerances, and the full
adaptation checklist live in `CLAUDE.md`.

## Worked example

A single qubit with the Hermitian off-diagonal coupling

```
H = omega ( |up><down| + |down><up| ) = omega * sigma_x      (hbar = 1)
```

starting from `|psi(0)> = |up>`. The exact (Rabi) solution is

```
|psi(t)>     = cos(omega t) |up> - i sin(omega t) |down>
P_down(t)    = sin^2(omega t)
<sigma_z>(t) = cos(2 omega t)
```

All three numerics stacks integrate the Schrodinger equation with RK4 and check
themselves against this closed form.

## Layout

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

## Prerequisites

Each stack is independent; install only the tools for the parts you use.

| Stack | Tools | Install (macOS / Homebrew) |
|---|---|---|
| Fortran | `fpm`, `gfortran` | `brew install fortran-lang/fortran/fpm gcc` |
| Python | `uv` (Python ≥ 3.14) | `brew install uv` |
| Mathematica | `wolframscript` | bundled with a Wolfram/Mathematica install |
| Manuscript | `latexmk` + a TeX distribution with REVTeX 4-2 | `brew install --cask mactex` |

## How to run

Run each stack from its own directory; any one can be run on its own.

```bash
# from the project root
( cd numerics/fortran     && fpm test && fpm run )                 # -> results/two_level.dat
( cd numerics/python      && uv sync && uv run pytest && uv run python run.py )  # -> CSV + plot
( cd numerics/mathematica && wolframscript -file two_level.wls )   # symbolic + NDSolve check
( cd manuscript           && make )                                # latexmk -> main.pdf
```

The Fortran test and the Mathematica script print `[PASS]`/`[FAIL]` and exit
non-zero on failure; `pytest` runs 4 checks against the analytic solution.
`run.py` also copies its plot into `manuscript/figs/`, so the manuscript builds
out of the box. Numerical output goes to each stack's gitignored `results/`
directory.

## Using it for a new project

This template is **standalone**: not a uv workspace member and not a git
submodule.

```bash
cp -r research-template projects/<new_project>
```

Then rename the packages (`two_level` / `two-level-template`), replace the
worked example, and update the manuscript. See the "Adapting the template"
section of `CLAUDE.md` for the full checklist.
