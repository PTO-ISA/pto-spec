// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-BINDER-EXEC-006","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":[],"kind":"execution","summary":"Canonical TMOV rejects an incomplete binding schema without effects.","pass_condition":"A source-only Function 2 block without its Local destination or Shared binder raises BundleControl before effects.","related_sources":["asl/block/model/dispatch/tile-execution.asl"]}
pure func BundleTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTileBindingV5(size_code: bits(4), destination: bits(2),
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

pure func BundleTestSharedBinding(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

pure func BundleTestSharedBindingV6(shared_tile_id: bits(6),
                                   size_code: bits(4),
                                   pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5))
                                  => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func BundleTestTileDestinationV5(size_code: bits(4),
                                      destination: bits(2),
                                      pe_mode: bits(3), last: boolean)
                                      => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = destination;
    instruction[11:9] = pe_mode;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleSharedTLSUMissingBinder()
begin
    // Canonical Function 2 cannot select a Shared direction without B.IOS and
    // the remaining Local-only binding is incomplete.
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    let missing_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00010', Zeros{5} + 24), 32);
    let missing_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('0000', '00', '111', Zeros{6}, TRUE), 32);
    assert missing_start == CommandExecution_Executed;
    assert missing_local == CommandExecution_Executed;
    let missing_completed = ExecuteBundleTileOperation();
    assert !missing_completed;
    assert _LastFault == Fault_BundleControl;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUMissingBinder();
    return 0;
end;
