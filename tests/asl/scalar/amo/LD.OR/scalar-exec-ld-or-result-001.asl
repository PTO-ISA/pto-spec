// PTO-TEST: {"id":"PTO-AVS-SCALAR-LD-OR-RESULT-001","source":"asl/scalar/amo/LD.OR.asl","requirements":["PTO-INST-SCALAR-LD-OR"],"kind":"execution","summary":"LD.OR performs its atomic update and publishes the prior value","pass_condition":"memory, destination, event, ordering, reservation, and TPC match the LD.OR contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckLDORResult()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 5;
    let operand = Zeros{PTO_XLEN} + 2;
    let expected = Zeros{PTO_XLEN} + 7;
    assert AtomicValueSized(Atomic_OR, old_value, operand, 8) == expected;

    Store(address, 8, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 8;
    WriteGPR(2, address);
    WriteGPR(3, operand);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x2000400b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 8) == expected;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 5;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert !_ReservationValid;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].address == address;
    assert _MemoryEvents[[0]].size_bytes == 8;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 8);
    assert _MemoryEvents[[0]].write_value == expected;
    assert _MemoryEvents[[0]].write_performed;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractAtomicOperation_LD_OR() == Atomic_OR;
    assert InstructionContractAtomicSizeBytes_LD_OR() == 8;
    assert InstructionContractPublishesOldValue_LD_OR();
    assert !InstructionContractSignExtendsOldValue_LD_OR();
end;

func main() => integer
begin
    ResetProfileState();
    CheckLDORResult();
    return 0;
end;
