// PTO-TEST: {"id":"PTO-AVS-SCALAR-LR-B-RESERVE-001","source":"asl/scalar/amo/LR.B.asl","requirements":["PTO-INST-SCALAR-LR-B"],"kind":"execution","summary":"LR.B loads its value and establishes the 64-byte-line reservation","pass_condition":"destination, event, ordering, reservation, and TPC match the LR.B contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckLRBReserve()
begin
    let address = Zeros{PTO_XLEN} + 320;
    let old_value = Zeros{PTO_XLEN} + 0x80;
    Store(address, 1, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 128;
    _ReservationSize = 8;
    WriteGPR(2, address);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000000b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Ones{5};
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x80;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _ReservationValid;
    assert _ReservationAddress == address;
    assert _ReservationSize == 1;

    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == address;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 1);
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;

    assert InstructionContractLoadSizeBytes_LR_B() == 1;
    assert InstructionContractIgnoresSrcZero_LR_B();
    assert InstructionContractReservationGranuleBytes_LR_B() == 64;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLRBReserve();
    return 0;
end;
