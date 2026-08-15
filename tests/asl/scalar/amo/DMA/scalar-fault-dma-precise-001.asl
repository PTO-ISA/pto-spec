// PTO-TEST: {"id":"PTO-AVS-SCALAR-DMA-PRECISE-001","source":"asl/scalar/amo/DMA.asl","requirements":["PTO-INST-SCALAR-DMA"],"kind":"fault","summary":"DMA destination-range fault is precise and restarts the whole copy","pass_condition":"fault preserves destination, events, reservation, and TPC context; recovery and legal reissue commit exactly once","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/fault-precision.asl"]}
func CheckDMAPreciseFaultAndReissue()
begin
    let source_address = Zeros{PTO_XLEN} + 0x100;
    let fault_address =
        Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 32);
    let legal_destination = Zeros{PTO_XLEN} + 0x300;

    for byte_index = 0 to 63 do
        WriteMemoryByte(
            source_address + NaturalToWord(byte_index as integer {0..262144}),
            Zeros{8} + byte_index + 1);
    end;
    for byte_index = 0 to 31 do
        WriteMemoryByte(
            fault_address + NaturalToWord(byte_index as integer {0..262144}),
            Zeros{8} + 0xa5);
    end;

    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x500;
    _ReservationSize = 8;
    StartMemoryEventCapture(2);
    WriteGPR(1, source_address);
    WriteGPR(2, fault_address);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000700b;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let rejected = ExecuteScalarInstruction(instruction, 32);
    assert rejected == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == fault_address;
    assert _MemoryEventCount == 0;
    assert _ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN} + 0x500;
    for byte_index = 0 to 31 do
        assert ReadMemoryByte(
            fault_address + NaturalToWord(
                byte_index as integer {0..262144})) == Zeros{8} + 0xa5;
    end;
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x100;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;

    WriteGPR(2, legal_destination);
    ClearFault();
    let executed = ExecuteScalarInstruction(instruction, 32);
    assert executed == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert _MemoryEventCount == 16;
    assert _ReservationValid;
    for byte_index = 0 to 63 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(legal_destination + offset) ==
            ReadMemoryByte(source_address + offset);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    CheckDMAPreciseFaultAndReissue();
    return 0;
end;
