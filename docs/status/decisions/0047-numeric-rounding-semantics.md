# ADR 0047: Numeric rounding semantics

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Status

Accepted. This decision completes PD-03 and supersedes the result-open parts of
ADR 0039. ADR 0049 separately closes PD-04 for the named hardware profile;
PD-02 and PD-05 through PD-12 remain outside this decision.

## Context

ADR 0039 separated the scalar active-rounding field, fixed scalar conversion
mnemonics, bundle `RMode`, public conversion controls, target controls, and
backend-only controls. It deliberately left their meanings and every
operation-domain rounding point open.

The remaining evidence contains two traps for an implementation:

- the scalar and bundle selectors are both three bits wide but do not share an
  encoding namespace; and
- `FCVTA` means nearest with ties away from zero, not directed rounding away
  from zero for every inexact value.

The published scalar contract and an independently reviewed executable ISA
model agree on the scalar field location, the four assigned directional codes,
and an RNE fallback for reserved values. The independent model is corroborating
evidence only; PTO semantics remain defined by this decision and the normative
ASL.

## Decision

### Semantic modes

The ASL type `NumericRoundingMode` is the common semantic vocabulary:

| Name | Rule |
| --- | --- |
| RNE | nearest, ties to even |
| RTM | toward negative infinity |
| RTP | toward positive infinity |
| RTZ | toward zero |
| RNA | nearest, ties away from zero |
| RTO | if inexact, select the adjacent result whose least-significant retained integer bit is one |
| RHB | nearest; on an exact halfway case select the numerically greater candidate |

Encoded selector namespaces must translate explicitly to this type. Equal bit
widths or ordinals never imply equal meanings.

### Scalar active rounding

`CORE_STATE[39:37]` has four assigned active-rounding encodings:

| Raw value | Resolution |
| --- | --- |
| `000` | RNE |
| `001` | RTM |
| `010` | RTP |
| `011` | RTZ |
| `100`–`111` | reserved; resolve to RNE |

The reserved fallback is deterministic and has no trap or other architectural
effect. It does not import meanings from bundle `RMode`.

Scalar floating binary, unary, format-conversion, and integer-to-floating
operations use the resolved active mode when encoding their destination.
Fused multiply-add variants evaluate the exact fused expression and round once
at the destination boundary.

### Fixed scalar conversions

The conversion mnemonic, not `CORE_STATE.FRM`, selects the mode:

| Mnemonic | Mode |
| --- | --- |
| `FCVTA` | RNA |
| `FCVTM` | RTM |
| `FCVTN` | RNE |
| `FCVTP` | RTP |
| `FCVTZ` | RTZ |

The finite source is rounded once before PD-07 selects an out-of-range,
indefinite, or saturation result. This decision fixes the order but leaves
those PD-07 results open.

### Bundle and public conversion selectors

`B.DATR.RMode` has the following complete mapping:

| Raw value | Bundle name | Semantic mode |
| --- | --- | --- |
| `000` | NONE | operation-defined default |
| `001` | RNE | RNE |
| `010` | RTZ | RTZ |
| `011` | RDN | RTM |
| `100` | RUP | RTP |
| `101` | RNA | RNA |
| `110` | RTO | RTO |
| `111` | RHB | RHB |

The public conversion enumeration is a separate namespace and translates as
follows:

| Public value | Public name | Bundle selection |
| --- | --- | --- |
| 0 | `CAST_NONE` | NONE |
| 1 | `CAST_RINT` | RNE |
| 2 | `CAST_ROUND` | RNA |
| 3 | `CAST_FLOOR` | RDN |
| 4 | `CAST_CEIL` | RUP |
| 5 | `CAST_TRUNC` | RTZ |
| 6 | `CAST_ODD` | RTO |

Public value 7 is unassigned and rejects before effects. There is no public
RHB ordinal in this version. Backend tokens with similar names remain
non-normative unless another accepted profile decision maps them.

Only `ACCCVT`, `TCVT`, `TQUANT`, and `TDEQUANT` consume
`TileNumericSelection`. NONE resolves to RNE except that floating-to-integer
`TCVT` resolves NONE to RTZ. An explicit bundle code always overrides that
default. These operations round at the destination-format boundary before
saturation. Saturation-disabled range results remain PD-07 decisions.

### Operation-fixed domains

All other tile operations ignore bundle `RMode` and use operation-fixed rules:

- floating elementwise, expansion, partial, and PReLU results use RNE at each
  operation-defined destination boundary; exact integer, bitwise, comparison,
  minimum, maximum, broadcast, and selection results do not round;
- reductions visit elements in increasing logical row-major order and round
  every floating sum or product step to the declared accumulator type using
  RNE; minimum, maximum, and argument selection do not round; and
- matrix operations visit K in increasing logical order, perform one
  RNE-rounded fused multiply-add into the declared accumulator per term, and
  apply any post-dot bias with RNE. `ACCCVT` owns the later accumulator
  conversion.

The generated domain ledger records the rule and saturation ordering for all
18 PD-03 domains and 102 affected operations.

## Rejected alternatives

- Treating scalar raw values 4 through 7 as the bundle modes was rejected
  because it conflates distinct architectural namespaces.
- Rejecting reserved scalar values before effects was rejected because the
  published scalar behavior and independent executable comparison both use a
  deterministic RNE fallback.
- Defining `FCVTA` as directed away from zero was rejected because it changes
  non-halfway values and conflicts with the mnemonic's ties-away contract.
- Passing public enumeration ordinals directly into `B.DATR.RMode` was rejected
  because `CAST_ROUND`, `CAST_FLOOR`, `CAST_CEIL`, and `CAST_TRUNC` have
  different ordinals from their bundle encodings.

## Consequences

PD-03 is complete for selector encodings, tie rules, operation defaults,
rounding points, and rounding-before-saturation order. The ASL carries semantic
rounding values rather than ambiguous raw codes across profile hooks.

This decision does not claim complete numeric results. Format encodings and
legality, special values, flags, overflow and indefinite results,
approximation error, reduction tie behavior, quantization equations, matrix
precision beyond the stated rounding points, and bounded target variation
remain owned by PD-02 and PD-05 through PD-12. ADR 0049 separately owns PD-04
subnormal handling for the named hardware profile. Stage 5 therefore remains
in progress.

## Evidence

- `asl/types.asl`
- `asl/scalar/floating.asl`
- `asl/scalar/dispatch.asl`
- `asl/bundle/dispatch.asl`
- `asl/tile/conversion.asl`
- `asl/tile/cube.asl`
- `spec/catalog/tile-operations.json`
- `spec/hardware-conformance-profile.json`
- `spec/evidence/numeric-rounding-selector-contract.json`
- `scripts/generate-numeric-rounding-selector-contract`
- `tests/asl/profile-tests.asl`
- `tests/asl/scalar-tests.asl`
- `tests/asl/bundle-tests.asl`
- `tests/asl/tile-tests.asl`
