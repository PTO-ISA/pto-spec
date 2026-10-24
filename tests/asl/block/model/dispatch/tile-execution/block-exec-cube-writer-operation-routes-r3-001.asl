// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-WRITER-OPERATION-ROUTES-R3-001","source":"asl/block/model/dispatch/tile-execution.asl","requirements":["PTO-TGPR2T-CONTRACT-001","PTO-TSEL-CONTRACT-001","PTO-TADD-CONTRACT-001","PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001"],"kind":"execution","summary":"TGPR2T, CUBE TSEL, and U8 TADD execute against bounded writer values and capacity-derived parents.","pass_condition":"Each producer publishes values through a 128-byte INIT_LAST writer in a 256-byte parent, with operation-derived valid geometry and larger capacity-derived physical columns retained.","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/block/model/dispatch/predicate-destination.asl","asl/block/model/dispatch/tgpr2t-schema.asl","asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/execution/predicate-carriers-value.asl","asl/tile/model/execution/elementwise.asl"]}

pure func R3OperationStart(selector: bits(10),
                           data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func R3M32Attribute() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

pure func R3TGPR2TAttribute(layout: bits(5), pad: bits(2),
                            rmode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = layout;
    instruction[28:27] = pad;
    instruction[17:15] = rmode;
    return instruction;
end;

func R3InstallWriter(binding: BundleTileBindingIndex)
begin
    _BundleTileBindings[[binding]].destination_size = 2;
    _BundleTileBindings[[binding]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.init = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.last = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.size_code = 1;
    _BundleTileBindings[[binding]].destination_assemble.offset =
        Zeros{PTO_XLEN};
end;

func TestR3TGPR2TWriterValue()
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10} + 0x07e, TileDataType_U8), 32);
    let attributes = ExecuteCommandInstruction(
        R3TGPR2TAttribute(Zeros{5}, '01', '001'), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000000000001);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x0000000000010000);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x0000000100000000);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x0001000000000000);
    SetBundleScalarBinding(0, 0, 2, 3, 4, 3);
    SetBundleScalarBinding(1, 0, 5, 0, 0, 1);
    AddBundleTileBinding(TRUE, 3, 2, '1111', FALSE, FALSE,
        0, 0, TRUE);
    R3InstallWriter(0);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x07e) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           SelectedBundleClosedTGPR2TSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 16 &&
           _Tiles[[destination]].columns == 16 &&
           _Tiles[[destination]].valid_rows == 16 &&
           _Tiles[[destination]].valid_columns == 8;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 0x21 &&
           ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 0x84 &&
           ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0xff &&
           ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xff &&
           ReadTileElement(destination, 0, 4) == Zeros{PTO_XLEN} + 0xff;
end;

func TestR3TSELWriterValue()
begin
    ResetProfileState();
    let source_true = ConfigureCubeTile(10, 128, 1, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    let source_false = ConfigureCubeTile(11, 128, 1, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert source_true && source_false;
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 21);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 11);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10} + 0x01a, TileDataType_U32), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    WriteGPR(2, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, 2, '1111', TRUE, TRUE,
        10, 11, TRUE);
    R3InstallWriter(0);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x01a) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation) &&
           SelectedBundleClosedTSELSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 16 &&
           _Tiles[[destination]].columns == 4 &&
           _Tiles[[destination]].valid_rows == 1 &&
           _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 20 &&
           ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 11;
end;

func TestR3TADDWriterValue()
begin
    ResetProfileState();
    let left = ConfigureCubeTile(1, 128, 16, 8,
        TileDataType_U8, TileLayout_CUBE_M16);
    let right = ConfigureCubeTile(2, 128, 16, 8,
        TileDataType_U8, TileLayout_CUBE_M16);
    assert left && right;
    for row = 0 to 15 looplimit 16 do
        for column = 0 to 7 looplimit 8 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 3);
            WriteTileElement(2, row, column, Zeros{PTO_XLEN} + 5);
        end;
    end;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10}, TileDataType_U8), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5} + 31,
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(TRUE, 0, 2, '1111', TRUE, TRUE,
        1, 2, TRUE);
    R3InstallWriter(0);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12}) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation) &&
           SelectedBundleClosedBinarySchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 16 &&
           _Tiles[[destination]].columns == 16 &&
           _Tiles[[destination]].valid_rows == 16 &&
           _Tiles[[destination]].valid_columns == 8;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 8 &&
           ReadTileElement(destination, 15, 7) == Zeros{PTO_XLEN} + 8;
end;

func main() => integer
begin
    TestR3TGPR2TWriterValue();
    TestR3TSELWriterValue();
    TestR3TADDWriterValue();
    return 0;
end;
