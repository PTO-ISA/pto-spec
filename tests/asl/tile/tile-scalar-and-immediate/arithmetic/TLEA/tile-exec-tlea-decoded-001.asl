// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-DECODED-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-INST-TILE-TLEA","PTO-TLEA-CONTRACT-001"],"kind":"execution","summary":"TLEA decodes its reserved-selector allocation and independently allocates widened byte-offset storage.","pass_condition":"A decoded S32 source produces S64 offsets -4 and 8 without source mutation, numeric status or memory events.","related_sources":["asl/block/model/dispatch/lea-schema.asl","asl/block/model/dispatch/descriptor-legality.asl","asl/block/model/dispatch/destination-operation.asl"]}
pure func LEAStart(source_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '01';
    instruction[24:20] = '01110';
    instruction[31:27] = TileDataTypeToEncoding(source_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xffffffff);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteGPR(2, Zeros{PTO_XLEN} + 32);
    RecordNumericStatusFlags('00100');
    let status_before = NumericStatusFlags();
    let started = ExecuteCommandInstruction(LEAStart(TileDataType_S32), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '0001', TRUE, FALSE, 1, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);
    let decoded = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x02e);
    assert decoded != PTO_TILE_OPERATION_COUNT;
    assert TileOperationOfIndex(decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TLEA;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_S64;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].rows == 8;
    assert ReadTileElement(destination, 0, 0) == Ones{PTO_XLEN} - 3;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 8;
    assert _Tiles[[1]].data_type == TileDataType_S32;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0xffffffff;
    assert _MemoryEventCount == 0;
    assert NumericStatusFlags() == status_before;
    StopMemoryEventCapture();
    return 0;
end;
