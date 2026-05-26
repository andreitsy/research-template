! ===========================================================================
! Unit test for the two_level RK4 solver.
!
! Integrates  H = omega sigma_x  from |psi(0)> = |up> and checks the result
! against the exact Rabi solution
!
!   P_down(t) = sin^2(omega t),   <sigma_z>(t) = cos(2 omega t),
!
! plus norm conservation.  Prints PASS/FAIL per check and calls `error stop`
! (nonzero exit) if any check fails, so `fpm test` reports failure.
! ===========================================================================
program check
  use two_level
  use, intrinsic :: iso_fortran_env, only: dp => real64
  implicit none

  integer,  parameter :: dim     = 2
  real(dp), parameter :: omega   = 0.7_dp
  real(dp), parameter :: dt      = 1.0e-3_dp
  integer,  parameter :: n_steps = 5000          ! t_end = 5.0
  real(dp), parameter :: tol     = 1.0e-6_dp

  complex(dp) :: H(dim, dim)
  complex(dp) :: psi(dim)
  real(dp)    :: t, p_down, sz, norm
  real(dp)    :: err_pdown, err_sz, err_norm
  real(dp)    :: max_err_pdown, max_err_sz, max_err_norm
  integer     :: step
  logical     :: ok

  call build_hamiltonian(omega, H)

  psi    = (0.0_dp, 0.0_dp)
  psi(1) = (1.0_dp, 0.0_dp)

  max_err_pdown = 0.0_dp
  max_err_sz    = 0.0_dp
  max_err_norm  = 0.0_dp

  t = 0.0_dp
  do step = 0, n_steps
     p_down = real(conjg(psi(2)) * psi(2), dp)
     sz     = real(conjg(psi(1))*psi(1) - conjg(psi(2))*psi(2), dp)
     norm   = real(conjg(psi(1))*psi(1) + conjg(psi(2))*psi(2), dp)

     err_pdown = abs(p_down - sin(omega*t)**2)
     err_sz    = abs(sz     - cos(2.0_dp*omega*t))
     err_norm  = abs(norm   - 1.0_dp)

     max_err_pdown = max(max_err_pdown, err_pdown)
     max_err_sz    = max(max_err_sz,    err_sz)
     max_err_norm  = max(max_err_norm,  err_norm)

     if (step == n_steps) exit
     call rk4_step(psi, H, dim, dt)
     t = t + dt
  end do

  ok = .true.
  call report("P_down(t) vs sin^2(omega t)", max_err_pdown, tol, ok)
  call report("<sigma_z>(t) vs cos(2 omega t)", max_err_sz, tol, ok)
  call report("norm conservation", max_err_norm, tol, ok)

  if (.not. ok) then
     error stop "two_level: one or more checks FAILED"
  end if
  write(*, '(A)') "All checks PASSED."

contains

  subroutine report(label, err, tolerance, ok)
    character(len=*), intent(in)    :: label
    real(dp),         intent(in)    :: err, tolerance
    logical,          intent(inout) :: ok
    character(len=4) :: tag

    if (err <= tolerance) then
       tag = "PASS"
    else
       tag = "FAIL"
       ok  = .false.
    end if
    write(*, '(A,A,A,ES12.4)') "[", tag, "] "//label//"  max_err = ", err
  end subroutine report

end program check
