# ADR 0064: B.FPATR Complete-Bundle Matrix PostProcess

- **Status**: accepted
- **Date**: 2026-08-11
- **Deciders**: PTO ISA maintainers
- **Issue**: [#64](https://github.com/PTO-ISA/pto-spec/issues/64)

## Decision

PTO ISA 0.58.0 accepts `B.FPATR` as the single complete-bundle matrix
post-processing attribute command.  It is latched once per CUBE Matrix bundle,
cleared with the bundle descriptor, and included in trap save/recover state.
Missing, duplicate, or non-Matrix use is rejected as `Fault_BundleControl`;
invalid fields, operand streams, aliases, and derived shapes use
`Fault_TileLegality` before allocation or destination effects.

The command form is a 32-bit `L32` encoding with mask `0x00007fff`, match and
canonical None word `0x00002023`.  Its closed `PreQuantMode` table, ReLU and
GroupN fields, reduction enables, and fixed bits are owned by the normative
ASL instruction unit.  Matrix B.DATR rounding/saturation legality is resolved
after the complete bundle is known; the None mode requires RMode=NONE and
Sat=0, while accepted non-None modes retain the full existing selector.

The dynamic B.IOT schema packs mathematical Local sources first, followed by
optional RowMaxIn, vector quantization, and vector PReLU parameters, with up
to eight Local sources and three Local destinations ordered as D, RowMaxOut,
and GroupMaxOut.  B.IOR scalar parameters retain the dense ADR 0055/0058
order, with LReLU-only consuming RegSrc0.  Output commits are one atomic group.

## Consequences

The 0.58.0 command projection is corrected to 100 command forms and 574 total
scalar-plus-command forms.  Existing twelve CUBE operation IDs, selectors,
and mathematical operand aliases remain unchanged.  Exact target numeric
results, FP19 exceptional behavior, and non-saturating overflow remain owned
by the numeric profile variation point rather than this architecture decision.

The normative owners are `asl/block/attributes/B.FPATR.asl`, the complete
bundle state/schema/dispatch/lifecycle units, the trap context and reference
profile owners, and the CUBE execution profile hook.  Catalog, documentation,
traceability, binary-closure, and checked AVS projections are generated from
those owners.
