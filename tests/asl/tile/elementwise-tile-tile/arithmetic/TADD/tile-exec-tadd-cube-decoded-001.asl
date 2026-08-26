// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-ELEMENTWISE-DECODED-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD","PTO-INST-TILE-TABS","PTO-INST-TILE-TADDS","PTO-INST-TILE-TFMA"],"kind":"execution","summary":"Decoded CUBE_M32/M16 elementwise operations execute and CUBE_N8 or mixed-layout forms reject before effects.","pass_condition":"Binary, unary, scalar, and TFMA CUBE normal paths publish expected values while CUBE_N8 and mixed-layout rejection preserves the destination.","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/elementwise.asl","asl/tile/model/execution/fused-multiply-add.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_3 = ConfigureCubeTile(3, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 20);
    var binary = DefaultTileInstructionOperands();
    binary.destination0 = 3;
    binary.source0 = 1;
    binary.source1 = 2;
    let (binary_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', binary);
    assert binary_status == TileExecution_Executed;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 22;

    let configured_4 = ConfigureCubeTile(4, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_5 = ConfigureCubeTile(5, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(5, row, column, Zeros{PTO_XLEN} + 7);
        end;
    end;
    var unary = DefaultTileInstructionOperands();
    unary.destination0 = 4;
    unary.source0 = 5;
    let (unary_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000001111', unary);
    assert unary_status == TileExecution_Executed;
    assert ReadTileElement(4, 1, 1) == Zeros{PTO_XLEN} + 7;

    let configured_6 = ConfigureCubeTile(6, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_7 = ConfigureCubeTile(7, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(7, 1, 0, Zeros{PTO_XLEN} + 6);
    var scalar = DefaultTileInstructionOperands();
    scalar.destination0 = 6;
    scalar.source0 = 7;
    scalar.scalar0 = Zeros{PTO_XLEN} + 3;
    let (scalar_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000100000', scalar);
    assert scalar_status == TileExecution_Executed;
    assert ReadTileElement(6, 1, 0) == Zeros{PTO_XLEN} + 9;

    let configured_8 = ConfigureCubeTile(8, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_9 = ConfigureCubeTile(9, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_10 = ConfigureCubeTile(10, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_11 = ConfigureCubeTile(11, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(9, row, column, Zeros{PTO_XLEN} + 2);
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 3);
            WriteTileElement(11, row, column, Zeros{PTO_XLEN} + 4);
        end;
    end;
    var fma = DefaultTileInstructionOperands();
    fma.destination0 = 8;
    fma.source0 = 9;
    fma.source1 = 10;
    fma.source2 = 11;
    let (fma_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000011100', fma);
    assert fma_status == TileExecution_Executed;
    assert ReadTileElement(8, 0, 1) == Zeros{PTO_XLEN} + 10;

    let configured_12 = ConfigureCubeTile(12, 128, 4, 8, TileDataType_U32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    let configured_13 = ConfigureCubeTile(13, 128, 4, 8, TileDataType_U32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    let configured_14 = ConfigureCubeTile(14, 128, 4, 8, TileDataType_U32,
        TileLayout_CUBE_N8, TileLocation_Matrix);
    for row = 0 to 3 looplimit 4 do
        for column = 0 to 7 looplimit 8 do
            WriteTileElement(12, row, column, Zeros{PTO_XLEN} + 1);
            WriteTileElement(13, row, column, Zeros{PTO_XLEN} + 2);
        end;
    end;
    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN} + 0x5a5a5a5a);
    var n8 = DefaultTileInstructionOperands();
    n8.destination0 = 14;
    n8.source0 = 12;
    n8.source1 = 13;
    ClearFault();
    let (n8_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', n8);
    assert n8_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a5a5a5a;

    let configured_15 = ConfigureCubeTile(15, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    ConfigureTile(16, 128, 2, 1, 2, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(17, 128, 2, 1, 2, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(16, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(17, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(17, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN} + 0x6b6b6b6b);
    var mixed = DefaultTileInstructionOperands();
    mixed.destination0 = 15;
    mixed.source0 = 16;
    mixed.source1 = 17;
    ClearFault();
    let (mixed_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', mixed);
    assert mixed_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 0x6b6b6b6b;
    return 0;
end;
