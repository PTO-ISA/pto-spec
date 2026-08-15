// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTDECODEDTILEEXECUTION-EXECUTION-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Covers Decoded Tile Execution.","pass_condition":"TestDecodedTileExecution completes without assertion failure","related_sources":[]}
func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
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

func TestDecodedTileExecution()
begin
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    ConfigureTwoByTwo(2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 11);

    var tepl_operands = DefaultTileInstructionOperands();
    tepl_operands.destination0 = 2;
    tepl_operands.source0 = 0;
    tepl_operands.source1 = 1;
    let (tepl_status, tepl_value) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', tepl_operands);
    assert tepl_status == TileExecution_Executed;
    assert tepl_value == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 16;

    ConfigureTwoByTwo(3);
    Store(Zeros{PTO_XLEN} + 512, 8, Zeros{PTO_XLEN} + 21);
    Store(Zeros{PTO_XLEN} + 520, 8, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 528, 8, Zeros{PTO_XLEN} + 23);
    Store(Zeros{PTO_XLEN} + 536, 8, Zeros{PTO_XLEN} + 24);
    var tlsu_operands = DefaultTileInstructionOperands();
    tlsu_operands.destination0 = 3;
    tlsu_operands.address = Zeros{PTO_XLEN} + 512;
    // Direct dispatch receives a fully decoded operand record. Supply the
    // dense two-element row stride explicitly; scalar0=0 is the architectural
    // encoded-zero stride, not the bundle-schema omitted-field default.
    tlsu_operands.scalar0 = Zeros{PTO_XLEN} + 2;
    let (tlsu_status, tlsu_value) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000000', tlsu_operands);
    assert tlsu_status == TileExecution_Executed;
    assert tlsu_value == Zeros{PTO_XLEN};
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(3, 1, 1) == Zeros{PTO_XLEN} + 24;

    ConfigureTwoByTwo(4);
    ConfigureTwoByTwo(5);
    ConfigureTwoByTwo(6);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(4, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(4, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 8);
    var cube_operands = DefaultTileInstructionOperands();
    cube_operands.destination0 = 6;
    cube_operands.source0 = 4;
    cube_operands.source1 = 5;
    SelectTestCUBEDataType('11000');
    let (cube_status, cube_value) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000000000', cube_operands);
    assert cube_status == TileExecution_Executed;
    assert cube_value == Zeros{PTO_XLEN};
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(6, 1, 1) == Zeros{PTO_XLEN} + 50;
    let (convert_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000001000', cube_operands);
    assert convert_status == TileExecution_Rejected;
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(6, 1, 1) == Zeros{PTO_XLEN} + 50;

    let (rejected_status, rejected_value) = ExecuteTileInstruction(
        TileDecode_TEPL, '111111111111', DefaultTileInstructionOperands());
    assert rejected_status == TileExecution_Rejected;
    assert rejected_value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;
end;
func main() => integer
begin
    ResetProfileState();
    TestDecodedTileExecution();
    return 0;
end;
