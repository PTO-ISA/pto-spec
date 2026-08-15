// PTO-TEST: {"id":"PTO-AVS-SCALAR-SWAPH-RESULT-001","source":"asl/scalar/amo/SWAPH.asl","requirements":["PTO-INST-SCALAR-SWAPH"],"kind":"execution","summary":"SWAPH atomically replaces memory and publishes the prior value","pass_condition":"memory, destination, atomic event, ordering, reservation, and TPC match the SWAPH contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckSWAPHResult()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0x8001;
    let replacement = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(address, 2, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 1;
    WriteGPR(2, address);
    WriteGPR(3, replacement);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x1000600b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 2) == Zeros{PTO_XLEN} + 0x7788;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x8001;
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 2);
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x7788;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractAtomicOperation_SWAPH() == Atomic_SWAP;
    assert InstructionContractAtomicSizeBytes_SWAPH() == 2;
end;

func main() => integer
begin
    ResetProfileState();
    CheckSWAPHResult();
    return 0;
end;
