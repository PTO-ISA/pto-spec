// PTO-TEST: {"id":"PTO-AVS-TILE-TROWARGMIN-INDEX-DTYPE-DECODED-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMIN.asl","requirements":["PTO-INST-TILE-TROWARGMIN"],"kind":"execution","summary":"decoded TROWARGMIN accepts S32 and U32 index destinations and rejects S16 before result publication","pass_condition":"decoded dispatch, binding, destination preflight, execution, and publication succeed for S32 and U32 destinations; S16 faults before result effects","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
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
        TileLayout_RowMajor,
        TileLocation_Any);
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
    let s32_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE,
        2,
        1,
        1,
        TRUE,
        TileDataType_S32);
    assert s32_resolved;
    let s32_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[s32_destination]].data_type == TileDataType_S32;
    let (s32_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x04D,
        BundleTileInstructionOperands(operation));
    assert s32_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(s32_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(s32_destination, 1, 0) ==
        Zeros{PTO_XLEN} + 1;

    PrepareDecodedTrowargmin();
    let u32_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x04D)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(u32_operation) == TileOperation_TROWARGMIN;
    assert BundleOperationBindingsComplete(u32_operation);
    assert SelectedBundleClosedReductionSchemaLegal(u32_operation);
    let u32_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE,
        2,
        1,
        1,
        TRUE,
        TileDataType_U32);
    assert u32_resolved;
    let u32_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[u32_destination]].data_type == TileDataType_U32;
    let (u32_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x04D,
        BundleTileInstructionOperands(u32_operation));
    assert u32_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(u32_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(u32_destination, 1, 0) ==
        Zeros{PTO_XLEN} + 1;

    PrepareDecodedTrowargmin();
    let rejected_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x04D)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(rejected_operation) == TileOperation_TROWARGMIN;
    assert BundleOperationBindingsComplete(rejected_operation);
    assert SelectedBundleClosedReductionSchemaLegal(rejected_operation);
    let rejected_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE,
        2,
        1,
        1,
        TRUE,
        TileDataType_S16);
    assert rejected_resolved;
    let rejected_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[rejected_destination]].data_type == TileDataType_S16;
    let source_before = ReadTileElement(0, 0, 0);
    let (rejected_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x04D,
        BundleTileInstructionOperands(rejected_operation));
    assert rejected_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == source_before;
    RollBackBundleTileDestinations();
    assert !_Tiles[[rejected_destination]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
