<!-- GENERATED FROM: asl/arch/data-types/trap-context.asl -->
# Trap Context

**Normative ASL source:** `asl/arch/data-types/trap-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-TRAP-CONTEXT}

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
    bundle_zero_participation_seen: boolean,
    bundle_control_attributes: BundleControlAttributes,
    bundle_data_attributes: BundleDataAttributes,
    bundle_data_attributes_present: boolean,
    bundle_hint: BundleHintAttributes,
    bundle_fixed_point_attributes: BundleFixedPointAttributes,
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
