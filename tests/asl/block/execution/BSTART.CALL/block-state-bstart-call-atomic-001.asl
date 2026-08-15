// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-CALL-ATOMIC-001","source":"asl/block/execution/BSTART.CALL.asl","requirements":["PTO-INST-BLOCK-BSTART-CALL"],"kind":"state-transition","summary":"Fused direct call computes independent branch and return targets atomically.","pass_condition":"Signed simm12 selects BPCN, unsigned uimm5 writes ra, and the candidate target is entered only at commit.","related_sources":["asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    var call = Zeros{64} + 0x50160002;
    call[15:4] = Ones{12};
    call[26:22] = Zeros{5} + 3;
    let status = ExecuteCommandInstruction(call, 32);
    assert status == CommandExecution_Executed;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x400;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x404;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 0x408;
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x480);
    assert committed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x3fe;
    return 0;
end;
