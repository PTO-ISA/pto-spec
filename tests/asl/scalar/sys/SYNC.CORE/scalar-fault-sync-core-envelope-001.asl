// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYNC-CORE-ENVELOPE-REJECT-001","source":"asl/scalar/sys/SYNC.CORE.asl","requirements":["PTO-SYNC-CORE-DECISION-BINDING-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-ARCH-CORE-SYNCHRONIZATION-001"],"kind":"fault","summary":"wrong kind or transfer, surplus body operation, malformed stop and unfetchable stop reject before SYNC.CORE arrival","pass_condition":"actual fetched forms fail with their existing BundleControl or instruction-fetch fault and do not allocate an arrival record; handler dispatch is also rejected before collective effects","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/arch/dispatch/top-level.asl"]}
func WriteEnvelopeWord(address: Word, value: bits(32))
begin
    WriteMemoryByte(address, value[7:0]);
    WriteMemoryByte(address + 1, value[15:8]);
    WriteMemoryByte(address + 2, value[23:16]);
    WriteMemoryByte(address + 3, value[31:24]);
end;

func WriteBarrierEnvelope(entry: Word, start_word: bits(32),
                          body_word: bits(32), stop_word: bits(32))
begin
    WriteEnvelopeWord(entry, start_word);
    WriteEnvelopeWord(entry + 4, body_word);
    WriteEnvelopeWord(entry + 8, stop_word);
end;

func AssertNoBarrierArrival(invocation: integer)
begin
    assert FindCoreSyncGenerationRecord(0, invocation, 0) ==
        PTO_MODEL_SYNC_GENERATIONS;
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        assert !_CoreSyncRecords[[0]][[slot]].valid ||
               _CoreSyncRecords[[0]][[slot]].arrived == Zeros{4};
    end;
end;

func TestWrongKindEnvelopeIsRejectedBeforeArrival()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x300;
    WriteBarrierEnvelope(entry, '00000000000000000001000000000001',
        '00000011001100001010000000101011',
        '00000000000000000000000000000001');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let invocation = _CurrentKernelInvocation;
    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let barrier_status = ExecuteNextPTOInstruction();
    assert barrier_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_BundleControl;
    AssertNoBarrierArrival(invocation);
end;

func TestWrongTransferEnvelopeIsRejectedBeforeArrival()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x340;
    WriteBarrierEnvelope(entry, '00000000000000000010000000000001',
        '00000011001100001010000000101011',
        '00000000000000000000000000000001');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let invocation = _CurrentKernelInvocation;
    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let barrier_status = ExecuteNextPTOInstruction();
    assert barrier_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_BundleControl;
    AssertNoBarrierArrival(invocation);
end;

func TestSurplusBodyOperationIsRejectedBeforeArrival()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x380;
    WriteEnvelopeWord(entry, '00000000000000000001000010000001');
    WriteEnvelopeWord(entry + 4, '00000000000000100000000000101011');
    WriteEnvelopeWord(entry + 8, '00000011001100001010000000101011');
    WriteEnvelopeWord(entry + 12, '00000000000000000000000000000001');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let invocation = _CurrentKernelInvocation;
    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let surplus_status = ExecuteNextPTOInstruction();
    assert surplus_status == PTOInstruction_Executed;
    let barrier_status = ExecuteNextPTOInstruction();
    assert barrier_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_BundleControl;
    AssertNoBarrierArrival(invocation);
end;

func TestMalformedStopIsRejectedBeforeArrival()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x3c0;
    WriteBarrierEnvelope(entry, '00000000000000000001000010000001',
        '00000011001100001010000000101011',
        '00000000000000000000000000000101');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let invocation = _CurrentKernelInvocation;
    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let barrier_status = ExecuteNextPTOInstruction();
    assert barrier_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_BundleControl;
    AssertNoBarrierArrival(invocation);
end;

func TestUnfetchableStopIsRejectedBeforeArrival()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 8);
    WriteEnvelopeWord(entry, '00000000000000000001000010000001');
    WriteEnvelopeWord(entry + 4, '00000011001100001010000000101011');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let invocation = _CurrentKernelInvocation;
    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let barrier_status = ExecuteNextPTOInstruction();
    assert barrier_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_InstructionPage;
    AssertNoBarrierArrival(invocation);
end;

func TestHandlerCannotEnterEncodedBarrier()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x400;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let invocation = _CurrentKernelInvocation;
    _CurrentMemoryOrigin = MemoryEventOrigin_Handler;
    var instruction: bits(48) =
        ZeroExtend{48}('00000011001100001010000000101011');
    let handler_status = ExecuteScalarInstruction(instruction, 32);
    assert handler_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    AssertNoBarrierArrival(invocation);
end;

func main() => integer
begin
    TestWrongKindEnvelopeIsRejectedBeforeArrival();
    TestWrongTransferEnvelopeIsRejectedBeforeArrival();
    TestSurplusBodyOperationIsRejectedBeforeArrival();
    TestMalformedStopIsRejectedBeforeArrival();
    TestUnfetchableStopIsRejectedBeforeArrival();
    TestHandlerCannotEnterEncodedBarrier();
    return 0;
end;
