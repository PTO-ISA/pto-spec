# ADR 0024: PC-relative and unscaled AGU addressing

- Status: accepted
- Scope: scalar AGU PC-relative and register-offset writeback forms

## Decision

Scalar PC-relative load and store forms align the current TPC down to a
four-byte boundary before adding their signed, four-byte-scaled displacement.
This rule matters when a 32-bit or 48-bit PC-relative form begins at a
halfword-aligned address whose bit 1 is set.

The six register-offset store-writeback forms `HL.SH.UPR`, `HL.SH.UPO`,
`HL.SW.UPR`, `HL.SW.UPO`, `HL.SD.UPR`, and `HL.SD.UPO` are genuinely
unscaled. Their modified register offset is added directly; it is not scaled by
the access width. Pre-index forms access the updated address and post-index
forms access the original base before publishing the same updated address.

## Rationale

Four-byte alignment gives PC-relative displacement encoding a stable base even
when variable-length scalar instructions place the current TPC on the other
halfword of a word. The `.U` marker on the six writeback stores distinguishes
them from their scaled register-offset counterparts and must remain observable
with a nonzero offset.

## Verification

Decoded PC-relative witnesses use a TPC with bit 1 set and assert an address
derived from the aligned base. Decoded witnesses for all six `.UPR/.UPO` forms
use nonzero offsets that distinguish unscaled from access-width-scaled
addresses and check both memory and writeback state.
