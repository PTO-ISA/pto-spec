// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DIM-LOW16-001","source":"asl/block/attributes/B.DIM.asl","requirements":["PTO-INST-BLOCK-B-DIM"],"kind":"boundary","summary":"B.DIM publishes only the low 16 bits of base plus immediate.","pass_condition":"An absolute-GPR base of 65535 plus immediate one writes zero to the selected LB.","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    WriteGPR(23, Zeros{PTO_XLEN} + 65535);
    var instruction = Zeros{64} + 0x43;
    instruction[19:15] = Zeros{5} + 23;
    instruction[31:20] = Zeros{12} + 1;
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};
    return 0;
end;
