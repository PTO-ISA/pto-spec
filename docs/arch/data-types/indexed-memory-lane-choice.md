<!-- GENERATED FROM: asl/arch/data-types/indexed-memory-lane-choice.asl -->
# Indexed Memory Lane Choice

**Normative ASL source:** `asl/arch/data-types/indexed-memory-lane-choice.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-indexed-choice-types-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the profile hook used when several indexed-memory lanes are eligible at the same logical position. It distinguishes scatter commit from gather-CAS atomic choice without assigning an implementation scheduling policy.

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-concepts role=concepts-state -->
## Choice inputs

`IndexedMemoryLaneChoiceKind` identifies the operation class. `position` is the current logical position, `lane_count` is the nonzero bounded lane population, and the returned `ModelTileElementIndex` names the selected lane position.

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-rules role=rules-interactions -->
## Legality predicate and hook

`IndexedMemoryLanePositionLegal` accepts a selection at or after the current position and strictly below `lane_count`. `SelectIndexedMemoryLanePosition` is an implementation-defined hook; its declaration supplies the current position as the reference fallback.

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-boundaries role=boundaries -->
## Boundaries

This type unit does not reorder memory effects, define conflict detection, or choose between operation kinds. Callers remain responsible for passing a valid current position and for applying the selected lane through the owning indexed-memory transaction.

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-example role=example-usage -->
## Non-normative reading example

With `position=2` and `lane_count=5`, the legality helper admits positions 2, 3, and 4. The concrete PTO v0 profile chooses 2, but that deterministic profile rule is owned by the profile implementation page.

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-related role=related-owners-navigation -->
## Related owners

- [Indexed-memory lane-choice profile](../profile/indexed-memory-lane-choice.md) supplies the PTO v0 implementation.
- Indexed gather/scatter operation owners define the memory effects that consume the choice.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/indexed-memory-lane-choice.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE","surface":"arch","classification":["data-types","indexed-memory-lane-choice"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}

type IndexedMemoryLaneChoiceKind of enumeration {
    IndexedMemoryLaneChoice_ScatterCommit,
    IndexedMemoryLaneChoice_GatherCASAtomic
};

readonly func IndexedMemoryLanePositionLegal(
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS},
    selected: ModelTileElementIndex) => boolean
begin
    return selected >= position && selected < lane_count;
end;

readonly impdef func SelectIndexedMemoryLanePosition(
    kind: IndexedMemoryLaneChoiceKind,
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS})
    => ModelTileElementIndex
begin
    return position;
end;
```
<!-- GENERATED-ASL-END: unit -->
