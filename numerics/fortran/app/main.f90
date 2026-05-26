! ===========================================================================
! Two-level Schrodinger evolution - RK4 driver
!
! System:
!   H = omega ( |up><down| + |down><up| ) = omega sigma_x
!   |psi(0)> = |up>
!
! Exact solution:
!   |psi(t)> = cos(omega t) |up> - i sin(omega t) |down>
!   P_down(t) = sin^2(omega t),   <sigma_z>(t) = cos(2 omega t)
!
! The program integrates the state and writes  t, P_up, P_down, <sigma_z>
! to ./results/two_level.dat.
!
! Basis ordering: index 1 = |up>, index 2 = |down>.
! ===========================================================================
program main
  use two_level
  use, intrinsic :: iso_fortran_env, only: dp => real64
  implicit none

  integer, parameter :: dim = 2

  real(dp), parameter :: omega   = 1.0_dp
  real(dp), parameter :: t_start = 0.0_dp
  real(dp), parameter :: t_end   = 10.0_dp
  integer,  parameter :: n_steps = 10000
  real(dp), parameter :: dt      = (t_end - t_start) / real(n_steps, dp)

  complex(dp) :: H(dim, dim)
  complex(dp) :: psi(dim)
  real(dp)    :: t, p_up, p_down, sz
  integer     :: step, io_unit

  call build_hamiltonian(omega, H)

  ! Initial state |up>
  psi    = (0.0_dp, 0.0_dp)
  psi(1) = (1.0_dp, 0.0_dp)

  open(newunit=io_unit, file="./results/two_level.dat", &
       status="replace", action="write")
  write(io_unit, '(A,F6.3)') "# omega = ", omega
  write(io_unit, '(A)')      "# t              P_up            P_down          <sigma_z>"

  t = t_start
  do step = 0, n_steps
     if (mod(step, 10) == 0) then
        p_up   = real(conjg(psi(1)) * psi(1), dp)
        p_down = real(conjg(psi(2)) * psi(2), dp)
        sz     = p_up - p_down
        write(io_unit, '(4ES16.8)') t, p_up, p_down, sz
     end if

     if (step == n_steps) exit

     call rk4_step(psi, H, dim, dt)
     t = t + dt
  end do

  close(io_unit)

  write(*, '(A,F6.3)') "Done. omega = ", omega
  write(*, '(A,ES14.6)') "Final P_down = ", real(conjg(psi(2))*psi(2), dp)
  write(*, '(A)')        "Output written to ./results/two_level.dat"

end program main
