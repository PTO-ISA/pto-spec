<!-- GENERATED FROM: asl/block/model/state/descriptor-state.asl -->
# Descriptor State

**Normative ASL source:** `asl/block/model/state/descriptor-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-purpose role=purpose-scope -->
## Purpose and scope

This unit defines two transitions: installing the operation descriptor of a new bundle, and clearing the per-bundle header state.

The operation descriptor records the exact `BSTART` form and its operation fields. The header state is everything that header commands accumulate for one bundle.

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-concepts role=concepts-state -->
## Concepts and visible state

A `BundleOperationDescriptor` holds a valid flag, the 7-bit form identity, an operation class, and four optional fields, each with its own valid flag: a 10-bit selector, a 5-bit data type, a 2-bit mode, and a 3-bit branch type.

`ClearBundleHeaderState` resets the descriptor, the dimensions, the binding arrays, the range group, the zero-participation marker, the control, data, hint, and fixed-point attributes, the execution-mask binding, the bundle argument, and the three per-bundle markers.

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-rules role=rules-interactions -->
## Rules and interactions

`InstallBundleOperationDescriptor` stores the descriptor. If the descriptor carries a data type and no `B.DATR` has been seen, it also copies that data type into the data attributes.

`ClearBundleHeaderState` sets every dimension to 1 and marks it absent. It sets the pad field to `11` and the data type to `DTYPE_NONE`, and it marks every binding invalid.

Design point: the pad field is cleared to `11`, which reads as `Null`, not to `00`. The ASL comment says absence is distinct from an explicitly encoded zero pad value. A bundle without `B.DATR` leaves padding undefined, while `B.DATR` with pad code `00` requests zeros.

Design point: omitted dimensions clear to 1 rather than 0. A bundle that never writes `LB1` reads 1 there, while an explicit `B.DIM` of 0 reaches the operation's legality checks as 0.

Design point: the start data type fills in the data attributes only when `B.DATR` is absent. A bundle without `B.DATR` therefore still has a data type, taken from its start form. A later `B.DATR` writes its own data-type field over the copied value; if that field is `DTYPE_NONE`, the effective type falls back to the start data type.

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-boundaries role=boundaries -->
## Architectural boundaries

`ClearBundleHeaderState` leaves `_LocalGenerations`, `_SharedGenerations`, `BARG`, the templates, and the active flags alone. Begin and stop write the active flags and `BARG`. Generations close only through their own paths or reset.

The clear does not zero every field. For example, a scalar binding keeps its old register selectors but is marked invalid.

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`BSTART.VEC TADD, FP32` installs a descriptor with a valid selector and data type `FP32`. With no `B.DATR`, `FP32` is copied into the data attributes, and the pad value stays `Null`. At commit, `ClearBundleHeaderState` erases the descriptor and all bindings, so the next bundle starts empty.

<!-- PTO-READER-BLOCK: block-model-state-descriptor-state-related role=related-owners-navigation -->
## Related owners

- [Bundle start dispatch](../dispatch/start.md) calls both transitions.
- [Descriptor legality](../dispatch/descriptor-legality.md) validates a descriptor before installation.
- [Enter and stop](../lifecycle/enter-stop.md) clears the header at commit.
- [Control state](control-state.md) lists the members.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/descriptor-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE","surface":"block","classification":["model","state","descriptor-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
func InstallBundleOperationDescriptor(descriptor: BundleOperationDescriptor)
begin
    _BundleOperation = descriptor;
    if descriptor.data_type_valid && !_BundleDataAttributesPresent then
        _BundleDataAttributes.data_type = descriptor.data_type;
    end;
end;

func ClearBundleHeaderState()
begin
    _BundleCommitTargetSet = FALSE;
    _BundleConditionSet = FALSE;
    _SystemBlockTerminalPending = FALSE;
    _BundleArgument = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
    _BundleOperation.valid = FALSE;
    _BundleOperation.form_identity = Zeros{7};
    _BundleOperation.operation_class = BundleOperation_Control;
    _BundleOperation.selector_valid = FALSE;
    _BundleOperation.selector = Zeros{10};
    _BundleOperation.data_type_valid = FALSE;
    _BundleOperation.data_type = Zeros{5};
    _BundleOperation.mode_valid = FALSE;
    _BundleOperation.mode = Zeros{2};
    _BundleOperation.branch_type_valid = FALSE;
    _BundleOperation.branch_type = Zeros{3};
    for index = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        _BundleDimensions[[index]] = ZeroExtend{PTO_XLEN}('1');
        _BundleDimensionPresent[[index]] = FALSE;
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].source_count = 0;
        _BundleScalarBindings[[index]].execution_mask_present = FALSE;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].destination_reused_by_generation = FALSE;
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
        _BundleTileBindings[[index]].source0_relative = FALSE;
        _BundleTileBindings[[index]].source1_relative = FALSE;
        _BundleTileBindings[[index]].parent_ref_valid = FALSE;
        _BundleTileBindings[[index]].parent_ref_relative = FALSE;
        _BundleTileBindings[[index]].parent_ref = 0;
        _BundleTileBindings[[index]].last = FALSE;
        _BundleTileBindings[[index]].source0_subview.valid = FALSE;
        _BundleTileBindings[[index]].source0_subview.derived.valid = FALSE;
        _BundleTileBindings[[index]].source0_subview.materialized = FALSE;
        _BundleTileBindings[[index]].source0_subview.materialized_index = 0;
        _BundleTileBindings[[index]].source1_subview.valid = FALSE;
        _BundleTileBindings[[index]].source1_subview.derived.valid = FALSE;
        _BundleTileBindings[[index]].source1_subview.materialized = FALSE;
        _BundleTileBindings[[index]].source1_subview.materialized_index = 0;
        _BundleTileBindings[[index]].destination_assemble.valid = FALSE;
        _BundleTileBindings[[index]].destination_assemble.derived.valid = FALSE;
        _BundleTileBindings[[index]].destination_assemble.materialized = FALSE;
        _BundleTileBindings[[index]].destination_assemble.materialized_index = 0;
    end;
    for index = 0 to 3 do
        _BundleSharedBindings[[index]].valid = FALSE;
        _BundleSharedBindings[[index]].shared_tile_id =
            Zeros{6} as SharedTileID;
        _BundleSharedBindings[[index]].size_code = 0;
        _BundleSharedBindings[[index]].pe_mask = Zeros{4};
        _BundleSharedBindings[[index]].consumed = FALSE;
        _BundleSharedBindings[[index]].source0_subview.valid = FALSE;
        _BundleSharedBindings[[index]].source0_subview.derived.valid = FALSE;
        _BundleSharedBindings[[index]].source0_subview.materialized = FALSE;
        _BundleSharedBindings[[index]].source0_subview.materialized_index = 0;
        _BundleSharedBindings[[index]].destination_assemble.valid = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.derived.valid = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.materialized = FALSE;
        _BundleSharedBindings[[index]].destination_assemble.materialized_index = 0;
    end;
    _BundleRangeGroup.open = FALSE;
    _BundleRangeGroup.zero_mode = FALSE;
    _BundleRangeGroup.kind = BundleRangeGroup_None;
    _BundleRangeGroup.tile_binding = 0;
    _BundleRangeGroup.shared_binding = 0;
    _BundleRangeGroup.source0_allowed = FALSE;
    _BundleRangeGroup.source1_allowed = FALSE;
    _BundleRangeGroup.destination_allowed = FALSE;
    _BundleRangeGroup.source0_seen = FALSE;
    _BundleRangeGroup.source1_seen = FALSE;
    _BundleRangeGroup.destination_seen = FALSE;
    _BundleZeroParticipationSeen = FALSE;
    _BundleControlAttributes.present = FALSE;
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = FALSE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.dimension_reduction = FALSE;
    _BundleDataAttributes.data_type_present = FALSE;
    _BundleDataAttributes.data_type = DTYPE_NONE;
    _BundleDataAttributes.data_layout = Zeros{5};
    // Absence is distinct from an explicitly encoded zero PadValue.  The
    // operation-visible omission default is Null; B.DATR 00 selects Zero.
    _BundleDataAttributes.pad_value = '11';
    _BundleDataAttributes.comparison_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
    _BundleDataAttributes.execution_mask_invert = FALSE;
    _BundleDataAttributes.execution_mask_zero = FALSE;
    _BundleDataAttributesPresent = FALSE;
    _BundleExecutionMask.valid = FALSE;
    _BundleExecutionMask.carrier = BundleExecutionMask_None;
    _BundleExecutionMask.predicate_tile = 0;
    _BundleExecutionMask.predicate_source_ordinal = 0;
    _BundleExecutionMask.low_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.high_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.word_count = 0;
    _BundleExecutionMask.layout = TileLayout_CUBE_M32;
    _BundleExecutionMask.valid_rows = 0;
    _BundleExecutionMask.valid_columns = 0;
    _BundleExecutionMask.invert = FALSE;
    _BundleExecutionMask.zero_inactive = FALSE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    _BundleExecutionMask.merge_base = 0;
    _BundleExecutionMask.predicate_tile_snapshot = Zeros{524288};
    _BundleHint.present = FALSE;
    _BundleHint.trace = FALSE;
    _BundleHint.trace_end = FALSE;
    _BundleHint.branch_valid = FALSE;
    _BundleHint.branch_likely = FALSE;
    _BundleHint.temperature = Zeros{2};
    _BundleHint.prefetch_size = Zeros{12};
    _BundleFixedPointAttributes.valid = FALSE;
    _BundleFixedPointAttributes.pre_quant_mode = Zeros{6};
    _BundleFixedPointAttributes.relu_mode = Zeros{3};
    _BundleFixedPointAttributes.group_n_code = Zeros{4};
    _BundleFixedPointAttributes.row_max_en = FALSE;
    _BundleFixedPointAttributes.group_max_en = FALSE;
    _BundleFixedPointAttributes.row_max_init = FALSE;
    _BundleFixedPointAttributes.max_abs_en = FALSE;
    _BundleFixedPointAttributes.trans_a = FALSE;
    _BundleFixedPointAttributes.trans_b = FALSE;
    _BundleFixedPointAttributes.c_scale_en = FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
