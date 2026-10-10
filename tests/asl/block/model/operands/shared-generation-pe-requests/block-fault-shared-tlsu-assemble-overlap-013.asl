// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-OVERLAP-013","source":"asl/block/model/operands/shared-generation-pe-requests.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"fault","summary":"An encoded overlapping PE contribution faults through the Shared B.ASSEMBLE owner and preserves the published parent.","pass_condition":"PE0 opens a real full-mask B.ASSEMBLE candidate; PE1's encoded request contributes the same CELL range and faults with TileLegality. The candidate is discarded by the existing fault owner, while the previously published Shared descriptor and payload remain unchanged.","related_sources":["asl/block/model/operands/shared-generation.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/gm-obligation-dispatch.asl"]}
pure func SharedOverlapStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedOverlapBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 19;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedOverlapAssemble() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func SharedOverlapTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func PrepareSharedOverlapPE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x4000 +
                (pe as integer {0..3}) * 0x100 + column);
    end;
    let start = ExecuteCommandInstruction(SharedOverlapStart(), 32);
    let shared = ExecuteCommandInstruction(SharedOverlapBinding(), 32);
    let assemble = ExecuteCommandInstruction(SharedOverlapAssemble(), 32);
    let tile = ExecuteCommandInstruction(SharedOverlapTileBinding(), 32);
    assert start == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           tile == CommandExecution_Executed &&
           _BundleSharedBindings[[0]].pe_mask == '1111';
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    ConfigureTile(1, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(1, 0, column,
            Zeros{PTO_XLEN} + 0x7777 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');
    let prior = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    PrepareSharedOverlapPE(0 as MemoryAgentId);
    let first_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert first_stop == CommandExecution_Executed && _LastFault == Fault_None;
    let index = SharedTileArrayIndex(shared_id);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].arrived_participants ==
               SharedGenerationPEBit(0 as MemoryAgentId) &&
           BundleSharedGenerationRequestWaiting(0) &&
           SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x7777;

    PrepareSharedOverlapPE(1 as MemoryAgentId);
    assert _CurrentModelCore == 0 && _CurrentMemoryAgent == 1;
    let overlapping_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert overlapping_stop != CommandExecution_Executed &&
           _LastFault == Fault_TileLegality;
    assert !BundleSharedGenerationOpen(shared_id) &&
           SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.capacity_bytes ==
               prior.tile.capacity_bytes &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x7777;
    return 0;
end;
