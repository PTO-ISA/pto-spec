// PTO-TEST: {"id":"PTO-AVS-ARCH-CORE-SYNC-ENCODED-BRANCH-BYPASS-001","source":"asl/arch/state/core-synchronization.asl","requirements":["PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-REQ-INSTRUCTION-DISPATCH-001"],"kind":"state-transition","summary":"an encoded per-PE control transfer that skips a valid SYNC.CORE envelope cannot arrive at its barrier","pass_condition":"three peers remain parked at the encoded barrier while a fourth follows its encoded JR target around the entire bundle, leaving the generation incomplete","related_sources":["asl/arch/dispatch/top-level.asl","asl/scalar/model/dispatch/top-level.asl","asl/scalar/sys/SYNC.CORE.asl"]}

func WriteBranchBypassProgram(entry: Word)
begin
    // JR r1; BSTART.SYS FALL; SYNC.CORE; BSTOP; continuation.
    WritePhysicalMemoryByte(entry, Zeros{8} + 0x27);
    WritePhysicalMemoryByte(entry + 1, Zeros{8} + 0xe0);
    WritePhysicalMemoryByte(entry + 2, Zeros{8});
    WritePhysicalMemoryByte(entry + 3, Zeros{8});
    WritePhysicalMemoryByte(entry + 4, Zeros{8} + 0x81);
    WritePhysicalMemoryByte(entry + 5, Zeros{8} + 0x10);
    WritePhysicalMemoryByte(entry + 6, Zeros{8});
    WritePhysicalMemoryByte(entry + 7, Zeros{8});
    WritePhysicalMemoryByte(entry + 8, Zeros{8} + 0x2b);
    WritePhysicalMemoryByte(entry + 9, Zeros{8} + 0xa0);
    WritePhysicalMemoryByte(entry + 10, Zeros{8} + 0x30);
    WritePhysicalMemoryByte(entry + 11, Zeros{8} + 0x03);
    WritePhysicalMemoryByte(entry + 12, Zeros{8} + 1);
    WritePhysicalMemoryByte(entry + 13, Zeros{8});
    WritePhysicalMemoryByte(entry + 14, Zeros{8});
    WritePhysicalMemoryByte(entry + 15, Zeros{8});
end;

func TestEncodedBranchBypassDoesNotArrive()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteBranchBypassProgram(entry);
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;

    // PE3 takes an encoded JR target past the complete SYNC envelope. PE0..2
    // take the same JR instruction to the envelope and must wait for PE3.
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        WriteGPR(1, if pe_number == 3 then entry + 16 else entry + 4);
        let branch_status = ExecuteNextPTOInstruction();
        assert branch_status == PTOInstruction_Executed;
        assert ReadTPC() == if pe_number == 3 then entry + 16 else entry + 4;
    end;

    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        let start_status = ExecuteNextPTOInstruction();
        assert start_status == PTOInstruction_Executed;
        assert ReadTPC() == entry + 8;
        let sync_status = ExecuteNextPTOInstruction();
        assert sync_status == PTOInstruction_Blocked;
        assert ReadTPC() == entry + 8;
    end;

    let slot = FindCoreSyncGenerationRecord(0, _CurrentKernelInvocation, 0);
    assert slot < PTO_MODEL_SYNC_GENERATIONS;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let bit_index = PTOPEMaskBitOfPEIdentity(pe_number);
        assert _CoreSyncRecords[[0]][[slot]].arrived[bit_index] == '1';
    end;
    let skipped_bit = PTOPEMaskBitOfPEIdentity(3);
    assert _CoreSyncRecords[[0]][[slot]].arrived[skipped_bit] == '0';
    assert !_CoreSyncRecords[[0]][[slot]].released;
    SelectExecutionContext(0, 3);
    assert ReadTPC() == entry + 16;
    assert _PEBarrierNextGeneration[[0]][[3]] == 0;

    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
end;

func main() => integer
begin
    TestEncodedBranchBypassDoesNotArrive();
    return 0;
end;
