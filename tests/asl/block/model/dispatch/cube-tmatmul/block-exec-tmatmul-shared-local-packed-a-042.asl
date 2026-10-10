// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-LOCAL-PACKED-A-042","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"A Local packed A does not trigger the Shared packed-primary even-K rule.","pass_condition":"Right-only Shared FP16 B with Local E2M1X2 A completes at odd K=17 and publishes a defined exact-shape FP32 destination.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/legality/matrix-functions.asl"]}

func main() => integer
begin
    ResetProfileState();
    SelectMemoryEventAgent(0);
    let a_capacity = TileCubePhysicalRequiredBytes(
        TileLayout_CUBE_M16, 16, 32, TileDataType_E2M1X2);
    let a_ready = ConfigureCubeTileForMaskWithPhysical(
        1, a_capacity, 16, 32, 16, 17, TileDataType_E2M1X2,
        TileLayout_CUBE_M16, '1111');
    assert a_ready;
    for row = 0 to 15 looplimit 16 do
        for column = 0 to 16 looplimit 17 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN});
        end;
    end;
    assert TileCubeDescriptorLegal(_Tiles[[1]]);

    ConfigureTileForMask(10, 256,
        DerivedTileRows(256, 32, TileDataType_FP16), 32,
        3, 17, TileDataType_FP16, TileLayout_RowMajor, '1111');
    for row = 0 to 2 looplimit 3 do
        for column = 0 to 16 looplimit 17 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN});
        end;
    end;
    InstallSharedTile((Zeros{6} + 42) as SharedTileID,
        _Tiles[[10]], '1111');

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 11;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 4, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', TRUE, FALSE, 1, 0, TRUE);
    assert BundleMatrixSharedSchemasLegal(
        0, TileDataType_E2M1X2, TileDataType_FP16,
        17, 3, 17, 1);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].valid_rows == 16;
    assert _Tiles[[destination]].valid_columns == 3;
    assert _BundleSharedBindings[[0]].consumed;
    return 0;
end;
