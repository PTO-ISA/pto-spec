<!-- GENERATED FROM: asl/arch/profile/indexed-memory-lane-choice.asl -->
# Indexed Memory Lane Choice

**Normative ASL source:** `asl/arch/profile/indexed-memory-lane-choice.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/indexed-memory-lane-choice.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE","surface":"arch","classification":["profile","indexed-memory-lane-choice"],"depends_on":["PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE"]}

readonly implementation func SelectIndexedMemoryLanePosition(
    kind: IndexedMemoryLaneChoiceKind,
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS})
    => ModelTileElementIndex
begin
    assert position < lane_count;
    return position;
end;
```
<!-- GENERATED-ASL-END: unit -->
