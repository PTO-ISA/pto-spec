// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLETLOADTSTOREROWSTRIDE-EXECUTION-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD"],"kind":"execution","summary":"migrated independent behavior point for TestBundleTLOADTSTORERowStride","pass_condition":"TestBundleTLOADTSTORERowStride completes without assertion failure","related_sources":[]}
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

func TestBundleTLOADTSTORERowStride()
begin
    // Complete local TLOAD bundles prove that the resolved B.IOR values drive
    // memory addressing, not merely the intermediate operand record.
    ResetProfileState();
    _Memory[[0x100]] = Zeros{8} + 1;
    _Memory[[0x108]] = Zeros{8} + 2;
    _Memory[[0x118]] = Zeros{8} + 3;
    _Memory[[0x120]] = Zeros{8} + 4;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x100);
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    let complete_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let complete_load_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    let complete_load_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert complete_load_start == CommandExecution_Executed;
    assert complete_load_destination == CommandExecution_Executed;
    assert complete_load_binding == CommandExecution_Executed;
    let complete_load = ExecuteBundleTileOperation();
    assert complete_load;
    let loaded_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(loaded_tile, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(loaded_tile, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(loaded_tile, 1, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(loaded_tile, 1, 1) == Zeros{PTO_XLEN} + 4;

    // Omitted B.IOR uses zero base and LB2 as dense row stride.
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 5;
    _Memory[[8]] = Zeros{8} + 6;
    _Memory[[32]] = Zeros{8} + 7;
    _Memory[[40]] = Zeros{8} + 8;
    let omitted_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let omitted_load_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    assert omitted_load_start == CommandExecution_Executed;
    assert omitted_load_destination == CommandExecution_Executed;
    let omitted_load = ExecuteBundleTileOperation();
    assert omitted_load;
    let omitted_loaded_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(omitted_loaded_tile, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(omitted_loaded_tile, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(omitted_loaded_tile, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(omitted_loaded_tile, 1, 1) == Zeros{PTO_XLEN} + 8;

    // An encoded zero stride aliases rows and is not replaced by LB2.
    ResetProfileState();
    _Memory[[0]] = Zeros{8} + 9;
    _Memory[[8]] = Zeros{8} + 10;
    let aliased_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let aliased_load_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    let aliased_load_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert aliased_load_start == CommandExecution_Executed;
    assert aliased_load_destination == CommandExecution_Executed;
    assert aliased_load_binding == CommandExecution_Executed;
    let aliased_load = ExecuteBundleTileOperation();
    assert aliased_load;
    let aliased_loaded_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(aliased_loaded_tile, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(aliased_loaded_tile, 0, 1) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(aliased_loaded_tile, 1, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(aliased_loaded_tile, 1, 1) == Zeros{PTO_XLEN} + 10;

    // Complete TSTORE bundles use the same unchanged RegSrc0/RegSrc1 fields.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 12);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 13);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 14);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    let complete_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    let complete_store_source = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    let complete_store_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert complete_store_start == CommandExecution_Executed;
    assert complete_store_source == CommandExecution_Executed;
    assert complete_store_binding == CommandExecution_Executed;
    let complete_store = ExecuteBundleTileOperation();
    assert complete_store;
    assert _Memory[[0x200]] == Zeros{8} + 11;
    assert _Memory[[0x208]] == Zeros{8} + 12;
    assert _Memory[[0x218]] == Zeros{8} + 13;
    assert _Memory[[0x220]] == Zeros{8} + 14;

    // Omitted TSTORE B.IOR also takes LB2, even when it differs from the
    // source tile descriptor's two columns.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 15);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 16);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 17);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 18);
    let omitted_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    let omitted_store_source = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    assert omitted_store_start == CommandExecution_Executed;
    assert omitted_store_source == CommandExecution_Executed;
    let omitted_store = ExecuteBundleTileOperation();
    assert omitted_store;
    assert _Memory[[0]] == Zeros{8} + 15;
    assert _Memory[[8]] == Zeros{8} + 16;
    assert _Memory[[24]] == Zeros{8} + 17;
    assert _Memory[[32]] == Zeros{8} + 18;

    // Encoded zero-stride TSTORE overwrites the first row in program order.
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 19);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 22);
    let aliased_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 24), 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let aliased_store_source = ExecuteCommandInstruction(
        BundleTestTileBindingV5('000', '00', '1111', Zeros{6}, TRUE), 32);
    let aliased_store_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert aliased_store_start == CommandExecution_Executed;
    assert aliased_store_source == CommandExecution_Executed;
    assert aliased_store_binding == CommandExecution_Executed;
    let aliased_store = ExecuteBundleTileOperation();
    assert aliased_store;
    assert _Memory[[0]] == Zeros{8} + 21;
    assert _Memory[[8]] == Zeros{8} + 22;

    // Packed four-bit bundles apply row stride to the logical element index
    // before selecting the containing byte and nibble, for both directions.
    ResetProfileState();
    _Memory[[0x300]] = Zeros{8} + 0x21;
    _Memory[[0x302]] = Zeros{8} + 0x43;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let packed_load_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00000', Zeros{5} + 28), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let packed_load_destination = ExecuteCommandInstruction(
        BundleTestTileDestinationV5('001', '00', '1111', TRUE), 32);
    let packed_load_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert packed_load_start == CommandExecution_Executed;
    assert packed_load_destination == CommandExecution_Executed;
    assert packed_load_binding == CommandExecution_Executed;
    let packed_load = ExecuteBundleTileOperation();
    assert packed_load;
    let packed_tile = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(packed_tile, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(packed_tile, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(packed_tile, 1, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(packed_tile, 1, 1) == Zeros{PTO_XLEN} + 4;

    ResetBundleControlState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x320);
    let packed_store_start = ExecuteCommandInstruction(
        BundleTestTLSUStart('00001', Zeros{5} + 28), 32);
    let packed_store_source = ExecuteCommandInstruction(
        BundleTestTileBindingV5(
            '000', '00', '1111', Zeros{6} + packed_tile, TRUE), 32);
    let packed_store_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert packed_store_start == CommandExecution_Executed;
    assert packed_store_source == CommandExecution_Executed;
    assert packed_store_binding == CommandExecution_Executed;
    let packed_store = ExecuteBundleTileOperation();
    assert packed_store;
    assert _Memory[[0x320]] == Zeros{8} + 0x21;
    assert _Memory[[0x322]] == Zeros{8} + 0x43;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTLOADTSTORERowStride();
    return 0;
end;
