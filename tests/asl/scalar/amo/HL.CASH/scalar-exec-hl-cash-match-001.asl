// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CASH-MATCH-001","source":"asl/scalar/amo/HL.CASH.asl","requirements":["PTO-INST-SCALAR-HL-CASH"],"kind":"execution","summary":"HL.CASH matching compare conditionally stores and publishes the prior value","pass_condition":"memory, destination, atomic event, reservation, ordering, and TPC match the HL.CASH contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckHL_CASHMatch()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0x8001;
    let desired = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(address, 2, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 2;
    WriteGPR(2, address);
    WriteGPR(3, old_value);
    WriteGPR(4, desired);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x1000600b000e;
    instruction[27:23] = Zeros{5} + 5;
    instruction[35:31] = Zeros{5} + 2;
    instruction[40:36] = Zeros{5} + 3;
    instruction[10:6] = Zeros{5} + 4;
    instruction[41] = '1';
    instruction[42] = '1';
    instruction[43] = '1';
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 2) == Zeros{PTO_XLEN} + 0x7788;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x8001;
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + (0x40 + 6);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 2);
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x7788;
    assert _MemoryEvents[[0]].write_performed;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractCompareSizeBytes_HL_CASH() == 2;
    assert InstructionContractHasFarField_HL_CASH() == TRUE;
end;

func main() => integer
begin
    ResetProfileState();
    CheckHL_CASHMatch();
    return 0;
end;
