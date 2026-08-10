# ADR 0058: Complete-Bundle GPR Operand Resolution

- **Status**: accepted
- **Date**: 2026-08-10
- **Deciders**: PTO ISA maintainers
- **Issue**: [#60](https://github.com/PTO-ISA/pto-spec/issues/60)

## Context

ADR 0055 established complete-bundle `B.IOR` omission and encoded-zero
semantics, but its consumer description did not close the operation controls
advertised by `TCI`, `TTRI`, `TSORT`, and `TMRGSORT`. The bridge therefore left
`flag0` and `diagonal` at their operation defaults even when a complete bundle
encoded those inputs, and field-name membership could report an operation as
representable without proving a resolver.

## Decision

The complete-bundle bridge packs consumed B.IOR GPR inputs in this fixed
logical order: `address`, `scalar0`, `scalar1`, `diagonal`, `flag0`. Fields not
present in the selected operation are removed before packing into `RegSrc0`
through `RegSrc2`. The affected mappings are:

| Operation | `RegSrc0` | `RegSrc1` |
| --- | --- | --- |
| TCI | `start` | `descending` |
| TTRI | `diagonal` | `upper` |
| TSORT | `descending` | — |
| TMRGSORT | `descending` | — |

`start` is an XLEN Word. `diagonal` is decoded as an XLEN two-complement
signed value and is legal only in `-65535..65535`. `descending` and `upper`
accept exactly raw zero or one. Other raw boolean values and out-of-range
diagonals fault with `Fault_TileLegality` before destination resolution or any
Tile effect. The operation defaults remain TCI `(0,FALSE)`, TTRI `(0,FALSE)`,
and FALSE for both sorting operations.

The bridge is fail-closed: every accepted operand must have a concrete
resolver or explicit default and a raw-value decode policy. Nonzero surplus
B.IOR fields and `RegDst` reject; an encoded zero remains a real zero selector;
a second B.IOR faults without replacing the first. `PE_MASK=0000` exits before
all GPR reads, validation, allocation, faults, and Tile updates.

The representability gate derives and records the concrete dense slot for each
GPR field. It rejects duplicate operand fields, duplicate assigned slots, and
any accepted operation requiring more than three GPR inputs; it never reports
such an operation as representable. Independent evidence executes the decoded
bundle through `BSTART`, `B.IOR`, `B.IOT`, and `BSTOP` so fault identity,
destination preservation, zero-mask suppression, and observable operation
results are covered at the architectural commit boundary.

TSORT and TMRGSORT retain their v0.58 direct-binary ordering contracts:
TSORT ties remain stable, TMRGSORT ties select the left source first, and both
require sources pre-sorted in the selected direction without adding payload
sortedness validation.

## Consequences

The ASL bundle schema resolves and validates raw controls before constructing
constrained `TileInstructionOperands` or allocating destinations. Catalog,
Markdown, independent AVS, totality evidence, and release traceability remain
projected from the existing four-surface owners; operation count, selectors,
and the reviewed binary ABI are unchanged.

ADR 0055 remains authoritative for B.IOR presence, encoded-zero rendering,
field encoding, and omission defaults except for this narrow consumer-resolution
refinement.
