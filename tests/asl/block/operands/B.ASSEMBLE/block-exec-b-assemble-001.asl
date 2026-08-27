// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-ASSEMBLE-ENCODING-001","source":"asl/block/operands/B.ASSEMBLE.asl","requirements":["PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"B.ASSEMBLE executes every INIT/MIDDLE/LAST/INIT_LAST control, Local 1..10 and Shared 1..12 parent boundaries, and all raw-legality and contradictory-control faults.","pass_condition":"each legal control preserves exact fields and XLEN offset in the destination carrier; Local 11/12 and every reserved raw form fault before state changes, while Shared parent codes 1..12 remain accepted","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/range-modifiers.asl"]}
pure func AssembleInstruction(init: boolean, last: boolean, reg_src: integer, uimm11: integer, parent_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + uimm11;
    instruction[19:15] = Zeros{5} + reg_src;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;
pure func LocalAssembleBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 10;
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    return instruction;
end;
pure func SharedAssembleBinder(size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 9;
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111';
    return instruction;
end;
func StartBlock()
begin
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
end;
func ResetAssembleFixture()
begin
    ResetBundleControlState();
    ClearFault();
    WriteBPC(Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN});
end;
func AssertAssembleIllegal(instruction: bits(64))
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    StartBlock();
    let started = ExecuteCommandInstruction(LocalAssembleBinder(), 32);
    assert started == CommandExecution_Executed;
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(instruction, 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert _BundleRangeGroup.open;
    assert !_BundleRangeGroup.destination_seen;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
end;
func AssertLocalAssemble(init: boolean, last: boolean, reg_src: integer, uimm11: integer, parent_size: integer)
begin
    ResetAssembleFixture();
    WriteGPR(reg_src as GPRIndex, Zeros{PTO_XLEN} + 0x1200 + reg_src);
    WriteTPC(Zeros{PTO_XLEN} + 0x580);
    StartBlock();
    let started = ExecuteCommandInstruction(LocalAssembleBinder(), 32);
    let accepted = ExecuteCommandInstruction(AssembleInstruction(init, last, reg_src, uimm11, parent_size), 32);
    assert started == CommandExecution_Executed;
    assert accepted == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_assemble.valid;
    assert _BundleTileBindings[[0]].destination_assemble.init == init;
    assert _BundleTileBindings[[0]].destination_assemble.last == last;
    assert _BundleTileBindings[[0]].destination_assemble.reg_src == reg_src;
    assert _BundleTileBindings[[0]].destination_assemble.uimm11 == (Zeros{11} + uimm11);
    assert _BundleTileBindings[[0]].destination_assemble.size_code == parent_size;
    let expected_base = if reg_src == 0 then Zeros{PTO_XLEN}
                        else Zeros{PTO_XLEN} + 0x1200 + reg_src;
    assert _BundleTileBindings[[0]].destination_assemble.offset == expected_base + uimm11;
end;
func AssertLocalAssembleBoundary(parent_size: integer)
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x5e0);
    StartBlock();
    let started = ExecuteCommandInstruction(LocalAssembleBinder(), 32);
    assert started == CommandExecution_Executed;
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(
        AssembleInstruction(TRUE, FALSE, 0, 0, parent_size), 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTPC() == before_tpc;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
end;
func AssertSharedAssemble(init: boolean, last: boolean, reg_src: integer, uimm11: integer, parent_size: integer)
begin
    ResetAssembleFixture();
    WriteGPR(reg_src as GPRIndex, Zeros{PTO_XLEN} + 0x2200 + reg_src);
    WriteTPC(Zeros{PTO_XLEN} + 0x5c0);
    StartBlock();
    // Keep the Shared binder in destination form even when the modifier
    // exercises the MIDDLE/LAST ParentSizeCode=0 class.
    let started = ExecuteCommandInstruction(
        SharedAssembleBinder(if parent_size == 0 then 1 else parent_size), 32);
    let accepted = ExecuteCommandInstruction(AssembleInstruction(init, last, reg_src, uimm11, parent_size), 32);
    assert started == CommandExecution_Executed;
    assert accepted == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].destination_assemble.valid;
    assert _BundleSharedBindings[[0]].destination_assemble.init == init;
    assert _BundleSharedBindings[[0]].destination_assemble.last == last;
    assert _BundleSharedBindings[[0]].destination_assemble.reg_src == reg_src;
    assert _BundleSharedBindings[[0]].destination_assemble.uimm11 == (Zeros{11} + uimm11);
    assert _BundleSharedBindings[[0]].destination_assemble.size_code == parent_size;
    let expected_base = if reg_src == 0 then Zeros{PTO_XLEN}
                        else Zeros{PTO_XLEN} + 0x2200 + reg_src;
    assert _BundleSharedBindings[[0]].destination_assemble.offset == expected_base + uimm11;
end;
func main() => integer
begin
    assert DecodeCommandForm(AssembleInstruction(TRUE, TRUE, 0, 0, 1), 32) == 75;
    // Every semantic control class is executed with an exact Local carrier.
    AssertLocalAssemble(TRUE, FALSE, 0, 0, 1);   // INIT, Local boundary 1
    AssertLocalAssemble(FALSE, FALSE, 23, 2047, 0); // MIDDLE
    AssertLocalAssemble(FALSE, TRUE, 0, 0, 0);   // LAST
    AssertLocalAssemble(TRUE, TRUE, 23, 2047, 10); // INIT_LAST, Local boundary 10
    AssertLocalAssembleBoundary(11);
    AssertLocalAssembleBoundary(12);
    // Shared explicitly covers both parent boundaries and INIT_LAST.
    AssertSharedAssemble(TRUE, TRUE, 0, 0, 1);
    AssertSharedAssemble(TRUE, TRUE, 23, 2047, 12);

    // Raw size 0..12 is legal only under its matching control class.  The
    // matrix below executes every legal parent code in a non-contradictory
    // form, proving the complete decoder reach rather than only boundaries.
    for parent_size = 1 to 12 looplimit 12 do
        AssertSharedAssemble(TRUE, FALSE, if parent_size == 1 then 0 else 23,
                             if parent_size == 12 then 2047 else 0, parent_size);
    end;
    AssertSharedAssemble(FALSE, FALSE, 0, 0, 0);
    AssertSharedAssemble(FALSE, TRUE, 23, 2047, 0);

    // Contradictory INIT/size classes are BundleControl faults.
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    StartBlock();
    let contradiction_started = ExecuteCommandInstruction(LocalAssembleBinder(), 32);
    assert contradiction_started == CommandExecution_Executed;
    let before_init_zero = ReadTPC();
    let contradictory_init = ExecuteCommandInstruction(AssembleInstruction(TRUE, FALSE, 0, 0, 0), 32);
    assert contradictory_init == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTPC() == before_init_zero;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
    ClearFault();
    let before_middle_nonzero = ReadTPC();
    let contradictory_middle = ExecuteCommandInstruction(AssembleInstruction(FALSE, FALSE, 0, 0, 1), 32);
    assert contradictory_middle == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTPC() == before_middle_nonzero;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;

    // Every reserved RegSrc and ParentSizeCode value rejects before reads,
    // state changes, or TPC advance on a fresh compatible group.
    for selector = 24 to 31 looplimit 8 do
        AssertAssembleIllegal(AssembleInstruction(TRUE, FALSE, selector, 0, 1));
    end;
    for reserved_size = 13 to 15 looplimit 3 do
        AssertAssembleIllegal(AssembleInstruction(TRUE, FALSE, 0, 0, reserved_size));
    end;
    return 0;
end;
