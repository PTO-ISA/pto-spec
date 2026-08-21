// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-SCHEMAS-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded B.IOT enforces operation-specific source and destination schemas.","pass_condition":"Local-to-Shared roles, common masks, source-only size zero, and partial GMOV participation are accepted or rejected before effects as specified.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/tile-bindings.asl"]}
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

pure func BundleTestTileBindingSchemas(size_code: bits(4),
                                      destination: bits(2),
                                      pe_mode: bits(3), source0: bits(6),
                                      last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = size_code;
    instruction[8:7] = destination;
    instruction[11:9] = pe_mode;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleTileBindingSchemas()
begin
    // TMOV Local-to-Shared uses Function 9/10. Its B.IOT is source-only:
    // Shared TSize belongs to destination B.IOS, while local TSize/DstTile
    // must both decode as absent.
    ResetProfileState();
    let insert_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let size_one = ExecuteCommandInstruction(
        BundleTestTileBindingSchemas('0001', '00', '101', Zeros{6}, TRUE), 32);
    assert insert_start == CommandExecution_Executed;
    assert size_one == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    ResetProfileState();
    let publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let size_seven = ExecuteCommandInstruction(
        BundleTestTileBindingSchemas('0001', '00', '101', Zeros{6}, TRUE), 32);
    assert publish_start == CommandExecution_Executed;
    assert size_seven == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    ResetProfileState();
    let zero_size_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let zero_size = ExecuteCommandInstruction(
        BundleTestTileBindingSchemas('0000', '00', '111', Zeros{6}, TRUE), 32);
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
        BundleTestTileBindingSchemas('0001', '01', '111', Zeros{6}, TRUE), 32);
    assert nonzero_destination_start == CommandExecution_Executed;
    assert nonzero_destination == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].valid;

    // Every B.IOT in one operation uses the same nonzero participant mask.
    ResetProfileState();
    let tepl_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let first_mask = ExecuteCommandInstruction(
        BundleTestTileBindingSchemas('0000', '00', '101', Zeros{6}, FALSE), 32);
    let mismatched_mask = ExecuteCommandInstruction(
        BundleTestTileBindingSchemas('0000', '00', '111', Zeros{6} + 1, TRUE), 32);
    assert tepl_start == CommandExecution_Executed;
    assert first_mask == CommandExecution_Executed;
    assert mismatched_mask == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[1]].valid;

    // GMOV remains a fixed Core4 rendezvous, but PE_MASK controls only which
    // Local destination fragments issue/write; a nonzero partial mask binds.
    ResetProfileState();
    let gmov_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01101', Zeros{5} + 24), 32);
    let partial_gmov = ExecuteCommandInstruction(
        BundleTestTileBindingSchemas('0000', '00', '110', Zeros{6}, TRUE), 32);
    assert gmov_start == CommandExecution_Executed;
    assert partial_gmov == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].pe_mask == '1110';
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTileBindingSchemas();
    return 0;
end;
