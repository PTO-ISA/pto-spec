// PTO-TEST: {"id":"PTO-AVS-SCALAR-SW-SUB-STORE-001","source":"asl/scalar/amo/SW.SUB.asl","requirements":["PTO-INST-SCALAR-SW-SUB"],"kind":"execution","summary":"SW.SUB performs one store-only modular subtraction without publishing the old value","pass_condition":"memory, event, ordering, reservation, queues, registers, and TPC match the mnemonic contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckSWSUBStoreOnly()
begin
    let address = Zeros{PTO_XLEN} + 256;
    Store(address, 4, Zeros{PTO_XLEN} + 7);
    WriteGPR(2, address);
    WriteGPR(3, Zeros{PTO_XLEN} + 5);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();
    StartMemoryEventCapture(0);

    var instruction: bits(48) = Zeros{48} + 0x4000300b;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) == Zeros{PTO_XLEN} + 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 2;
    assert InstructionContractAtomicOperation_SW_SUB() == Atomic_SUB;
    assert InstructionContractAtomicSizeBytes_SW_SUB() == 4;
    assert !InstructionContractPublishesOldValue_SW_SUB();
end;

func main() => integer
begin
    ResetProfileState();
    CheckSWSUBStoreOnly();
    return 0;
end;
