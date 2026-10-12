// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-PRIVATE-FOURSTREAM-010","source":"asl/block/model/dispatch/tlsu-gmov.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-BSTART-GMOV-COLLECTIVE-001","PTO-GMOV-CORE4-PEER-001"],"kind":"execution","summary":"encoded four-stream GMOV reads each peer_tid-selected private source fragment","pass_condition":"all four real PE source banks are preflighted, then each selected PE copies the fragment from its private peer_tid into its own destination; source banks and GM history remain unchanged","related_sources":["asl/block/model/dispatch/tlsu-gmov.asl","asl/tile/model/memory/shared-movement.asl","asl/arch/state/pe-execution-context.asl"]}
pure func GMOVPrivateFourStreamStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVPrivateFourStreamBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    instruction[19] = '1';
    instruction[25:20] = Zeros{6};
    return instruction;
end;

pure func GMOVPrivateFourStreamPeer() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func ExecuteGMOVPrivateFourStreamPE(pe: MemoryAgentId,
                                    peer: integer {0..3})
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    WriteGPR(2, Zeros{PTO_XLEN} + peer);
    let start = ExecuteCommandInstruction(GMOVPrivateFourStreamStart(), 32);
    let binding = ExecuteCommandInstruction(
        GMOVPrivateFourStreamBinding(), 32);
    let peers = ExecuteCommandInstruction(GMOVPrivateFourStreamPeer(), 32);
    assert start == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;
    assert peers == CommandExecution_Executed;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert !_BundleActive;
    assert _Tiles[[0]].contents_defined;
    assert ReadTileElement(0 as TileIndex, 0, 0) ==
        Zeros{PTO_XLEN} + (0x40 +
            (pe as integer {0..3}));
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;
    assert ReadTileElement(1 as TileIndex, 0, 0) ==
        Zeros{PTO_XLEN} + (0x40 + peer);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launched == KernelLifecycle_Started;
    var peers: array [[PTO_MODEL_MEMORY_AGENTS]] of integer {0..3};
    peers[[0]] = 2;
    peers[[1]] = 0;
    peers[[2]] = 3;
    peers[[3]] = 1;
    StartMemoryEventCapture(0);
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
        var source_mask = Zeros{4};
        source_mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
        ConfigureTileForMask(0, 128, 1, 1, 1, 1, TileDataType_U8,
            TileLayout_RowMajor, source_mask);
        InstallRelativeTileFixture(0, 0);
        let source_value = Zeros{PTO_XLEN} + (0x40 + pe_number);
        WriteTileElement(0, 0, 0, source_value);
        WriteGPR(2, Zeros{PTO_XLEN} + peers[[pe_number]]);
    end;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        let peer = peers[[pe_number]];
        ExecuteGMOVPrivateFourStreamPE(pe, peer);
    end;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
