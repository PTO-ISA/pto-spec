// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLETILEBINDINGV5SCHEMAS-EXECUTION-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"migrated independent behavior point for TestBundleTileBindingV5Schemas","pass_condition":"TestBundleTileBindingV5Schemas completes without assertion failure","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTileBindingV5(tile_size: bits(3), destination: bits(2),
                                 pe_mask: bits(4), source0: bits(6),
                                 last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleTileBindingV5Schemas()
begin
    // TMOV Local-to-Shared uses Function 9/10. Its B.IOT is source-only:
    // Shared TSize belongs to destination B.IOS, while local TSize/DstTile
    // must both decode as absent.
    ResetProfileState();
    let insert_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let size_one = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '00', '0011', Zeros{6}, TRUE), 32);
    assert insert_start == CommandExecution_Executed;
    assert size_one == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    ResetProfileState();
    let publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let size_seven = ExecuteCommandInstruction(
        BundleTestTileBindingV5('111', '00', '1100', Zeros{6}, TRUE), 32);
    assert publish_start == CommandExecution_Executed;
    assert size_seven == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    ResetProfileState();
    let zero_size_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let zero_size = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    assert zero_size_start == CommandExecution_Executed;
    assert zero_size == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BundleOperation.selector == Zeros{10} + 9;
    assert _BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination_size == 0;
    assert _BundleTileBindings[[0]].pe_mask == '1111';

    ResetProfileState();
    let nonzero_destination_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let nonzero_destination = ExecuteCommandInstruction(
        BundleTestTileBindingV5('001', '01', '1111', Zeros{6}, TRUE), 32);
    assert nonzero_destination_start == CommandExecution_Executed;
    assert nonzero_destination == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    // Every B.IOT in one operation uses the same nonzero participant mask.
    ResetProfileState();
    let tepl_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let first_mask = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0011', Zeros{6}, FALSE), 32);
    let mismatched_mask = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0101', Zeros{6} + 1, TRUE), 32);
    assert tepl_start == CommandExecution_Executed;
    assert first_mask == CommandExecution_Executed;
    assert mismatched_mask == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[1]].valid;

    // GMOV is a fixed Core4 collective and rejects any mask other than 1111.
    ResetProfileState();
    let gmov_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01101', Zeros{5} + 24), 32);
    let partial_gmov = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0111', Zeros{6}, TRUE), 32);
    assert gmov_start == CommandExecution_Executed;
    assert partial_gmov == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTileBindingV5Schemas();
    return 0;
end;
