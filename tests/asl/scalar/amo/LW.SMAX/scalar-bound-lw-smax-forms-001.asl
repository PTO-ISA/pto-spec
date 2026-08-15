// PTO-TEST: {"id":"PTO-AVS-SCALAR-LW-SMAX-FORMS-001","source":"asl/scalar/amo/LW.SMAX.asl","requirements":["PTO-INST-SCALAR-LW-SMAX"],"kind":"boundary","summary":"LW.SMAX reads T and U sources and pushes its result to U with default modifiers","pass_condition":"relative sources, U push, relaxed ordering, nonoverlap reservation, and TPC match the LW.SMAX contract","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckLWSMAXRelativeDefaultForm()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 5;
    let operand = Zeros{PTO_XLEN} + 7;
    let expected = Zeros{PTO_XLEN} + 7;
    let reservation_address = Zeros{PTO_XLEN} + 512;

    Store(address, 4, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = reservation_address;
    _ReservationSize = 4;
    PushTemporaryQueue(TRUE, address);
    PushTemporaryQueue(FALSE, operand);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x4000200b;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) == expected;
    assert ReadTemporaryQueue(TRUE, 0) == address;
    assert ReadTemporaryQueue(FALSE, 0) ==
        NormalizeAtomicReturn(old_value, 4);
    assert ReadTemporaryQueue(FALSE, 1) == operand;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
    assert _ReservationValid;
    assert _ReservationAddress == reservation_address;
    assert _ReservationSize == 4;

    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].read_value == old_value;
    assert _MemoryEvents[[0]].write_value == expected;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLWSMAXRelativeDefaultForm();
    return 0;
end;
