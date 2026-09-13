// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-SUBVIEW-PREFLIGHT-032","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001"],"kind":"atomicity","summary":"Shared TMATMUL rejects one invalid per-PE CELL subview before effects.","pass_condition":"A single participating PE with an out-of-range Shared B.SUBVIEW offset causes Fault_TileLegality for the complete 1111 cooperative operation without payload reads, binding consumption, or destination allocation.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/operands/shared-generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(10, 256, 8, 16, 2, 8,
        TileDataType_U16, TileLayout_RowMajor, '1111');
    ConfigureTileForMask(11, 256, 16, 8, 4, 8,
        TileDataType_U16, TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 16);
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
    _BundleSharedBindings[[1]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[1]].source0_subview.reg_src = 2;
    _BundleSharedBindings[[1]].source0_subview.uimm11 = Zeros{11};
    _BundleSharedBindings[[1]].source0_subview.size_code = 1;
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
