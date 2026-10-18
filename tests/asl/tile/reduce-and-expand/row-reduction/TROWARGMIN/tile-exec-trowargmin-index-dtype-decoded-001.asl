// PTO-TEST: {"id":"PTO-AVS-TILE-TROWARGMIN-INDEX-DTYPE-DECODED-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMIN.asl","requirements":["PTO-INST-TILE-TROWARGMIN"],"kind":"execution","summary":"decoded TROWARGMIN publishes a U32 index destination and rejects S32 or S16 destinations before result publication","pass_condition":"the complete decoded bundle allocates and publishes U32 indices; direct semantic calls with manually preallocated S32 and S16 destinations fault atomically before result effects","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
pure func TrowargminIndexDtypeDecodedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '01101';
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

func PrepareDecodedTrowargmin()
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        2,
        4,
        2,
        3,
        TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 2, Zeros{PTO_XLEN} + 6);

    let started = ExecuteCommandInstruction(
        TrowargminIndexDtypeDecodedStart(),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        0,
        0,
        TRUE);
end;

func TestRejectedIndexDestination(data_type: TileDataType)
begin
    PrepareDecodedTrowargmin();
    let rejected_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x04D)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(rejected_operation) == TileOperation_TROWARGMIN;
    assert BundleOperationBindingsComplete(rejected_operation);
    assert SelectedBundleClosedReductionSchemaLegal(rejected_operation);
    let rejected_destination: TileIndex = 5;
    ConfigureTileForMask(rejected_destination, 128, 2, 1, 2, 1,
        data_type, TileLayout_RowMajor, '1111');
    WriteTileElement(rejected_destination, 0, 0,
        Zeros{PTO_XLEN} + 0x55);
    MarkTileValidRegionDefined(rejected_destination);
    _BundleTileBindings[[0]].destination = rejected_destination;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    assert _Tiles[[rejected_destination]].data_type == data_type;
    let source_before = ReadTileElement(0, 0, 0);
    let destination_before = ReadTileElement(rejected_destination, 0, 0);
    let (rejected_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x04D,
        BundleTileInstructionOperands(rejected_operation));
    assert rejected_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == source_before;
    assert ReadTileElement(rejected_destination, 0, 0) == destination_before;
    assert _Tiles[[rejected_destination]].allocated;
end;

func main() => integer
begin
    PrepareDecodedTrowargmin();
    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x04D)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(operation) == TileOperation_TROWARGMIN;
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 1;

    TestRejectedIndexDestination(TileDataType_S32);
    TestRejectedIndexDestination(TileDataType_S16);
    return 0;
end;
