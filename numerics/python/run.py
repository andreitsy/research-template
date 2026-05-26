#!/usr/bin/env python3
"""Run the two-level RK4 evolution, save a CSV trace, and plot the dynamics.

Parameters are read from parameters.ini (falling back to defaults).

    uv run --package two-level-template python run.py
"""

import shutil
from pathlib import Path

import numpy as np

from two_level import load_params
from two_level.plotting import plot_dynamics
from two_level.solver import evolve, populations, sigma_z

RESULTS = Path("results")
# Drop the figure straight into the manuscript so `make` works without a
# manual copy step. Path is resolved relative to this file, not the cwd.
MANUSCRIPT_FIGS = Path(__file__).resolve().parents[2] / "manuscript" / "figs"


def main() -> None:
    params = load_params("parameters.ini")
    times, psi_t = evolve(params)

    p_up, p_down = populations(psi_t)
    sz = sigma_z(psi_t)

    RESULTS.mkdir(parents=True, exist_ok=True)
    csv = RESULTS / "two_level.csv"
    np.savetxt(
        csv,
        np.column_stack([times, p_up, p_down, sz]),
        delimiter=",",
        header="t,P_up,P_down,sigma_z",
        comments="",
    )
    print(f"Saved {csv}")

    png = plot_dynamics(params, times, psi_t, RESULTS / "two_level_dynamics.png")
    print(f"Saved {png}")

    MANUSCRIPT_FIGS.mkdir(parents=True, exist_ok=True)
    fig_copy = MANUSCRIPT_FIGS / "two_level_dynamics.png"
    shutil.copyfile(png, fig_copy)
    print(f"Copied figure to {fig_copy}")


if __name__ == "__main__":
    main()
