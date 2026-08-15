// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-BARG-001","source":"asl/block/lifecycle/BSTART.asl","requirements":["PTO-INST-BLOCK-BSTART"],"kind":"state-transition","summary":"BSTART initializes BARG without entering its candidate continuation.","pass_condition":"A direct BSTART records its own address in BPC, advances to the sequential header, and selects BPCN only at commit.","related_sources":["asl/block/model/dispatch/start.asl","asl/block/model/lifecycle/begin.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var direct = Zeros{64} + 0x00000011;
    direct[31:7] = Zeros{25} + 1;
    let status = ExecuteCommandInstruction(direct, 32);
    assert status == CommandExecution_Executed;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    let committed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x180);
    assert committed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;
    return 0;
end;
