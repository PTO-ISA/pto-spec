// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPACK-TUNPACK-EXPANSION-VIEW-R4-001","source":"asl/block/model/dispatch/cell-rearrangement-schema.asl","requirements":["PTO-TPACK-CONTRACT-001","PTO-TUNPACK-CONTRACT-001","PTO-TROWEXPANDMUL-CONTRACT-001"],"kind":"execution","summary":"Decoded BSTART type controls pack/unpack destination geometry and expansion source operation views while preserving source backing descriptors.","pass_condition":"Decoded TPACK creates U8 [2,4] from one-byte U8 sources, TUNPACK creates U16 [2,2] from a BF16 source word, and TROWEXPANDMUL.BF16 executes with U16 and BF16 source backing.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/expansion-schema.asl","asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/rearrangement.asl","asl/tile/model/execution/expansion.asl"]}
pure func OperationStart(code: bits(12), data_type: TileDataType)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = code[6:5];
    instruction[24:20] = code[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func CubeM32Attribute() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

func BeginOperation(code: bits(12), data_type: TileDataType)
begin
    let started = ExecuteCommandInstruction(
        OperationStart(code, data_type), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(CubeM32Attribute(), 32);
    assert attributed == CommandExecution_Executed;
end;

func TestDecodedTPACK()
begin
    ResetProfileState();
    let source0 = ConfigureCubeTile(1, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let source1 = ConfigureCubeTile(2, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert source0 && source1;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x12);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x21);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0x22);

    BeginOperation(Zeros{12} + 0x077, TileDataType_U8);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000101);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x077)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleCellRearrangementSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U8;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 4;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x21;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0x12;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 0x22;
end;

func TestDecodedTUNPACK()
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert source;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4080);

    BeginOperation(Zeros{12} + 0x078, TileDataType_U16);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000202);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x078)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleCellRearrangementSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U16;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0x4080;
end;

func TestDecodedExpansionOperationView()
begin
    ResetProfileState();
    let full_source = ConfigureCubeTile(1, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    let broadcast = ConfigureCubeTile(2, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert full_source && broadcast;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x4140);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 0x4180);

    BeginOperation(Zeros{12} + 0x047, TileDataType_BF16);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x047)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert CurrentBundleTileLayout() == TileLayout_CUBE_M32;
    assert TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding) == TileDataType_BF16;
    assert SelectedBundleComparisonDimensionsLegal();
    assert TileExpansionBroadcastLegalAs(
        2, TileAxis_Row, TileDataType_BF16);
    assert TileReductionAndExpansionSourceLegalAs(
        1, TileDataType_BF16);
    assert SelectedBundleComparisonShapeMatches(1);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x4080;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0x4110;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 0x4140;
    assert _Tiles[[1]].data_type == TileDataType_U16;
    assert _Tiles[[2]].data_type == TileDataType_BF16;
end;

func main() => integer
begin
    TestDecodedTPACK();
    TestDecodedTUNPACK();
    TestDecodedExpansionOperationView();
    return 0;
end;
