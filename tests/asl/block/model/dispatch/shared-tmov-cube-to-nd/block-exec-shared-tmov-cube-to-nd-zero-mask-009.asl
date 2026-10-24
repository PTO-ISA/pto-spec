// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-ZERO-MASK-009","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-BSTART-TMOV-SHARED-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"execution","summary":"zero-PE_MASK CUBE-to-ND TMOV preserves its strict no-effect precedence","pass_condition":"A valid M32 source and existing published Shared parent pass the encoded Layout-24 header with zero participation; no Shared generation opens, no source payload is consumed, the prior parent remains unchanged, and no GM event or fault occurs","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}

pure func ZeroMaskStart() => bits(64)
begin
    return Zeros{64} + 0x38211181;
end;

pure func ZeroMaskDATR() => bits(64)
begin
    return Zeros{64} + 0x01f01c23;
end;

pure func ZeroMaskSharedBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4} + 8;
    instruction[11:9] = '000';
    return instruction;
end;

pure func ZeroMaskAssemble() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 6;
    return instruction;
end;

pure func ZeroMaskSourceBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '000';
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 55) as SharedTileID;
    ConfigureTileForMask(10, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, '1111');
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    let configured = ConfigureCubeTileForMask(0, 4096, 32, 128,
        TileDataType_E4M3, TileLayout_CUBE_M32, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    for row = 0 to 31 looplimit 65536 do
        for column = 0 to 127 looplimit 65536 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + 1 + row * 13 + column * 7);
        end;
    end;
    assert TilePayloadIntactForMask(0, '1111');
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity,
        0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    StartMemoryEventCapture(0);
    let start_status = ExecuteCommandInstruction(ZeroMaskStart(), 32);
    let datr_status = ExecuteCommandInstruction(ZeroMaskDATR(), 32);
    let shared_status = ExecuteCommandInstruction(
        ZeroMaskSharedBinding(shared_id as bits(6)), 32);
    let assemble_status = ExecuteCommandInstruction(ZeroMaskAssemble(), 32);
    let source_status = ExecuteCommandInstruction(ZeroMaskSourceBinding(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           assemble_status == CommandExecution_Executed &&
           source_status == CommandExecution_Executed;
    let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    let generation_index = SharedTileArrayIndex(shared_id);
    assert stopped == CommandExecution_Executed && _LastFault == Fault_None &&
           !BundleSharedGenerationOpen(shared_id) &&
           _SharedGenerations[[generation_index]].next_operation_ordinal == 0 &&
           SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.data_type == TileDataType_U8 &&
           TileReadLogicalElement(SharedTileRecord(shared_id).tile, 0) ==
               Zeros{PTO_XLEN} + 0x5a &&
           TilePayloadIntactForMask(0, '1111') && _MemoryEventCount == 0;
    return 0;
end;
