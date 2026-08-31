// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-BFI-PACKED-WORD-002","source":"asl/scalar/alu/HL.BFI.asl","requirements":["PTO-INST-SCALAR-HL-BFI"],"kind":"execution","summary":"HL.BFI duplicates a low 32-bit value into the high XLEN half with M=4 and N=4.","pass_condition":"The exact compiler-emitted encoding converts 2 into 0x0000000200000002.","related_sources":["asl/scalar/model/alu/bitfield.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    BeginBundleAt(
        Zeros{PTO_XLEN} + 0x100,
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x110,
        Zeros{PTO_XLEN} + 0x110,
        Zeros{PTO_XLEN},
        TRUE);
    let materialize = ExecuteScalarInstruction(Zeros{48} + 0xf896, 16);
    let duplicate = ExecuteScalarInstruction(
        Zeros{48} + 0x018c2fcd103e, 48);
    assert materialize == ScalarExecution_Executed;
    assert duplicate == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) ==
        Zeros{PTO_XLEN} + 0x0000000200000002;
    return 0;
end;
