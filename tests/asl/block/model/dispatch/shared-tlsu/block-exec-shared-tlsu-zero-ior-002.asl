// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-ZERO-IOR-EXEC-002","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":[],"kind":"execution","summary":"Shared TLSU zero masks are no-ops and unused B.IOR fields reject","pass_condition":"zero-mask no-effect and invalid B.IOR rejection assertions hold","related_sources":[]}
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

func TestBundleSharedTLSUZeroMaskAndIOR()
begin
    // B.IOS mask 0000 is a true no-op that performs no memory access, does not
    // initialize the Shared destination, and does not need a B.IOT companion.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 4096);
    let zero_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let zero_load_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{6} + 63, '0001', Zeros{3}), 32);
    let zero_load_unused_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    assert zero_load_start == CommandExecution_Executed;
    assert zero_load_shared == CommandExecution_Executed;
    assert zero_load_unused_ior == CommandExecution_Executed;
    let zero_load_completed = ExecuteBundleTileOperation();
    assert zero_load_completed;
    assert _LastFault == Fault_None;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !SharedTileRecord((Zeros{6} + 63) as SharedTileID).descriptor_valid;

    // Nonzero fields in an otherwise unused B.IOR reject a Shared TMOV before
    // either the Shared destination or Local source lifetime changes.
    ResetProfileState();
    ConfigureTileForMask(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any, '1000');
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    let invalid_publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let invalid_publish_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{6} + 18, '0001', '001'), 32);
    let invalid_publish_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('0000', '00', '001', Zeros{6}, TRUE), 32);
    let invalid_publish_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    assert invalid_publish_start == CommandExecution_Executed;
    assert invalid_publish_shared == CommandExecution_Executed;
    assert invalid_publish_local == CommandExecution_Executed;
    assert invalid_publish_ior == CommandExecution_Executed;
    let invalid_publish_completed = ExecuteBundleTileOperation();
    assert !invalid_publish_completed;
    assert _LastFault == Fault_BundleControl;
    assert !SharedTileRecord((Zeros{6} + 18) as SharedTileID).descriptor_valid;
    assert _Tiles[[0]].allocated;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUZeroMaskAndIOR();
    return 0;
end;
