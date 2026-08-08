// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEELEMENTDEFINEDNESS-EXECUTION-001","source":"asl/tile/model/definedness/elements.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestTileElementDefinedness","pass_condition":"TestTileElementDefinedness completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func AssertTwoByTwoTileEquals(index: TileIndex, expected: Word)
begin
    for row = 0 to 1 do
        for column = 0 to 1 do
            assert ReadTileElement(index, row, column) == expected;
        end;
    end;
end;

func TestTileElementDefinedness()
begin
    ResetProfileState();
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    ConfigureTwoByTwo(2);
    ExecuteTileFillScalar(1, Zeros{PTO_XLEN} + 10);
    ExecuteTileFillScalar(2, Zeros{PTO_XLEN} + 0x5a);

    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    assert TileElementDefined(0, 0, 0);
    assert !TileElementDefined(0, 0, 1);
    assert _Tiles[[0]].defined_valid_elements == 1;
    assert !_Tiles[[0]].contents_defined;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 1;

    var add = DefaultTileInstructionOperands();
    add.destination0 = 2;
    add.source0 = 0;
    add.source1 = 1;
    ClearFault();
    let (partial_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', add);
    assert partial_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    AssertTwoByTwoTileEquals(2, Zeros{PTO_XLEN} + 0x5a);

    ConfigureTile(3, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileFillScalar(3, Zeros{PTO_XLEN} + 0x66);
    var reduction = DefaultTileInstructionOperands();
    reduction.destination0 = 3;
    reduction.source0 = 0;
    ClearFault();
    let (partial_reduction_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001000000', reduction);
    assert partial_reduction_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x66;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 0x66;

    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    assert _Tiles[[0]].defined_valid_elements == 4;
    assert _Tiles[[0]].contents_defined;
    ClearFault();
    let (complete_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', add);
    assert complete_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 14;

    ConfigureTwoByTwo(0);
    assert _Tiles[[0]].defined_valid_elements == 0;
    assert !TileElementDefined(0, 0, 0);
    assert !_Tiles[[0]].contents_defined;
    ReleaseTile(0);
    assert _Tiles[[0]].defined_elements == Zeros{PTO_MODEL_TILE_ELEMENTS};
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestTileElementDefinedness();
    return 0;
end;
