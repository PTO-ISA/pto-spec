# ADR 0019: Define the PTO predicate-register contract

## Status

Accepted.

## Context

PTO exposes eight 64-bit predicate registers, P0 through P7. The existing model
stored all eight but only read P0 for bundle-body `B.Z` and `B.NZ`. It did not
define a producer, the status of P1 through P7, or preservation across trap
entry and recovery. That made seven registers accidental state and allowed
recovery to lose visible predicate values.

The comparison ISA uses one kernel EXEC mask produced by vector comparison.
PTO deliberately has no vector instruction execution surface, so importing
that producer or inventing seven selector encodings would violate the PTO
architecture boundary.

## Decision

- P0 through P7 are independent 64-bit architectural registers and reset to
  zero.
- Entering a PTO bundle body initializes P0 to all ones, meaning every EXEC bit
  is active. A conditional bundle that is not entered does not modify P0.
- Inside an active bundle body, `B.Z` and `B.NZ` consume P0 only. Outside a
  bundle body they consume the existing bundle-control predicate and do not
  read any predicate register.
- P1 through P7 are reserved visible state in PTO v0. No accepted instruction
  encoding selects, produces, or consumes them. Their values do not affect
  control flow, tile legality, memory access, or numeric results.
- A trap snapshot saves all eight predicate registers. Successful recovery
  restores all eight before execution resumes. Failed recovery leaves the live
  predicate registers unchanged apart from the trap-entry state already
  defined by the fault envelope.
- A future instruction or profile that uses P1 through P7 must add an explicit
  selector/producer contract, reserved-code analysis, effects, aliases, and
  executable evidence; it cannot reinterpret the existing storage silently.

## Consequences

P0 now has a defined producer, consumer, reset, and preservation contract.
P1 through P7 have explicit reserved behavior rather than implied semantics.
Tests cover lowest/highest indices, body entry, P0-only consumption, reset, and
trap recovery.
