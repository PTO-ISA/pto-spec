// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-FP-RSVD-001","source":"asl/block/encoding/C.BSTART.FP.asl","requirements":["PTO-INST-BLOCK-C-BSTART-FP"],"kind":"fault","summary":"C.BSTART.FP rejects every unassigned BrType before block effects","pass_condition":"BrType 0, 2, 3, 4, and 6 raise Fault_IllegalInstruction without opening an FP block","related_sources":["asl/block/model/dispatch/top-level.asl"]}
func AssertReservedCompressedFPStart(branch_type: bits(3))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    var instruction: bits(64) = Zeros{64} + 0x0080;
    instruction[13:11] = branch_type;
    let status = ExecuteCommandInstruction(instruction, 16);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;
end;

func main() => integer
begin
    AssertReservedCompressedFPStart('000');
    AssertReservedCompressedFPStart('010');
    AssertReservedCompressedFPStart('011');
    AssertReservedCompressedFPStart('100');
    AssertReservedCompressedFPStart('110');
    return 0;
end;
