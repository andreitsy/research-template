! ===========================================================================
! Module: two_level
!
! Real-time evolution of a two-level system under the time-independent
! Schrodinger equation (hbar = 1):
!
!   i d|psi>/dt = H |psi|   =>   d|psi>/dt = -i H |psi>
!
! The example Hamiltonian is the Hermitian off-diagonal coupling
!
!   H = omega ( |up><down| + |down><up| ) = omega * sigma_x
!
! Basis ordering: index 1 = |up>, index 2 = |down>.
!
! The integrator (rk4_step) and right-hand side (schrodinger_rhs) are written
! for an arbitrary Hilbert-space dimension `dim`, so the module is reusable for
! larger systems by passing a different H.
! ===========================================================================
module two_level
  use, intrinsic :: iso_fortran_env, only: dp => real64
  implicit none
  private

  ! Imaginary unit - exported so drivers can build operators conveniently.
  complex(dp), parameter, public :: CI = (0.0_dp, 1.0_dp)

  public :: build_hamiltonian, schrodinger_rhs, rk4_step

contains

  ! ---------------------------------------------------------------------------
  ! build_hamiltonian
  !
  ! Fills the 2x2 Hamiltonian  H = omega * sigma_x  in the {|up>, |down>} basis.
  ! ---------------------------------------------------------------------------
  pure subroutine build_hamiltonian(omega, H)
    real(dp),    intent(in)  :: omega
    complex(dp), intent(out) :: H(2, 2)

    H = (0.0_dp, 0.0_dp)
    H(1, 2) = cmplx(omega, 0.0_dp, dp)   ! omega |up><down|
    H(2, 1) = cmplx(omega, 0.0_dp, dp)   ! omega |down><up|  (Hermitian conjugate)
  end subroutine build_hamiltonian


  ! ---------------------------------------------------------------------------
  ! schrodinger_rhs
  !
  ! Computes  dpsi = -i H psi.
  ! ---------------------------------------------------------------------------
  pure subroutine schrodinger_rhs(psi, H, dim, dpsi)
    integer,     intent(in)  :: dim
    complex(dp), intent(in)  :: psi(dim)
    complex(dp), intent(in)  :: H(dim, dim)
    complex(dp), intent(out) :: dpsi(dim)

    dpsi = -CI * matmul(H, psi)
  end subroutine schrodinger_rhs


  ! ---------------------------------------------------------------------------
  ! rk4_step
  !
  ! Advances |psi> by one step dt using the classical RK4 scheme:
  !
  !   k1 = f(psi)
  !   k2 = f(psi + dt/2 k1)
  !   k3 = f(psi + dt/2 k2)
  !   k4 = f(psi + dt   k3)
  !   psi <- psi + dt/6 (k1 + 2 k2 + 2 k3 + k4)
  !
  ! psi is updated in-place.
  ! ---------------------------------------------------------------------------
  subroutine rk4_step(psi, H, dim, dt)
    integer,     intent(in)    :: dim
    complex(dp), intent(inout) :: psi(dim)
    complex(dp), intent(in)    :: H(dim, dim)
    real(dp),    intent(in)    :: dt

    complex(dp) :: k1(dim), k2(dim), k3(dim), k4(dim)

    call schrodinger_rhs(psi,                  H, dim, k1)
    call schrodinger_rhs(psi + 0.5_dp*dt*k1,   H, dim, k2)
    call schrodinger_rhs(psi + 0.5_dp*dt*k2,   H, dim, k3)
    call schrodinger_rhs(psi +        dt*k3,   H, dim, k4)

    psi = psi + (dt / 6.0_dp) * (k1 + 2.0_dp*k2 + 2.0_dp*k3 + k4)
  end subroutine rk4_step

end module two_level
