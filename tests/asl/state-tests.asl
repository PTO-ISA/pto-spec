func TestScalarState()
begin
    WriteGPR(1, Zeros{PTO_XLEN} + 42);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 42;
    WriteGPR(0, Ones{PTO_XLEN});
    assert ReadGPR(0) == Zeros{PTO_XLEN};

    WritePC(Zeros{PTO_XLEN} + 16);
    assert ReadPC() == Zeros{PTO_XLEN} + 16;
    ClearFault();
    assert _LastFault == Fault_None;
end;

func TestTileRegisterMapping()
begin
    assert TileHandOf(0) == TileHand_T;
    assert TileHandOf(15) == TileHand_T;
    assert TileHandOf(16) == TileHand_U;
    assert TileHandOf(32) == TileHand_M;
    assert TileHandOf(63) == TileHand_N;
    assert TileIndexWithinHand(0) == 1;
    assert TileIndexWithinHand(63) == 16;

    assert TileCapacityIsLegal(0);
    assert TileCapacityIsLegal(256);
    assert TileCapacityIsLegal(262144);
    assert !TileCapacityIsLegal(32);
    assert !TileCapacityIsLegal(524288);
end;

func TestScalarOperandBridge()
begin
    ConfigureTile(0, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(16, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(2, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(19, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);

    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 24);
    WriteTileElement(19, 0, 0, Zeros{PTO_XLEN} + 31);
    assert ReadScalarRegisterOperand(26) == Zeros{PTO_XLEN} + 24;
    assert ReadScalarRegisterOperand(31) == Zeros{PTO_XLEN} + 31;

    WriteScalarDestination(30, Zeros{PTO_XLEN} + 300);
    WriteScalarDestination(31, Zeros{PTO_XLEN} + 310);
    assert ReadTileElement(16, 0, 0) == Zeros{PTO_XLEN} + 300;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 310;

    WriteGPR(5, Zeros{PTO_XLEN} + 5);
    WriteScalarDestination(24, Ones{PTO_XLEN});
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 5;
end;
