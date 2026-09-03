// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-EXPANSION-BUNDLE-002","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWEXPAND-CONTRACT-001","PTO-TROWEXPANDADD-CONTRACT-001"],"kind":"execution","summary":"Decoded direct-layout B.DATR drives CUBE expansion schema validation, raw COPY, destination allocation, execution, and mixed-layout rejection.","pass_condition":"CUBE_M16 TROWEXPANDADD and raw TF32 TROWEXPAND bundles publish M16 destinations, while an M32 broadcast mismatch faults before destination allocation.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl"]}
pure func CubeExpansionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00101';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func CubeCopyStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00100';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_TF32);
    return instruction;
end;

pure func DirectCubeLayoutAttribute(layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

func PrepareCubeExpansion(broadcast_layout: TileLayout)
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 128, 2, 2,
        TileDataType_U8, TileLayout_CUBE_M16, TileLocation_Matrix);
    let broadcast = ConfigureCubeTile(2, 128, 2, 1,
        TileDataType_U8, broadcast_layout, TileLocation_Matrix);
    assert source && broadcast;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 40);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(CubeExpansionStart(), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(
        DirectCubeLayoutAttribute(Zeros{5} + 31), 32);
    assert attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
end;

func PrepareCubeCopy()
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 128, 2, 1,
        TileDataType_TF32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x3f800002);
    assert !TileNumericEncodingValid(
        TileDataType_TF32, Zeros{PTO_XLEN} + 0x3f800001);
    let started = ExecuteCommandInstruction(CubeCopyStart(), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(
        DirectCubeLayoutAttribute(Zeros{5} + 31), 32);
    assert attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
end;

func main() => integer
begin
    PrepareCubeExpansion(TileLayout_CUBE_M16);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x045)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].columns > 2;
    assert _Tiles[[destination]].contents_defined;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 42;
    assert TileElementDefined(destination, 0, 2);
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN};

    PrepareCubeCopy();
    let copied = ExecuteBundleTileOperation();
    assert copied;
    assert _LastFault == Fault_None;
    let copy_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[copy_destination]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(copy_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(copy_destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x3f800001;
    assert ReadTileElement(copy_destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x3f800002;
    assert ReadTileElement(copy_destination, 1, 1) ==
        Zeros{PTO_XLEN} + 0x3f800002;

    PrepareCubeExpansion(TileLayout_CUBE_M32);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
