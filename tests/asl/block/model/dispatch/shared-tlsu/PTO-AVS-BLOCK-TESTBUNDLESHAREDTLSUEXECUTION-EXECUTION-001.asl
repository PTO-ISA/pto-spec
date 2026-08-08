// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLESHAREDTLSUEXECUTION-EXECUTION-001","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestBundleSharedTLSUExecution","pass_condition":"TestBundleSharedTLSUExecution completes without assertion failure","related_sources":[]}
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

func TestBundleSharedTLSUExecution()
begin
    // GM-to-Shared takes its per-PE size and mask from destination B.IOS.
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 0x2a;
    WriteGPR(2, Zeros{PTO_XLEN});
    let load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let load_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 17, '001', '1111'), 32);
    let load_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert load_start == CommandExecution_Executed;
    assert load_shared == CommandExecution_Executed;
    assert load_address == CommandExecution_Executed;
    let load_completed = ExecuteBundleTileOperation();
    assert load_completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert SharedTileFullyInitialized(Zeros{8} + 17);
    assert SharedTileRecord(Zeros{8} + 17).tile.capacity_bytes == 128;
    assert SharedTileRecord(Zeros{8} + 17).tile.payload[[0]] ==
        Zeros{PTO_XLEN} + 0x2a;

    // An unmasked Shared store reads all four quarters.
    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    let store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    let store_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 17), 32);
    let store_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert store_start == CommandExecution_Executed;
    assert store_shared == CommandExecution_Executed;
    assert store_address == CommandExecution_Executed;
    let store_completed = ExecuteBundleTileOperation();
    assert store_completed;
    assert _Memory[[8]] == Zeros{8} + 0x2a;

    // Shared TSTORE uses omitted B.IOR's LB2/Col default, not the persistent
    // Shared descriptor's column count.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    InstallSharedTile(Zeros{8} + 18, _Tiles[[0]], '1111');
    let lb2_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    let lb2_store_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 18), 32);
    assert lb2_store_start == CommandExecution_Executed;
    assert lb2_store_shared == CommandExecution_Executed;
    let lb2_store_completed = ExecuteBundleTileOperation();
    assert lb2_store_completed;
    assert _Memory[[0]] == Zeros{8} + 1;
    assert _Memory[[8]] == Zeros{8} + 2;
    assert _Memory[[24]] == Zeros{8} + 3;
    assert _Memory[[32]] == Zeros{8} + 4;

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
        BundleTestSharedBindingV6(Zeros{8} + 255, '001', Zeros{4}), 32);
    let zero_load_unused_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    assert zero_load_start == CommandExecution_Executed;
    assert zero_load_shared == CommandExecution_Executed;
    assert zero_load_unused_ior == CommandExecution_Executed;
    let zero_load_completed = ExecuteBundleTileOperation();
    assert zero_load_completed;
    assert _LastFault == Fault_None;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !SharedTileRecord(Zeros{8} + 255).descriptor_valid;

    // Nonzero fields in an otherwise unused B.IOR reject a Shared TMOV before
    // either the Shared destination or Local source lifetime changes.
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    let invalid_publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let invalid_publish_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 18, '001', '1111'), 32);
    let invalid_publish_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    let invalid_publish_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    assert invalid_publish_start == CommandExecution_Executed;
    assert invalid_publish_shared == CommandExecution_Executed;
    assert invalid_publish_local == CommandExecution_Executed;
    assert invalid_publish_ior == CommandExecution_Executed;
    let invalid_publish_completed = ExecuteBundleTileOperation();
    assert !invalid_publish_completed;
    assert _LastFault == Fault_BundleControl;
    assert !SharedTileRecord(Zeros{8} + 18).descriptor_valid;
    assert _Tiles[[0]].allocated;

    // Publish creates a fully initialized register; an explicitly encoded
    // all-zero B.IOR is legal and equivalent to omission for this schema.
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    let publish_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let publish_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 19, '001', '1111'), 32);
    let publish_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    let publish_zero_ior = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert publish_start == CommandExecution_Executed;
    assert publish_shared == CommandExecution_Executed;
    assert publish_local == CommandExecution_Executed;
    assert publish_zero_ior == CommandExecution_Executed;
    let publish_completed = ExecuteBundleTileOperation();
    assert publish_completed;
    assert SharedTileFullyInitialized(Zeros{8} + 19);
    assert !_Tiles[[0]].allocated;

    ResetBundleControlState();
    let broadcast_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01011', Zeros{5} + 24), 32);
    let broadcast_shared = ExecuteCommandInstruction(
        BundleTestSharedBinding(Zeros{8} + 19), 32);
    let broadcast_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '01', '1111', TRUE), 32);
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
        BundleTestSharedBinding(Zeros{8} + 19), 32);
    let extract_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '10', '1111', TRUE), 32);
    assert extract_start == CommandExecution_Executed;
    assert extract_shared == CommandExecution_Executed;
    assert extract_destination == CommandExecution_Executed;
    let extract_completed = ExecuteBundleTileOperation();
    assert extract_completed;
    let extract_tile = _BundleTileBindings[[0]].destination;
    assert _Tiles[[extract_tile]].capacity_bytes == 128;
    assert ReadTileElement(extract_tile, 0, 0) ==
        Zeros{PTO_XLEN} + 11;

    // Insert creates a one-PE allocation and consumes the Local source.
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
    assert !_Tiles[[0]].allocated;

    // A read may select an unallocated Shared PE lane. That lane has
    // undefined-register value behavior rather than raising a fault.
    ResetBundleControlState();
    let partial_broadcast_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01011', Zeros{5} + 24), 32);
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

    // A zero-masked Local-to-Shared move is a true no-op: it neither updates
    // the Shared record nor consumes the encoded last-use source lifetime.
    let zero_insert_mask =
        SharedTileRecord(Zeros{8} + 23).initialized_mask;
    let zero_insert_value =
        ReadSharedTileWord(Zeros{8} + 23, 0);
    ResetBundleControlState();
    ClearFault();
    let zero_insert_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01001', Zeros{5} + 24), 32);
    let zero_insert_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '001', Zeros{4}), 32);
    let zero_insert_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', Zeros{4}, Zeros{6}, TRUE), 32);
    assert zero_insert_start == CommandExecution_Executed;
    assert zero_insert_shared == CommandExecution_Executed;
    assert zero_insert_local == CommandExecution_Executed;
    let zero_insert_completed = ExecuteBundleTileOperation();
    assert zero_insert_completed;
    assert _LastFault == Fault_None;
    assert !_BundleSharedBindings[[0]].consumed;
    assert _Tiles[[0]].allocated;
    assert SharedTileRecord(Zeros{8} + 23).initialized_mask ==
        zero_insert_mask;
    assert ReadSharedTileWord(Zeros{8} + 23, 0) ==
        zero_insert_value;

    // A zero-masked Shared-to-Local move is a true no-op and therefore does
    // not allocate its encoded Local destination.
    ResetBundleControlState();
    ClearFault();
    let zero_extract_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01100', Zeros{5} + 24), 32);
    let zero_extract_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '000', Zeros{4}), 32);
    let zero_extract_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '10', Zeros{4}, TRUE), 32);
    assert zero_extract_start == CommandExecution_Executed;
    assert zero_extract_shared == CommandExecution_Executed;
    assert zero_extract_destination == CommandExecution_Executed;
    let zero_extract_completed = ExecuteBundleTileOperation();
    assert zero_extract_completed;
    assert _LastFault == Fault_None;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // Function 14 is the accepted partition-store encoding variant.
    ResetBundleControlState();
    ClearFault();
    _SystemRegisters.thread_id = Zeros{PTO_XLEN};
    WriteGPR(2, Zeros{PTO_XLEN} + 16);
    let partition_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01110', Zeros{5} + 24), 32);
    let partition_shared = ExecuteCommandInstruction(
        BundleTestSharedBindingV6(Zeros{8} + 23, '000', '0001'), 32);
    let partition_address = ExecuteCommandInstruction(
        BundleTestScalarBinding('00000', '00010', '00000', '00000'), 32);
    assert partition_start == CommandExecution_Executed;
    assert partition_shared == CommandExecution_Executed;
    assert partition_address == CommandExecution_Executed;
    let partition_completed = ExecuteBundleTileOperation();
    assert partition_completed;
    assert _Memory[[16]] == Zeros{8} + 7;

    // Shared encoding variants are not executable without their binder.
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    let missing_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('01010', Zeros{5} + 24), 32);
    let missing_local = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    assert missing_start == CommandExecution_Executed;
    assert missing_local == CommandExecution_Executed;
    let missing_completed = ExecuteBundleTileOperation();
    assert !missing_completed;
    assert _LastFault == Fault_TileLegality;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUExecution();
    return 0;
end;
