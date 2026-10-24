// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-BSTART-INCOMPLETE-PREDECESSOR-001","source":"asl/block/model/dispatch/start.asl","requirements":["PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-B-ASSEMBLE-SPECULATION-001"],"kind":"state-transition","summary":"a following encoded BSTART preserves an incomplete no-fault Shared predecessor and reports the legacy executed status","pass_condition":"a real launched PE0 Shared TMOV contribution leaves its predecessor, BARG, operation descriptor, execution domain, and TPC unchanged when the following encoded BSTART cannot complete the Shared cohort; status remains Executed with no fault, no successor is installed, and the prior published Shared payload remains visible","related_sources":["asl/block/model/dispatch/start.asl","asl/block/model/commit/validation.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl"]}

pure func SharedPredecessorStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedPredecessorBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 19;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedPredecessorModifier(offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

pure func SharedPredecessorTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func PrepareSharedPredecessor()
begin
    ConfigureTile(0, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(0, 0, column,
            Zeros{PTO_XLEN} + 0x11000 + column);
    end;
    let start = ExecuteCommandInstruction(SharedPredecessorStart(), 32);
    let shared = ExecuteCommandInstruction(SharedPredecessorBinding(), 32);
    let assemble = ExecuteCommandInstruction(
        SharedPredecessorModifier(0), 32);
    let tile = ExecuteCommandInstruction(
        SharedPredecessorTileBinding(), 32);
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
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(1, 512, 4, 16, 1, 16, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 15 do
        WriteTileElement(1, 0, column,
            Zeros{PTO_XLEN} + 0x5555 + column);
    end;
    InstallSharedTile(shared_id, _Tiles[[1]], '1111');
    assert SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x5555;

    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    PrepareSharedPredecessor();
    assert _BundleActive && _LastFault == Fault_None;
    let old_domain = _BundleExecutionDomainToken;
    let old_tpc = ReadTPC();
    let old_bpc = ReadBPC();
    let old_barg_kind = _BARG.block_type;
    let old_barg_transfer = _BARG.transfer_type;
    let old_barg_taken = _BARG.taken;
    let old_barg_bpcn = _BARG.bpcn;
    let old_start = _BundleStartEncodedInstruction;
    let old_operation_valid = _BundleOperation.valid;
    let old_operation_form = _BundleOperation.form_identity;
    let old_operation_class = _BundleOperation.operation_class;
    let old_operation_selector = _BundleOperation.selector;
    let old_operation_data_type = _BundleOperation.data_type;
    let index = SharedTileArrayIndex(shared_id);
    StartMemoryEventCapture(0);

    // This is a real encoded BSTART at the active Shared predecessor boundary.
    let status = ExecuteCommandInstruction(SharedPredecessorStart(), 32);

    assert status == CommandExecution_Executed &&
           _LastFault == Fault_None;
    assert _BundleActive &&
           _BundleExecutionDomainToken == old_domain &&
           ReadTPC() == old_tpc && ReadBPC() == old_bpc &&
           _BARG.block_type == old_barg_kind &&
           _BARG.transfer_type == old_barg_transfer &&
           _BARG.taken == old_barg_taken &&
           _BARG.bpcn == old_barg_bpcn;
    assert _BundleStartEncodedInstruction == old_start &&
           _BundleOperation.valid == old_operation_valid &&
           _BundleOperation.form_identity == old_operation_form &&
           _BundleOperation.operation_class == old_operation_class &&
           _BundleOperation.selector == old_operation_selector &&
           _BundleOperation.data_type == old_operation_data_type;
    assert BundleSharedGenerationRequestWaiting(0) &&
           _SharedGenerations[[index]].open &&
           !_SharedGenerations[[index]].published &&
           SharedTilePublished(shared_id) &&
           ReadSharedTileWord(shared_id, 0 as PackedTileElementIndex) ==
               Zeros{PTO_XLEN} + 0x5555 &&
           _MemoryEventCount == 0;
    return 0;
end;
