// PTO-TEST: {"id":"PTO-AVS-TILE-TGATHER-STAGE2-DECODED-001","source":"asl/tile/irregular-and-complex/layout/TGATHER.asl","requirements":["PTO-TGATHER-CONTRACT-001","PTO-INST-TILE-TGATHER"],"kind":"execution","summary":"decoded TGATHER accepts independent index widths, preserves raw non-packed carriers, and rejects full-width out-of-range rows","pass_condition":"decoded U64 and S16 indices execute for U8 and TF32 sources, invalid TF32 payload bits move unchanged, and a U64 value above 32 bits faults before destination publication","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/tile/model/legality/indexed-rearrangement.asl","asl/tile/model/execution/indexed-rearrangement.asl"]}

pure func TgatherStage2Start(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01111';
    instruction[31:27] = data_type;
    return instruction;
end;

func PrepareTgatherStage2(data_type: TileDataType,
                          index_type: TileDataType,
                          first_index: Word,
                          second_index: Word)
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        2,
        2,
        2,
        1,
        data_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        2,
        1,
        2,
        1,
        index_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    let started = ExecuteCommandInstruction(
        TgatherStage2Start(TileDataTypeToEncoding(data_type)),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        TRUE,
        0,
        1,
        TRUE);
    WriteTileElement(1, 0, 0, first_index);
    WriteTileElement(1, 1, 0, second_index);
end;

func main() => integer
begin
    PrepareTgatherStage2(
        TileDataType_U8,
        TileDataType_U64,
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x22);
    let u64_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06F)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(u64_operation) == TileOperation_TGATHER;
    assert BundleOperationBindingsComplete(u64_operation);
    assert SelectedBundleTileMasksLegal();
    let u64_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE, 2, 1, 1, TRUE, TileDataType_U8);
    assert u64_resolved;
    let u64_destination = _BundleTileBindings[[0]].destination;
    let (u64_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x06F,
        BundleTileInstructionOperands(u64_operation));
    assert u64_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert _Tiles[[u64_destination]].data_type == TileDataType_U8;
    assert ReadTileElement(u64_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x22;
    assert ReadTileElement(u64_destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x11;

    PrepareTgatherStage2(
        TileDataType_TF32,
        TileDataType_S16,
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN});
    let invalid_tf32_row0 = Zeros{PTO_XLEN} + 0x3f800001;
    let invalid_tf32_row1 = Zeros{PTO_XLEN} + 0x3f800002;
    WriteTileElement(0, 0, 0, invalid_tf32_row0);
    WriteTileElement(0, 1, 0, invalid_tf32_row1);
    let s16_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06F)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(s16_operation) == TileOperation_TGATHER;
    let s16_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE, 2, 1, 1, TRUE, TileDataType_TF32);
    assert s16_resolved;
    let s16_destination = _BundleTileBindings[[0]].destination;
    let (s16_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x06F,
        BundleTileInstructionOperands(s16_operation));
    assert s16_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(s16_destination, 0, 0) == invalid_tf32_row1;
    assert ReadTileElement(s16_destination, 1, 0) == invalid_tf32_row0;

    PrepareTgatherStage2(
        TileDataType_U8,
        TileDataType_U64,
        Zeros{PTO_XLEN} + 0x0000000100000001,
        Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x42);
    let rejected_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06F)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(rejected_operation) == TileOperation_TGATHER;
    let rejected_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE, 2, 1, 1, TRUE, TileDataType_U8);
    assert rejected_resolved;
    let rejected_destination = _BundleTileBindings[[0]].destination;
    let source_before = ReadTileElement(0, 0, 0);
    let (rejected_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x06F,
        BundleTileInstructionOperands(rejected_operation));
    assert rejected_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == source_before;
    RollBackBundleTileDestinations();
    assert !_Tiles[[rejected_destination]].allocated;
    return 0;
end;
