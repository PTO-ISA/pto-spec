// PTO-TEST: {"id":"PTO-AVS-SCALAR-DMA-OVERLAP-001","source":"asl/scalar/amo/DMA.asl","requirements":["PTO-INST-SCALAR-DMA"],"kind":"boundary","summary":"DMA snapshots Reg5 queue sources before forward-overlap commit","pass_condition":"forward overlap has memmove bytes, input queues are preserved, and a nonoverlapping reservation survives","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckDMAForwardOverlap()
begin
    let source_address = Zeros{PTO_XLEN} + 0x100;
    let destination_address = source_address + 8;
    var expected: array [[64]] of Byte;

    for byte_index = 0 to 63 do
        let value = Zeros{8} + 0x80 + byte_index;
        expected[[byte_index]] = value;
        WriteMemoryByte(
            source_address + NaturalToWord(byte_index as integer {0..262144}),
            value);
    end;

    PushTemporaryQueue(TRUE, source_address);
    PushTemporaryQueue(FALSE, destination_address);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x300;
    _ReservationSize = 8;
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    StartMemoryEventCapture(1);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000700b;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTemporaryQueue(TRUE, 0) == source_address;
    assert ReadTemporaryQueue(FALSE, 0) == destination_address;
    assert _ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN} + 0x300;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;

    for byte_index = 0 to 63 do
        assert ReadMemoryByte(
            destination_address + NaturalToWord(
                byte_index as integer {0..262144})) == expected[[byte_index]];
    end;
end;

func main() => integer
begin
    ResetProfileState();
    CheckDMAForwardOverlap();
    return 0;
end;
