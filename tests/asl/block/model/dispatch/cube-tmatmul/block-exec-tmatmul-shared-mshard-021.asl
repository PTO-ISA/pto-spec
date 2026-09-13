// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-MSHARD-021","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-GROUP-M-DISTRIBUTION-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Cooperative TMATMUL distributes Core-total group M into exact current-PE fragments for both A physical majors.","pass_condition":"Boundary group sizes 1, 17, 64, 65, and 128 derive the frozen M16/M32 valid-row distribution; active PEs consume their exact Shared-A slice and inactive PEs publish no Local state for TransA=0 and TransA=1.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl"]}

func ExecuteSharedGroupMForPE(group_m: integer {1..128},
                              pe: MemoryAgentId,
                              expected_valid_m: integer {0..32},
                              expected_first: integer,
                              transpose: boolean)
begin
    ResetProfileState();
    SelectMemoryEventAgent(pe);

    let source_capacity = if group_m <= 64 then 128 else 256;
    let source_columns = if !transpose then 1
        else if group_m <= 16 then 16
        else if group_m <= 32 then 32
        else if group_m <= 64 then 64
        else 128;
    let source_rows = if transpose then
        DerivedTileRows(source_capacity, source_columns, TileDataType_U16)
        else if group_m <= 64 then 64 else 128;
    let source_valid_rows = if transpose then 1 else group_m;
    let source_valid_columns = if transpose then group_m else 1;
    ConfigureTileForMask(10, source_capacity, source_rows, source_columns,
        source_valid_rows, source_valid_columns, TileDataType_U16,
        TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 128, 128, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor, '1111');
    for row = 0 to source_valid_rows - 1 looplimit 128 do
        for column = 0 to source_valid_columns - 1 looplimit 128 do
            let logical_row = if transpose then column else row;
            WriteTileElement(10, row, column,
                Zeros{PTO_XLEN} + logical_row + 2);
        end;
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
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        transpose, FALSE);
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

    ExecuteSharedGroupMForPE(1, 0, 1, 20, FALSE);
    ExecuteSharedGroupMForPE(1, 1, 0, 0, FALSE);
    ExecuteSharedGroupMForPE(17, 1, 1, 180, FALSE);
    ExecuteSharedGroupMForPE(17, 2, 0, 0, FALSE);
    ExecuteSharedGroupMForPE(64, 3, 16, 500, FALSE);
    ExecuteSharedGroupMForPE(65, 2, 1, 660, FALSE);
    ExecuteSharedGroupMForPE(65, 3, 0, 0, FALSE);
    ExecuteSharedGroupMForPE(128, 3, 32, 980, FALSE);

    // Re-run tail and zero-row boundaries through the TransA=1 [K,M]
    // physical schema; the same logical m_global fragments must result.
    ExecuteSharedGroupMForPE(1, 0, 1, 20, TRUE);
    ExecuteSharedGroupMForPE(1, 1, 0, 0, TRUE);
    ExecuteSharedGroupMForPE(17, 0, 16, 20, TRUE);
    ExecuteSharedGroupMForPE(17, 1, 1, 180, TRUE);
    ExecuteSharedGroupMForPE(17, 2, 0, 0, TRUE);
    ExecuteSharedGroupMForPE(17, 3, 0, 0, TRUE);
    ExecuteSharedGroupMForPE(65, 2, 1, 660, TRUE);
    ExecuteSharedGroupMForPE(65, 3, 0, 0, TRUE);
    ExecuteSharedGroupMForPE(128, 3, 32, 980, TRUE);
    return 0;
end;
