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

func TestTileManagement()
begin
    ConfigureTile(38, 256, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    WriteTileElement(38, 0, 0, Zeros{PTO_XLEN} + 71);
    WriteTileElement(38, 0, 1, Zeros{PTO_XLEN} + 72);
    ConfigurePipe(0, Zeros{PTO_XLEN} + 1024, 64, 2);
    TPUSH(0, 38);
    assert _Pipes[[0]].count == 1;
    TPOP(39, 0);
    assert _Pipes[[0]].count == 0;
    assert _Tiles[[39]].allocated;
    assert ReadTileElement(39, 0, 0) == Zeros{PTO_XLEN} + 71;
    assert ReadTileElement(39, 0, 1) == Zeros{PTO_XLEN} + 72;

    let allocated_slot = TALLOC(0);
    assert allocated_slot == Zeros{PTO_XLEN} + 1088;
    Store(allocated_slot, 8, Zeros{PTO_XLEN} + 99);
    TPUSHGlobal(0, allocated_slot);
    assert _Pipes[[0]].count == 1;
    let popped_slot = TPOPGlobal(0);
    assert popped_slot == allocated_slot;
    let popped_value = LoadUnsigned(popped_slot, 8);
    assert popped_value == Zeros{PTO_XLEN} + 99;
    TFREE(0);
    assert _Pipes[[0]].count == 0;
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

// PTO-REQ-TILE-DISPATCH-001: representative decoded effects cover every
// direct family, value-returning management, and unknown-selector rejection.
func TestDecodedTileExecution()
begin
    ConfigureTwoByTwo(0);
    ConfigureTwoByTwo(1);
    ConfigureTwoByTwo(2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
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

    ConfigurePipe(1, Zeros{PTO_XLEN} + 2048, 64, 2);
    var allocation_operands = DefaultTileInstructionOperands();
    allocation_operands.pipe = 1;
    let (allocation_status, allocation_value) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', allocation_operands);
    assert allocation_status == TileExecution_Executed;
    assert allocation_value == Zeros{PTO_XLEN} + 2048;

    let (rejected_status, rejected_value) = ExecuteTileInstruction(
        TileDecode_TEPL, '111111111111', DefaultTileInstructionOperands());
    assert rejected_status == TileExecution_Rejected;
    assert rejected_value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;
end;

// PTO-REQ-TILE-LEGALITY-001: all legality failures are decided before the
// first destination, pipe, or composite matrix effect.
func TestDecodedTileLegalityFaults()
begin
    ConfigureTwoByTwo(7);
    ConfigureTwoByTwo(8);
    ConfigureTwoByTwo(9);
    ExecuteTileFillScalar(7, Zeros{PTO_XLEN} + 8);
    ExecuteTileFillScalar(8, Zeros{PTO_XLEN} + 2);
    ExecuteTileFillScalar(9, Zeros{PTO_XLEN} + 0x5a);
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
    assert _TrapNumber == Zeros{6} + 5;
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(9, 0, 1) == Zeros{PTO_XLEN} + 0x5a;

    ConfigureTile(8, 0, 0, 0, 0, 0, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ClearFault();
    let (shape_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', division_operands);
    assert shape_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(9, 1, 1) == Zeros{PTO_XLEN} + 0x5a;

    var pipe_operands = DefaultTileInstructionOperands();
    pipe_operands.pipe = 2;
    ClearFault();
    let (pipe_status, pipe_value) = ExecuteTileInstruction(
        TileDecode_TEPL, '000011100010', pipe_operands);
    assert pipe_status == TileExecution_Rejected;
    assert pipe_value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_TileLegality;
    assert !_Pipes[[2]].producer_claimed;

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
