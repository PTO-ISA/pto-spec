// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-MSHARD-021","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"Cooperative TMATMUL distributes Core-total group M into exact current-PE fragments.","pass_condition":"Boundary group sizes 1, 17, 64, 65, and 128 derive the frozen M16/M32 valid-row distribution; active PEs consume their exact Shared-A slice and inactive PEs publish no Local state.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl"]}

func ExecuteSharedGroupMForPE(group_m: integer {1..128},
                              pe: MemoryAgentId,
                              expected_valid_m: integer {0..32},
                              expected_first: integer)
begin
    ResetProfileState();
    SelectMemoryEventAgent(pe);

    let source_capacity = if group_m <= 64 then 128 else 256;
    let source_rows = if group_m <= 64 then 64 else 128;
    ConfigureTileForMask(10, source_capacity, source_rows, 1,
        group_m, 1, TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(11, 128, 128, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to group_m - 1 looplimit 128 do
        WriteTileElement(10, row, 0, Zeros{PTO_XLEN} + row + 2);
    end;
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 10);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');
    let shared_capacity = CoreTileCapacityInUse();

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + group_m);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    if expected_valid_m == 0 then
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
        assert CoreTileCapacityInUse() == shared_capacity;
    else
        let destination = BundleMatrixDestinationAt(0);
        var expected_mask = Zeros{4};
        expected_mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
        assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
        assert _TileAllocationMasks[[destination]] == expected_mask;
        assert _Tiles[[destination]].valid_rows == expected_valid_m;
        assert _Tiles[[destination]].valid_columns == 1;
        assert ReadTileElement(destination, 0, 0) ==
            Zeros{PTO_XLEN} + expected_first;
    end;
end;

func main() => integer
begin
    assert BundleMatrixCooperativeValidM(1, 0) == 1;
    assert BundleMatrixCooperativeValidM(1, 1) == 0;
    assert BundleMatrixCooperativeValidM(17, 0) == 16;
    assert BundleMatrixCooperativeValidM(17, 1) == 1;
    assert BundleMatrixCooperativeValidM(17, 2) == 0;
    assert BundleMatrixCooperativeValidM(64, 3) == 16;
    assert BundleMatrixCooperativeValidM(65, 0) == 32;
    assert BundleMatrixCooperativeValidM(65, 1) == 32;
    assert BundleMatrixCooperativeValidM(65, 2) == 1;
    assert BundleMatrixCooperativeValidM(65, 3) == 0;
    assert BundleMatrixCooperativeValidM(128, 3) == 32;

    ExecuteSharedGroupMForPE(1, 0, 1, 20);
    ExecuteSharedGroupMForPE(1, 1, 0, 0);
    ExecuteSharedGroupMForPE(17, 1, 1, 180);
    ExecuteSharedGroupMForPE(17, 2, 0, 0);
    ExecuteSharedGroupMForPE(64, 3, 16, 500);
    ExecuteSharedGroupMForPE(65, 2, 1, 660);
    ExecuteSharedGroupMForPE(65, 3, 0, 0);
    ExecuteSharedGroupMForPE(128, 3, 32, 980);
    return 0;
end;
