// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-ABORT-011","source":"asl/block/model/operands/shared-generation-pe-requests.asl","requirements":["PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"execution","summary":"Kernel abort discards an incomplete encoded Shared candidate without erasing the published parent and permits a fresh invocation ordinal.","pass_condition":"A real PE0 B.ASSEMBLE LAST submission opens an incomplete Core candidate; abort closes only that invocation-owned candidate while preserving the prior published Shared value and ordinal allocator; a new invocation can begin a fresh candidate at the next ordinal.","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/state/shared-generation-state.asl"]}
pure func AbortSharedAssembleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func AbortSharedAssembleBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 19;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func AbortSharedAssembleModifier(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func AbortSharedTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func PrepareAbortSharedPE(pe: MemoryAgentId, epoch: integer)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x1000 + epoch * 0x10000 +
                (pe as integer {0..3}) * 0x100 + column);
    end;
    let start = ExecuteCommandInstruction(AbortSharedAssembleStart(), 32);
    let shared = ExecuteCommandInstruction(AbortSharedAssembleBinding(), 32);
    let assemble = ExecuteCommandInstruction(AbortSharedAssembleModifier(
        pe as integer {0..3}), 32);
    let tile = ExecuteCommandInstruction(AbortSharedTileBinding(), 32);
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
            Zeros{PTO_XLEN} + 0x5555 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');

    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    PrepareAbortSharedPE(0 as MemoryAgentId, 0);
    assert _CurrentModelCore == 0 && _CurrentMemoryAgent == 0 &&
           _CurrentKernelInvocation != 0 && _CurrentMemoryOrigin ==
               MemoryEventOrigin_Kernel;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    let index = SharedTileArrayIndex(shared_id);
    let first_ordinal = _SharedGenerations[[index]].operation_ordinal;
    assert first_ordinal == 1 &&
           _SharedGenerations[[index]].core_identity == 0 &&
           _SharedGenerations[[index]].invocation_identity ==
               _CurrentKernelInvocation &&
           _SharedGenerations[[index]].arrived_participants ==
               SharedGenerationPEBit(0 as MemoryAgentId) &&
           BundleSharedGenerationOpen(shared_id) &&
           BundleSharedGenerationRequestWaiting(0);
    assert ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x5555;

    let aborted = AbortKernelInvocation(0 as PTOModelCoreIdentity);
    assert aborted == KernelLifecycle_Started;
    assert !BundleSharedGenerationOpen(shared_id);
    assert ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x5555;

    let relaunched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert relaunched == KernelLifecycle_Started;
    PrepareAbortSharedPE(0 as MemoryAgentId, 1);
    assert _CurrentKernelInvocation !=
           _SharedGenerations[[index]].invocation_identity;
    let retry_tpc = ReadTPC();
    let retry = ExecuteCommandInstruction(Zeros{64}, 16);
    assert retry == CommandExecution_Executed && _LastFault == Fault_None &&
           ReadTPC() == retry_tpc && BundleSharedGenerationRequestWaiting(0);
    assert _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].operation_ordinal ==
               first_ordinal + 1 &&
           _SharedGenerations[[index]].arrived_participants ==
               SharedGenerationPEBit(0 as MemoryAgentId) &&
           _SharedGenerations[[index]].invocation_identity ==
               _CurrentKernelInvocation;
    assert ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x5555;
    return 0;
end;
