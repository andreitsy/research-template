"""Cross-check the RK4 solver against the closed-form Rabi solution."""

import numpy as np

from two_level import SimulationParams
from two_level.analytic import (
    analytic_p_down,
    analytic_sigma_z,
    analytic_state,
)
from two_level.solver import evolve, hamiltonian, populations, sigma_z


def test_hamiltonian_is_omega_sigma_x():
    H = hamiltonian(0.7)
    expected = 0.7 * np.array([[0, 1], [1, 0]], dtype=complex)
    assert np.allclose(H, expected)
    assert np.allclose(H, H.conj().T), "Hamiltonian must be Hermitian"


def test_norm_is_conserved():
    params = SimulationParams(omega=0.7, t_end=5.0, n_steps=5000)
    _, psi_t = evolve(params)
    norms = np.sum(np.abs(psi_t) ** 2, axis=1)
    assert np.allclose(norms, 1.0, atol=1e-8)


def test_matches_analytic_observables():
    params = SimulationParams(omega=0.7, t_end=5.0, n_steps=5000)
    times, psi_t = evolve(params)

    _, p_down = populations(psi_t)
    sz = sigma_z(psi_t)

    assert np.max(np.abs(p_down - analytic_p_down(params.omega, times))) < 1e-6
    assert np.max(np.abs(sz - analytic_sigma_z(params.omega, times))) < 1e-6


def test_matches_analytic_state():
    params = SimulationParams(omega=1.3, t_end=3.0, n_steps=6000)
    times, psi_t = evolve(params)
    psi_exact = analytic_state(params.omega, times)
    # States agree up to numerical RK4 error (global phase fixed by psi(0)=|up>).
    assert np.max(np.abs(psi_t - psi_exact)) < 1e-6
