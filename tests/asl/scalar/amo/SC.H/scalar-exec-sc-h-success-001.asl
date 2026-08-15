// PTO-TEST: {"id":"PTO-AVS-SCALAR-SC-H-SUCCESS-001","source":"asl/scalar/amo/SC.H.asl","requirements":["PTO-INST-SCALAR-SC-H"],"kind":"execution","summary":"SC.H succeeds for a same-line reservation independent of LR address and width","pass_condition":"truncated store, zero status, event, reservation clear, ordering, and TPC match the SC.H contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckSCHSuccess()
begin
    let reservation_address = Zeros{PTO_XLEN} + 256;
    let store_address = Zeros{PTO_XLEN} + (320 - 2);
    let value = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(store_address, 2, Zeros{PTO_XLEN});
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = reservation_address;
    _ReservationSize = 1;
    WriteGPR(2, value);
    WriteGPR(3, store_address);
    WriteGPR(5, Ones{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x1000100b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(store_address, 2) == Zeros{PTO_XLEN} + 0x7788;
    assert ReadGPR(5) == Zeros{PTO_XLEN};
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[0]].address == store_address;
    assert _MemoryEvents[[0]].size_bytes == 2;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x7788;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractStoreSizeBytes_SC_H() == 2;
    assert InstructionContractReservationGranuleBytes_SC_H() == 64;
    assert InstructionContractSuccessStatus_SC_H() == Zeros{PTO_XLEN};
end;

func main() => integer
begin
    ResetProfileState();
    CheckSCHSuccess();
    return 0;
end;
