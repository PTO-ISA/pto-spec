// PTO-TEST: {"id":"PTO-AVS-SCALAR-DMA-COPY-001","source":"asl/scalar/amo/DMA.asl","requirements":["PTO-INST-SCALAR-DMA"],"kind":"execution","summary":"DMA copies one disjoint 64-byte snapshot and emits the complete relaxed event sequence","pass_condition":"destination bytes, sixteen ordered events, reservation invalidation, and TPC match the DMA contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/atomicity.asl"]}
func CheckDMADisjointCopy()
begin
    let source_address = Zeros{PTO_XLEN} + 0x100;
    let destination_address = Zeros{PTO_XLEN} + 0x200;

    for byte_index = 0 to 63 do
        WriteMemoryByte(
            source_address + NaturalToWord(byte_index as integer {0..262144}),
            Zeros{8} + byte_index + 1);
        WriteMemoryByte(
            destination_address + NaturalToWord(byte_index as integer {0..262144}),
            Zeros{8} + 0xaa);
    end;

    _ReservationValid = TRUE;
    _ReservationAddress = destination_address;
    _ReservationSize = 8;
    WriteGPR(1, source_address);
    WriteGPR(2, destination_address);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    StartMemoryEventCapture(0);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000700b;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert !_ReservationValid;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;

    for byte_index = 0 to 63 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(destination_address + offset) ==
            ReadMemoryByte(source_address + offset);
    end;

    assert _MemoryEventCount == 16;
    for chunk = 0 to 7 do
        let offset = NaturalToWord((chunk * 8) as integer {0..262144});
        assert _MemoryEvents[[chunk]].kind == MemoryEvent_Load;
        assert _MemoryEvents[[chunk]].address == source_address + offset;
        assert _MemoryEvents[[chunk]].size_bytes == 8;
        assert _MemoryEvents[[chunk]].order == MemoryOrder_Relaxed;
        assert _MemoryEvents[[chunk + 8]].kind == MemoryEvent_Store;
        assert _MemoryEvents[[chunk + 8]].address == destination_address + offset;
        assert _MemoryEvents[[chunk + 8]].size_bytes == 8;
        assert _MemoryEvents[[chunk + 8]].order == MemoryOrder_Relaxed;
        assert _MemoryEvents[[chunk + 8]].write_value ==
            _MemoryEvents[[chunk]].read_value;
    end;

    assert InstructionContractCopySizeBytes_DMA() == 64;
    assert InstructionContractEventChunkSizeBytes_DMA() == 8;
    assert InstructionContractEventChunkCount_DMA() == 8;
end;

func main() => integer
begin
    ResetProfileState();
    CheckDMADisjointCopy();
    return 0;
end;
