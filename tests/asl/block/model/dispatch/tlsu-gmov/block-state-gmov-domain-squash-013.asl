// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-DOMAIN-SQUASH-013","source":"asl/block/model/dispatch/tlsu-gmov.asl","requirements":["PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-B-ASSEMBLE-SPECULATION-001","PTO-BSTART-GMOV-COLLECTIVE-001"],"kind":"state-transition","summary":"GMOV selection squash is domain-scoped and a saved stale ordinal cannot recapture after recovery","pass_condition":"PE0 opens two encoded reuse occurrences at distinct sites, PE1 faults after joining the first, squashing that domain preserves and completes the second occurrence, and recovering the first saved context waits without destination or source effects","related_sources":["asl/block/model/operands/local-generation-squash.asl","asl/block/model/state/source-lifetime.asl","asl/arch/state/trap-context.asl"]}
pure func GMOVSquashStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27; return instruction;
end;

pure func GMOVSquashBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[18:15] = '0001'; instruction[11:9] = '101';
    instruction[19] = '1'; instruction[26] = '0'; return instruction;
end;

pure func GMOVSquashPeer() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2; return instruction;
end;

func PrepareGMOVSquashPE(pe: MemoryAgentId, site: integer)
begin
    SelectExecutionContext(0, pe); ClearBundleHeaderState(); ClearFault();
    WriteBPC(Zeros{PTO_XLEN} + site); WriteTPC(Zeros{PTO_XLEN} + site);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let start = ExecuteCommandInstruction(GMOVSquashStart(), 32);
    let binding = ExecuteCommandInstruction(GMOVSquashBinding(), 32);
    let peer = ExecuteCommandInstruction(GMOVSquashPeer(), 32);
    assert start == CommandExecution_Executed &&
           binding == CommandExecution_Executed &&
           peer == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x400);
    assert launched == KernelLifecycle_Started;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        var source_mask = Zeros{4};
        source_mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
        ConfigureTileForMask(0, 128, 1, 1, 1, 1, TileDataType_U8,
            TileLayout_RowMajor, source_mask);
        InstallRelativeTileFixture(0, 0);
        WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80 + pe_number);
        WriteGPR(2, Zeros{PTO_XLEN} + 2);
    end;
    SelectExecutionContext(0, 1);
    for index = 1 to 15 do
        ConfigureTileForMask(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, '0100');
        WriteTileElement(index as TileIndex, 0, 0,
            Zeros{PTO_XLEN} + index);
    end;

    PrepareGMOVSquashPE(0, 0x400);
    let first_pe0 = ExecuteBundleTileOperation(); assert first_pe0;
    PrepareGMOVSquashPE(0, 0x440);
    let second_pe0 = ExecuteBundleTileOperation(); assert second_pe0;

    PrepareGMOVSquashPE(1, 0x400);
    let faulted = ExecuteBundleTileOperation();
    assert !faulted && _LastFault == Fault_TileAllocation;
    let stale_ordinal = _BundleTileBindings[[0]].gmov_selection_ordinal;
    let stale_domain = _BundleExecutionDomainToken;
    assert stale_ordinal > 0;
    SaveTrapContext(0, 0);
    EnterBundleExecutionDomainSquashEvent(stale_domain);

    SelectExecutionContext(0, 0);
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined &&
           ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x82;
    SelectExecutionContext(0, 1);
    ReleaseTile(15);
    PrepareGMOVSquashPE(1, 0x440);
    let second_pe1 = ExecuteBundleTileOperation();
    assert second_pe1 && _LastFault == Fault_None;
    SelectExecutionContext(0, 2);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '1';

    SelectExecutionContext(0, 1);
    let recovered = RecoverTrapContext(0); assert recovered;
    ClearFault();
    let stale_retry = ExecuteBundleTileOperation();
    assert !stale_retry && _LastFault == Fault_None &&
           _BundleTileBindings[[0]].gmov_selection_ordinal == stale_ordinal;
    SelectExecutionContext(0, 2);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '1';
    return 0;
end;
