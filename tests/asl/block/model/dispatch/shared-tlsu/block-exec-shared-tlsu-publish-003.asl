// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-PUBLISH-EXEC-003","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-INST-BLOCK-B-ASSEMBLE","PTO-B-ASSEMBLE-SHARED-STANDALONE-001"],"kind":"execution","summary":"Shared TLSU publish, broadcast, and extract preserve descriptor semantics","pass_condition":"collective INIT_LAST publish, broadcast, and extract assertions hold","related_sources":["asl/block/operands/B.ASSEMBLE.asl","asl/block/model/operands/shared-generation.asl"]}
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

pure func BundleTestSharedAssemble(parent_size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = parent_size_code;
    return instruction;
end;

func TestBundleSharedTLSUPublish()
begin
    // Publish creates a fully initialized register; an explicitly encoded
    // all-zero B.IOR is legal and equivalent to omission for this schema.
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    let publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let publish_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{6} + 19, '0001', '111'), 32);
    let publish_assemble = ExecuteCommandInstruction(
        BundleTestSharedAssemble('0001'), 32);
    let publish_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('0000', '00', '111', Zeros{6}, TRUE), 32);
    let publish_zero_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert publish_start == CommandExecution_Executed;
    assert publish_shared == CommandExecution_Executed;
    assert publish_assemble == CommandExecution_Executed;
    assert publish_local == CommandExecution_Executed;
    assert publish_zero_ior == CommandExecution_Executed;
    let publish_completed = ExecuteBundleTileOperation();
    assert publish_completed;
    assert SharedTileFullyInitialized((Zeros{6} + 19) as SharedTileID);
    assert _Tiles[[0]].allocated;

    ResetBundleControlState();
    let broadcast_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01011', Zeros{5} + 24), 32);
    let broadcast_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{6} + 19), 32);
    let broadcast_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('0001', '01', '111', TRUE), 32);
    assert broadcast_start == CommandExecution_Executed;
    assert broadcast_shared == CommandExecution_Executed;
    assert broadcast_destination == CommandExecution_Executed;
    let broadcast_completed = ExecuteBundleTileOperation();
    assert broadcast_completed;
    let broadcast_tile = _BundleTileBindings[[0]].destination;
    assert _Tiles[[broadcast_tile]].capacity_bytes == 128;
    assert ReadTileElement(broadcast_tile, 0, 0) ==
        Zeros{PTO_XLEN} + 11;

    ResetBundleControlState();
    let extract_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01100', Zeros{5} + 24), 32);
    let extract_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{6} + 19), 32);
    let extract_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('0001', '10', '111', TRUE), 32);
    assert extract_start == CommandExecution_Executed;
    assert extract_shared == CommandExecution_Executed;
    assert extract_destination == CommandExecution_Executed;
    let extract_completed = ExecuteBundleTileOperation();
    assert extract_completed;
    let extract_tile = _BundleTileBindings[[0]].destination;
    assert _Tiles[[extract_tile]].capacity_bytes == 128;
    assert ReadTileElement(extract_tile, 0, 0) ==
        Zeros{PTO_XLEN} + 11;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUPublish();
    return 0;
end;
