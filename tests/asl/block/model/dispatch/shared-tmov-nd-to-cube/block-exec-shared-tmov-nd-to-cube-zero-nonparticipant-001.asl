// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-ZERO-NONPARTICIPANT-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001","PTO-TMOV-SHARED-ND-TO-CUBE-001"],"kind":"execution","summary":"zero-mask and nonparticipating reverse TMOV requests do not inspect a missing source or private offset","pass_condition":"PE_MASK=0000 completes without source publication, GPR range validation, lifetime capture, allocation, or fault; a PE outside the selected mask likewise completes without reading its deliberately out-of-range GPR, allocating a CUBE, capturing lifetime, or faulting","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/shared-bindings.asl"]}

pure func SharedNDToCubeMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeMaskDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeMaskSource(shared_id: bits(6),
    pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func SharedNDToCubeMaskSubview() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = Zeros{4} + 6;
    return instruction;
end;

pure func SharedNDToCubeMaskDestination(pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

readonly func SharedNDToCubeMaskHasDestination() => boolean
begin
    for tile = 0 to 63 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func SharedNDToCubeMaskHasLifetime(shared_id: SharedTileID)
    => boolean
begin
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func ExecuteSharedNDToCubeMaskedPE(pe: MemoryAgentId,
    pe_mode: bits(3), shared_id: SharedTileID)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    WriteTPC(Zeros{PTO_XLEN} + 0x480);
    WriteGPR(2, Zeros{PTO_XLEN} + 65535);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeMaskStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeMaskDATR(), 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeMaskSource(shared_id as bits(6), pe_mode), 32);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeMaskSubview(), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeMaskDestination(pe_mode), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stopped == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           !SharedNDToCubeMaskHasDestination() &&
           !SharedNDToCubeMaskHasLifetime(shared_id) &&
           !SharedTileRecord(shared_id).descriptor_valid;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x480);
    assert launched == KernelLifecycle_Started;
    let shared_id = (Zeros{6} + 45) as SharedTileID;
    ExecuteSharedNDToCubeMaskedPE(0 as MemoryAgentId, '000', shared_id);
    ExecuteSharedNDToCubeMaskedPE(1 as MemoryAgentId, '001', shared_id);
    return 0;
end;
