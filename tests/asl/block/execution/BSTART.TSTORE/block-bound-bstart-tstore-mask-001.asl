// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-MASK-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"boundary","summary":"Decoded Function 1 accepts every nonzero Shared consumer mask and zero remains a strict no-op","pass_condition":"full and sparse nonzero masks store one published Shared payload without mask faults while zero completes without source readiness or GM effects","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/state/shared-registers.asl"]}
pure func TStoreMaskStart(function: bits(5), data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func TStoreMaskShared(shared_tile_id: bits(6), pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0000';
    instruction[11:9] = pe_mode;
    return instruction;
end;

func InstallTStoreMaskSource()
begin
    ConfigureTile(0, 128, 16, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x2a);
    MarkTileValidRegionDefined(0);
    InstallSharedTile((Zeros{6} + 7) as SharedTileID, _Tiles[[0]], '1111');
    assert SharedTilePublished((Zeros{6} + 7) as SharedTileID);
end;

func main() => integer
begin
    ResetProfileState();
    InstallTStoreMaskSource();
    _Memory[[0]] = Zeros{8} + 0x55;
    let full_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let full_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '111'), 32);
    assert full_start == CommandExecution_Executed;
    assert full_source == CommandExecution_Executed;
    let full_completed = ExecuteBundleTileOperation();
    assert full_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x2a;
    assert _BundleSharedBindings[[0]].consumed;

    ResetProfileState();
    InstallTStoreMaskSource();
    _Memory[[0]] = Zeros{8} + 0x55;
    let sparse_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let sparse_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '001'), 32);
    assert sparse_start == CommandExecution_Executed;
    assert sparse_source == CommandExecution_Executed;
    let sparse_completed = ExecuteBundleTileOperation();
    assert sparse_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x2a;
    assert _BundleSharedBindings[[0]].consumed;

    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0x55;
    let zero_start = ExecuteCommandInstruction(
        TStoreMaskStart('00001', Zeros{5} + 24), 32);
    let zero_source = ExecuteCommandInstruction(
        TStoreMaskShared(Zeros{6} + 7, '000'), 32);
    assert zero_start == CommandExecution_Executed;
    assert zero_source == CommandExecution_Executed;
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _LastFault == Fault_None;
    assert _Memory[[0]] == Zeros{8} + 0x55;
    assert !SharedTileRecord((Zeros{6} + 7) as SharedTileID).descriptor_valid;
    return 0;
end;
