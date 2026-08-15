// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-B-DIMI-VALUES-001","source":"asl/block/attributes/C.B.DIMI.asl","requirements":["PTO-INST-BLOCK-C-B-DIMI"],"kind":"boundary","summary":"C.B.DIMI maps LoopNest 0, 1, and 2 to LB0, LB1, and LB2 and zero-extends imm8","pass_condition":"immediate values 0, 1, and 255 update only the selected write-once LB and each successful command advances TPC by two bytes","related_sources":["asl/block/model/dispatch/decode.asl","asl/block/model/schema/dimensions.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x102,
        Zeros{PTO_XLEN} + 0x102,
        Zeros{PTO_XLEN} + 0x102,
        FALSE);

    let lb0_status = ExecuteCommandInstruction(Zeros{64} + 0x003c, 16);
    assert lb0_status == CommandExecution_Executed;
    assert _BundleDimensionPresent[[0]];
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};

    var lb1_instruction: bits(64) = Zeros{64} + 0x003c;
    lb1_instruction[15:14] = '01';
    lb1_instruction[13:6] = Zeros{8} + 1;
    let lb1_status = ExecuteCommandInstruction(lb1_instruction, 16);
    assert lb1_status == CommandExecution_Executed;
    assert _BundleDimensionPresent[[1]];
    assert _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 1;

    var lb2_instruction: bits(64) = Zeros{64} + 0x003c;
    lb2_instruction[15:14] = '10';
    lb2_instruction[13:6] = Ones{8};
    let lb2_status = ExecuteCommandInstruction(lb2_instruction, 16);
    assert lb2_status == CommandExecution_Executed;
    assert _BundleDimensionPresent[[2]];
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 255;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;

    assert InstructionContractDimension_C_B_DIMI('00') == 0;
    assert InstructionContractDimension_C_B_DIMI('01') == 1;
    assert InstructionContractDimension_C_B_DIMI('10') == 2;
    assert InstructionContractValue_C_B_DIMI(Ones{8}) ==
        Zeros{PTO_XLEN} + 255;
    return 0;
end;
