# ADR 0040: Numeric format namespace ownership

## Status

Accepted structural checkpoint; bit-exact formats, target availability, and
operation/type legality remain open.

## Context

`PD-02` requires a complete bit-level format table and an operation/type/profile
legality matrix before target numeric conformance can close. PTO currently has
five distinct numeric type-code namespaces:

- two-bit scalar FSU source selectors;
- five-bit scalar floating destination selectors;
- five-bit scalar integer destination selectors;
- six-bit TMA/TALLOC tile data-type selectors; and
- five-bit bundle `DataType` selectors.

Some numeric codes coincide across namespaces and others differ. For example,
TMA/TALLOC code 2 denotes the raw `F16` carrier while bundle code 4 denotes
`F16`; `FP4` is mapped only in the TMA/TALLOC namespace, while `E8M0` is mapped
only in the bundle namespace. Treating the integers as one shared encoding
would therefore change architectural behavior.

The public PTO type system establishes visible names, widths, and target
availability observations but does not resolve every PTO ASL binding. In
particular, the exact `FP8`, `FPL8`, `FP4`, `FPL4`, and `E8M0` roles remain
ambiguous or profile-dependent. The reviewed independent executable model
corroborates the scalar raw-carrier table and bundle field width, but it does
not supply tile numeric format semantics or an independent numeric oracle.

## Decision

The generated
`spec/evidence/numeric-format-namespace-contract.json` is the fail-closed
structural checkpoint for `PD-02`.

1. Numeric codes are namespace-local. Equality of code values across scalar,
   TMA/TALLOC, and bundle namespaces has no architectural meaning unless a
   later accepted PTO decision explicitly maps them.
2. All 19 `TileDataType` identities and their raw storage widths are closed.
   Width and signedness are exact for integer carriers. Floating identities
   remain raw carrier names until their bit-exact format rules are accepted.
3. Scalar source selectors 0 and 1 select 64-bit and 32-bit raw carriers;
   selectors 2 and 3 reject before effects. Scalar floating and integer
   destination selectors 0 through 14 have the Stage 4 carrier widths recorded
   in `scalar-fsu-totality.json`; selectors 15 through 31 reject before effects.
4. The TMA/TALLOC namespace contains 18 mapped and 46 reserved six-bit codes.
   `E8M0` is intentionally unmapped there. The bundle namespace contains 18
   mapped and 14 reserved five-bit codes. `FP4` is intentionally unmapped
   there. These are separate, total encoding tables rather than a conflict to
   hide with aliases.
5. `FP4`, `FPL4`, `S4`, and `U4` use the closed packed-memory rule: the even or
   low-index element occupies bits `[3:0]`, the odd or high-index element
   occupies bits `[7:4]`, loads zero-extend the selected nibble, and stores
   preserve the sibling nibble.
6. Unmapped codes reject before architectural effects. A helper fallback after
   a failed legality predicate is unreachable and does not create an
   architectural alias.

## Consequences

Reviewers can now distinguish every structural numeric namespace, carrier
width, mapped code, reserved code, and packed-four-bit rule without inferring
target arithmetic from a backend. The generated artifact and repository
checker fail on namespace, width, mapping, source-hash, or residual drift.

`PD-02` remains open. Closure still requires bit-exact floating layouts,
accepted bindings for specialized eight- and four-bit types, the architectural
role of `E8M0`, the complete scalar/tile operation/type/profile legality
matrix, target availability, and positive/reserved vectors for every accepted
tuple. This checkpoint does not increment the `S5-T2-A2` accepted-decision
count or promote maturity beyond M4.

## Evidence

- `spec/evidence/numeric-format-namespace-contract.json`
- `scripts/generate-numeric-format-namespace-contract`
- `spec/evidence/scalar-fsu-totality.json`
- `spec/evidence/tma-totality.json`
- `asl/types.asl`
- `asl/scalar/floating.asl`
- `asl/tile/state.asl`
- `asl/tile/memory.asl`
- `asl/bundle/dispatch.asl`
- `tests/asl/state-tests.asl`
- `tests/asl/scalar-tests.asl`
- `tests/asl/bundle-tests.asl`
- `tests/asl/tma-totality-tests.asl`
- `docs/architecture-decisions/0028-scalar-fsu-totality-and-profile-boundary.md`
- `docs/architecture-decisions/0033-tma-four-bit-memory-packing.md`
- `docs/architecture-decisions/0037-numeric-profile-identity-and-variation-framework.md`
