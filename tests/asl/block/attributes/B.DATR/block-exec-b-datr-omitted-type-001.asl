// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-OMITTED-TYPE-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"execution","summary":"Omitted B.DATR inherits the typed BSTART data type.","pass_condition":"A TLOAD block started with U64 retains U64 when no B.DATR instruction is present.","related_sources":["asl/block/model/state/descriptor-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var start = Zeros{64} + 0x00011181;
    start[31:27] = Zeros{5} + 24;
    let status = ExecuteCommandInstruction(start, 32);
    assert status == CommandExecution_Executed;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    return 0;
end;
