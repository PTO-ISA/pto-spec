// PTO-TEST: {"id":"PTO-AVS-BLOCK-RANGE-PEMODE-ZERO-001","source":"asl/block/model/operands/range-modifiers.asl","requirements":["PTO-INST-BLOCK-B-SUBVIEW","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"PEMode=000 executes a broad raw-legal B.SUBVIEW/B.ASSEMBLE matrix as discarded syntactic groups while nonzero controls retain carriers and reserved forms remain illegal.","pass_condition":"both source selectors, every legal subview size, every raw-legal assemble control/size, RegSrc/uimm extremes, Local/Shared zero groups, and matching nonzero controls execute with no zero-mode reads/effects/faults; every reserved encoding is IllegalInstruction with no effect","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/range-modifiers.asl"]}
pure func ZeroBIOTSourceBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 3;
    instruction[19] = '1';
    instruction[11:9] = '000';
    return instruction;
end;
pure func ZeroBIOTTwoSourceBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 4;
    instruction[25:20] = Zeros{6} + 3;
    instruction[11:9] = '000';
    return instruction;
end;
pure func ZeroBIOTDestinationBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 10;
    instruction[11:9] = '000';
    instruction[8:7] = '00';
    return instruction;
end;
pure func NonzeroBIOTDestinationBinder() => bits(64)
begin
    var instruction = ZeroBIOTDestinationBinder();
    instruction[11:9] = '111';
    return instruction;
end;
pure func NonzeroBIOTSourceBinder() => bits(64)
begin
    var instruction = ZeroBIOTSourceBinder();
    instruction[11:9] = '111';
    return instruction;
end;
pure func ZeroBIOSSourceBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 7;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '000';
    return instruction;
end;
pure func ZeroBIOSDestinationBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = Zeros{4} + 12;
    instruction[11:9] = '000';
    return instruction;
end;
pure func ZeroSubview(source_select: boolean, reg_src: integer, uimm11: integer, size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if source_select then '1' else '0';
    instruction[30:20] = Zeros{11} + uimm11;
    instruction[19:15] = Zeros{5} + reg_src;
    instruction[10:7] = Zeros{4} + size_code;
    return instruction;
end;
pure func ZeroAssemble(init: boolean, last: boolean, reg_src: integer, uimm11: integer, parent_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + uimm11;
    instruction[19:15] = Zeros{5} + reg_src;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;
func StartBlock()
begin
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
end;
func ResetZeroRangeFixture()
begin
    ResetBundleControlState();
    ClearFault();
    WriteBPC(Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN});
end;
func AssertZeroSubview(source_select: boolean, reg_src: integer, uimm11: integer, size_code: integer)
begin
    ResetZeroRangeFixture();
    WriteGPR(reg_src as GPRIndex, Zeros{PTO_XLEN} + 0x3300 + reg_src);
    let before_gpr = ReadGPR(reg_src as GPRIndex);
    WriteTPC(Zeros{PTO_XLEN} + 0x800);
    StartBlock();
    let binder = ExecuteCommandInstruction(ZeroBIOTTwoSourceBinder(), 32);
    let before_tpc = ReadTPC();
    let modifier = ExecuteCommandInstruction(ZeroSubview(source_select, reg_src, uimm11, size_code), 32);
    assert binder == CommandExecution_Executed;
    assert modifier == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == before_tpc + 4;
    assert ReadGPR(reg_src as GPRIndex) == before_gpr;
    assert _BundleZeroParticipationSeen;
    assert BundleTileBindingCount() == 0;
    assert BundleSharedBindingCount() == 0;
    assert !_BundleRangeGroup.source0_seen;
    assert !_BundleRangeGroup.source1_seen;
    assert !_BundleRangeGroup.destination_seen;
end;
func AssertZeroAssemble(binder: bits(64), init: boolean, last: boolean, reg_src: integer, uimm11: integer, parent_size: integer)
begin
    ResetZeroRangeFixture();
    WriteGPR(reg_src as GPRIndex, Zeros{PTO_XLEN} + 0x4400 + reg_src);
    let before_gpr = ReadGPR(reg_src as GPRIndex);
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    StartBlock();
    let started = ExecuteCommandInstruction(binder, 32);
    let before_tpc = ReadTPC();
    let modifier = ExecuteCommandInstruction(ZeroAssemble(init, last, reg_src, uimm11, parent_size), 32);
    assert started == CommandExecution_Executed;
    assert modifier == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == before_tpc + 4;
    assert ReadGPR(reg_src as GPRIndex) == before_gpr;
    assert _BundleZeroParticipationSeen;
    assert BundleTileBindingCount() == 0;
    assert BundleSharedBindingCount() == 0;
    assert !_BundleRangeGroup.source0_seen;
    assert !_BundleRangeGroup.source1_seen;
    assert !_BundleRangeGroup.destination_seen;
end;
func AssertZeroIllegal(instruction: bits(64), binder: bits(64))
begin
    ResetZeroRangeFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0xa00);
    StartBlock();
    let started = ExecuteCommandInstruction(binder, 32);
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(instruction, 32);
    assert started == CommandExecution_Executed;
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert BundleTileBindingCount() == 0;
    assert BundleSharedBindingCount() == 0;
    assert !_BundleRangeGroup.source0_seen;
    assert !_BundleRangeGroup.source1_seen;
    assert !_BundleRangeGroup.destination_seen;
end;
func main() => integer
begin
    // Raw-legal Subview matrix: both selectors, sizes 1..12, RegSrc 0/23,
    // and uimm 0/2047 all execute with no read, role, binding, or allocation.
    for source_select = 0 to 1 looplimit 2 do
        for size = 1 to 12 looplimit 12 do
            AssertZeroSubview(source_select == 1,
                              if size == 1 then 0 else 23,
                              if size == 12 then 2047 else 0, size);
        end;
    end;
    // Both zero-mode B.IOT and B.IOS groups discard the same raw-legal source
    // modifier; this explicitly exercises the Shared zero path and source1.
    ResetZeroRangeFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0xb00);
    StartBlock();
    let zero_ios_source_binder = ExecuteCommandInstruction(ZeroBIOSSourceBinder(), 32);
    let zero_ios_source1 = ExecuteCommandInstruction(ZeroSubview(TRUE, 23, 2047, 12), 32);
    assert zero_ios_source_binder == CommandExecution_Executed;
    assert zero_ios_source1 == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert BundleSharedBindingCount() == 0;
    assert _BundleZeroParticipationSeen;

    // INIT/MIDDLE/LAST/INIT_LAST and every raw-legal parent size are accepted
    // behind PEMode=000, including combinations that are contradictory for a
    // participating binder.  Zero mode suppresses those downstream checks.
    for init = 0 to 1 looplimit 2 do
        for last = 0 to 1 looplimit 2 do
            for parent_size = 0 to 12 looplimit 13 do
                AssertZeroAssemble(ZeroBIOTDestinationBinder(), init == 1, last == 1,
                                   if parent_size == 0 then 0 else 23,
                                   if parent_size == 12 then 2047 else 0, parent_size);
            end;
        end;
    end;
    AssertZeroAssemble(ZeroBIOSDestinationBinder(), TRUE, TRUE, 23, 2047, 12);

    // Corresponding nonzero controls retain exact carriers and therefore read
    // the selected GPR only on the participating path.
    ResetZeroRangeFixture();
    WriteGPR(23, Zeros{PTO_XLEN} + 0x5500);
    StartBlock();
    let nonzero_subview_binder = ExecuteCommandInstruction(NonzeroBIOTSourceBinder(), 32);
    let nonzero_subview = ExecuteCommandInstruction(ZeroSubview(FALSE, 23, 2047, 10), 32);
    assert nonzero_subview_binder == CommandExecution_Executed;
    assert nonzero_subview == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].source0_subview.valid;
    assert _BundleTileBindings[[0]].source0_subview.reg_src == 23;
    assert _BundleTileBindings[[0]].source0_subview.offset == (Zeros{PTO_XLEN} + 0x5500) + 2047;
    ResetZeroRangeFixture();
    WriteGPR(23, Zeros{PTO_XLEN} + 0x6600);
    StartBlock();
    let nonzero_assemble_binder = ExecuteCommandInstruction(NonzeroBIOTDestinationBinder(), 32);
    let nonzero_assemble = ExecuteCommandInstruction(ZeroAssemble(TRUE, TRUE, 23, 2047, 10), 32);
    assert nonzero_assemble_binder == CommandExecution_Executed;
    assert nonzero_assemble == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_assemble.valid;
    assert _BundleTileBindings[[0]].destination_assemble.reg_src == 23;
    assert _BundleTileBindings[[0]].destination_assemble.offset == (Zeros{PTO_XLEN} + 0x6600) + 2047;

    // Reserved forms remain IllegalInstruction even though the syntactic
    // binder has PEMode=000.  Each case is isolated to preserve fault priority.
    for selector = 24 to 31 looplimit 8 do
        AssertZeroIllegal(ZeroSubview(FALSE, selector, 0, 1), ZeroBIOTSourceBinder());
        AssertZeroIllegal(ZeroAssemble(TRUE, TRUE, selector, 0, 1), ZeroBIOTDestinationBinder());
    end;
    AssertZeroIllegal(ZeroSubview(FALSE, 0, 0, 0), ZeroBIOTSourceBinder());
    for reserved_size = 13 to 15 looplimit 3 do
        AssertZeroIllegal(ZeroSubview(FALSE, 0, 0, reserved_size), ZeroBIOTSourceBinder());
        AssertZeroIllegal(ZeroAssemble(TRUE, TRUE, 0, 0, reserved_size), ZeroBIOTDestinationBinder());
    end;
    var reserved_subview = ZeroSubview(FALSE, 0, 0, 1);
    reserved_subview[11] = '1';
    AssertZeroIllegal(reserved_subview, ZeroBIOTSourceBinder());
    return 0;
end;
