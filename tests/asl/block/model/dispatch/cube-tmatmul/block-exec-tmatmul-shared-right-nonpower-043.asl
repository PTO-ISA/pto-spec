// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-RIGHT-NONPOWER-043","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"Right-only Shared TMATMUL uses non-power dimensions and real source capacity across the M shard tail.","pass_condition":"M=17,N=3,K=192 succeeds for active PE0 and PE1 with Local U16 A, Shared U16 B [N,K], and exact defined U32 M16 outputs; inactive PE behavior remains covered by the group-M regression.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/dispatch/cube-tmatmul.asl"]}

func RunRightOnlySharedGroupM(pe: MemoryAgentId,
                              expected_m: integer {1..16})
begin
    ResetProfileState();
    SelectMemoryEventAgent(pe);
    let a_capacity = TileCubePhysicalRequiredBytes(
        TileLayout_CUBE_M16, 16, 256, TileDataType_U16);
    let a_ready = ConfigureCubeTileForMaskWithPhysical(
        1, a_capacity, 16, 256, expected_m, 192,
        TileDataType_U16, TileLayout_CUBE_M16, '1111');
    assert a_ready;
    for row = 0 to expected_m - 1 looplimit 16 do
        for inner = 0 to 191 looplimit 192 do
            WriteTileElement(1, row, inner, Zeros{PTO_XLEN});
        end;
    end;

    ConfigureTileForMask(10, 4096,
        DerivedTileRows(4096, 256, TileDataType_U16), 256,
        3, 192, TileDataType_U16, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[10]], '1111');
    assert SharedTileDescriptorLegal((Zeros{6} + 41) as SharedTileID);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 192);
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].valid_rows == expected_m;
    assert _Tiles[[destination]].valid_columns == 3;
    assert _BundleSharedBindings[[0]].consumed;
end;

func main() => integer
begin
    RunRightOnlySharedGroupM(0, 16);
    RunRightOnlySharedGroupM(1, 1);
    return 0;
end;
