// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE","surface":"block","classification":["model","state","descriptor-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
func InstallBundleOperationDescriptor(descriptor: BundleOperationDescriptor)
begin
    _BundleOperation = descriptor;
end;

func ClearBundleHeaderState()
begin
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
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].source_count = 0;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
        _BundleTileBindings[[index]].last = FALSE;
    end;
    for index = 0 to 3 do
        _BundleSharedBindings[[index]].valid = FALSE;
        _BundleSharedBindings[[index]].shared_id = Zeros{8};
        _BundleSharedBindings[[index]].size_code = 0;
        _BundleSharedBindings[[index]].pe_mask = Zeros{4};
        _BundleSharedBindings[[index]].consumed = FALSE;
    end;
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = FALSE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.direct_register = FALSE;
    _BundleDataAttributes.data_type = Zeros{5};
    _BundleDataAttributes.data_layout = Zeros{5};
    _BundleDataAttributes.pad_value = Zeros{2};
    _BundleDataAttributes.conversion_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
end;
