// PTO-TEST: {"id":"PTO-AVS-SCALAR-LW-UMIN-RESULT-001","source":"asl/scalar/amo/LW.UMIN.asl","requirements":["PTO-INST-SCALAR-LW-UMIN"],"kind":"execution","summary":"LW.UMIN performs its atomic update and publishes the prior value","pass_condition":"memory, destination, event, ordering, reservation, and TPC match the LW.UMIN contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckLWUMINResult()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0xffffffff;
    let operand = Zeros{PTO_XLEN} + 5;
    let expected = Zeros{PTO_XLEN} + 5;
    assert AtomicValueSized(Atomic_UMIN, old_value, operand, 4) == expected;

    Store(address, 4, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 4;
    WriteGPR(2, address);
    WriteGPR(3, operand);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x7000200b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) == expected;
    assert ReadGPR(5) == Ones{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert !_ReservationValid;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].address == address;
    assert _MemoryEvents[[0]].size_bytes == 4;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 4);
    assert _MemoryEvents[[0]].write_value == expected;
    assert _MemoryEvents[[0]].write_performed;
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;
    assert InstructionContractAtomicOperation_LW_UMIN() == Atomic_UMIN;
    assert InstructionContractAtomicSizeBytes_LW_UMIN() == 4;
    assert InstructionContractPublishesOldValue_LW_UMIN();
    assert InstructionContractSignExtendsOldValue_LW_UMIN();
end;

func main() => integer
begin
    ResetProfileState();
    CheckLWUMINResult();
    return 0;
end;
