# ADR 0065: ADDTPC page-relative scaling correction

- Status: accepted
- Date: 2026-08-15
- Requirement: PTO-REQ-SCALAR-CONTROL-001,
  PTO-REQ-SCALAR-EXECUTION-001
- Issue: https://github.com/PTO-ISA/pto-spec/issues/77

## Context

The accepted BRU model separated scalar PC-relative value materialization from
branch and jump target formation, but the ADDTPC wording in ADR-0021 and
ADR-0027 normalized its encoded displacement with the branch/jump halfword
scale. ADDTPC is the page-relative scalar PC materialization operation: its
encoded signed displacement is measured in 4-KiB pages.

## Decision

`ADDTPC` computes `TPC + (SignExtend(imm20) << 12)` and `HL.ADDTPC` computes
`TPC + (SignExtend(imm32) << 12)`. The value is based on pre-increment TPC,
is written through the existing Reg5 destination rules, and wraps modulo
`2^64`. Sequential TPC advancement remains at the scalar dispatch boundary;
ADDTPC does not install a control-flow target.

The existing 20-bit and 32-bit encoded carriers, explicit dispatch
sign-extension, exact encodings, assembly spellings, signedness metadata,
RegDst != R10 constraint, destination aliases, and fault behavior are
unchanged.

This decision supersedes and narrows the ADDTPC and HL.ADDTPC portions of
ADR-0021 and ADR-0027. Their rules for `B.*`, `J`, `JR`, `SETRET`,
`HL.SETRET`, and `C.SETRET` remain in force: those operations retain their
existing halfword scaling and signed/unsigned decode contracts.

## Consequences

Decoded ADDTPC evidence must assert page-scaled destination values, including
signed 20/32-bit boundaries and modulo-`2^64` wrap. BRU totality and generated
comparison evidence must not describe ADDTPC as halfword-scaled. The
independent comparison remains corroborating evidence only; if its pinned
snapshot retains halfword ADDTPC behavior, that row is recorded as an explicit
semantic divergence while PTO ASL remains authoritative.

No new fault, profile hook, default, unspecified case, encoding, or ABI is
introduced.

The clean baseline at `4d115387b8a8a3c135f78189778d38547e75c697` contains 574
encoded forms whose verified catalog projection fingerprint is
`01c90cd710651a44bd2c6a5c21334345d317e0a54fadd2ef182c2477e9e24cf5`. The
binary-closure checker was still bound to the stale `b2281e...` value. ADR 0065
authorizes rebinding that checker to the full verified baseline fingerprint;
catalog forms, masks/matches, fields, constraints, assembly, encoded ABI, and
form count are unchanged.

## Verification

The decoded BRU effect and alias matrices cover normal GPR, discard, push-T,
and push-U destinations, pre-increment TPC and sequential advancement,
signed minimum/maximum values, and modulo-`2^64` wrap. Generator output,
catalogs, instruction pages, traceability, release projections, and the
repository V1 gates must agree with this owner and preserve the existing
encoding counts and fingerprints.
