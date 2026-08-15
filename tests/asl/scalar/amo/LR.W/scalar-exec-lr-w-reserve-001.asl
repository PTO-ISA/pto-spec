// PTO-TEST: {"id":"PTO-AVS-SCALAR-LR-W-RESERVE-001","source":"asl/scalar/amo/LR.W.asl","requirements":["PTO-INST-SCALAR-LR-W"],"kind":"execution","summary":"LR.W loads its value and establishes the 64-byte-line reservation","pass_condition":"destination, event, ordering, reservation, and TPC match the LR.W contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckLRWReserve()
begin
    let address = Zeros{PTO_XLEN} + 320;
    let old_value = Zeros{PTO_XLEN} + 0x80000001;
    Store(address, 4, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 128;
    _ReservationSize = 8;
    WriteGPR(2, address);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x2000000b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Ones{5};
    instruction[25] = '1';
    instruction[26] = '1';
    instruction[27] = '1';

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(5) == SignExtend{PTO_XLEN}('10000000000000000000000000000001');
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert _ReservationValid;
    assert _ReservationAddress == address;
    assert _ReservationSize == 4;

    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == address;
    assert _MemoryEvents[[0]].size_bytes == 4;
    assert _MemoryEvents[[0]].read_value ==
        NormalizeMemoryAccessValue(old_value, 4);
    assert _MemoryEvents[[0]].order == MemoryOrder_AcquireRelease;

    assert InstructionContractLoadSizeBytes_LR_W() == 4;
    assert InstructionContractIgnoresSrcZero_LR_W();
    assert InstructionContractReservationGranuleBytes_LR_W() == 64;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLRWReserve();
    return 0;
end;
