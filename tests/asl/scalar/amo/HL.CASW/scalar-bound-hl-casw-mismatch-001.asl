// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CASW-MISMATCH-001","source":"asl/scalar/amo/HL.CASW.asl","requirements":["PTO-INST-SCALAR-HL-CASW"],"kind":"boundary","summary":"HL.CASW mismatch is an ordered atomic read with no write","pass_condition":"memory, U destination, mismatch event, reservation preservation, and TPC match the HL.CASW contract","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckHL_CASWMismatch()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0x80000001;
    let wrong_expected = Zeros{PTO_XLEN} + 7;
    let desired = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(address, 4, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 4;
    PushTemporaryQueue(TRUE, address);
    PushTemporaryQueue(FALSE, wrong_expected);
    WriteGPR(4, desired);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x2000600b000e;
    instruction[27:23] = Zeros{5} + 30;
    instruction[35:31] = Zeros{5} + 24;
    instruction[40:36] = Zeros{5} + 28;
    instruction[10:6] = Zeros{5} + 4;

    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) ==
        NormalizeMemoryAccessValue(old_value, 4);
    assert ReadTemporaryQueue(TRUE, 0) == address;
    assert ReadTemporaryQueue(FALSE, 0) == SignExtend{PTO_XLEN}('10000000000000000000000000000001');
    assert ReadTemporaryQueue(FALSE, 1) == wrong_expected;
    assert _ReservationValid;
    assert _ReservationAddress == address;
    assert ReadTPC() == Zeros{PTO_XLEN} + (0x80 + 6);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert !_MemoryEvents[[0]].write_performed;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
end;

func main() => integer
begin
    ResetProfileState();
    CheckHL_CASWMismatch();
    return 0;
end;
