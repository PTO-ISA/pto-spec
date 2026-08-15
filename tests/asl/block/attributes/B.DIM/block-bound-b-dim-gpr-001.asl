// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DIM-GPR-BOUNDARY-001","source":"asl/block/attributes/B.DIM.asl","requirements":["PTO-INST-BLOCK-B-DIM"],"kind":"boundary","summary":"B.DIM accepts only absolute GPR selectors 0 through 23.","pass_condition":"Selector 23 supplies the dimension base and selector 24 rejects before changing LB state.","related_sources":["asl/block/model/dispatch/commands.asl"]}
pure func BundleDimensionInstruction(
    destination: BundleDimensionIndex, source: Reg5Selector,
    immediate: bits(17)) => bits(64)
begin
    var instruction = Zeros{64} + 0x43;
    instruction[14:12] = Zeros{3} + destination;
    instruction[19:15] = Zeros{5} + source;
    instruction[31:20] = immediate[11:0];
    instruction[11:7] = immediate[16:12];
    return instruction;
end;

func OpenDimensionHeader()
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_Standard, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
end;

func main() => integer
begin
    OpenDimensionHeader();
    WriteGPR(23, Zeros{PTO_XLEN} + 5);
    let accepted = ExecuteCommandInstruction(
        BundleDimensionInstruction(0, 23, Zeros{17} + 7), 32);
    assert accepted == CommandExecution_Executed;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 12;

    OpenDimensionHeader();
    let rejected = ExecuteCommandInstruction(
        BundleDimensionInstruction(0, 24, Zeros{17} + 7), 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};
    return 0;
end;
