// PTO-TEST: {"id":"PTO-AVS-BLOCK-ROW-EXPAND-BROADCAST-BYTE-OFFSET-R2-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWEXPAND-CONTRACT-001"],"kind":"execution","summary":"Decoded CUBE_M32 TROWEXPAND interprets B.DATR.RMode as a BF16 byte offset and splats the selected raw element.","pass_condition":"offset 2 selects BF16 slot 1 in each row, preserves raw bits without numeric status, and publishes the expected CUBE destination","related_sources":["asl/block/attributes/B.DATR.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl"]}
pure func RowBroadcastCopyStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00100';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_BF16);
    return instruction;
end;

pure func RowBroadcastAttributes(offset: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[17:15] = offset;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

pure func RowBroadcastCopyBinding(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func RunSelectedBF16Copy()
begin
    ResetProfileState();
    let broadcast_ready = ConfigureCubeTile(
        1, 128, 2, 2, TileDataType_BF16, TileLayout_CUBE_M32);
    assert broadcast_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4001);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4081);

    let started = ExecuteCommandInstruction(RowBroadcastCopyStart(), 32);
    let attributed = ExecuteCommandInstruction(
        RowBroadcastAttributes(Zeros{3} + 2), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowBroadcastCopyBinding(Zeros{6} + 1), 32);
    assert binding == CommandExecution_Executed;

    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x4001;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x4001;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0x4081;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 0x4081;
    assert _Tiles[[1]].data_type == TileDataType_BF16;
    assert NumericStatusFlags() == Zeros{5};
end;

func main() => integer
begin
    RunSelectedBF16Copy();
    return 0;
end;
