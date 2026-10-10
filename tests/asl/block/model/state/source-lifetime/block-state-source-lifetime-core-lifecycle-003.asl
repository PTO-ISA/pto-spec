// PTO-TEST: {"id":"PTO-AVS-BLOCK-SOURCE-LIFETIME-CORE-LIFECYCLE-003","source":"asl/block/model/state/source-lifetime.asl","requirements":["PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"Identical encoded Shared last-use occurrences remain isolated by Core and invocation lifecycle.","pass_condition":"PE0 captures S14 independently in two Cores, aborting Core0 preserves both payloads and the Core1 caller context, Core1 completes and consumes only its payload, and ending Core1 preserves the selected caller context.","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/arch/state/pe-execution-context.asl","asl/block/operands/B.IOS.asl"]}
pure func CoreLifetimeStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001'; instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func CoreLifetimeBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 14; instruction[11:9] = '111';
    instruction[26] = '1'; return instruction;
end;

pure func CoreLifetimeAddress() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2; return instruction;
end;

func RunCoreLifetimePE(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                       address: integer)
begin
    SelectExecutionContext(core, pe); ClearBundleHeaderState();
    WriteGPR(2, Zeros{PTO_XLEN} + address);
    let started = ExecuteCommandInstruction(CoreLifetimeStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(CoreLifetimeBinding(), 32);
    let addressed = ExecuteCommandInstruction(CoreLifetimeAddress(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           addressed == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation(); assert completed;
end;

func InstallCoreLifetimeShared(core: PTOModelCoreIdentity, value: integer)
begin
    SelectExecutionContext(core, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + value);
    InstallSharedTile((Zeros{6} + 14) as SharedTileID, _Tiles[[0]], '1111');
end;

func main() => integer
begin
    ResetProfileState();
    let launched0 = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x300);
    let launched1 = LaunchKernelInvocation(1, Zeros{PTO_XLEN} + 0x300);
    assert launched0 == KernelLifecycle_Started &&
           launched1 == KernelLifecycle_Started;
    InstallCoreLifetimeShared(0, 0x41); InstallCoreLifetimeShared(1, 0x42);
    RunCoreLifetimePE(0, 0, 8); RunCoreLifetimePE(1, 0, 16);
    let shared_id = (Zeros{6} + 14) as SharedTileID;
    SelectExecutionContext(0, 0); let core0_before = SharedTileRecord(shared_id);
    SelectExecutionContext(1, 2); let core1_before = SharedTileRecord(shared_id);
    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started &&
           _CurrentModelCore == 1 && _CurrentMemoryAgent == 2;
    let core1_after_abort = SharedTileRecord(shared_id);
    assert core0_before.payload_live && core1_before.payload_live &&
           core1_after_abort.payload_live;
    SelectExecutionContext(0, 0); let core0_after = SharedTileRecord(shared_id);
    assert core0_after.payload_live;

    for pe = 1 to 3 do
        RunCoreLifetimePE(1, pe as MemoryAgentId, 24 + pe * 8);
    end;
    SelectExecutionContext(1, 2); let core1_completed = SharedTileRecord(shared_id);
    assert !core1_completed.payload_live;
    let ended = EndKernelInvocation(1);
    assert ended == KernelLifecycle_Started &&
           _CurrentModelCore == 1 && _CurrentMemoryAgent == 2;
    SelectExecutionContext(0, 0); let core0_final = SharedTileRecord(shared_id);
    assert core0_final.payload_live;
    return 0;
end;
