"""Closed-form solution of H = omega sigma_x with |psi(0)> = |up>.

    |psi(t)> = cos(omega t) |up> - i sin(omega t) |down>
    P_down(t) = sin^2(omega t)
    <sigma_z>(t) = cos(2 omega t)
"""

from __future__ import annotations

import numpy as np


def analytic_state(omega: float, t: np.ndarray) -> np.ndarray:
    """Exact |psi(t)> as a (len(t), 2) complex array, starting from |up>."""
    t = np.asarray(t, dtype=float)
    psi = np.empty((t.size, 2), dtype=complex)
    psi[:, 0] = np.cos(omega * t)
    psi[:, 1] = -1j * np.sin(omega * t)
    return psi


def analytic_p_down(omega: float, t: np.ndarray) -> np.ndarray:
    return np.sin(omega * np.asarray(t, dtype=float)) ** 2


def analytic_sigma_z(omega: float, t: np.ndarray) -> np.ndarray:
    return np.cos(2.0 * omega * np.asarray(t, dtype=float))
