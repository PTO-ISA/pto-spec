// PTO-TEST: {"id":"PTO-AVS-SCALAR-SD-ADD-FORMS-001","source":"asl/scalar/amo/SD.ADD.asl","requirements":["PTO-INST-SCALAR-SD-ADD"],"kind":"boundary","summary":"SD.ADD reads T and U relative sources with relaxed local defaults","pass_condition":"relative sources, default modifiers, memory, ordering, reservation, queues, and TPC match the SD.ADD contract","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckSDADDRelativeDefaultForm()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 7;
    let operand = Zeros{PTO_XLEN} + 5;
    let expected = Zeros{PTO_XLEN} + 12;
    let reservation_address = Zeros{PTO_XLEN} + 512;

    Store(address, 8, old_value);
    _ReservationValid = TRUE;
    _ReservationAddress = reservation_address;
    _ReservationSize = 8;
    PushTemporaryQueue(TRUE, address);
    PushTemporaryQueue(FALSE, operand);
    let old_t = ReadTemporaryQueue(TRUE, 0);
    let old_u = ReadTemporaryQueue(FALSE, 0);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();
    StartMemoryEventCapture(0);

    var instruction: bits(48) = Zeros{48} + 0x0000500b;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 8) == expected;
    assert ReadTemporaryQueue(TRUE, 0) == old_t;
    assert ReadTemporaryQueue(FALSE, 0) == old_u;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
    assert _ReservationValid;
    assert _ReservationAddress == reservation_address;
    assert _ReservationSize == 8;

    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].address == address;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 8);
    assert _MemoryEvents[[0]].write_value == expected;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
end;

func main() => integer
begin
    ResetProfileState();
    CheckSDADDRelativeDefaultForm();
    return 0;
end;
