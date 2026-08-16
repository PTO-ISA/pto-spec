// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-PARTIAL-EXEC-004","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":[],"kind":"execution","summary":"Shared TLSU partial masks permit undefined lanes and reject descriptor mismatch","pass_condition":"partial-lane and descriptor mismatch assertions hold","related_sources":[]}
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

pure func BundleTestSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func BundleTestSharedBindingV6(shared_id: bits(8),
                                   tile_size: bits(3),
                                   pe_mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = pe_mask;
    instruction[11:9] = tile_size;
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

pure func BundleTestTileDestinationV5(tile_size: bits(3),
                                      destination: bits(2),
                                      pe_mask: bits(4), last: boolean)
                                      => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = pe_mask;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func TestBundleSharedTLSUPartial()
begin
    // Insert creates a one-PE allocation while the Local source persists.
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    let insert_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let insert_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '001', '0001'), 32);
    let insert_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0001', Zeros{6}, TRUE), 32);
    assert insert_start == CommandExecution_Executed;
    assert insert_shared == CommandExecution_Executed;
    assert insert_local == CommandExecution_Executed;
    assert _BundleOperation.selector == Zeros{10} + 9;
    assert BundleSharedTLSUSelected();
    assert BundleSharedBindingCount() == 1;
    assert BundleTileBindingCount() == 1;
    assert _BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].source0_valid;
    assert !_BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].last;
    assert _BundleTileBindings[[0]].destination_size == 0;
    assert _BundleTileBindings[[0]].pe_mask == '0001';
    assert TileSourceContentsDefined(_BundleTileBindings[[0]].source0);
    assert _Tiles[[_BundleTileBindings[[0]].source0]].capacity_bytes == 128;
    assert BundleSharedTMOVLocalSchemaLegal();
    let insert_completed = ExecuteBundleTileOperation();
    assert insert_completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert SharedTileRecord(Zeros{8} + 23).allocation_mask == '0001';
    assert SharedTileRecord(Zeros{8} + 23).initialized_mask == '0001';
    assert SharedTileFullyInitialized(Zeros{8} + 23);
    assert _Tiles[[0]].allocated;

    // A read may select an unallocated Shared PE lane. That lane has
    // undefined-register value behavior rather than raising a fault.
    ResetBundleControlState();
    let partial_broadcast_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01100', Zeros{5} + 24), 32);
    let partial_broadcast_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '000', '0011'), 32);
    let partial_broadcast_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '0011', TRUE), 32);
    assert partial_broadcast_start == CommandExecution_Executed;
    assert partial_broadcast_shared == CommandExecution_Executed;
    assert partial_broadcast_destination == CommandExecution_Executed;
    let partial_broadcast_completed = ExecuteBundleTileOperation();
    assert partial_broadcast_completed;
    assert _LastFault == Fault_None;

    ResetBundleControlState();
    ClearFault();
    let partial_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01110', Zeros{5} + 24), 32);
    let partial_store_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '000', '0011'), 32);
    let partial_store_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert partial_store_start == CommandExecution_Executed;
    assert partial_store_shared == CommandExecution_Executed;
    assert partial_store_address == CommandExecution_Executed;
    let partial_store_completed = ExecuteBundleTileOperation();
    assert partial_store_completed;
    assert _LastFault == Fault_None;

    // A partial Local-to-Shared descriptor mismatch is rejected before the
    // source lifetime or Shared record changes.
    ResetBundleControlState();
    ClearFault();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 10);
    let mismatch_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let mismatch_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '001', '0010'), 32);
    let mismatch_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '0010', Zeros{6}, TRUE), 32);
    assert mismatch_start == CommandExecution_Executed;
    assert mismatch_shared == CommandExecution_Executed;
    assert mismatch_local == CommandExecution_Executed;
    assert !BundleSharedTMOVLocalSchemaLegal();
    let mismatch_completed = ExecuteBundleTileOperation();
    assert !mismatch_completed;
    assert _LastFault == Fault_TileLegality;
    assert SharedTileRecord(Zeros{8} + 23).tile.columns == 1;
    assert _Tiles[[0]].allocated;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUPartial();
    return 0;
end;
