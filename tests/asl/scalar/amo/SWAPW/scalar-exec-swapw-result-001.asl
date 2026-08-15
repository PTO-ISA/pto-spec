// PTO-TEST: {"id":"PTO-AVS-SCALAR-SWAPW-RESULT-001","source":"asl/scalar/amo/SWAPW.asl","requirements":["PTO-INST-SCALAR-SWAPW"],"kind":"execution","summary":"SWAPW atomically replaces memory and publishes the prior value","pass_condition":"memory, destination, atomic event, ordering, reservation, and TPC match the SWAPW contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckSWAPWResult()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0x80000001;
    let replacement = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(address, 4, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 1;
    WriteGPR(2, address);
    WriteGPR(3, replacement);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x2000600b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) == Zeros{PTO_XLEN} + 0x55667788;
    assert ReadGPR(5) == SignExtend{PTO_XLEN}('10000000000000000000000000000001');
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 4);
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x55667788;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractAtomicOperation_SWAPW() == Atomic_SWAP;
    assert InstructionContractAtomicSizeBytes_SWAPW() == 4;
end;

func main() => integer
begin
    ResetProfileState();
    CheckSWAPWResult();
    return 0;
end;
