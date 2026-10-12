// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-PARTIAL-REUSE-009","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"A partial Shared last-use cohort ignores nonparticipants and does not let a retained occurrence complete the cohort.","pass_condition":"A retained nonparticipant leaves the payload live, the first selected last-use PE returns without releasing it, and the final selected PE releases the payload without waiting for either nonparticipant.","related_sources":["asl/block/model/operands/shared-bindings.asl"]}
pure func PartialLastUseStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PartialLastUseBinding(last_use: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 12;
    instruction[11:9] = '101';
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

pure func PartialLastUseAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func RunPartialStore(pe: MemoryAgentId, last_use: boolean, address: integer)
begin
    SelectExecutionContext(0, pe);
    ClearBundleHeaderState();
    WriteGPR(2, Zeros{PTO_XLEN} + address);
    let started = ExecuteCommandInstruction(PartialLastUseStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(
        PartialLastUseBinding(last_use), 32);
    let addressed = ExecuteCommandInstruction(PartialLastUseAddress(), 32);
    assert bound == CommandExecution_Executed;
    assert addressed == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x180);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3c);
    let shared_id = (Zeros{6} + 12) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');

    RunPartialStore(2, FALSE, 8);
    let after_retain = SharedTileRecord(shared_id);
    assert after_retain.payload_live;
    RunPartialStore(0, TRUE, 16);
    let after_first = SharedTileRecord(shared_id);
    assert after_first.payload_live;
    RunPartialStore(1, TRUE, 24);
    let after_last = SharedTileRecord(shared_id);
    assert !after_last.payload_live;
    assert _Memory[[8]] == Zeros{8} &&
           _Memory[[16]] == Zeros{8} + 0x3c &&
           _Memory[[24]] == Zeros{8} + 0x3c;
    return 0;
end;
