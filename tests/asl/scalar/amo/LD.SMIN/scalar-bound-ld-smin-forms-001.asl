// PTO-TEST: {"id":"PTO-AVS-SCALAR-LD-SMIN-FORMS-001","source":"asl/scalar/amo/LD.SMIN.asl","requirements":["PTO-INST-SCALAR-LD-SMIN"],"kind":"boundary","summary":"LD.SMIN reads T and U sources and pushes its result to U with default modifiers","pass_condition":"relative sources, U push, relaxed ordering, nonoverlap reservation, and TPC match the LD.SMIN contract","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckLDSMINRelativeDefaultForm()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 5;
    let operand = Zeros{PTO_XLEN} + 7;
    let expected = Zeros{PTO_XLEN} + 5;
    let reservation_address = Zeros{PTO_XLEN} + 512;
    Store(address, 8, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = reservation_address;
    _ReservationSize = 8;
    PushTemporaryQueue(TRUE, address);
    PushTemporaryQueue(FALSE, operand);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x5000400b;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 8) == expected;
    assert ReadTemporaryQueue(TRUE, 0) == address;
    assert ReadTemporaryQueue(FALSE, 0) ==
        NormalizeAtomicReturn(old_value, 8);
    assert ReadTemporaryQueue(FALSE, 1) == operand;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
    assert _ReservationValid;
    assert _ReservationAddress == reservation_address;
    assert _ReservationSize == 8;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].read_value == old_value;
    assert _MemoryEvents[[0]].write_value == expected;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLDSMINRelativeDefaultForm();
    return 0;
end;
