// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-OBLIGATION-SCALAR-FAULT-RETRY-001","source":"asl/arch/memory-model/gm-obligations.asl","requirements":["PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-MEMORY-MODEL-REPLAY-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001","PTO-ARCH-CORE-SYNCHRONIZATION-001"],"kind":"state-transition","summary":"a fetched older scalar request remains fault-capable through precise recovery and retains identity on retry","pass_condition":"the real fetched LD faults before effects, its obligation blocks arrival, recovery retries the same request identity, and only successful completion clears the arrival boundary","related_sources":["asl/arch/dispatch/top-level.asl","asl/scalar/model/dispatch/top-level.asl","asl/scalar/agu/LD.asl","asl/arch/state/trap-context.asl"]}
func WriteScalarFaultRetryProgram(entry: Word)
begin
    // ld r5, [r2 + r0] (L32), followed by the accepted SYS envelope.
    WriteMemoryByte(entry, Zeros{8} + 0x89);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x32);
    WriteMemoryByte(entry + 2, Zeros{8} + 0x01);
    WriteMemoryByte(entry + 3, Zeros{8});
    WriteMemoryByte(entry + 4, Zeros{8} + 0x81);
    WriteMemoryByte(entry + 5, Zeros{8} + 0x10);
    WriteMemoryByte(entry + 6, Zeros{8});
    WriteMemoryByte(entry + 7, Zeros{8});
    WriteMemoryByte(entry + 8, Zeros{8} + 0x2b);
    WriteMemoryByte(entry + 9, Zeros{8} + 0xa0);
    WriteMemoryByte(entry + 10, Zeros{8} + 0x30);
    WriteMemoryByte(entry + 11, Zeros{8} + 0x03);
    WriteMemoryByte(entry + 12, Zeros{8} + 1);
    WriteMemoryByte(entry + 13, Zeros{8});
    WriteMemoryByte(entry + 14, Zeros{8});
    WriteMemoryByte(entry + 15, Zeros{8});
end;

func TestFetchedScalarFaultBlocksArrivalAndRetryKeepsIdentity()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x200;
    WriteScalarFaultRetryProgram(entry);
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    SetCurrentACR(2);
    WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteGPR(2, Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    let invocation = _CurrentKernelInvocation;
    StartMemoryEventCapture(0);

    let fault_status = ExecuteNextPTOInstruction();
    assert fault_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _MemoryEventCount == 0;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x55;
    let faulted = _GMObligations[[0]][[0]][[0]];
    assert faulted.active;
    assert faulted.invocation == invocation;
    assert faulted.instruction_pc == entry;
    assert faulted.request_class == GMRequest_Scalar;
    assert faulted.encoded_request[31:0] ==
        '00000000000000010011001010001001';
    assert faulted.state == GMObligation_Faulted;
    assert faulted.may_fault;
    assert !CoreGMObligationsPermitArrival(0, 0, invocation, 16);

    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert ReadTPC() == entry;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x300, Zeros{8} + 0x78);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x301, Zeros{8} + 0x56);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x302, Zeros{8} + 0x34);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x303, Zeros{8} + 0x12);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x304, Zeros{8} + 0xef);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x305, Zeros{8} + 0xcd);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x306, Zeros{8} + 0xab);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x307, Zeros{8} + 0x90);

    let retry_status = ExecuteNextPTOInstruction();
    assert retry_status == PTOInstruction_Executed;
    assert ReadTPC() == entry + 4;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x90abcdef12345678;
    let retried = _GMObligations[[0]][[0]][[0]];
    assert retried.identity == faulted.identity;
    assert retried.invocation == faulted.invocation;
    assert retried.instruction_pc == faulted.instruction_pc;
    assert retried.submission_order == faulted.submission_order;
    assert retried.state == GMObligation_Completed;
    assert retried.base_address == Zeros{PTO_XLEN} + 0x300;
    assert !retried.may_fault;
    assert CoreGMObligationsPermitArrival(0, 0, invocation, 16);
    assert CoreGMObligationsComplete(0, 0, invocation, 16);

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let barrier_status = ExecuteNextPTOInstruction();
    assert barrier_status == PTOInstruction_Blocked;
    assert ReadTPC() == entry + 8;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert !_CoreSyncRecords[[0]][[0]].released;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    TestFetchedScalarFaultBlocksArrivalAndRetryKeepsIdentity();
    return 0;
end;
