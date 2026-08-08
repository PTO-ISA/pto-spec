# ADR 0038: Scalar numeric flag state and producer ownership

## Status

Accepted structural checkpoint; target production rules remain open.

## Context

`PD-06` asks for a complete scalar numeric exception contract. PTO already
exposes five status bits in `CORE_STATE`, and the Stage 4 scalar FSU model routes
profile-returned bits into that state. The target-profile decision package did
not yet distinguish this closed state/lifecycle mechanism from the still-open
conditions under which target arithmetic produces each flag.

The pinned public PTO contract does not define a complete scalar exception-flag
register or producer table. CPU, A2A3, and A5 implementations contain numeric
control and saturation mechanisms but do not provide architecture-visible
sticky flag evidence. They therefore cannot silently define PTO behavior.

A reviewed independent executable ISA model corroborates a five-bit common
state field, the NV/DZ/OF/UF/NX order, sticky accumulation, reset, system-
register replacement, and illegal-type rejection before flag effects. Its
numeric helpers are unbound declarations, and its comparison/minimum/maximum
flag behavior differs from PTO, so it is not a producer oracle.

## Decision

The portable scalar exception-state mechanism is:

1. `CORE_STATE[36:32]` stores NV, DZ, OF, UF, and NX from low to high.
2. Reset clears all five bits.
3. A completed scalar numeric form ORs all produced bits into the old field in
   one update. The bits are independent and have no priority; a numeric form
   cannot clear an old bit.
4. A permitted full `CORE_STATE` system-register write replaces the field and
   may clear bits. This software write is distinct from numeric accumulation.
5. An illegal source type, destination type, encoding, or other rejected form
   faults before a flag update or profile-producer call.
6. Numeric exception outcomes do not themselves raise a synchronous PTO trap.
   Trap entry snapshots `CORE_STATE`; successful recovery restores the
   manager-visible ECSTATE value, including every numeric flag.

Every one of the 30 scalar FSU forms has exactly one producer owner in
`spec/evidence/scalar-numeric-flag-contract.json`:

- `FABS` produces no flags.
- `FMIN`, `FMAX`, and the four quiet comparisons produce NV exactly for a
  signaling NaN input.
- The four signaling comparisons produce NV exactly for any NaN input.
- The other 19 forms obtain an exact five-bit vector from one named numeric-
  profile hook. Each supported operation/type rule must define that vector;
  a missing rule rejects before effects under ADR 0037.

## Consequences

The flag state, lifecycle, trap envelope, and 30/30 producer-owner matrix are
closed. Eleven architecture-owned forms have complete production conditions.
Nineteen profile-owned forms still require exact conditions for NV, DZ, OF, UF,
and NX, including simultaneous production, tininess and NX coupling, special
values, conversion overflow, and rounding.

This decision does not accept `PD-06`, increment the `S5-T2-A2` decision count,
or establish target numeric conformance. `PD-06` remains open until all 19
profile-owned rows have accepted operation/type rules and independent vectors.
The repository maturity therefore remains M4 and `S5-T2` remains open.

## Evidence

- `spec/evidence/scalar-numeric-flag-contract.json`
- `scripts/generate-scalar-numeric-flag-contract`
- `asl/scalar/floating.asl`
- `asl/scalar/dispatch.asl`
- `asl/profiles/pto-v0.asl`
- `tests/asl/scalar-tests.asl`
- `docs/status/decisions/0028-scalar-fsu-totality-and-profile-boundary.md`
- `spec/evidence/numeric-profile-decision-proposals.json`
