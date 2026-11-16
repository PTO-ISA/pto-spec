// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-LOCAL-ASSEMBLE-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"fault","summary":"reverse TMOV rejects B.ASSEMBLE attached to the Local destination before effects","pass_condition":"a decoded singleton Shared ND-to-CUBE bundle accepts Local B.ASSEMBLE INIT_LAST as a command descriptor but BSTOP rejects the reverse schema before Local allocation, Shared generation/publication change, or source-lifetime capture","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/operands/local-generation.asl","asl/block/model/state/source-lifetime.asl"]}

pure func SharedNDToCubeLocalAssembleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeLocalAssembleDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeLocalAssembleShared(shared_id: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '001';
    instruction[26] = '1';
    return instruction;
end;

pure func SharedNDToCubeLocalAssembleDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeLocalAssembleCommand() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 6;
    return instruction;
end;

pure func SharedNDToCubeLocalAssembleValue(row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 0x81234567 + row * 131 + column * 17;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x700);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeLocalAssembleValue(
                    row as integer {0..31}, column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 37) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let source_before = SharedTileRecord(shared_id);
    let capacity_before = TileCapacityInUseForPE(0);
    let lifetime_ordinal_before = _NextBundleSourceLifetimeOrdinal;

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeLocalAssembleStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeLocalAssembleDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeLocalAssembleShared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeLocalAssembleDestination(), 32);
    let assemble_status = ExecuteCommandInstruction(
        SharedNDToCubeLocalAssembleCommand(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed &&
           assemble_status == CommandExecution_Executed &&
           _BundleTileBindings[[0]].destination_assemble.valid &&
           !BundleSharedTMOVSharedNDToCubeSchemaLegal() &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    let source_after = SharedTileRecord(shared_id);
    var source_lifetime_found = FALSE;
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) then
            source_lifetime_found = TRUE;
        end;
    end;
    assert stop_status == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           !source_lifetime_found &&
           _NextBundleSourceLifetimeOrdinal == lifetime_ordinal_before &&
           TileCapacityInUseForPE(0) == capacity_before &&
           source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published &&
           source_after.whole_parent_ready == source_before.whole_parent_ready;
    return 0;
end;
