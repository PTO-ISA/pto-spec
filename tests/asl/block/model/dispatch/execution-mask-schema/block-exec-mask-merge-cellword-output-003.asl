// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-MERGE-CELLWORD-OUTPUT-003","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001","PTO-TUNPACK-CONTRACT-001"],"kind":"execution","summary":"TUNPACK MERGE validates and preserves its derived destination descriptor while the mask retains source CELL-word coordinates.","pass_condition":"Decoded TUNPACK uses one source-word mask coordinate per row but merges the inactive row from a prior hand output with two derived destination columns.","related_sources":["asl/block/model/dispatch/cell-rearrangement-schema.asl","asl/tile/model/execution/rearrangement.asl"]}
pure func CellwordMergeStart(code: bits(12), data_type: TileDataType)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = code[6:5];
    instruction[24:20] = code[4:0];
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func CellwordMergeAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

pure func CellwordMergeIOR(control: bits(5), mask: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = control;
    instruction[24:20] = mask;
    instruction[26] = '1';
    return instruction;
end;

pure func CellwordMergeIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} +
        (if source1_valid then 0x00004013 else 0x00005013);
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

func BeginCellwordMerge(code: bits(12), data_type: TileDataType,
    control: Word, source0: bits(6), source1: bits(6),
    source1_valid: boolean)
begin
    WritePEGPR(0, 2, control);
    // CUBE_M32 CELL-word coordinate (row 0, word 0) is bit zero; row 1 is
    // inactive and must be copied from the prior destination output.
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(
        CellwordMergeStart(code, data_type), 32);
    let attributed = ExecuteCommandInstruction(CellwordMergeAttributes(), 32);
    let masked = ExecuteCommandInstruction(
        CellwordMergeIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    let bound = ExecuteCommandInstruction(
        CellwordMergeIOT(source0, source1, source1_valid), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    assert masked == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert !_Tiles[[0]].allocated;
end;

func TestTUNPACKMerge()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 2, 2, TileDataType_BF16, TileLayout_CUBE_M32);
    let base_ready = ConfigureCubeTile(
        12, 128, 2, 2, TileDataType_U16, TileLayout_CUBE_M32);
    assert source_ready && base_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(0, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 70);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 71);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN} + 80);
    WriteTileElement(12, 1, 1, Zeros{PTO_XLEN} + 81);
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(12);
    BeginCellwordMerge(Zeros{12} + 0x078, TileDataType_U16,
        Zeros{PTO_XLEN} + 0x00000202,
        Zeros{6} + 10, Zeros{6}, FALSE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x078)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleExecutionMaskCoordinateValidColumns(operation) == 1;
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination == 0;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 80;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 81;
end;

func main() => integer
begin
    TestTUNPACKMerge();
    return 0;
end;
