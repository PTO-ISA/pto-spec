// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-ICALL-BARG-001","source":"asl/block/execution/BSTART.ICALL.asl","requirements":["PTO-INST-BLOCK-BSTART-ICALL"],"kind":"state-transition","summary":"Fused indirect call snapshots the retiring BARG.BPCN.","pass_condition":"The new indirect-call block retains the retiring candidate target across prior-block commit and enters it only when the new block commits.","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    var predecessor = Zeros{64} + 0x00003001;
    predecessor[31:15] = Zeros{17} + 8;
    let first = ExecuteCommandInstruction(predecessor, 32);
    assert first == CommandExecution_Executed;

    var icall = Zeros{64} + 0x50166001;
    icall[26:22] = Zeros{5} + 2;
    let second = ExecuteCommandInstruction(icall, 32);
    assert second == CommandExecution_Executed;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x50a;
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x580);
    assert committed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x510;
    return 0;
end;
