// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-MASK-PARTITION-EXEC-005","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":[],"kind":"execution","summary":"Shared TLSU zero-mask moves and partition stores preserve state","pass_condition":"zero-mask and partition-store assertions hold","related_sources":[]}
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

func TestBundleSharedTLSUMaskAndPartition()
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
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleSharedTLSUMaskAndPartition();
    return 0;
end;
