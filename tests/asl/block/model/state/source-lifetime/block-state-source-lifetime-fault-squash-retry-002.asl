// PTO-TEST: {"id":"PTO-AVS-BLOCK-SOURCE-LIFETIME-FAULT-SQUASH-RETRY-002","source":"asl/block/model/state/source-lifetime.asl","requirements":["PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"An encoded Shared last-use fault does not complete its PE and a squashed captured domain cannot be revived from a saved context.","pass_condition":"PE0 completes without releasing the payload, PE1 faults after capture, recovery of its saved stale marker waits without completion after squash, and a fresh encoded request plus PE2 and PE3 complete the cohort exactly once.","related_sources":["asl/block/operands/B.IOS.asl","asl/block/model/operands/local-generation-squash.asl","asl/arch/state/trap-context.asl"]}
pure func LifetimeRetryStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001'; instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func LifetimeRetryBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 13; instruction[11:9] = '111';
    instruction[26] = '1'; return instruction;
end;

pure func LifetimeRetryAddress() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2; return instruction;
end;

pure func LifetimeReplacementStart() => bits(64)
begin
    var instruction = LifetimeRetryStart();
    instruction[24:20] = '00000'; return instruction;
end;

pure func LifetimeReplacementBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 13;
    instruction[18:15] = '0001'; instruction[11:9] = '001';
    return instruction;
end;

func PrepareLifetimeRetryPE(pe: MemoryAgentId, address: Word)
begin
    SelectExecutionContext(0, pe); ClearBundleHeaderState();
    WriteBPC(Zeros{PTO_XLEN} + 0x240);
    WriteTPC(Zeros{PTO_XLEN} + 0x240);
    WriteGPR(2, address);
    let started = ExecuteCommandInstruction(LifetimeRetryStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(LifetimeRetryBinding(), 32);
    let addressed = ExecuteCommandInstruction(LifetimeRetryAddress(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           addressed == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x240);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x71);
    let shared_id = (Zeros{6} + 13) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');

    PrepareLifetimeRetryPE(0, Zeros{PTO_XLEN} + 8);
    let first = ExecuteBundleTileOperation(); assert first;
    let after_first = SharedTileRecord(shared_id);
    assert after_first.payload_live;

    PrepareLifetimeRetryPE(1, Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES);
    let faulted = ExecuteBundleTileOperation();
    assert !faulted && _LastFault == Fault_DataPage;
    let stale_ordinal = _BundleSharedBindings[[0]].source_lifetime_ordinal;
    let stale_domain = _BundleExecutionDomainToken;
    let before_squash = SharedTileRecord(shared_id);
    assert stale_ordinal > 0 && before_squash.payload_live;
    EnterBundleExecutionDomainSquashEvent(stale_domain);
    let slot = FindBundleSourceLifetimeOrdinal(stale_ordinal);
    assert slot >= 0;
    let pe0_bit = PTOPEMaskBitOfPEIdentity(0);
    let pe1_bit = PTOPEMaskBitOfPEIdentity(1);
    assert _BundleSourceLifetimes[[slot]].completed_mask[pe0_bit] == '1' &&
           _BundleSourceLifetimes[[slot]].captured_mask[pe1_bit] == '0';
    let still_pinned = SharedSourceLifetimePinned(shared_id);
    assert still_pinned;

    // The unsquashed PE0 completion keeps the exact generation pinned. An
    // encoded replacement therefore waits before its GM read or publication.
    SelectExecutionContext(0, 0); ClearBundleHeaderState();
    _Memory[[64]] = Zeros{8} + 0x7a;
    WriteGPR(2, Zeros{PTO_XLEN} + 64);
    let replacement_start = ExecuteCommandInstruction(
        LifetimeReplacementStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let replacement_binding = ExecuteCommandInstruction(
        LifetimeReplacementBinding(), 32);
    let replacement_address = ExecuteCommandInstruction(
        LifetimeRetryAddress(), 32);
    assert replacement_start == CommandExecution_Executed &&
           replacement_binding == CommandExecution_Executed &&
           replacement_address == CommandExecution_Executed;
    let before_replacement = SharedTileRecord(shared_id);
    let replacement_waits = ExecuteBundleTileOperation();
    let after_replacement = SharedTileRecord(shared_id);
    assert !replacement_waits && _LastFault == Fault_None &&
           after_replacement.payload_generation ==
               before_replacement.payload_generation &&
           TileReadLogicalElement(after_replacement.tile, 0) ==
               Zeros{PTO_XLEN} + 0x71;

    SelectExecutionContext(0, 1);
    let recovered = RecoverTrapContext(0);
    assert recovered;
    ClearFault(); WriteGPR(2, Zeros{PTO_XLEN} + 16);
    let stale_retry = ExecuteBundleTileOperation();
    assert !stale_retry && _LastFault == Fault_None &&
           _BundleSharedBindings[[0]].source_lifetime_ordinal == stale_ordinal;
    let after_stale = SharedTileRecord(shared_id);
    assert after_stale.payload_live;

    for pe = 1 to 3 do
        PrepareLifetimeRetryPE(pe as MemoryAgentId,
            Zeros{PTO_XLEN} + 16 + pe * 8);
        let completed = ExecuteBundleTileOperation(); assert completed;
        assert _BundleSharedBindings[[0]].source_lifetime_ordinal ==
            stale_ordinal;
        let current = SharedTileRecord(shared_id);
        if pe < 3 then assert current.payload_live;
        else assert !current.payload_live; end;
    end;
    return 0;
end;
