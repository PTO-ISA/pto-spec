<!-- GENERATED FROM: asl/arch/data-types/trap-context.asl -->
# Trap Context

**Normative ASL source:** `asl/arch/data-types/trap-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-TRAP-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-trap-context-type-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the complete typed `TrapContext` snapshot used to preserve recoverable execution state across trap handling.

The record shape is centralized so capture and restore owners operate on the same state bundle.

<!-- PTO-READER-BLOCK: arch-trap-context-type-concepts-state role=concepts-state -->
## Concepts and visible state

- The snapshot begins with validity, source `AccessControlRing`, `tpc`, `bpc`, core state, bundle and commit arguments, and bundle-active flags.
- It carries bundle descriptors, dimensions, scalar/tile/shared bindings, range-group state, control/data/fixed-point/hint attributes, and local/shared generation snapshots.
- It also preserves memory-copy and frame templates, temporary `T`/`U` queues with validity snapshots, predicate state, return targets, and the bundle execution-domain token.

<!-- PTO-READER-BLOCK: arch-trap-context-type-rules-interactions role=rules-interactions -->
## Rules and interactions

`valid` states whether the record contains a restorable context; the record type itself does not perform capture or restore.

Presence flags remain explicit for condition, commit target, data attributes, and bundle dimensions rather than being inferred from payload contents.

Queue values and queue-validity arrays are separate fields, preserving readiness independently from stored words.

<!-- PTO-READER-BLOCK: arch-trap-context-type-boundaries role=boundaries -->
## Architectural boundaries

This type declaration does not define trap routing, cause values, capture timing, or restore legality. Those behaviors remain in trap-state and recovery owners.

The record must not be read as permission for nested bundle execution; it snapshots the existing one-level architecture state.

<!-- PTO-READER-BLOCK: arch-trap-context-type-example-usage role=example-usage -->
## Non-normative reading example

A saved context can retain `bundle_data_attributes_present = FALSE` while still carrying the typed data-attribute field; restore logic uses the explicit presence bit.

To understand what is captured on a fault, combine this record layout with the current trap capture/restore ASL; the record alone does not specify the transition.

<!-- PTO-READER-BLOCK: arch-trap-context-type-related-owners role=related-owners-navigation -->
## Related owners

- [Trap-context state](../state/trap-context.md)
- [Trap recovery profile](../profile/trap-context-recovery.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/trap-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-TRAP-CONTEXT","surface":"arch","classification":["data-types","trap-context"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
type TrapContext of record {
    valid: boolean,
    source_acr: AccessControlRing,
    tpc: Word,
    bpc: Word,
    core_state: Word,
    bundle_argument: Word,
    commit_argument: Word,
    bundle_active: boolean,
    bundle_body_active: boolean,
    bundle_commit_target_set: boolean,
    bundle_condition_set: boolean,
    system_block_terminal_pending: boolean,
    barg: BundleArgumentRegister,
    bundle_sequential_pc: Word,
    frame_stack_return_target: Word,
    return_address: Word,
    bundle_argument_kind: bits(3),
    bundle_operation: BundleOperationDescriptor,
    bundle_dimensions: BundleDimensionSnapshot,
    bundle_dimension_present: BundleDimensionPresenceSnapshot,
    bundle_scalar_bindings: BundleScalarBindingSnapshot,
    bundle_tile_bindings: BundleTileBindingSnapshot,
    bundle_shared_bindings: BundleSharedBindingSnapshot,
    bundle_range_group: BundleRangeGroupState,
    bundle_zero_participation_seen: boolean,
    bundle_control_attributes: BundleControlAttributes,
    bundle_data_attributes: BundleDataAttributes,
    bundle_data_attributes_present: boolean,
    bundle_hint: BundleHintAttributes,
    bundle_fixed_point_attributes: BundleFixedPointAttributes,
    local_generations: LocalGenerationSnapshot,
    shared_generations: SharedGenerationSnapshot,
    bundle_execution_domain_token: integer,
    memory_copy_template: MemoryCopyTemplateState,
    frame_template: FrameTemplateState,
    t_queue: TemporaryQueueSnapshot,
    t_queue_valid: TemporaryQueueValiditySnapshot,
    u_queue: TemporaryQueueSnapshot,
    u_queue_valid: TemporaryQueueValiditySnapshot,
    predicates: PredicateSnapshot
};
```
<!-- GENERATED-ASL-END: unit -->
