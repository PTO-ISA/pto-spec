// PTO-TEST: {"id":"PTO-AVS-SCALAR-SW-UMIN-STORE-001","source":"asl/scalar/amo/SW.UMIN.asl","requirements":["PTO-INST-SCALAR-SW-UMIN"],"kind":"execution","summary":"SW.UMIN performs one store-only atomic update without publishing the old value","pass_condition":"memory, event, ordering, reservation, queues, registers, and TPC match the mnemonic contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckSWUMINStoreOnly()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Ones{PTO_XLEN};
    let operand = Zeros{PTO_XLEN} + 1;
    let expected = Zeros{PTO_XLEN} + 1;

    // Seed values that expose an accidental RegDst or queue result.
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x66);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x77);
    let old_t = ReadTemporaryQueue(TRUE, 0);
    let old_u = ReadTemporaryQueue(FALSE, 0);

    Store(address, 4, old_value);
    _ReservationValid = TRUE;
    _ReservationAddress = address;
    _ReservationSize = 4;
    WriteGPR(2, address);
    WriteGPR(3, operand);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();
    StartMemoryEventCapture(0);

    var instruction: bits(48) = Zeros{48} + 0x7000300b;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[25] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) == expected;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTemporaryQueue(TRUE, 0) == old_t;
    assert ReadTemporaryQueue(FALSE, 0) == old_u;
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
    assert _MemoryEvents[[0]].order == MemoryOrder_Release;

    assert InstructionContractAtomicOperation_SW_UMIN() == Atomic_UMIN;
    assert InstructionContractAtomicSizeBytes_SW_UMIN() == 4;
    assert !InstructionContractPublishesOldValue_SW_UMIN();
end;

func main() => integer
begin
    ResetProfileState();
    CheckSWUMINStoreOnly();
    return 0;
end;
