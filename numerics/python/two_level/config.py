"""Simulation parameters and parameters.ini loader."""

from __future__ import annotations

import configparser
from dataclasses import dataclass
from pathlib import Path

import numpy as np


@dataclass(frozen=True)
class SimulationParams:
    """Parameters of the two-level real-time evolution (hbar = 1)."""

    omega: float = 1.0
    t_start: float = 0.0
    t_end: float = 10.0
    n_steps: int = 10000

    @property
    def dt(self) -> float:
        return (self.t_end - self.t_start) / self.n_steps

    @property
    def times(self) -> np.ndarray:
        return np.linspace(self.t_start, self.t_end, self.n_steps + 1)


def load_params(path: str | Path = "parameters.ini") -> SimulationParams:
    """Read a SimulationParams from an INI file; fall back to defaults if absent."""
    path = Path(path)
    if not path.exists():
        return SimulationParams()

    cfg = configparser.ConfigParser()
    cfg.read(path)
    return SimulationParams(
        omega=cfg.getfloat("model", "omega", fallback=1.0),
        t_start=cfg.getfloat("evolution", "t_start", fallback=0.0),
        t_end=cfg.getfloat("evolution", "t_end", fallback=10.0),
        n_steps=cfg.getint("evolution", "n_steps", fallback=10000),
    )
