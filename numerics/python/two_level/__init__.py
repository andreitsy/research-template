"""Two-level system template: H = omega (|up><down| + |down><up|) = omega sigma_x.

Basis ordering: index 0 = |up>, index 1 = |down>.
"""

from .config import SimulationParams, load_params
from .solver import hamiltonian, evolve
from .analytic import analytic_state, analytic_p_down, analytic_sigma_z

__all__ = [
    "SimulationParams",
    "load_params",
    "hamiltonian",
    "evolve",
    "analytic_state",
    "analytic_p_down",
    "analytic_sigma_z",
]
