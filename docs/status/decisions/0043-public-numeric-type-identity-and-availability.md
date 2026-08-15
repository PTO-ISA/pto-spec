# ADR 0043: Public numeric type identity and target availability

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Status

Accepted structural checkpoint; bit-exact specialized formats, operation/type
legality, and numeric result rules remain open.

## Context

The first `PD-02` checkpoint separated five encoded type namespaces and fixed
their raw-carrier widths, but it deliberately did not bind those catalog names
to the public PTO type system. Without a checked binding, a familiar spelling
such as `FP8`, `FPL8`, or `F64` could be mistaken for a published numeric type,
and a backend-supported C++ carrier could silently become architecture.

PTO names 16 public element-type identities and defines an A2/A3 and A5
availability baseline. A target profile may narrow support but cannot redefine
portable PTO semantics. Simulator behavior is not a target-profile or
numeric-result definition.

## Decision

The generated `spec/evidence/public-numeric-type-baseline.json` ledger is the
fail-closed `PD-02-SC2` binding and availability checkpoint.

1. The public identities are three base floating types, five A5-only
   specialized floating types, and eight signed or unsigned integer types.
2. All 16 public types bind to PTO catalog identities. The three base floating
   types bind to `FP16`, `BF16`, and `FP32`; the five A5-only specialized
   floating types bind to `E4M3`, `E5M2`, `HiF8`, `E1M2X2`, and `E2M1X2`; and
   the eight integer types bind to `S8`, `U8`, `S16`, `U16`, `S32`, `U32`,
   `S64`, and `U64`.
3. A2/A3 supports those 11 base identities. A5 supports all 16 published
   identities. These are type-support facts only; they do not make every
   operation/type tuple legal and do not select a numeric result.
4. Nine catalog types remain outside the public inventory: `FP64`, `TF32`,
   `HF32`, `E3M2`, `E2M3`, `E8M0`, `HiF4X2`, `S4X2`, and `U4X2`. Their PTO
   architectural identity is unchanged, and none gains a public alias by
   implication.
5. Public type names and widths do not define NaN payloads, signaling behavior,
   subnormal handling, rounding, flags, saturation, conversion overflow,
   accumulation, or any other result rule. Those decisions remain open.

## Consequences

`S5-T2-A5` closes public type discovery, all 16 accepted catalog bindings,
and the published A2/A3-versus-A5 type availability baseline. It does not
accept `PD-02`, populate a domain result rule, select a variation-point route,
or change the M4 maturity floor.

The remaining `PD-02` work is finite and explicit: complete every scalar and
tile operation/type/profile legality tuple, publish independent numeric result
and exception vectors, record downstream byte-and-effect parity for the
immutable hardware profile, and accept architecture and formal-model review
against the exact 0.57.1 type contract.
These four legality, vector, parity, and review residuals remain open.

## Evidence

- `spec/evidence/public-numeric-type-baseline.json`
- `scripts/generate-public-numeric-type-baseline`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/executable-model-comparison.json`
- `scripts/check-catalogs`
