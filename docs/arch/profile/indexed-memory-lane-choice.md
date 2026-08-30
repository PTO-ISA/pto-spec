<!-- GENERATED FROM: asl/arch/profile/indexed-memory-lane-choice.asl -->
# Indexed Memory Lane Choice

**Normative ASL source:** `asl/arch/profile/indexed-memory-lane-choice.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-purpose role=purpose-scope -->
## Purpose and scope

This page supplies the PTO v0 implementation of the indexed-memory lane-choice hook. It makes the reference model deterministic without turning that ordering into an additional encoded operand or implementation scheduling requirement.

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-concepts role=concepts-state -->
## Ascending logical position

The implementation asserts that the current `position` is below `lane_count` and returns that same position. Repeated callers therefore select the earliest logical position they present to the hook.

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-rules role=rules-interactions -->
## Operation-kind handling

Both `ScatterCommit` and `GatherCASAtomic` use the same position-preserving rule in this profile. The `kind` value remains visible in the interface so a different named profile can define a reviewed choice policy without changing callers.

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-boundaries role=boundaries -->
## Boundaries

The profile does not define lane eligibility, conflict grouping, memory ordering, or transaction commit. Those rules are established before and after the hook by the owning indexed-memory operation. Passing `position >= lane_count` violates the implementation precondition.

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-example role=example-usage -->
## Non-normative choice example

For a caller presenting logical position 3 of 8 eligible positions, the profile returns 3. The caller then applies the operation-specific effect and advances according to its own transaction rules.

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-related role=related-owners-navigation -->
## Related owners

- [Indexed-memory lane-choice types](../data-types/indexed-memory-lane-choice.md) define the hook contract and operation kinds.
- Indexed gather/scatter owners define eligibility and committed memory effects.
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
