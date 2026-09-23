// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-STORE-005","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"execution","summary":"A decoded Shared TSTORE last-use source releases capacity only after successful operation completion.","pass_condition":"TSTORE writes GM and consumes Shared payload, a later TSTORE of the retained Sx faults, and a pending source keeps its marker through retry without premature release.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/capacity/shared.asl"]}
pure func SharedLastUseStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedLastUseStoreBinding(last_use: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 7;
    instruction[11:9] = '111';
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

pure func SharedLastUseStoreAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func BeginSharedLastUseStore(last_use: boolean)
begin
    let started = ExecuteCommandInstruction(SharedLastUseStoreStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(
        SharedLastUseStoreBinding(last_use), 32);
    assert bound == CommandExecution_Executed;
    let addressed = ExecuteCommandInstruction(
        SharedLastUseStoreAddress(), 32);
    assert addressed == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    let shared_id = (Zeros{6} + 7) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    BeginSharedLastUseStore(TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _Memory[[8]] == Zeros{8} + 0x55;
    assert SharedTileRecord(shared_id).descriptor_valid;
    assert !SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 0;

    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 16);
    BeginSharedLastUseStore(FALSE);
    let repeated = ExecuteBundleTileOperation();
    assert !repeated;
    assert _LastFault == Fault_TileLegality;
    assert _Memory[[16]] == Zeros{8};
    assert SharedTileRecord(shared_id).descriptor_valid;

    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 24);
    BeginSharedLastUseStore(TRUE);
    let pending = ExecuteBundleTileOperation();
    assert !pending;
    assert _LastFault == Fault_None;
    assert !SharedTileRecord(shared_id).descriptor_valid;
    assert SharedTileCapacityInUse() == 0;
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x77);
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    let retried = ExecuteBundleTileOperation();
    assert retried;
    assert _Memory[[24]] == Zeros{8} + 0x77;
    assert !SharedTileRecord(shared_id).payload_live;
    return 0;
end;
