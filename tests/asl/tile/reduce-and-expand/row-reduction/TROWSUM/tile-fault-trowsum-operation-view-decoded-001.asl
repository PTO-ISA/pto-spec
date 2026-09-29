// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-OPERATION-VIEW-DECODED-FAULTS-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"Decoded TROWSUM bundles reject width, packed, RCPE6M2, malformed operation-view payload, and unsupported operation-type cases.","pass_condition":"Each active BSTART/B.IOT/TEPL case completes with Fault_TileLegality and no destination publication, capacity use, status update, or source descriptor/payload change; the malformed payload uses a legal U32 backing tag but is invalid under the selected TF32 operation type.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowsumDecodedFaultStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = data_type;
    return instruction;
end;

pure func TrowsumDecodedFaultBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    return instruction;
end;

func AssertDecodedTrowsumViewFault(
    source_type: TileDataType,
    operation_type: TileDataType,
    first: Word,
    second: Word)
begin
    ResetProfileState();
    ConfigureTile(1, 128, 32, 4, 1, 2,
        source_type, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, first);
    WriteTileElement(1, 0, 1, second);
    let source_before = _Tiles[[1]];
    let capacity_before = CoreTileCapacityInUse();
    let status_before = NumericStatusFlags();
    let raw_first = ReadTileElement(1, 0, 0);
    let raw_second = ReadTileElement(1, 0, 1);

    let started = ExecuteCommandInstruction(
        TrowsumDecodedFaultStart(TileDataTypeToEncoding(operation_type)), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(
        TrowsumDecodedFaultBinding(), 32);
    assert bound == CommandExecution_Executed;

    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert !SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert CoreTileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == status_before;
    assert _Tiles[[1]].data_type == source_before.data_type;
    assert _Tiles[[1]].allocated == source_before.allocated;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert _Tiles[[1]].contents_defined == source_before.contents_defined;
    assert ReadTileElement(1, 0, 0) == raw_first;
    assert ReadTileElement(1, 0, 1) == raw_second;
end;

func main() => integer
begin
    // The source encodings are legal U16 and FP32 bit patterns respectively;
    // the selected FP32 view is rejected because the carrier widths differ.
    AssertDecodedTrowsumViewFault(
        TileDataType_U16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN} + 0x4000);

    // A packed source pair cannot be reinterpreted as an unpacked U8 view.
    AssertDecodedTrowsumViewFault(
        TileDataType_E2M1X2, TileDataType_U8,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2);

    // RCPE6M2 remains excluded specifically as reduction backing.
    AssertDecodedTrowsumViewFault(
        TileDataType_RCPE6M2, TileDataType_U8,
        Zeros{PTO_XLEN} + 0x30, Zeros{PTO_XLEN} + 0x40);

    // 0x3f800001 has a legal U32 backing tag but is malformed under the
    // selected TF32 operation view. Reserved BSTART DataType encodings reject
    // at their separate decode boundary and are not bundle rollback cases.
    AssertDecodedTrowsumViewFault(
        TileDataType_U32, TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x3f800001,
        Zeros{PTO_XLEN} + 0x3f800000);

    // HiF8 is equal-width with U8, but it is not a supported TROWSUM type.
    AssertDecodedTrowsumViewFault(
        TileDataType_U8, TileDataType_HiF8,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2);
    return 0;
end;
