// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-IOR-STREAM-001","source":"asl/block/model/dispatch/scalar-schema.asl","requirements":["PTO-BSTART-TIMG2COL-PARAMS-001"],"kind":"execution","summary":"TIMG2COL accepts exactly two contiguous source-only 3+3 B.IOR records.","pass_condition":"The canonical pair is accepted while a malformed first record, an interleaved command, and a third record reject before a second or surplus binding is installed.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/timg2col-parameters.asl"]}
pure func TIMG2COLStreamStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TIMG2COLStreamIOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let malformed_start = ExecuteCommandInstruction(TIMG2COLStreamStart(), 32);
    assert malformed_start == CommandExecution_Executed;
    let malformed_first = ExecuteCommandInstruction(
        TIMG2COLStreamIOR(2, 3, 0), 32);
    assert malformed_first == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleScalarBindings[[0]].valid;

    ResetProfileState();
    let interleaved_start = ExecuteCommandInstruction(TIMG2COLStreamStart(), 32);
    assert interleaved_start == CommandExecution_Executed;
    let interleaved_first = ExecuteCommandInstruction(
        TIMG2COLStreamIOR(2, 0, 0), 32);
    assert interleaved_first == CommandExecution_Executed;
    assert BundleTIMG2COLIORSecondExpected();
    let interleaved_command = ExecuteCommandInstruction(
        Zeros{64} + 0x00000043, 32);
    assert interleaved_command == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleScalarBindings[[0]].valid;
    assert !_BundleScalarBindings[[1]].valid;

    ResetProfileState();
    let canonical_start = ExecuteCommandInstruction(TIMG2COLStreamStart(), 32);
    assert canonical_start == CommandExecution_Executed;
    let canonical_first = ExecuteCommandInstruction(
        TIMG2COLStreamIOR(2, 0, 0), 32);
    assert canonical_first == CommandExecution_Executed;
    let canonical_second = ExecuteCommandInstruction(
        TIMG2COLStreamIOR(3, 4, 5), 32);
    assert canonical_second == CommandExecution_Executed;
    assert _BundleScalarBindings[[0]].source_count == 3;
    assert _BundleScalarBindings[[1]].source_count == 3;
    assert !BundleTIMG2COLIORSecondExpected();
    let surplus = ExecuteCommandInstruction(TIMG2COLStreamIOR(6, 7, 8), 32);
    assert surplus == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    return 0;
end;
