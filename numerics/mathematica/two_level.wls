#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ===========================================================================
   Symbolic / numeric verification of the two-level template model

     H = omega ( |up><down| + |down><up| ) = omega sigma_x
     |psi(0)> = |up>

   Checks the exact propagator MatrixExp[-i H t] against the closed-form
   Rabi solution and an independent NDSolve integration.

   Basis ordering: index 1 = |up>, index 2 = |down>.

   Run with:  wolframscript -file two_level.wls
   Prints PASS/FAIL per check; exits 1 if any check fails.
   =========================================================================== *)

allOK = True;

report[label_, ok_] := (
  Print[If[ok, "[PASS] ", "[FAIL] "], label];
  If[! ok, allOK = False];
);

(* --- Operators --------------------------------------------------------- *)
omega = Symbol["omega"];
sx = {{0, 1}, {1, 0}};
H  = omega sx;
up   = {1, 0};
down = {0, 1};

(* --- Exact propagator -------------------------------------------------- *)
psit = FullSimplify[MatrixExp[-I H t].up, Assumptions -> omega \[Element] Reals && t \[Element] Reals];

psiExact = {Cos[omega t], -I Sin[omega t]};
report["psi(t) = MatrixExp[-i H t]|up> equals (cos wt, -i sin wt)",
  FullSimplify[psit - psiExact == {0, 0}, Assumptions -> {omega, t} \[Element] Reals]];

(* --- Observables ------------------------------------------------------- *)
pDown = FullSimplify[Abs[psit[[2]]]^2, Assumptions -> {omega, t} \[Element] Reals];
report["P_down(t) = sin^2(omega t)",
  FullSimplify[pDown - Sin[omega t]^2 == 0, Assumptions -> {omega, t} \[Element] Reals]];

sigmaZ = FullSimplify[Abs[psit[[1]]]^2 - Abs[psit[[2]]]^2,
  Assumptions -> {omega, t} \[Element] Reals];
report["<sigma_z>(t) = cos(2 omega t)",
  FullSimplify[sigmaZ - Cos[2 omega t] == 0, Assumptions -> {omega, t} \[Element] Reals]];

report["norm conserved: <psi|psi> = 1",
  FullSimplify[Conjugate[psit].psit - 1 == 0, Assumptions -> {omega, t} \[Element] Reals]];

(* --- Independent numeric (NDSolve) cross-check ------------------------- *)
Module[{w = 0.7, tend = 5.0, c1, c2, sol, num, exact, err},
  sol = NDSolve[
    {I c1'[t] == w c2[t], I c2'[t] == w c1[t], c1[0] == 1, c2[0] == 0},
    {c1, c2}, {t, 0, tend}, MaxStepSize -> 0.001, AccuracyGoal -> 10];
  err = Max@Table[
    num   = Abs[c2[t] /. sol][[1]]^2;
    exact = Sin[w t]^2;
    Abs[num - exact], {t, 0, tend, 0.05}];
  report["NDSolve P_down matches sin^2(omega t) (max_err < 1e-6), err="
    <> ToString[CForm[err]], err < 1.*^-6];
];

(* --- Exit code --------------------------------------------------------- *)
If[allOK,
  Print["All checks PASSED."]; Exit[0],
  Print["One or more checks FAILED."]; Exit[1]
];
