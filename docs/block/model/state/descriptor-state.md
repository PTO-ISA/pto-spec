<!-- GENERATED FROM: asl/block/model/state/descriptor-state.asl -->
# Descriptor State

**Normative ASL source:** `asl/block/model/state/descriptor-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE}

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
        _BundleDimensions[[index]] = Zeros{PTO_XLEN};
        _BundleDimensionPresent[[index]] = FALSE;
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].source_count = 0;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].destination_reused_by_generation = FALSE;
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
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
    _BundleDataAttributesPresent = FALSE;
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
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
