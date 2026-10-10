// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-PEER-LAST-USE-011","source":"asl/block/model/dispatch/tlsu-gmov.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001","PTO-BSTART-GMOV-COLLECTIVE-001","PTO-GMOV-CORE4-PEER-001"],"kind":"state-transition","summary":"encoded GMOV resolves a relative source in each selected peer bank and retires repeated-peer last-use only after every selected destination completes","pass_condition":"different private T#1 mappings supply the peer-selected payload, a repeated peer remains live after its first consumer and retires after its slower second consumer, an unselected peer remains live, and destinations publish only for selected PEs","related_sources":["asl/block/model/dispatch/tlsu-gmov.asl","asl/block/model/operands/tile-bindings.asl","asl/arch/state/pe-execution-context.asl"]}
pure func GMOVPeerLastUseStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVPeerLastUseBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '110';
    instruction[8:7] = '00';
    instruction[19] = '1';
    instruction[25:20] = Zeros{6};
    instruction[26] = '1';
    return instruction;
end;

pure func GMOVPeerLastUsePeer() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func ExecuteGMOVPeerLastUsePE(pe: MemoryAgentId,
                              peer: integer {0..3},
                              expected: integer {0..255},
                              selected: boolean)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    WriteGPR(2, Zeros{PTO_XLEN} + peer);
    let start = ExecuteCommandInstruction(GMOVPeerLastUseStart(), 32);
    let binding = ExecuteCommandInstruction(GMOVPeerLastUseBinding(), 32);
    let peers = ExecuteCommandInstruction(GMOVPeerLastUsePeer(), 32);
    assert start == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;
    assert peers == CommandExecution_Executed;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !_BundleActive;
    if selected then
        assert _Tiles[[0]].allocated && _Tiles[[0]].contents_defined;
        assert ReadTileElement(0 as TileIndex, 0, 0) ==
            Zeros{PTO_XLEN} + expected;
    else
        assert !_Tiles[[0]].allocated;
    end;
end;

func AssertGMOVPeerSourceLive(pe: MemoryAgentId,
                              source: TileIndex,
                              expected_live: boolean)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    if expected_live then
        assert _TilePayloadLiveMasks[[source]] != Zeros{4};
    else
        assert _TilePayloadLiveMasks[[source]] == Zeros{4};
    end;
    assert RelativeTileDestinationPublished(source);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x240);
    assert launched == KernelLifecycle_Started;
    var sources: array [[PTO_MODEL_MEMORY_AGENTS]] of TileIndex;
    sources[[0]] = 4;
    sources[[1]] = 5;
    sources[[2]] = 7;
    sources[[3]] = 8;
    var peers: array [[PTO_MODEL_MEMORY_AGENTS]] of integer {0..3};
    peers[[0]] = 2;
    peers[[1]] = 2;
    peers[[2]] = 2;
    peers[[3]] = 3;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
        var source_mask = Zeros{4};
        source_mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
        let source = sources[[pe_number]];
        ConfigureTileForMask(source, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, source_mask);
        InstallRelativeTileFixture(0, source);
        WriteTileElement(source, 0, 0,
            Zeros{PTO_XLEN} + (0x40 + pe_number));
        WriteGPR(2, Zeros{PTO_XLEN} + peers[[pe_number]]);
    end;

    // PE0 and PE2 both consume PE2:T#1.  PE2 is deliberately last so the
    // first completed destination cannot retire the shared source early.
    ExecuteGMOVPeerLastUsePE(0, 2, 0x42, TRUE);
    AssertGMOVPeerSourceLive(2, sources[[2]], TRUE);
    ExecuteGMOVPeerLastUsePE(1, 2, 0x42, TRUE);
    AssertGMOVPeerSourceLive(2, sources[[2]], TRUE);
    ExecuteGMOVPeerLastUsePE(3, 3, 0x43, FALSE);
    AssertGMOVPeerSourceLive(3, sources[[3]], TRUE);
    ExecuteGMOVPeerLastUsePE(2, 2, 0x42, TRUE);
    AssertGMOVPeerSourceLive(2, sources[[2]], FALSE);

    // Source lifetime effects apply to the selected peer banks, never to the
    // executing destination PE's differently ordered T hand.
    AssertGMOVPeerSourceLive(0, sources[[0]], TRUE);
    AssertGMOVPeerSourceLive(1, sources[[1]], TRUE);
    return 0;
end;
