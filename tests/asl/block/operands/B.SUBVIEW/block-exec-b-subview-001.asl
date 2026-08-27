// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-SUBVIEW-ENCODING-001","source":"asl/block/operands/B.SUBVIEW.asl","requirements":["PTO-INST-BLOCK-B-SUBVIEW","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"B.SUBVIEW executes the exact 0x53 decoder matrix with Local 1..10 and Shared 1..12 role-dependent size legality.","pass_condition":"each legal field combination reaches the selected Local or Shared carrier with the exact XLEN-wrapped offset; Local 11/12 and every reserved form fault before reads or state changes","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/range-modifiers.asl"]}
pure func SubviewInstruction(source_select: boolean, reg_src: integer, uimm11: integer, size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if source_select then '1' else '0';
    instruction[30:20] = Zeros{11} + uimm11;
    instruction[19:15] = Zeros{5} + reg_src;
    instruction[10:7] = Zeros{4} + size_code;
    return instruction;
end;
pure func LocalRangeBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 3;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 10;
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    return instruction;
end;
pure func LocalTwoSourceBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 4;
    instruction[25:20] = Zeros{6} + 3;
    instruction[11:9] = '111';
    return instruction;
end;
pure func SharedRangeBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 7;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;
func StartBlock()
begin
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
end;
func ResetSubviewFixture()
begin
    ResetBundleControlState();
    ClearFault();
    WriteBPC(Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN});
end;
func AssertSubviewIllegal(instruction: bits(64))
begin
    ResetSubviewFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    StartBlock();
    let started = ExecuteCommandInstruction(LocalRangeBinder(), 32);
    assert started == CommandExecution_Executed;
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(instruction, 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert _BundleRangeGroup.open;
    assert !_BundleRangeGroup.source0_seen;
    assert !_BundleRangeGroup.source1_seen;
    assert !_BundleRangeGroup.destination_seen;
    assert !_BundleTileBindings[[0]].source0_subview.valid;
    assert !_BundleTileBindings[[0]].source1_subview.valid;
end;
func AssertLocalSubview(source_select: boolean, reg_src: integer, uimm11: integer, size_code: integer)
begin
    ResetSubviewFixture();
    WriteGPR(reg_src as GPRIndex, Zeros{PTO_XLEN} + 0x1200 + reg_src);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    StartBlock();
    let binder = if source_select then LocalTwoSourceBinder() else LocalRangeBinder();
    let started = ExecuteCommandInstruction(binder, 32);
    let accepted = ExecuteCommandInstruction(SubviewInstruction(source_select, reg_src, uimm11, size_code), 32);
    assert started == CommandExecution_Executed;
    assert accepted == CommandExecution_Executed;
    let expected_base = if reg_src == 0 then Zeros{PTO_XLEN}
                        else Zeros{PTO_XLEN} + 0x1200 + reg_src;
    let expected_offset = expected_base + uimm11;
    if source_select then
        assert _BundleTileBindings[[0]].source1_subview.valid;
        assert _BundleTileBindings[[0]].source1_subview.reg_src == reg_src;
        assert _BundleTileBindings[[0]].source1_subview.uimm11 == (Zeros{11} + uimm11);
        assert _BundleTileBindings[[0]].source1_subview.size_code == size_code;
        assert _BundleTileBindings[[0]].source1_subview.offset == expected_offset;
        assert !_BundleTileBindings[[0]].source0_subview.valid;
    else
        assert _BundleTileBindings[[0]].source0_subview.valid;
        assert _BundleTileBindings[[0]].source0_subview.reg_src == reg_src;
        assert _BundleTileBindings[[0]].source0_subview.uimm11 == (Zeros{11} + uimm11);
        assert _BundleTileBindings[[0]].source0_subview.size_code == size_code;
        assert _BundleTileBindings[[0]].source0_subview.offset == expected_offset;
        assert !_BundleTileBindings[[0]].source1_subview.valid;
    end;
end;
func AssertLocalSubviewBoundary(size_code: integer)
begin
    ResetSubviewFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x340);
    StartBlock();
    let started = ExecuteCommandInstruction(LocalRangeBinder(), 32);
    assert started == CommandExecution_Executed;
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(
        SubviewInstruction(FALSE, 0, 0, size_code), 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTPC() == before_tpc;
    assert _BundleRangeGroup.open;
    assert !_BundleRangeGroup.source0_seen;
    assert !_BundleTileBindings[[0]].source0_subview.valid;
end;
func AssertSharedSubview(reg_src: integer, uimm11: integer, size_code: integer)
begin
    ResetSubviewFixture();
    WriteGPR(reg_src as GPRIndex, Zeros{PTO_XLEN} + 0x2200 + reg_src);
    WriteTPC(Zeros{PTO_XLEN} + 0x380);
    StartBlock();
    let started = ExecuteCommandInstruction(SharedRangeBinder(), 32);
    let accepted = ExecuteCommandInstruction(SubviewInstruction(FALSE, reg_src, uimm11, size_code), 32);
    assert started == CommandExecution_Executed;
    assert accepted == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].source0_subview.valid;
    assert _BundleSharedBindings[[0]].source0_subview.reg_src == reg_src;
    assert _BundleSharedBindings[[0]].source0_subview.uimm11 == (Zeros{11} + uimm11);
    assert _BundleSharedBindings[[0]].source0_subview.size_code == size_code;
    let expected_base = if reg_src == 0 then Zeros{PTO_XLEN}
                        else Zeros{PTO_XLEN} + 0x2200 + reg_src;
    assert _BundleSharedBindings[[0]].source0_subview.offset == expected_base + uimm11;
end;
func main() => integer
begin
    assert DecodeCommandForm(SubviewInstruction(FALSE, 0, 0, 1), 32) == 74;
    // Both source selectors, RegSrc 0/23, uimm 0/2047, and every Local size.
    for size = 1 to 10 looplimit 10 do
        AssertLocalSubview(size == 2,
                           if size == 1 then 0 else 23,
                           if size == 10 then 2047 else 0, size);
    end;
    // Explicit SrcSelect=1 boundary and RegSrc/uimm upper extremes.
    AssertLocalSubview(TRUE, 23, 2047, 10);
    AssertLocalSubviewBoundary(11);
    AssertLocalSubviewBoundary(12);
    // Shared reaches the complete 1..12 range, including both boundaries.
    for size = 1 to 12 looplimit 12 do
        AssertSharedSubview(if size == 1 then 0 else 23,
                            if size == 10 then 2047 else 0, size);
    end;
    AssertSharedSubview(23, 2047, 12);
    // XLEN arithmetic wraps in the derived carrier.
    ResetSubviewFixture();
    WriteGPR(2, Ones{PTO_XLEN} - 3);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    StartBlock();
    let wrap_started = ExecuteCommandInstruction(LocalRangeBinder(), 32);
    let wrap_accepted = ExecuteCommandInstruction(SubviewInstruction(FALSE, 2, 2047, 10), 32);
    assert wrap_started == CommandExecution_Executed;
    assert wrap_accepted == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].source0_subview.offset == Zeros{PTO_XLEN} + 2043;
    // Every reserved RegSrc and SubviewSizeCode value is rejected before a
    // read/carrier update, and reserved bit 11 is checked independently.
    for selector = 24 to 31 looplimit 8 do
        AssertSubviewIllegal(SubviewInstruction(FALSE, selector, 0, 1));
    end;
    AssertSubviewIllegal(SubviewInstruction(FALSE, 0, 0, 0));
    for reserved_size = 13 to 15 looplimit 3 do
        AssertSubviewIllegal(SubviewInstruction(FALSE, 0, 0, reserved_size));
    end;
    var reserved = SubviewInstruction(FALSE, 0, 0, 1);
    reserved[11] = '1';
    AssertSubviewIllegal(reserved);
    return 0;
end;
