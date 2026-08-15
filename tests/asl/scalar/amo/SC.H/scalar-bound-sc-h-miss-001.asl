// PTO-TEST: {"id":"PTO-AVS-SCALAR-SC-H-MISS-001","source":"asl/scalar/amo/SC.H.asl","requirements":["PTO-INST-SCALAR-SC-H"],"kind":"boundary","summary":"SC.H reservation miss is probe-free and pushes status one to U","pass_condition":"inaccessible address does not fault or access memory and returns one while clearing the reservation","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckSCHProbeFreeMiss()
begin
    let inaccessible_address = Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES + 1;
    let value = Zeros{PTO_XLEN} + 0x1122334455667788;
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 128;
    _ReservationSize = 8;
    StartMemoryEventCapture(0);
    PushTemporaryQueue(TRUE, value);
    PushTemporaryQueue(FALSE, inaccessible_address);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x1000100b;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTemporaryQueue(TRUE, 0) == value;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTemporaryQueue(FALSE, 1) == inaccessible_address;
    assert !_ReservationValid;
    assert _MemoryEventCount == 0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
    assert InstructionContractMissStatus_SC_H() == Zeros{PTO_XLEN} + 1;
    assert InstructionContractMissIsProbeFree_SC_H();
end;

func main() => integer
begin
    ResetProfileState();
    CheckSCHProbeFreeMiss();
    return 0;
end;
