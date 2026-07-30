func ConfigureTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTileElementwiseAndAliasing()
begin
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    ConfigureTwoByTwo(2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 40);

    ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 44;

    // Destination aliases source_left. Both sources are snapshotted first.
    ExecuteTileBinary(TileBinary_ADD, 0, 0, 1);
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 44;

    ExecuteTileBinary(TileBinary_DIV, 2, 1, 0);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    ExecuteTileFillScalar(2, Zeros{PTO_XLEN} + 3);
    ExecuteTileAxpy(2, 1, Zeros{PTO_XLEN} + 2);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 23;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 83;
end;

func TestTileMemory()
begin
    ConfigureTwoByTwo(3);
    ConfigureTwoByTwo(4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 101);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 102);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 103);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 104);
    TSTORE(Zeros{PTO_XLEN} + 64, 3);
    TLOAD(4, Zeros{PTO_XLEN} + 64);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 101;
    assert ReadTileElement(4, 1, 1) == Zeros{PTO_XLEN} + 104;

    let before_first = ReadTileElement(4, 0, 0);
    let before_last = ReadTileElement(4, 1, 1);
    TPREFETCH(Zeros{PTO_XLEN} + 64, 32);
    assert ReadTileElement(4, 0, 0) == before_first;
    assert ReadTileElement(4, 1, 1) == before_last;

    ConfigureTwoByTwo(24);
    ConfigureTwoByTwo(25);
    WriteTileElement(24, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(24, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(24, 1, 0, Zeros{PTO_XLEN} + 0);
    WriteTileElement(24, 1, 1, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 256, 8, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 264, 8, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 272, 8, Zeros{PTO_XLEN} + 33);
    Store(Zeros{PTO_XLEN} + 280, 8, Zeros{PTO_XLEN} + 44);
    MGATHER(25, Zeros{PTO_XLEN} + 256, 24);
    assert ReadTileElement(25, 0, 0) == Zeros{PTO_XLEN} + 44;
    assert ReadTileElement(25, 1, 0) == Zeros{PTO_XLEN} + 11;
    MSCATTER(Zeros{PTO_XLEN} + 320, 25, 24);
    let scattered_first = LoadUnsigned(Zeros{PTO_XLEN} + 320, 8);
    let scattered_last = LoadUnsigned(Zeros{PTO_XLEN} + 344, 8);
    assert scattered_first == Zeros{PTO_XLEN} + 11;
    assert scattered_last == Zeros{PTO_XLEN} + 44;
end;

func TestTileMatmul()
begin
    ConfigureTwoByTwo(5);
    ConfigureTwoByTwo(6);
    ConfigureTwoByTwo(7);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(6, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(6, 1, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(7, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(7, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(7, 1, 1, Zeros{PTO_XLEN});

    TMATMUL(7, 5, 6, FALSE);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(7, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(7, 1, 0) == Zeros{PTO_XLEN} + 43;
    assert ReadTileElement(7, 1, 1) == Zeros{PTO_XLEN} + 50;

    ConfigureTile(26, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(26, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(26, 0, 1, Zeros{PTO_XLEN} + 2);
    TMATMUL_BIAS(7, 5, 6, 26);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(7, 1, 1) == Zeros{PTO_XLEN} + 52;
    TMATMUL_ACC(7, 5, 6);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 39;

    ConfigureTile(27, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(28, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(27, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(27, 1, 0, Zeros{PTO_XLEN} + 3);
    TGEMV(28, 5, 27);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 18;

    // Decoded MX-bias must reject an undefined bias even though the catalog
    // carries it in destination1, and permitted destination/bias aliasing uses
    // the source snapshot taken before the matrix destination is overwritten.
    for index = 32 to 37 do
        ConfigureTile(index as TileIndex, 256, 1, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(33, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(34, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(35, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(36, 0, 0, Zeros{PTO_XLEN} + 1);
    var mx_bias_operands = DefaultTileInstructionOperands();
    mx_bias_operands.destination0 = 36;
    mx_bias_operands.source0 = 32;
    mx_bias_operands.source1 = 33;
    mx_bias_operands.source2 = 34;
    mx_bias_operands.source3 = 35;
    mx_bias_operands.destination1 = 37;
    ClearFault();
    let (undefined_bias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000000101', mx_bias_operands);
    assert undefined_bias_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(36, 0, 0) == Zeros{PTO_XLEN} + 1;

    mx_bias_operands.destination1 = 36;
    ClearFault();
    let (alias_bias_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000000101', mx_bias_operands);
    assert alias_bias_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(36, 0, 0) == Zeros{PTO_XLEN} + 121;
end;

func TestTileReduction()
begin
    ConfigureTwoByTwo(8);
    ConfigureTile(9, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(10, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(8, 1, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(8, 1, 1, Zeros{PTO_XLEN} + 3);

    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 9, 8);
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(9, 1, 0) == Zeros{PTO_XLEN} + 7;

    ExecuteTileReduction(TileReduction_ARGMAX, TileAxis_Column, 10, 8);
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(10, 0, 1) == Zeros{PTO_XLEN} + 1;
end;

func TestTileExpansion()
begin
    ConfigureTwoByTwo(11);
    ConfigureTile(12, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTwoByTwo(13);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN} + 20);

    ExecuteTileExpand(TileExpand_ADD, TileAxis_Row, 13, 11, 12);
    assert ReadTileElement(13, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(13, 0, 1) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(13, 1, 0) == Zeros{PTO_XLEN} + 23;
    assert ReadTileElement(13, 1, 1) == Zeros{PTO_XLEN} + 24;

    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN} + 4);
    ExecuteTileExpand(TileExpand_DIV, TileAxis_Row, 13, 11, 12);
    assert ReadTileElement(13, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(13, 1, 1) == Zeros{PTO_XLEN} + 1;
end;

func TestTileGeneration()
begin
    ConfigureTwoByTwo(14);
    TCI(14, Zeros{PTO_XLEN} + 5, FALSE);
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(14, 1, 1) == Zeros{PTO_XLEN} + 8;

    TTRI(14, FALSE, 0);
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(14, 1, 1) == Zeros{PTO_XLEN} + 1;

    ConfigureTile(15, 256, 3, 3, 3, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TFILLPAD(15, 14, Zeros{PTO_XLEN} + 9);
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(15, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(15, 2, 2) == Zeros{PTO_XLEN} + 9;
end;

func TestTileRearrangement()
begin
    ConfigureTwoByTwo(16);
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(16, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(16, 1, 1, Zeros{PTO_XLEN} + 40);

    ConfigureTile(17, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TEXTRACT(17, 16, 1, 0);
    assert ReadTileElement(17, 0, 0) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(17, 0, 1) == Zeros{PTO_XLEN} + 40;

    ConfigureTwoByTwo(18);
    TTRANS(18, 16);
    assert ReadTileElement(18, 0, 1) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(18, 1, 0) == Zeros{PTO_XLEN} + 20;

    ConfigureTile(19, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(19, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(19, 0, 1, Zeros{PTO_XLEN});
    ConfigureTile(20, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TGATHER(20, 16, 19);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 40;
    assert ReadTileElement(20, 0, 1) == Zeros{PTO_XLEN} + 10;

    ConfigureTile(21, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TINTERLEAVE(21, 17, 20);
    assert ReadTileElement(21, 0, 0) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(21, 0, 1) == Zeros{PTO_XLEN} + 40;
    assert ReadTileElement(21, 0, 2) == Zeros{PTO_XLEN} + 40;
    assert ReadTileElement(21, 0, 3) == Zeros{PTO_XLEN} + 10;

    ConfigureTile(22, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(23, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TDEINTERLEAVE(22, 23, 21);
    assert ReadTileElement(22, 0, 1) == Zeros{PTO_XLEN} + 40;
    assert ReadTileElement(23, 0, 1) == Zeros{PTO_XLEN} + 10;

    ConfigureTile(43, 256, 3, 3, 3, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(44, 256, 4, 4, 4, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TCI(43, Zeros{PTO_XLEN} + 1, FALSE);
    TIMG2COL(44, 43, 2, 2, 1, 1, 0, 0, Zeros{PTO_XLEN});
    assert ReadTileElement(44, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(44, 0, 3) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(44, 3, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(44, 3, 3) == Zeros{PTO_XLEN} + 9;
end;

func TestTileComplex()
begin
    ConfigureTile(29, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(30, 256, 1, 3, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(31, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(29, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(29, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(29, 0, 2, Zeros{PTO_XLEN} + 6);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(30, 0, 1, Zeros{PTO_XLEN} + 3);
    ExecuteTilePartial(TilePartial_ADD, 31, 29, 30);
    assert ReadTileElement(31, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(31, 0, 1) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(31, 0, 2) == Zeros{PTO_XLEN} + 6;

    ConfigureTile(45, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(46, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(47, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(48, 256, 1, 3, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    TCI(47, Zeros{PTO_XLEN} + 10, FALSE);
    TCI(48, Zeros{PTO_XLEN} + 20, FALSE);
    ExecuteTilePartialArg(TRUE, 45, 46, 29, 30, 47, 48);
    assert ReadTileElement(45, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(46, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(45, 0, 2) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(46, 0, 2) == Zeros{PTO_XLEN} + 12;

    ConfigureTile(32, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(33, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(32, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(32, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(32, 0, 3, Zeros{PTO_XLEN} + 2);
    TSORT(33, 32, FALSE);
    assert ReadTileElement(33, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(33, 0, 3) == Zeros{PTO_XLEN} + 4;

    ConfigureTile(34, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(35, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(36, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(34, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(34, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(35, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(35, 0, 1, Zeros{PTO_XLEN} + 3);
    TMRGSORT(36, 34, 35, FALSE);
    assert ReadTileElement(36, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(36, 0, 3) == Zeros{PTO_XLEN} + 4;

    ConfigureTile(37, 2048, 1, 256, 1, 256, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(49, 256, 3, 1, 3, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(50, 256, 1, 4, 1, 4, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(49, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(49, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(49, 2, 0, Zeros{PTO_XLEN});
    WriteTileElement(50, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(50, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(50, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(50, 0, 3, Zeros{PTO_XLEN} + 3);
    THISTOGRAM(37, 50, 49, 0);
    assert ReadTileElement(37, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(37, 0, 1) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(37, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(37, 0, 3) == Zeros{PTO_XLEN} + 4;
end;

func TestTileConversion()
begin
    ConfigureTile(40, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(41, 256, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(42, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 257);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 100);
    TCVT(41, 40);
    assert ReadTileElement(41, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(41, 0, 1) == Zeros{PTO_XLEN} + 100;
    TQUANT(41, 40, Zeros{PTO_XLEN} + 10, Zeros{PTO_XLEN} + 3);
    assert ReadTileElement(41, 0, 1) == Zeros{PTO_XLEN} + 13;
    TDEQUANT(42, 41, Zeros{PTO_XLEN} + 10, Zeros{PTO_XLEN} + 3);
    assert ReadTileElement(42, 0, 1) == Zeros{PTO_XLEN} + 100;
end;

func TestTileHandlerClosure()
begin
    ConfigureTwoByTwo(51);
    ConfigureTwoByTwo(52);
    ConfigureTwoByTwo(53);
    ConfigureTwoByTwo(54);
    WriteTileElement(51, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(51, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(51, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(51, 1, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(52, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(52, 0, 1, Zeros{PTO_XLEN} + 3);
    WriteTileElement(52, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(52, 1, 1, Zeros{PTO_XLEN} + 4);

    ExecuteTileUnary(TileUnary_NEG, 53, 51);
    assert ReadTileElement(53, 0, 0) == Zeros{PTO_XLEN} - 1;
    ExecuteTileScalar(TileBinary_ADD, 53, 51, Zeros{PTO_XLEN} + 5);
    assert ReadTileElement(53, 0, 1) == Zeros{PTO_XLEN} + 9;
    ExecuteTileCompare(53, 51, 52, TileComparison_LT);
    assert ReadTileElement(53, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(53, 0, 1) == Zeros{PTO_XLEN};
    ExecuteTileCompareScalar(53, 51, Zeros{PTO_XLEN} + 3,
        TileComparison_GE);
    assert ReadTileElement(53, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(53, 0, 1) == Zeros{PTO_XLEN} + 1;
    ExecuteTileSelect(54, 53, 51, 52);
    assert ReadTileElement(54, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(54, 0, 1) == Zeros{PTO_XLEN} + 4;
    ExecuteTileSelectScalar(54, 53, 51, Zeros{PTO_XLEN} + 9);
    assert ReadTileElement(54, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(54, 0, 1) == Zeros{PTO_XLEN} + 4;

    ConfigureTwoByTwo(55);
    ConfigureTile(56, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(57, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(58, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(59, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(60, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(61, 256, 1, 4, 1, 4, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTwoByTwo(62);
    ExecuteTileFillScalar(55, Zeros{PTO_XLEN});
    ExecuteTileFillScalar(61, Zeros{PTO_XLEN});
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 8);
    TINSERT(55, 56, 1, 0);
    assert ReadTileElement(55, 1, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(55, 1, 1) == Zeros{PTO_XLEN} + 8;

    WriteTileElement(57, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(57, 0, 1, Zeros{PTO_XLEN} + 24);
    TGATHERB(58, 55, 57);
    assert ReadTileElement(58, 0, 0) == ReadTileElement(55, 0, 0);
    assert ReadTileElement(58, 0, 1) == Zeros{PTO_XLEN} + 8;

    WriteTileElement(57, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(57, 0, 1, Zeros{PTO_XLEN} + 3);
    TSCATTER(61, 56, 57);
    assert ReadTileElement(61, 0, 1) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(61, 0, 3) == Zeros{PTO_XLEN} + 8;

    TCONCAT(59, 56, 58, TileAxis_Column);
    assert ReadTileElement(59, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(59, 0, 3) == Zeros{PTO_XLEN} + 8;
    TRESHAPE(60, 55);
    assert ReadTileElement(60, 0, 2) == Zeros{PTO_XLEN} + 7;
    TMOV(62, 55);
    assert ReadTileElement(62, 1, 1) == Zeros{PTO_XLEN} + 8;

    // This closure test owns its matrix fixture. It must not inherit tiles
    // configured by TestTileMatmul when executed as an independent shard.
    ConfigureTwoByTwo(5);
    ConfigureTwoByTwo(6);
    ConfigureTwoByTwo(7);
    ConfigureTile(27, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(28, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(6, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(6, 1, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(27, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(27, 1, 0, Zeros{PTO_XLEN} + 3);

    ConfigureTile(61, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(62, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(63, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(61, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(61, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(62, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(62, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(63, 0, 0, Zeros{PTO_XLEN} + 1);
    TMATMUL_MX(7, 5, 6, 61, 62);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 19;
    TGEMV_BIAS(28, 5, 27, 61);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 19;
    TGEMV_ACC(28, 5, 27);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 17;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 37;
    TGEMV_MX(28, 5, 27, 61, 63);
    assert ReadTileElement(28, 0, 0) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(28, 1, 0) == Zeros{PTO_XLEN} + 18;
end;

func TestTileSelectorClosureExtensions()
begin
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 3);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} - 5);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 6);
    TPRELU(1, 0, Zeros{PTO_XLEN} + 2);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} - 6;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 4;

    TFREE(63);
    assert !_Tiles[[63]].allocated;
    TALLOC(63, 256, 2, 2, 2, 2, Zeros{PTO_XLEN} + 24, FALSE);
    assert _Tiles[[63]].allocated;
    assert !_Tiles[[63]].contents_defined;
    assert _Tiles[[63]].data_type == TileDataType_U64;
    TFREE(63);
    ConfigureTwoByTwo(62);
    TPUSH(63, 1);
    assert ReadTileElement(63, 1, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 6;
    TPOP(62, 63);
    assert ReadTileElement(62, 0, 0) == Zeros{PTO_XLEN} - 6;
    assert !_Tiles[[63]].allocated;

    ConfigureTile(55, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(56, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(57, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileFillScalar(55, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(56, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(56, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(56, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTileElement(57, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(57, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(57, 0, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 1536, 8, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 1544, 8, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 1552, 8, Zeros{PTO_XLEN} + 33);
    MGATHER_MASK(55, Zeros{PTO_XLEN} + 1536, 56, 57);
    assert ReadTileElement(55, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(55, 0, 1) == Zeros{PTO_XLEN} + 0xaa;
    assert ReadTileElement(55, 0, 2) == Zeros{PTO_XLEN} + 33;

    Store(Zeros{PTO_XLEN} + 2048, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 2056, 8, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 2064, 8, Zeros{PTO_XLEN});
    MSCATTER_MASK(Zeros{PTO_XLEN} + 2048, 55, 56, 57);
    let masked_scatter_first = LoadUnsigned(Zeros{PTO_XLEN} + 2048, 8);
    let masked_scatter_middle = LoadUnsigned(Zeros{PTO_XLEN} + 2056, 8);
    let masked_scatter_last = LoadUnsigned(Zeros{PTO_XLEN} + 2064, 8);
    assert masked_scatter_first == Zeros{PTO_XLEN} + 11;
    assert masked_scatter_middle == Zeros{PTO_XLEN};
    assert masked_scatter_last == Zeros{PTO_XLEN} + 33;

    ConfigureTile(58, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(59, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(58, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(58, 0, 1, Zeros{PTO_XLEN} + 99);
    WriteTileElement(58, 0, 2, Zeros{PTO_XLEN} + 33);
    WriteTileElement(59, 0, 0, Zeros{PTO_XLEN} + 111);
    WriteTileElement(59, 0, 1, Zeros{PTO_XLEN} + 222);
    WriteTileElement(59, 0, 2, Zeros{PTO_XLEN} + 333);
    MGATHER_CAS(55, Zeros{PTO_XLEN} + 1536, 56, 58, 59);
    assert ReadTileElement(55, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(55, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert ReadTileElement(55, 0, 2) == Zeros{PTO_XLEN} + 33;
    let cas_first = LoadUnsigned(Zeros{PTO_XLEN} + 1536, 8);
    let cas_middle = LoadUnsigned(Zeros{PTO_XLEN} + 1544, 8);
    let cas_last = LoadUnsigned(Zeros{PTO_XLEN} + 1552, 8);
    assert cas_first == Zeros{PTO_XLEN} + 111;
    assert cas_middle == Zeros{PTO_XLEN} + 22;
    assert cas_last == Zeros{PTO_XLEN} + 333;

    ConfigureTwoByTwo(2);
    ConfigureTwoByTwo(3);
    ConfigureTwoByTwo(4);
    ConfigureTile(5, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(6, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTwoByTwo(7);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 8);
    ExecuteTileFillScalar(5, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(6, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(7, Zeros{PTO_XLEN} + 2);
    TMATMUL_MX_BIAS(4, 2, 3, 5, 6, 7);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 21;
    TMATMUL_MX_ACC(4, 2, 3, 5, 6);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 40;
    ACCCVT(7, 4);
    assert ReadTileElement(7, 1, 1) == Zeros{PTO_XLEN} + 102;

    ConfigureTile(8, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(9, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(8, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(9, 0, 0, Zeros{PTO_XLEN} + 1);
    ExecuteTileFillScalar(5, Zeros{PTO_XLEN} + 1);
    TGEMV_MX_BIAS(8, 2, 5, 5, 9, 5);
    assert ReadTileElement(8, 0, 0) == Zeros{PTO_XLEN} + 4;
    TGEMV_MX_ACC(8, 2, 5, 5, 9);
    assert ReadTileElement(8, 0, 0) == Zeros{PTO_XLEN} + 7;
end;

// PTO-REQ-TILE-DISPATCH-001: representative decoded effects cover every
// direct family, value-returning management, and unknown-selector rejection.
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
    var tma_operands = DefaultTileInstructionOperands();
    tma_operands.destination0 = 3;
    tma_operands.address = Zeros{PTO_XLEN} + 512;
    let (tma_status, tma_value) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000000', tma_operands);
    assert tma_status == TileExecution_Executed;
    assert tma_value == Zeros{PTO_XLEN};
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
    let (cube_status, cube_value) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000000000', cube_operands);
    assert cube_status == TileExecution_Executed;
    assert cube_value == Zeros{PTO_XLEN};
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(6, 1, 1) == Zeros{PTO_XLEN} + 50;

    let (rejected_status, rejected_value) = ExecuteTileInstruction(
        TileDecode_TEPL, '111111111111', DefaultTileInstructionOperands());
    assert rejected_status == TileExecution_Rejected;
    assert rejected_value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;
end;

// PTO-REQ-TILE-CAPACITY-001: allocation legality is decided before the first
// descriptor or payload effect, including packed storage and aggregate limits.
func TestTileCapacityLegality()
begin
    ResetProfileState();
    assert TileOperandsLegal_TALLOC(20, 262144, 1, 1, 1, 1,
        Zeros{PTO_XLEN} + 24, FALSE);
    ConfigureTile(20, 524288, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert _Tiles[[20]].capacity_bytes == 524288;
    ReleaseTile(20);

    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} + 768;

    ConfigureTile(20, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(20, 0, 0, Zeros{PTO_XLEN} + 0x55);

    var allocation = DefaultTileInstructionOperands();
    allocation.destination0 = 20;
    allocation.positive0 = 1;
    allocation.positive1 = 1;
    allocation.natural0 = 1;
    allocation.natural1 = 1;
    allocation.scalar0 = Zeros{PTO_XLEN} + 24;

    // Zero and sub-minimum capacities are rejected without converting an
    // allocated destination into a free or partially reconfigured tile.
    allocation.byte_count = 0;
    ClearFault();
    let (zero_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation);
    assert zero_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _Tiles[[20]].capacity_bytes == 256;
    assert _Tiles[[20]].rows == 1;
    assert _Tiles[[20]].contents_defined;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 0x55;

    allocation.byte_count = 255;
    ClearFault();
    let (small_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation);
    assert small_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _Tiles[[20]].capacity_bytes == 256;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 0x55;

    // 33 U64 elements need 264 bytes, so a 256-byte descriptor is illegal.
    allocation.byte_count = 256;
    allocation.positive0 = 33;
    ClearFault();
    let (storage_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation);
    assert storage_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert _Tiles[[20]].rows == 1;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 0x55;

    // Exact-capacity allocation succeeds and makes the payload undefined.
    allocation.positive0 = 32;
    allocation.natural0 = 32;
    ClearFault();
    let (exact_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation);
    assert exact_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert _Tiles[[20]].capacity_bytes == 256;
    assert _Tiles[[20]].rows == 32;
    assert !_Tiles[[20]].contents_defined;

    // Reconfiguration replaces, rather than double-counts, the destination's
    // old capacity. A third allocation beyond the aggregate limit is rejected.
    ConfigureTile(21, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    allocation.destination0 = 20;
    allocation.byte_count = 512;
    allocation.positive0 = 1;
    allocation.natural0 = 1;
    ClearFault();
    let (replace_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation);
    assert replace_status == TileExecution_Executed;
    assert TileCapacityInUseExcept(63) == 768;

    allocation.destination0 = 22;
    allocation.byte_count = 256;
    ClearFault();
    let (aggregate_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation);
    assert aggregate_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[22]].allocated;
    assert _Tiles[[20]].capacity_bytes == 512;
    assert _Tiles[[21]].capacity_bytes == 256;

    ReleaseTile(20);
    assert TileCapacityInUseExcept(63) == 256;
    ResetProfileState();
end;

// PTO-REQ-TILE-DEFINEDNESS-001: one element write defines only that element;
// whole-region consumers reject until every valid element is defined.
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
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 0x5a;

    ConfigureTile(3, 256, 2, 1, 2, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ExecuteTileFillScalar(3, Zeros{PTO_XLEN} + 0x66);
    var reduction = DefaultTileInstructionOperands();
    reduction.destination0 = 3;
    reduction.source0 = 0;
    ClearFault();
    let (partial_reduction_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000010100', reduction);
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

// PTO-REQ-TILE-MANAGEMENT-001: explicit slots replace hidden pipe state.
// Push preserves its producer; pop consumes its selected slot after copying.
func TestTileManagementHandoff()
begin
    ResetProfileState();
    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} + 256;
    ConfigureTwoByTwo(1);
    ExecuteTileFillScalar(1, Zeros{PTO_XLEN} + 11);

    var push = DefaultTileInstructionOperands();
    push.destination0 = 60;
    push.source0 = 1;
    ClearFault();
    let (capacity_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100000', push);
    assert capacity_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[60]].allocated;
    assert _Tiles[[1]].allocated;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 11;

    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} + 1536;
    ClearFault();
    let (push_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100000', push);
    assert push_status == TileExecution_Executed;
    assert _Tiles[[1]].allocated;
    assert _Tiles[[60]].allocated;
    assert ReadTileElement(60, 1, 1) == Zeros{PTO_XLEN} + 11;

    // A full slot rejects a second publication and preserves its first value.
    ExecuteTileFillScalar(1, Zeros{PTO_XLEN} + 22);
    ClearFault();
    let (full_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100000', push);
    assert full_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(60, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 22;
    assert !TileOperandsLegal_TPUSH(1, 1);

    ConfigureTwoByTwo(3);
    ExecuteTileFillScalar(3, Zeros{PTO_XLEN} + 33);
    push.destination0 = 61;
    push.source0 = 3;
    ClearFault();
    let (second_push_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100000', push);
    assert second_push_status == TileExecution_Executed;
    assert ReadTileElement(61, 0, 0) == Zeros{PTO_XLEN} + 33;

    ConfigureTwoByTwo(2);
    ExecuteTileFillScalar(2, Zeros{PTO_XLEN} + 0x5a);
    var pop = DefaultTileInstructionOperands();
    pop.destination0 = 2;
    pop.source0 = 60;
    ClearFault();
    let (pop_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100001', pop);
    assert pop_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert !_Tiles[[60]].allocated;

    // The source operand selects the explicit slot; there is no implicit FIFO
    // cursor. A mismatched consumer rejects and keeps the selected slot held.
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    pop.destination0 = 4;
    pop.source0 = 61;
    ClearFault();
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100001', pop);
    assert shape_status == TileExecution_Rejected;
    assert _Tiles[[61]].allocated;
    ConfigureTwoByTwo(4);
    ClearFault();
    let (second_pop_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100001', pop);
    assert second_pop_status == TileExecution_Executed;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 33;
    assert !_Tiles[[61]].allocated;
    assert !TileOperandsLegal_TPOP(4, 4);

    // Consuming the released slot again and freeing it again both fail before
    // changing the configured consumer.
    ClearFault();
    let (empty_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100001', pop);
    assert empty_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 11;

    var free = DefaultTileInstructionOperands();
    free.destination0 = 60;
    ClearFault();
    let (double_free_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100011', free);
    assert double_free_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 11;
    ResetProfileState();
end;

// PTO-REQ-TILE-LEGALITY-001: all legality failures are decided before the
// first destination or composite matrix effect.
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
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 0x5a;

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
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(9, 0, 1) == Zeros{PTO_XLEN} + 0x5a;

    ReleaseTile(8);
    ClearFault();
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', division_operands);
    assert shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(9, 1, 1) == Zeros{PTO_XLEN} + 0x5a;

    ConfigureTwoByTwo(10);
    ConfigureTwoByTwo(11);
    ConfigureTwoByTwo(12);
    ConfigureTile(13, 256, 2, 3, 2, 3, TileDataType_U64,
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
    ClearFault();
    let (matrix_status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, '000000000001', matrix_operands);
    assert matrix_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(12, 0, 0) == Zeros{PTO_XLEN} + 0x66;
    assert ReadTileElement(12, 1, 1) == Zeros{PTO_XLEN} + 0x66;
end;

// PTO-REQ-MEMORY-COMPLETION-001: a gather fault at the first, middle, or last
// element preserves the complete destination; corrected reissue restarts at 0.
func TestTileMemoryCompletionAndRestart()
begin
    ConfigureTile(14, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(15, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    Store(Zeros{PTO_XLEN} + 1024, 8, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 1032, 8, Zeros{PTO_XLEN} + 0x22);
    Store(Zeros{PTO_XLEN} + 1040, 8, Zeros{PTO_XLEN} + 0x33);
    var gather_operands = DefaultTileInstructionOperands();
    gather_operands.destination0 = 14;
    gather_operands.address = Zeros{PTO_XLEN} + 1024;
    gather_operands.source0 = 15;

    ExecuteTileFillScalar(14, Zeros{PTO_XLEN} + 0x5a);
    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN} + 384);
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 2);
    ClearFault();
    let (first_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000100', gather_operands);
    assert first_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x5a;

    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 384);
    ClearFault();
    let (middle_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000100', gather_operands);
    assert middle_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x5a;

    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 384);
    ClearFault();
    let (last_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000100', gather_operands);
    assert last_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x5a;

    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 2);
    ClearFault();
    let (restart_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000100', gather_operands);
    assert restart_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x22;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x33;

    ConfigureTile(16, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(17, 256, 1, 3, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(16, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(17, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(17, 0, 1, Zeros{PTO_XLEN} + 320);
    WriteTileElement(17, 0, 2, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 1536, 8, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 1544, 8, Zeros{PTO_XLEN} + 0xbb);
    Store(Zeros{PTO_XLEN} + 1552, 8, Zeros{PTO_XLEN} + 0xcc);
    var scatter_operands = DefaultTileInstructionOperands();
    scatter_operands.address = Zeros{PTO_XLEN} + 1536;
    scatter_operands.source0 = 16;
    scatter_operands.source1 = 17;
    ClearFault();
    let (scatter_fault_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000101', scatter_operands);
    assert scatter_fault_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    ClearFault();
    let scatter_preserved_first = LoadUnsigned(Zeros{PTO_XLEN} + 1536, 8);
    let scatter_preserved_middle = LoadUnsigned(Zeros{PTO_XLEN} + 1544, 8);
    let scatter_preserved_last = LoadUnsigned(Zeros{PTO_XLEN} + 1552, 8);
    assert scatter_preserved_first == Zeros{PTO_XLEN} + 0xaa;
    assert scatter_preserved_middle == Zeros{PTO_XLEN} + 0xbb;
    assert scatter_preserved_last == Zeros{PTO_XLEN} + 0xcc;

    WriteTileElement(17, 0, 1, Zeros{PTO_XLEN} + 1);
    ClearFault();
    let (scatter_restart_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, '000000000101', scatter_operands);
    assert scatter_restart_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    let scatter_restart_first = LoadUnsigned(Zeros{PTO_XLEN} + 1536, 8);
    let scatter_restart_middle = LoadUnsigned(Zeros{PTO_XLEN} + 1544, 8);
    let scatter_restart_last = LoadUnsigned(Zeros{PTO_XLEN} + 1552, 8);
    assert scatter_restart_first == Zeros{PTO_XLEN} + 1;
    assert scatter_restart_middle == Zeros{PTO_XLEN} + 2;
    assert scatter_restart_last == Zeros{PTO_XLEN} + 3;
end;
