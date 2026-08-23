// PTO-TEST: {"id":"PTO-AVS-BLOCK-DTYPE-NONE-RESOLUTION-001","source":"asl/block/model/dispatch/descriptor-legality.asl","requirements":[],"kind":"execution","summary":"DTYPE_NONE is field-valid only for B.DATR and TMOV and resolves without becoming a TileDataType","pass_condition":"TestBundleDataTypeNoneResolution completes without assertion failure","related_sources":["asl/arch/data-types/tile-data-types.asl","asl/block/attributes/B.DATR.asl","asl/block/execution/BSTART.TMOV.asl","asl/block/model/dispatch/destination-shape.asl"]}
func DTypeNoneConfigureTile(index: TileIndex, data_type: TileDataType)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func DTypeNoneInstallOperation(operation_class: BundleOperationClass,
                               selector: bits(10), data_type: bits(5))
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = operation_class,
        selector_valid = TRUE,
        selector = selector,
        data_type_valid = TRUE,
        data_type = data_type,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func TestBundleDataTypeNoneResolution()
begin
    assert BundleDataTypeFieldValid(DTYPE_NONE);
    assert !BundleDataTypeConcrete(DTYPE_NONE);
    assert !BundleDataTypeFieldValid(Zeros{5} + 15);

    // The sentinel is decode-valid only on the explicitly accepted fields.
    let b_datr = Zeros{64} + 0x01f01023;
    assert DecodeCommandForm(b_datr, 32) != PTO_COMMAND_FORM_COUNT;
    var tmov = Zeros{64} + 0x00211181;
    tmov[31:27] = DTYPE_NONE;
    assert DecodeCommandForm(tmov, 32) != PTO_COMMAND_FORM_COUNT;
    var tepl = Zeros{64} + 0x00019181;
    tepl[31:27] = DTYPE_NONE;
    let tepl_form = DecodeCommandForm(tepl, 32);
    assert tepl_form != PTO_COMMAND_FORM_COUNT;
    let tepl_descriptor = DecodeBundleOperationDescriptor(tepl,
        tepl_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
    assert !BundleOperationDescriptorLegal(tepl_descriptor);

    // Explicit DTYPE_NONE in B.DATR preserves a concrete BSTART type.
    ResetProfileState();
    DTypeNoneInstallOperation(BundleOperation_TileElement, Zeros{10},
        Zeros{5} + 24);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_None;
    assert _BundleDataAttributes.data_type_present;
    let (start_valid, start_type) = ResolveBundleEffectiveDataType();
    assert start_valid;
    assert start_type == TileDataType_U64;

    // A concrete B.DATR type has precedence over BSTART.
    SetBundleDataAttributeState(Zeros{5} + 8, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    let (datr_valid, datr_type) = ResolveBundleEffectiveDataType();
    assert datr_valid;
    assert datr_type == TileDataType_E5M2;

    // Local TMOV inherits the source descriptor when both fields are None.
    ResetProfileState();
    DTypeNoneConfigureTile(0, TileDataType_U16);
    DTypeNoneInstallOperation(BundleOperation_TileMemory, Zeros{10} + 2,
        DTYPE_NONE);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    AddBundleTileBinding(TRUE, 2, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    let (local_valid, local_type) = ResolveBundleEffectiveDataType();
    assert local_valid;
    assert local_type == TileDataType_U16;
    let local_resolved = ResolveBundleTileDestinations();
    assert local_resolved;
    assert _Tiles[[32]].allocated;
    assert _Tiles[[32]].data_type == TileDataType_U16;

    // Shared-to-Local TMOV inherits the Shared source descriptor.
    ResetProfileState();
    DTypeNoneConfigureTile(10, TileDataType_E4M3);
    InstallSharedTile((Zeros{6} + 31) as SharedTileID, _Tiles[[10]], '1111');
    DTypeNoneInstallOperation(BundleOperation_TileMemory, Zeros{10} + 11,
        DTYPE_NONE);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    BindBundleSharedIO((Zeros{6} + 31) as SharedTileID, 0, '1111');
    let (shared_valid, shared_type) = ResolveBundleEffectiveDataType();
    assert shared_valid;
    assert shared_type == TileDataType_E4M3;

    // A TMOV with no concrete encoded type or source descriptor is rejected
    // before destination allocation.
    ResetProfileState();
    DTypeNoneInstallOperation(BundleOperation_TileMemory, Zeros{10} + 2,
        DTYPE_NONE);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    AddBundleTileBinding(TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    let unresolved = ResolveBundleTileDestinations();
    assert !unresolved;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[32]].allocated;
end;

func main() => integer
begin
    ResetProfileState();
    TestBundleDataTypeNoneResolution();
    return 0;
end;
