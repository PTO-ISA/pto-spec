// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-REDUCTION-BUNDLE-002","source":"asl/block/model/dispatch/reduction-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWSUM-CONTRACT-001"],"kind":"execution","summary":"A decoded direct-layout B.DATR drives CUBE reduction schema validation, destination allocation, execution, and atomic publication for a source above 2 KiB.","pass_condition":"CUBE_M16 TROWSUM bundles allocate and publish the exact reduced shape for both 128-byte and 4096-byte sources.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func CubeReductionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func DirectCubeLayoutAttribute(layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

func PrepareCubeReduction(source_capacity: integer {128,4096})
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(1, source_capacity, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 4);
    let started = ExecuteCommandInstruction(CubeReductionStart(), 32);
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
    PrepareCubeReduction(128);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].columns > 1;
    assert _Tiles[[destination]].contents_defined;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert TileElementDefined(destination, 0, 1);
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};

    PrepareCubeReduction(4096);
    let expanded = ExecuteBundleTileOperation();
    assert expanded;
    assert _LastFault == Fault_None;
    let expanded_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[expanded_destination]].columns == 2;
    assert _Tiles[[expanded_destination]].rows == 16;
    return 0;
end;
