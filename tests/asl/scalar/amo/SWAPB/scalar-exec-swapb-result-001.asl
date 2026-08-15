// PTO-TEST: {"id":"PTO-AVS-SCALAR-SWAPB-RESULT-001","source":"asl/scalar/amo/SWAPB.asl","requirements":["PTO-INST-SCALAR-SWAPB"],"kind":"execution","summary":"SWAPB atomically replaces memory and publishes the prior value","pass_condition":"memory, destination, atomic event, ordering, reservation, and TPC match the SWAPB contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckSWAPBResult()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0x80;
    let replacement = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(address, 1, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 1;
    WriteGPR(2, address);
    WriteGPR(3, replacement);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000600b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 1) == Zeros{PTO_XLEN} + 0x88;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x80;
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 1);
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x88;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractAtomicOperation_SWAPB() == Atomic_SWAP;
    assert InstructionContractAtomicSizeBytes_SWAPB() == 1;
end;

func main() => integer
begin
    ResetProfileState();
    CheckSWAPBResult();
    return 0;
end;
