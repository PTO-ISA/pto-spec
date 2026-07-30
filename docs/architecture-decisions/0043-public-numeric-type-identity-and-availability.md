# ADR 0043: Public numeric type identity and target availability

## Status

Accepted structural checkpoint; bit-exact specialized formats, operation/type
legality, and numeric result rules remain open.

## Context

The first `PD-02` checkpoint separated five encoded type namespaces and fixed
their raw-carrier widths, but it deliberately did not bind those catalog names
to the public PTO type system. Without a checked binding, a familiar spelling
such as `FP8`, `FPL8`, or `F64` could be mistaken for a published numeric type,
and a backend-supported C++ carrier could silently become architecture.

The public PTO type table at the pinned source revision names 16 element-type
identities. It also gives an A2/A3 and A5 availability baseline. The public
profile contract permits a target profile to narrow support, but not to
redefine portable PTO semantics. The CPU simulator is implementation evidence;
it is not a target-profile or numeric-result oracle.

## Decision

The generated `spec/evidence/public-numeric-type-baseline.json` ledger is the
fail-closed `PD-02-SC2` binding and availability checkpoint.

1. The public identities are three base floating types, five A5-only
   specialized floating types, and eight signed or unsigned integer types.
2. The base public types bind to the unambiguous PTO catalog identities:
   `F16`, `BF16`, `F32`, `S8`, `U8`, `S16`, `U16`, `S32`, `U32`, `S64`, and
   `U64`.
3. A2/A3 supports those 11 base identities. A5 supports all 16 published
   identities. These are type-support facts only; they do not make every
   operation/type tuple legal and do not select a numeric result.
4. `FP8`, `FPL8`, `FP4`, and `FPL4` remain unbound because the public names do
   not establish a unique mapping to the catalog names. The published E5M2
   versus `float8_e5m3fn` spelling conflict also remains explicit.
5. `F64` and `E8M0` remain PTO raw-carrier identities without a public
   element-type binding at the pinned revision. They are not aliases for a
   public type by implication.
6. Public type names and widths do not define NaN payloads, signaling behavior,
   subnormal handling, rounding, flags, saturation, conversion overflow,
   accumulation, or any other result rule. Those decisions remain open.

## Consequences

`S5-T2-A5` closes public type discovery, the 11 unambiguous catalog bindings,
and the published A2/A3-versus-A5 type availability baseline. It does not
accept `PD-02`, populate a domain result rule, select a variation-point route,
or change the M4 maturity floor.

The remaining `PD-02` work is finite and explicit: bind the specialized
catalog identities, decide the public role of `F64` and `E8M0`, resolve the
E5M2/E5M3FN conflict, define bit-exact payload and exceptional-value formats,
complete the operation/type/profile legality matrix, and publish target
availability vectors.

The pinned Linx Sail model is only structural evidence here. Its scalar type
fields corroborate carrier namespaces, while its tile numeric selectors do not
execute payload arithmetic and use code spaces that conflict with PTO catalog
names. It therefore supplies neither these public bindings nor a result oracle.

## Evidence

- `spec/evidence/public-numeric-type-baseline.json`
- `scripts/generate-public-numeric-type-baseline`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/executable-model-comparison.json`
- `scripts/check-catalogs`
