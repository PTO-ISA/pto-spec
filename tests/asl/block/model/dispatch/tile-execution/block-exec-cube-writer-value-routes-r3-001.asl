// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-WRITER-REARRANGEMENT-R3-001","source":"asl/block/model/dispatch/tile-execution.asl","requirements":["PTO-INST-TILE-TPERMUTE","PTO-INST-TILE-TSHUF","PTO-TPACK-CONTRACT-001","PTO-TUNPACK-CONTRACT-001","PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001"],"kind":"execution","summary":"CUBE rearrangement producers execute against exact B.ASSEMBLE writer values while retaining larger capacity-derived parents.","pass_condition":"TSHUF, TPERMUTE, TPACK, and TUNPACK publish their operation-derived writer values through 128-byte INIT_LAST ranges in 256-byte parents; every parent retains capacity-derived physical geometry and correct valid-prefix values.","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/block/model/dispatch/cell-rearrangement-schema.asl","asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/execution/rearrangement.asl"]}

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

func TestR3TSHUFWriterValue()
begin
    ResetProfileState();
    let source0 = ConfigureCubeTile(1, 128, 2, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    let source1 = ConfigureCubeTile(2, 128, 2, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    assert source0 && source1;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10} + 0x076, TileDataType_U32), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000302);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 3, 2, '1111', TRUE, TRUE,
        1, 2, TRUE);
    R3InstallWriter(0);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x076) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert started == CommandExecution_Executed &&
           SelectedBundleCellRearrangementSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 32 &&
           _Tiles[[destination]].columns == 2 &&
           _Tiles[[destination]].valid_rows == 2 &&
           _Tiles[[destination]].valid_columns == 1;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 2 &&
           ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 1;
end;

func TestR3TPERMUTEWriterValue()
begin
    ResetProfileState();
    let first = ConfigureCubeTile(1, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    let second = ConfigureCubeTile(2, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    let selector = ConfigureCubeTile(4, 128, 1, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert first && second && selector;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x04030201);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x08070605);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(4, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 3, Zeros{PTO_XLEN} + 5);
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10} + 0x075, TileDataType_U32), 32);
    AddBundleTileBinding(FALSE, 0, 1, '1111', TRUE, TRUE,
        1, 2, FALSE);
    AddBundleTileBinding(TRUE, 3, 2, '1111', TRUE, FALSE,
        4, 0, TRUE);
    R3InstallWriter(1);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x075) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert started == CommandExecution_Executed &&
           BundleOperationBindingsComplete(operation) &&
           SelectedBundleCellRearrangementSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 32 &&
           _Tiles[[destination]].columns == 2 &&
           _Tiles[[destination]].valid_rows == 1 &&
           _Tiles[[destination]].valid_columns == 1;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x06020501;
end;

func TestR3TPACKWriterValue()
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
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10} + 0x077, TileDataType_U8), 32);
    let attributes = ExecuteCommandInstruction(R3M32Attribute(), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000101);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 3, 2, '1111', TRUE, TRUE,
        1, 2, TRUE);
    R3InstallWriter(0);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x077) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           BundleOperationBindingsComplete(operation) &&
           SelectedBundleCellRearrangementSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 32 &&
           _Tiles[[destination]].columns == 8 &&
           _Tiles[[destination]].valid_rows == 2 &&
           _Tiles[[destination]].valid_columns == 4;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x21;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x12;
    assert ReadTileElement(destination, 1, 1) ==
        Zeros{PTO_XLEN} + 0x22;
end;

func TestR3TUNPACKWriterValue()
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert source;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    let started = ExecuteCommandInstruction(
        R3OperationStart(Zeros{10} + 0x078, TileDataType_U16), 32);
    let attributes = ExecuteCommandInstruction(R3M32Attribute(), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000202);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 3, 2, '1111', TRUE, FALSE,
        1, 0, TRUE);
    R3InstallWriter(0);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x078) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].capacity_bytes == 256 &&
           _Tiles[[destination]].rows == 32 &&
           _Tiles[[destination]].columns == 4 &&
           _Tiles[[destination]].valid_rows == 2 &&
           _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x4000 &&
           ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} &&
           ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0x4080;
end;

func main() => integer
begin
    TestR3TSHUFWriterValue();
    TestR3TPERMUTEWriterValue();
    TestR3TPACKWriterValue();
    TestR3TUNPACKWriterValue();
    return 0;
end;
