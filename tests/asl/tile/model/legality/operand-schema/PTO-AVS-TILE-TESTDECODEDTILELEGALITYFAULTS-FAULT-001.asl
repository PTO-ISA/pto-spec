// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTDECODEDTILELEGALITYFAULTS-FAULT-001","source":"asl/tile/model/legality/operand-schema.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for TestDecodedTileLegalityFaults","pass_condition":"TestDecodedTileLegalityFaults completes without assertion failure","related_sources":[]}
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

func SelectTestCUBEDataType(data_type: bits(5))
begin
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10},
        data_type_valid = TRUE,
        data_type = data_type,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    });
end;

func TestDecodedTileLegalityFaults()
begin
    ConfigureTwoByTwo(7);
    ConfigureTwoByTwo(8);
    ConfigureTwoByTwo(9);
    ExecuteTileFillScalar(8, Zeros{PTO_XLEN} + 2);
    ExecuteTileFillScalar(9, Zeros{PTO_XLEN} + 0x5a);
    var undefined_operands = DefaultTileInstructionOperands();
    undefined_operands.destination0 = 9;
    undefined_operands.source0 = 7;
    undefined_operands.source1 = 8;
    ClearFault();
    let (undefined_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', undefined_operands);
    assert undefined_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    AssertTwoByTwoTileEquals(9, Zeros{PTO_XLEN} + 0x5a);

    ExecuteTileFillScalar(7, Zeros{PTO_XLEN} + 8);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    var division_operands = DefaultTileInstructionOperands();
    division_operands.destination0 = 9;
    division_operands.source0 = 7;
    division_operands.source1 = 8;
    WritePC(Zeros{PTO_XLEN} + 0x280);
    ClearFault();
    let (division_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000011', division_operands);
    assert division_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x280;
    assert _ACRTrapNumber[[CurrentACR()]] == Zeros{6} + 5;
    AssertTwoByTwoTileEquals(9, Zeros{PTO_XLEN} + 0x5a);

    ReleaseTile(8);
    ClearFault();
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', division_operands);
    assert shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    AssertTwoByTwoTileEquals(9, Zeros{PTO_XLEN} + 0x5a);

    ConfigureTwoByTwo(10);
    ConfigureTwoByTwo(11);
    ConfigureTwoByTwo(12);
    ConfigureTile(13, 256, 2, 4, 2, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileFillScalar(10, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(11, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(12, Zeros{PTO_XLEN} + 0x66);
    ExecuteTileFillScalar(13, Zeros{PTO_XLEN} + 1);
    var matrix_operands = DefaultTileInstructionOperands();
    matrix_operands.destination0 = 12;
    matrix_operands.source0 = 10;
    matrix_operands.source1 = 11;
    matrix_operands.source2 = 13;
    SelectTestCUBEDataType('11000');
    ClearFault();
    let (matrix_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000000001', matrix_operands);
    assert matrix_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    AssertTwoByTwoTileEquals(12, Zeros{PTO_XLEN} + 0x66);
end;
func main() => integer
begin
    ResetProfileState();
    TestDecodedTileLegalityFaults();
    return 0;
end;
