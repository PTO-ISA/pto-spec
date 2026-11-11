// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-OBLIGATION-RETRY-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-FETCH-001","PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001","PTO-INST-SCALAR-LW","PTO-INST-SCALAR-HL-LDIP"],"kind":"state-transition","summary":"A scoped ordinary-load fault and retry retain the same outer request/scope occurrence, then a scoped pair load completes with exact obligation metadata.","pass_condition":"Retry reuses one identity and encoded carrier until one successful Scalar event completes it; the pair's two component events share the carrier scope while one separate obligation reaches Completed.","related_sources":["asl/arch/memory-model/gm-obligations.asl","asl/arch/state/trap-context.asl","asl/scalar/model/dispatch/top-level.asl","asl/scalar/model/agu/memory.asl"]}

func BuildScopedCarrier(payload: bits(48), length_code: bits(2),
                        scope_code: bits(2)) => bits(64)
begin
    var carrier: bits(64) = Zeros{64};
    carrier[63:16] = payload;
    carrier[11:10] = length_code;
    carrier[9:8] = scope_code;
    carrier[7:0] = Zeros{8} + 0x1f;
    return carrier;
end;

func WriteScopedCarrier(address: Word, carrier: bits(64))
begin
    WriteMemoryByte(address, carrier[7:0]);
    WriteMemoryByte(address + 1, carrier[15:8]);
    WriteMemoryByte(address + 2, carrier[23:16]);
    WriteMemoryByte(address + 3, carrier[31:24]);
    WriteMemoryByte(address + 4, carrier[39:32]);
    WriteMemoryByte(address + 5, carrier[47:40]);
    WriteMemoryByte(address + 6, carrier[55:48]);
    WriteMemoryByte(address + 7, carrier[63:56]);
end;

func TestScopedOrdinaryRequestRetriesWithSameOuterOccurrence()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let aligned_address = Zeros{PTO_XLEN} + 0x940;
    let fault_address = aligned_address + 1;
    let value = Zeros{PTO_XLEN} + 0x53a4c5d6;
    let invocation_started = LaunchKernelInvocation(0, entry);
    assert invocation_started == KernelLifecycle_Started;
    var load: bits(48) = Zeros{48} + 0x2009;
    load[11:7] = Zeros{5} + 3;
    load[19:15] = Zeros{5} + 1;
    let carrier = BuildScopedCarrier(load, '01', '10');
    WriteScopedCarrier(entry, carrier);
    Store(aligned_address, 4, value);
    SelectExecutionContext(0, 0);
    WriteTPC(entry);
    WriteGPR(1, fault_address);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xaaaa);
    _CurrentProgramOrder = 9;
    SetCurrentACR(2);
    WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(aligned_address, 4, value);

    let failed = ExecuteNextPTOInstruction();
    assert failed == PTOInstruction_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _TrapContexts[[1]].tpc == entry;
    assert _MemoryEventCount == 1;
    let failed_obligation = _GMObligations[[0]][[0]][[0]];
    assert failed_obligation.active;
    assert failed_obligation.identity == 0;
    assert failed_obligation.invocation == _KernelInvocationByCore[[0]];
    assert failed_obligation.request_class == GMRequest_Scalar;
    assert failed_obligation.shareability == MemoryShareability_InterCore;
    assert failed_obligation.encoded_request == carrier;
    assert failed_obligation.instruction_pc == entry;
    assert failed_obligation.submission_order == 10;
    assert failed_obligation.state == GMObligation_Faulted;
    assert _NextGMObligationIdentity[[0]][[0]] == 1;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    WriteGPR(1, aligned_address);
    WriteTPC(entry);
    RetryGMObligation(0, 0, 0 as GMObligationIndex);
    let submitted_obligation = _GMObligations[[0]][[0]][[0]];
    assert submitted_obligation.identity == failed_obligation.identity;
    assert submitted_obligation.encoded_request == carrier;
    assert submitted_obligation.shareability == MemoryShareability_InterCore;
    assert submitted_obligation.state == GMObligation_Submitted;

    let retried = ExecuteNextPTOInstruction();
    assert retried == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(3) == value;
    assert _MemoryEventCount == 2;
    let completed_obligation = _GMObligations[[0]][[0]][[0]];
    assert completed_obligation.identity == failed_obligation.identity;
    assert completed_obligation.invocation == failed_obligation.invocation;
    assert completed_obligation.request_class == GMRequest_Scalar;
    assert completed_obligation.shareability == MemoryShareability_InterCore;
    assert completed_obligation.encoded_request == carrier;
    assert completed_obligation.instruction_pc == entry;
    assert completed_obligation.submission_order == 10;
    assert completed_obligation.state == GMObligation_Completed;
    assert _NextGMObligationIdentity[[0]][[0]] == 1;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_InterCore;
    assert _MemoryEvents[[1]].read_value == value;
    assert _MemoryEvents[[1]].read_from == 0;
    assert MemoryExecutionAllowedRC();
end;

func TestScopedPairHasOneCompletedOuterObligation()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let pair_entry = entry + 0x40;
    let address = Zeros{PTO_XLEN} + 0xa00;
    let first_value = Zeros{PTO_XLEN} + 0x1111222233334444;
    let second_value = Zeros{PTO_XLEN} + 0x5555666677778888;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    var load_pair: bits(48) = Zeros{48} + 0x3019001e;
    load_pair[27:23] = Zeros{5} + 3;
    load_pair[15:11] = Zeros{5} + 4;
    load_pair[35:31] = Zeros{5} + 1;
    let carrier = BuildScopedCarrier(load_pair, '10', '01');
    WriteScopedCarrier(pair_entry, carrier);
    Store(address, 8, first_value);
    Store(address + 8, 8, second_value);
    SelectExecutionContext(0, 0);
    WriteTPC(pair_entry);
    WriteGPR(1, address);
    _CurrentProgramOrder = 12;
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(address, 8, first_value);
    - = AddInitialWriteEvent(address + 8, 8, second_value);

    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Executed;
    assert ReadTPC() == pair_entry + 8;
    assert ReadGPR(3) == first_value;
    assert ReadGPR(4) == second_value;
    assert _MemoryEventCount == 4;
    let obligation = _GMObligations[[0]][[0]][[0]];
    assert obligation.active;
    assert obligation.identity == 0;
    assert obligation.request_class == GMRequest_Scalar;
    assert obligation.shareability == MemoryShareability_IntraCore;
    assert obligation.encoded_request == carrier;
    assert obligation.instruction_pc == pair_entry;
    assert obligation.submission_order == 13;
    assert obligation.invocation == _KernelInvocationByCore[[0]];
    assert obligation.state == GMObligation_Completed;
    assert _NextGMObligationIdentity[[0]][[0]] == 1;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[3]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[3]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[3]].shareability == MemoryShareability_IntraCore;
    SetMemoryReadFrom(2, 0);
    SetMemoryReadFrom(3, 1);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;

func main() => integer
begin
    TestScopedOrdinaryRequestRetriesWithSameOuterOccurrence();
    TestScopedPairHasOneCompletedOuterObligation();
    return 0;
end;
