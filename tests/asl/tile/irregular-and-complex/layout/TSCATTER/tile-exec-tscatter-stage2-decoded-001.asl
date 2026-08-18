// PTO-TEST: {"id":"PTO-AVS-TILE-TSCATTER-STAGE2-DECODED-001","source":"asl/tile/irregular-and-complex/layout/TSCATTER.asl","requirements":["PTO-TSCATTER-CONTRACT-001","PTO-INST-TILE-TSCATTER"],"kind":"execution","summary":"decoded TSCATTER accepts independent index widths and preserves raw non-packed carriers","pass_condition":"decoded S16 and U64 indices execute for U64 and TF32 sources, with B64 results and invalid TF32 payload bits published unchanged","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/tile/model/legality/indexed-rearrangement.asl","asl/tile/model/execution/indexed-rearrangement.asl"]}

pure func TscatterStage2Start(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '10000';
    instruction[31:27] = data_type;
    return instruction;
end;

func PrepareTscatterStage2(data_type: TileDataType,
                           index_type: TileDataType,
                           first_index: Word,
                           second_index: Word)
begin
    ResetProfileState();
    ConfigureTile(
        0,
        256,
        2,
        2,
        2,
        1,
        data_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        256,
        2,
        1,
        2,
        1,
        index_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    let started = ExecuteCommandInstruction(
        TscatterStage2Start(TileDataTypeToEncoding(data_type)),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE,
        0,
        2,
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
    PrepareTscatterStage2(
        TileDataType_U64,
        TileDataType_S16,
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN});
    let u64_value0 = Zeros{PTO_XLEN} + 0x1122334455667788;
    let u64_value1 = Zeros{PTO_XLEN} + 0x8877665544332211;
    WriteTileElement(0, 0, 0, u64_value0);
    WriteTileElement(0, 1, 0, u64_value1);
    let s16_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x070)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(s16_operation) == TileOperation_TSCATTER;
    assert BundleOperationBindingsComplete(s16_operation);
    let s16_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE, 2, 1, 1, TRUE, TileDataType_U64);
    assert s16_resolved;
    let s16_destination = _BundleTileBindings[[0]].destination;
    let (s16_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x070,
        BundleTileInstructionOperands(s16_operation));
    assert s16_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert _Tiles[[s16_destination]].data_type == TileDataType_U64;
    assert ReadTileElement(s16_destination, 1, 0) == u64_value0;
    assert ReadTileElement(s16_destination, 0, 0) == u64_value1;

    PrepareTscatterStage2(
        TileDataType_TF32,
        TileDataType_U64,
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN});
    let invalid_tf32_value0 = Zeros{PTO_XLEN} + 0x3f800001;
    let invalid_tf32_value1 = Zeros{PTO_XLEN} + 0x3f800002;
    WriteTileElement(0, 0, 0, invalid_tf32_value0);
    WriteTileElement(0, 1, 0, invalid_tf32_value1);
    let u64_operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x070)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationOfIndex(u64_operation) == TileOperation_TSCATTER;
    let u64_resolved = ResolveBundleTileDestinationsWithShapeAndType(
        TRUE, 2, 1, 1, TRUE, TileDataType_TF32);
    assert u64_resolved;
    let u64_destination = _BundleTileBindings[[0]].destination;
    let (u64_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL,
        Zeros{12} + 0x070,
        BundleTileInstructionOperands(u64_operation));
    assert u64_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(u64_destination, 1, 0) == invalid_tf32_value0;
    assert ReadTileElement(u64_destination, 0, 0) == invalid_tf32_value1;
    return 0;
end;
