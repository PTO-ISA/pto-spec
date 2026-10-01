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

`TrapContext` is a single record with 41 fields that names every value a trap capture writes and a trap restore reads.

This page owns the record shape only. The unit declares no function, so it neither captures nor restores a context.

Design point: the record is declared once, and the capture side and the restore side both use its field names. Adding a field therefore changes the shape seen by both sides at the same moment, and neither side can keep a private copy of state that the other side does not save.

<!-- PTO-READER-BLOCK: arch-trap-context-type-concepts-state role=concepts-state -->
## Concepts and visible state

- The leading fields are `valid`, `source_acr`, `tpc`, `bpc`, `core_state`, `bundle_argument` and `commit_argument`, followed by the bundle flags `bundle_active`, `bundle_body_active`, `bundle_commit_target_set`, `bundle_condition_set` and `system_block_terminal_pending`.
- The middle fields carry `barg`, the bundle sequencing values and the typed bundle snapshot records, among them `bundle_dimensions`, `bundle_scalar_bindings`, `bundle_data_attributes` and `bundle_data_attributes_present`.
- The trailing fields carry `local_generations`, `shared_generations`, `bundle_execution_domain_token`, `memory_copy_template`, `frame_template`, `memory_replay_state`, `t_queue`, `t_queue_valid`, `u_queue`, `u_queue_valid`, and `predicates`.

Design point: `t_queue` and `t_queue_valid`, and `u_queue` and `u_queue_valid`, are four separate fields rather than one array with an embedded validity bit. Because the captured words and the captured readiness are stored apart, a restore can put the queue words back and still mark a slot as not ready; readiness is saved state and is never derived from the stored word.

<!-- PTO-READER-BLOCK: arch-trap-context-type-rules-interactions role=rules-interactions -->
## Rules and interactions

`valid` is a field of the record and the only flag that says whether the record holds a restorable context. A capture sets it, and a successful portable restore clears it again.

The presence questions are answered by booleans saved beside the values they qualify, not by the payload contents: `bundle_commit_target_set`, `bundle_condition_set`, `bundle_dimension_present`, and `bundle_data_attributes_present` each have their own field.

The address-valued fields, among them `tpc`, `bpc`, `core_state`, `bundle_argument` and `return_address`, are all declared `Word`, so a saved address keeps the full architectural width.

Design point: because the capture copies the typed `bundle_data_attributes` record and the separate `bundle_data_attributes_present` flag side by side, a saved context can hold `bundle_data_attributes_present = FALSE` while the payload record still carries its captured field values. A restore that reads the payload without testing the flag can apply attributes that were never in effect.

<!-- PTO-READER-BLOCK: arch-trap-context-type-boundaries role=boundaries -->
## Architectural boundaries

This declaration defines no trap routing, no cause value, no capture timing, and no restore legality. Those belong to the trap-state owner and to the memory-model owners that call the capture path.

The record describes one level of architectural state. It is not permission to start a nested bundle, because the values it saves are the state objects that already exist in the one-level architecture.

Design point: `PortableTrapContextRecoverable` requires more than `valid`; it also requires `bpc[0]` and `tpc[0]` to be zero, so a record can be marked valid and still be refused by the portable recovery path. `valid` therefore means that a context was written, not that the context can be used.

The field types themselves are owned outside this unit. The bundle snapshots and templates come from the block state types, `MemoryReplayState` comes from the memory-model data types, and `Word` comes from the integer data types. Line 1 lists one dependency, so the remaining owners appear only in the field declarations.

<!-- PTO-READER-BLOCK: arch-trap-context-type-example-usage role=example-usage -->
## Non-normative reading example

A saved context can hold `bundle_data_attributes_present = FALSE` while the typed `bundle_data_attributes` record is still present with its captured field values, because the capture copies `_BundleDataAttributes` and `_BundleDataAttributesPresent` next to each other. Restore logic must read the boolean.

`RecoverPortableTrapContext` clears `valid` after it has written the saved fields back. To see the whole transition, read this record together with the trap-state ASL that performs the capture and the restore; the record alone does not specify either.

<!-- PTO-READER-BLOCK: arch-trap-context-type-related-owners role=related-owners-navigation -->
## Related owners

- [Trap-context state](../state/trap-context.md)
- [Execution context](../programming-model/execution-context.md)
- [Memory-model data types](memory-model.md)
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
    memory_replay_state: MemoryReplayState,
    t_queue: TemporaryQueueSnapshot,
    t_queue_valid: TemporaryQueueValiditySnapshot,
    u_queue: TemporaryQueueSnapshot,
    u_queue_valid: TemporaryQueueValiditySnapshot,
    predicates: PredicateSnapshot
};
```
<!-- GENERATED-ASL-END: unit -->
