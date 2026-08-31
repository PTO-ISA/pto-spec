// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-BFI-RESERVED-002","source":"asl/scalar/alu/HL.BFI.asl","requirements":["PTO-INST-SCALAR-HL-BFI"],"kind":"fault","summary":"HL.BFI rejects byte offsets and byte counts outside the assigned eight-byte word.","pass_condition":"imms=8 and immr=8 each fault before source readiness, destination, queue, or TPC effects.","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    WriteGPR(1, Ones{PTO_XLEN});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x55);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x777);
    var instruction: bits(48) = Zeros{48} + 0x0000204d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[15:10] = Zeros{6} + 8;
    let bad_offset = ExecuteScalarInstruction(instruction, 48);
    assert bad_offset == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x777;

    ClearFault();
    instruction[15:10] = Zeros{6};
    instruction[9:4] = Zeros{6} + 8;
    let bad_count = ExecuteScalarInstruction(instruction, 48);
    assert bad_count == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x777;
    return 0;
end;
