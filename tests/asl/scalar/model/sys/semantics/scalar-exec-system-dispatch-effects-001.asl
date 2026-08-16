// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARSYSTEMDISPATCHEFFECTS-EXECUTION-001","source":"asl/scalar/model/sys/semantics.asl","requirements":[],"kind":"execution","summary":"Covers Scalar System Dispatch Effects.","pass_condition":"TestScalarSystemDispatchEffects completes without assertion failure","related_sources":[]}
func TestScalarSystemDispatchEffects()
begin
    // Context-family SSR accesses in this test are manager operations. Do not
    // depend on a preceding fault to change the active ACR implicitly.
    SetCurrentACR(0);
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x84,
        Zeros{PTO_XLEN} + 0x84, FALSE);
    EnterBundleBody();
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    var ssrset_instruction: bits(48) = Zeros{48} + 0x0000103b;
    ssrset_instruction[19:15] = Zeros{5} + 5;
    let ssrset_status = ExecuteScalarInstruction(ssrset_instruction, 32);
    assert ssrset_status == ScalarExecution_Executed;
    let tp_after_set = ReadSystemRegister(SystemRegister_THREAD_PTR);
    assert tp_after_set == Zeros{PTO_XLEN} + 0x55;

    var ssrget_instruction: bits(48) = Zeros{48} + 0x0000003b;
    ssrget_instruction[11:7] = Zeros{5} + 6;
    let ssrget_status = ExecuteScalarInstruction(ssrget_instruction, 32);
    assert ssrget_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x55;

    WriteGPR(7, Zeros{PTO_XLEN} + 0x66);
    var ssrswap_instruction: bits(48) = Zeros{48} + 0x0000203b;
    ssrswap_instruction[11:7] = Zeros{5} + 8;
    ssrswap_instruction[19:15] = Zeros{5} + 7;
    let ssrswap_status = ExecuteScalarInstruction(ssrswap_instruction, 32);
    assert ssrswap_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 0x55;
    let tp_after_swap = ReadSystemRegister(SystemRegister_THREAD_PTR);
    assert tp_after_swap == Zeros{PTO_XLEN} + 0x66;

    var compressed_get: bits(48) = Zeros{48} + 0x802c;
    let compressed_get_status = ExecuteScalarInstruction(compressed_get, 16);
    assert compressed_get_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x66;

    WriteGPR(5, Zeros{PTO_XLEN} + 0x1234);
    var long_set: bits(48) = Zeros{48} + 0x0000103b000e;
    long_set[47:36] = Zeros{12} + 0xf10;
    long_set[15:4] = Zeros{12} + 1;
    long_set[35:31] = Zeros{5} + 5;
    let long_set_status = ExecuteScalarInstruction(long_set, 48);
    assert long_set_status == ScalarExecution_Executed;
    let long_system_value = ReadSystemRegisterAddress(Zeros{24} + 0x1f10);
    assert long_system_value == Zeros{PTO_XLEN} + 0x1234;

    let before_data_cache = _DataCacheEpoch;
    var maintenance: bits(48) = Zeros{48} + 0x0030602b;
    maintenance[19:15] = Zeros{5} + 5;
    let maintenance_status = ExecuteScalarInstruction(maintenance, 32);
    assert maintenance_status == ScalarExecution_Executed;
    assert _DataCacheEpoch == before_data_cache + 1;

    WriteGPR(5, Zeros{PTO_XLEN} + 17);
    var wait_event: bits(48) = Zeros{48} + 0x0010002b;
    wait_event[19:15] = Zeros{5} + 5;
    let wait_event_status = ExecuteScalarInstruction(wait_event, 32);
    assert wait_event_status == ScalarExecution_Executed;
    assert _LastControlRequest == ExecutionControl_WaitEvent;
    assert _ControlRequestOperand == Zeros{PTO_XLEN} + 17;

    let before_instruction = _InstructionCacheEpoch;
    var fence_data: bits(48) = Zeros{48} + 0x0000202b;
    fence_data[27:24] = '1010';
    fence_data[23:20] = '0101';
    let fence_status = ExecuteScalarInstruction(fence_data, 32);
    assert fence_status == ScalarExecution_Executed;
    assert _LastFencePredecessor == '1010';
    assert _LastFenceSuccessor == '0101';
    assert _InstructionCacheEpoch == before_instruction + 1;

    ResetBundleControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN} + 0x102,
        Zeros{PTO_XLEN} + 0x102,
        FALSE);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x800);
    var set_target: bits(48) = Zeros{48} + 0x0000403b;
    set_target[19:15] = Zeros{5} + 5;
    let set_target_status = ExecuteScalarInstruction(set_target, 32);
    assert set_target_status == ScalarExecution_Executed;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x800;
    ResetBundleControlState();

    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, FALSE);
    EnterBundleBody();
    let before_request = _ArchitectureRequestEpoch;
    var close_request: bits(48) = Zeros{48} + 0x0000302b;
    close_request[23:20] = '0001';
    let close_status = ExecuteScalarInstruction(close_request, 32);
    assert close_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_ServiceRequest;
    assert CurrentACR() == 1;
    assert _ArchitectureRequestEpoch == before_request + 1;
    assert _ControlRequestOperand[3:0] == '0001';

    ClearFault();
    ResetBundleControlState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x404,
        Zeros{PTO_XLEN} + 0x404, FALSE);
    EnterBundleBody();
    var enter_request: bits(48) = Zeros{48} + 0x0100302b;
    enter_request[23:20] = '0010';
    let enter_status = ExecuteScalarInstruction(enter_request, 32);
    assert enter_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;

    ClearFault();
    WritePC(Zeros{PTO_XLEN} + 0x400);
    var breakpoint: bits(48) = Zeros{48} + 0x0010102b;
    breakpoint[27:24] = '1001';
    let breakpoint_status = ExecuteScalarInstruction(breakpoint, 32);
    assert breakpoint_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_SoftwareBreakpoint;
    assert _ACRTrapCause[[CurrentACR()]] == Zeros{24} + 9;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x400;

    ClearFault();
    var assertion: bits(48) = Zeros{48} + 0x0000102b;
    let assertion_status = ExecuteScalarInstruction(assertion, 32);
    assert assertion_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_Assert;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarSystemDispatchEffects();
    return 0;
end;
