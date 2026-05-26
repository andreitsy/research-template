"""RK4 integrator for the time-independent Schrodinger equation (hbar = 1).

    i d|psi>/dt = H |psi>   =>   d|psi>/dt = -i H |psi>

The same algorithm as the Fortran reference implementation, so the two stacks
can be cross-checked against each other and against the analytic solution.
"""

from __future__ import annotations

import numpy as np

from .config import SimulationParams


def hamiltonian(omega: float) -> np.ndarray:
    """H = omega (|up><down| + |down><up|) = omega sigma_x in the {|up>, |down>} basis."""
    return omega * np.array([[0.0, 1.0], [1.0, 0.0]], dtype=complex)


def _rhs(psi: np.ndarray, H: np.ndarray) -> np.ndarray:
    return -1j * (H @ psi)


def _rk4_step(psi: np.ndarray, H: np.ndarray, dt: float) -> np.ndarray:
    k1 = _rhs(psi, H)
    k2 = _rhs(psi + 0.5 * dt * k1, H)
    k3 = _rhs(psi + 0.5 * dt * k2, H)
    k4 = _rhs(psi + dt * k3, H)
    return psi + (dt / 6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4)


def evolve(
    params: SimulationParams,
    psi0: np.ndarray | None = None,
) -> tuple[np.ndarray, np.ndarray]:
    """Integrate the Schrodinger equation on the parameter time grid.

    Returns
    -------
    times : (n_steps + 1,) array of times.
    psi_t : (n_steps + 1, 2) complex array of states, row k = |psi(t_k)>.
    """
    if psi0 is None:
        psi0 = np.array([1.0, 0.0], dtype=complex)  # |up>

    H = hamiltonian(params.omega)
    dt = params.dt
    times = params.times

    psi_t = np.empty((times.size, psi0.size), dtype=complex)
    psi = psi0.astype(complex)
    psi_t[0] = psi
    for k in range(1, times.size):
        psi = _rk4_step(psi, H, dt)
        psi_t[k] = psi

    return times, psi_t


def populations(psi_t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Return (P_up, P_down) along a trajectory psi_t of shape (N, 2)."""
    probs = np.abs(psi_t) ** 2
    return probs[:, 0], probs[:, 1]


def sigma_z(psi_t: np.ndarray) -> np.ndarray:
    """<sigma_z>(t) = P_up - P_down along a trajectory."""
    p_up, p_down = populations(psi_t)
    return p_up - p_down
