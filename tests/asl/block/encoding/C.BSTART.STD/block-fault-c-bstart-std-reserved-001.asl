// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-BSTART-STD-RSVD-001","source":"asl/block/encoding/C.BSTART.STD.asl","requirements":["PTO-INST-BLOCK-C-BSTART-STD"],"kind":"fault","summary":"C.BSTART.STD rejects each unassigned start BrType including the fused ICALL halfword","pass_condition":"BrType 2, 3, 4, and 6 cannot execute as standalone C.BSTART.STD instructions; code 0 remains owned by C.BSTOP","related_sources":["asl/block/model/dispatch/top-level.asl","asl/block/lifecycle/C.BSTOP.asl"]}
func AssertReservedCompressedSTDStart(branch_type: bits(3))
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    var instruction: bits(64) = Zeros{64};
    instruction[13:11] = branch_type;
    let status = ExecuteCommandInstruction(instruction, 16);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleActive;
end;

func main() => integer
begin
    AssertReservedCompressedSTDStart('010');
    AssertReservedCompressedSTDStart('011');
    AssertReservedCompressedSTDStart('100');
    AssertReservedCompressedSTDStart('110');
    return 0;
end;
