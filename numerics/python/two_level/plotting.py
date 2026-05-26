"""Plot the two-level dynamics: numeric RK4 vs analytic Rabi solution."""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

from .analytic import analytic_p_down, analytic_sigma_z
from .config import SimulationParams
from .solver import populations, sigma_z


def plot_dynamics(
    params: SimulationParams,
    times: np.ndarray,
    psi_t: np.ndarray,
    out_path: str | Path = "results/two_level_dynamics.png",
) -> Path:
    """Plot P_down(t) and <sigma_z>(t), numeric vs analytic, and save a PNG."""
    out_path = Path(out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    _, p_down = populations(psi_t)
    sz = sigma_z(psi_t)
    p_down_exact = analytic_p_down(params.omega, times)
    sz_exact = analytic_sigma_z(params.omega, times)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(times, p_down, color="C0", label=r"$P_\downarrow(t)$ (RK4)")
    ax.plot(times, p_down_exact, color="C0", ls="--", lw=1.0,
            label=r"$\sin^2(\omega t)$")
    ax.plot(times, sz, color="C3", label=r"$\langle \sigma_z(t) \rangle$ (RK4)")
    ax.plot(times, sz_exact, color="C3", ls="--", lw=1.0,
            label=r"$\cos(2\omega t)$")

    ax.set_xlabel(r"$\omega$-time $t$")
    ax.set_ylabel("expectation value")
    ax.set_title(
        r"Two-level dynamics: $H=\omega\,\sigma_x$, "
        r"$|\psi(0)\rangle=|{\uparrow}\rangle$"
    )
    ax.axhline(0.0, color="grey", ls=":", lw=0.7)
    ax.legend(ncol=2)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig(out_path, dpi=300)
    plt.close(fig)
    return out_path
