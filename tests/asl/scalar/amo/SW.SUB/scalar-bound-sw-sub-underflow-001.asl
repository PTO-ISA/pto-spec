// PTO-TEST: {"id":"PTO-AVS-SCALAR-SW-SUB-UNDERFLOW-001","source":"asl/scalar/amo/SW.SUB.asl","requirements":["PTO-INST-SCALAR-SW-SUB"],"kind":"boundary","summary":"SW.SUB wraps zero minus one at its access width","pass_condition":"The exact-width result is all ones; adjacent memory and source registers remain unchanged","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let address = Zeros{PTO_XLEN} + 256;
    Store(address, 4, Zeros{PTO_XLEN});
    WriteMemoryByte(address + 4, '10100101');
    WriteGPR(2, address);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    var instruction: bits(48) = Zeros{48} + 0x4000300b;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 4) == NormalizeMemoryAccessValue(Ones{PTO_XLEN}, 4);
    assert ReadMemoryByte(address + 4) == '10100101';
    assert ReadGPR(2) == address;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
