func TestScalarState()
begin
    WriteGPR(1, Zeros{PTO_XLEN} + 42);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 42;
    WriteGPR(0, Ones{PTO_XLEN});
    assert ReadGPR(0) == Zeros{PTO_XLEN};

    WritePC(Zeros{PTO_XLEN} + 16);
    assert ReadPC() == Zeros{PTO_XLEN} + 16;
    WritePredicateRegister(0, Zeros{PTO_XLEN} + 0xf0);
    WritePredicateRegister(7, Zeros{PTO_XLEN} + 0x7f);
    assert ReadPredicateRegister(0) == Zeros{PTO_XLEN} + 0xf0;
    assert ReadPredicateRegister(7) == Zeros{PTO_XLEN} + 0x7f;
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
    assert TileCapacityIsLegal(524288);
    assert !TileCapacityIsLegal(32);
end;

func TestScalarTemporaryQueues()
begin
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 10);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 20);
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 20;
    assert ReadScalarRegisterOperand(25) == Zeros{PTO_XLEN} + 10;

    WriteScalarDestination(30, Zeros{PTO_XLEN} + 300);
    WriteScalarDestination(30, Zeros{PTO_XLEN} + 301);
    WriteScalarDestination(31, Zeros{PTO_XLEN} + 310);
    assert ReadScalarRegisterOperand(28) == Zeros{PTO_XLEN} + 301;
    assert ReadScalarRegisterOperand(29) == Zeros{PTO_XLEN} + 300;
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 310;

    WriteGPR(5, Zeros{PTO_XLEN} + 5);
    WriteScalarDestination(24, Ones{PTO_XLEN});
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 5;
end;

func TestTileAllocationState()
begin
    ConfigureTile(5, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_ImplementationDefined, TileLocation_Any);
    assert _Tiles[[5]].allocated;
    assert !_Tiles[[5]].contents_defined;
    assert TileDescriptorConfigured(5);
    assert !TileGenericIndexingPermitted(_Tiles[[5]]);
    assert !TileDescriptorLegal(5);

    ConfigureTile(5, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert !_Tiles[[5]].contents_defined;
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 9);
    assert _Tiles[[5]].contents_defined;
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 9;
end;
