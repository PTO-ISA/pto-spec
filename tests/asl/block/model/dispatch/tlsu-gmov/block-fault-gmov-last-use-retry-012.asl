// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-LAST-USE-RETRY-012","source":"asl/block/model/dispatch/tlsu-gmov.asl","requirements":["PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-BSTART-GMOV-COLLECTIVE-001","PTO-GMOV-CORE4-PEER-001"],"kind":"fault","summary":"a captured encoded GMOV allocation fault and trap retry do not falsely complete peer-source last-use","pass_condition":"PE0 captures a two-consumer peer source then faults destination allocation, trap recovery retries the same captured selection, PE0 completion retains the source, and PE1 completion consumes it exactly once","related_sources":["asl/block/model/state/source-lifetime.asl","asl/block/model/faults/rollback.asl","asl/arch/state/trap-context.asl"]}
pure func GMOVRetryStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVRetryBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '101';
    instruction[19] = '1';
    instruction[26] = '1';
    return instruction;
end;

pure func GMOVRetryPeer() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func PrepareGMOVRetryBlock(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let start = ExecuteCommandInstruction(GMOVRetryStart(), 32);
    let binding = ExecuteCommandInstruction(GMOVRetryBinding(), 32);
    let peer = ExecuteCommandInstruction(GMOVRetryPeer(), 32);
    assert start == CommandExecution_Executed &&
           binding == CommandExecution_Executed &&
           peer == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x280);
    assert launched == KernelLifecycle_Started;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
        var source_mask = Zeros{4};
        source_mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
        ConfigureTileForMask(0, 128, 1, 1, 1, 1, TileDataType_U8,
            TileLayout_RowMajor, source_mask);
        InstallRelativeTileFixture(0, 0);
        WriteTileElement(0, 0, 0,
            Zeros{PTO_XLEN} + 0x60 + pe_number);
        WriteGPR(2, Zeros{PTO_XLEN} + 2);
    end;

    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    for index = 1 to 15 do
        ConfigureTileForMask(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, '1000');
        WriteTileElement(index as TileIndex, 0, 0,
            Zeros{PTO_XLEN} + index);
    end;
    PrepareGMOVRetryBlock(0 as MemoryAgentId);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileAllocation;
    assert _TrapContexts[[0]].valid;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '1';

    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ReleaseTile(15);
    let recovered = RecoverTrapContext(0);
    assert recovered;
    ClearFault();
    let retried = ExecuteBundleTileOperation();
    assert retried && _LastFault == Fault_None;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '1';

    PrepareGMOVRetryBlock(1 as MemoryAgentId);
    let peer_completed = ExecuteBundleTileOperation();
    assert peer_completed && _LastFault == Fault_None;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 2 as MemoryAgentId);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '0';
    return 0;
end;
