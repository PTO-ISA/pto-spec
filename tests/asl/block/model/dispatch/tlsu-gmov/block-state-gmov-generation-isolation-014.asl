// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-GENERATION-ISOLATION-014","source":"asl/block/model/dispatch/tlsu-gmov.asl","requirements":["PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-BSTART-GMOV-COLLECTIVE-001"],"kind":"state-transition","summary":"an old GMOV completion cannot consume a replacement payload generation at the same peer tile index","pass_condition":"PE0 captures and completes one half of an old generation, replacing the peer payload makes PE1 reject the stale snapshot while preserving the new data, and a next-site encoded occurrence consumes the replacement only after both selected PEs finish","related_sources":["asl/block/model/state/source-lifetime.asl","asl/arch/state/pe-execution-context.asl","asl/tile/model/state/allocation.asl"]}
pure func GMOVGenerationStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27; return instruction;
end;

pure func GMOVGenerationBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x04005013;
    instruction[18:15] = '0001'; instruction[11:9] = '101';
    instruction[19] = '1'; instruction[26] = '1'; return instruction;
end;

pure func GMOVGenerationPeer() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2; return instruction;
end;

func PrepareGMOVGenerationPE(pe: MemoryAgentId, site: integer)
begin
    SelectExecutionContext(0, pe); ClearBundleHeaderState();
    WriteBPC(Zeros{PTO_XLEN} + site); WriteTPC(Zeros{PTO_XLEN} + site);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let start = ExecuteCommandInstruction(GMOVGenerationStart(), 32);
    let binding = ExecuteCommandInstruction(GMOVGenerationBinding(), 32);
    let peer = ExecuteCommandInstruction(GMOVGenerationPeer(), 32);
    assert start == CommandExecution_Executed &&
           binding == CommandExecution_Executed &&
           peer == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x340);
    assert launched == KernelLifecycle_Started;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        var source_mask = Zeros{4};
        source_mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
        ConfigureTileForMask(0, 128, 1, 1, 1, 1, TileDataType_U8,
            TileLayout_RowMajor, source_mask);
        InstallRelativeTileFixture(0, 0);
        WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x70 + pe_number);
        WriteGPR(2, Zeros{PTO_XLEN} + 2);
    end;

    PrepareGMOVGenerationPE(0, 0x340);
    let first = ExecuteBundleTileOperation(); assert first;
    SelectExecutionContext(0, 2);
    let old_epoch = LocalTilePayloadGeneration(2, 0);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '1';
    ReleaseTile(0);
    ConfigureTileForMask(0, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, '0010');
    InstallRelativeTileFixture(0, 0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xa2);
    let replacement_epoch = LocalTilePayloadGeneration(2, 0);
    assert replacement_epoch > old_epoch;

    PrepareGMOVGenerationPE(1, 0x340);
    let stale = ExecuteBundleTileOperation();
    assert !stale && _LastFault == Fault_TileLegality;
    SelectExecutionContext(0, 2);
    assert _TilePayloadLiveMasks[[0]][PTOPEMaskBitOfPEIdentity(2)] == '1' &&
           ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xa2;

    var new_lifetime_ordinal: integer = 0;
    var new_selection_ordinal: integer = 0;
    for pe_number = 0 to 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        if pe_number == 1 then
            let recovered = RecoverTrapContext(CurrentACR());
            assert recovered;
        end;
        ClearFault();
        PrepareGMOVGenerationPE(pe, 0x3a0);
        let completed = ExecuteBundleTileOperation(); assert completed;
        if pe_number == 0 then
            new_lifetime_ordinal =
                _BundleTileBindings[[0]].source0_lifetime_ordinal;
            new_selection_ordinal =
                _BundleTileBindings[[0]].gmov_selection_ordinal;
            assert new_lifetime_ordinal > 0 && new_selection_ordinal > 0;
        else
            assert _BundleTileBindings[[0]].source0_lifetime_ordinal ==
                       new_lifetime_ordinal &&
                   _BundleTileBindings[[0]].gmov_selection_ordinal ==
                       new_selection_ordinal;
        end;
        SelectExecutionContext(0, 2);
        if pe_number == 0 then
            assert _TilePayloadLiveMasks[[0]][
                PTOPEMaskBitOfPEIdentity(2)] == '1';
        else
            assert _TilePayloadLiveMasks[[0]][
                PTOPEMaskBitOfPEIdentity(2)] == '0';
        end;
    end;
    return 0;
end;
