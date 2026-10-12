// PTO-TEST: {"id":"PTO-AVS-BLOCK-SOURCE-LIFETIME-OCCURRENCE-ORDER-004","source":"asl/block/model/state/source-lifetime.asl","requirements":["PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"Concurrent encoded last-use occurrences join the earliest ordinal and retain one generation until every occurrence completes.","pass_condition":"PE0 opens two same-site occurrences, later PEs join the first ordinal before the second, completing the first does not release the shared generation, completing the second releases it once, and slot reuse allocates a larger ordinal for a republished generation.","related_sources":["asl/block/operands/B.IOS.asl","asl/tile/model/state/shared-registers.asl"]}
pure func OrderedLifetimeStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001'; instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func OrderedLifetimeBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 15; instruction[11:9] = '111';
    instruction[26] = '1'; return instruction;
end;

pure func OrderedLifetimeAddress() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2; return instruction;
end;

func RunOrderedLifetimePE(pe: MemoryAgentId, address: integer) => integer
begin
    SelectExecutionContext(0, pe); ClearBundleHeaderState();
    WriteBPC(Zeros{PTO_XLEN} + 0x380); WriteTPC(Zeros{PTO_XLEN} + 0x380);
    WriteGPR(2, Zeros{PTO_XLEN} + address);
    let started = ExecuteCommandInstruction(OrderedLifetimeStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(OrderedLifetimeBinding(), 32);
    let addressed = ExecuteCommandInstruction(OrderedLifetimeAddress(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           addressed == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation(); assert completed;
    return _BundleSharedBindings[[0]].source_lifetime_ordinal;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x380);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x51);
    let shared_id = (Zeros{6} + 15) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    let first = RunOrderedLifetimePE(0, 8);
    let second = RunOrderedLifetimePE(0, 16);
    assert first > 0 && second > first;
    for pe = 1 to 3 do
        let joined = RunOrderedLifetimePE(pe as MemoryAgentId, 24 + pe * 8);
        assert joined == first;
    end;
    let after_first = SharedTileRecord(shared_id);
    assert after_first.payload_live;
    for pe = 1 to 3 do
        let joined = RunOrderedLifetimePE(pe as MemoryAgentId, 64 + pe * 8);
        assert joined == second;
    end;
    let after_second = SharedTileRecord(shared_id);
    assert !after_second.payload_live;

    SelectExecutionContext(0, 0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x52);
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    let reused_slot = RunOrderedLifetimePE(0, 104);
    assert reused_slot > second;
    let republished = SharedTileRecord(shared_id);
    assert republished.payload_live;
    return 0;
end;
