// PTO-TEST: {"id":"PTO-AVS-TILE-TLSU-DECODE-BOUND-004","source":"asl/tile/model/memory/load-store.asl","requirements":[],"kind":"boundary","summary":"TLSU decoded selectors close assigned and rejected operations","pass_condition":"decoded selector closure assertions hold","related_sources":[]}
func ConfigurePackedTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    // Keep packed data and U64 index tiles on the same legal physical shape:
    // 16 rows x 16 power-of-two columns. Only the valid-column extent varies.
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureByteTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTlsuDecodedSelectorClosure()
begin
    StopMemoryEventCapture();
    ConfigurePackedTlsuTile(20, 1);
    ConfigurePackedTlsuTile(21, 1);
    ConfigureTile(22, 1024, 1, 16, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(23, 128, 1, 16, 1, 1);
    ConfigureByteTlsuTile(24, 1);
    ConfigureByteTlsuTile(25, 1);
    WriteTileElement(20, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(23, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(24, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(25, 0, 0, Zeros{PTO_XLEN} + 4);

    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 0xa2);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    let (load_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12}, operands);
    assert load_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 2;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    let (store_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 1, operands);
    assert store_status == TileExecution_Executed;
    let stored_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert stored_byte == Zeros{PTO_XLEN} + 0xa3;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.source0 = 21;
    let (move_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 2, operands);
    assert move_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.scalar0 = Zeros{PTO_XLEN} + 1;
    operands.positive0 = 1;
    operands.positive1 = 1;
    operands.positive2 = 1;
    // TPREFETCH's direct semantic carrier receives DataType from the active
    // block start because the operation has no destination descriptor.
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMemory;
    _BundleOperation.data_type_valid = TRUE;
    _BundleOperation.data_type = Zeros{5} + 27;
    let (prefetch_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 3, operands);
    assert prefetch_status == TileExecution_Executed;

    ReleaseTile(20);
    ConfigureByteTlsuTile(20, 1);
    ReleaseTile(21);
    ConfigureByteTlsuTile(21, 1);
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 3);
    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    let (gather_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 4, operands);
    assert gather_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    ReleaseTile(20);
    ConfigureByteTlsuTile(20, 1);

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    operands.source1 = 22;
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 5, operands);
    assert scatter_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    operands.source1 = 23;
    let (masked_gather_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 6, operands);
    assert masked_gather_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    operands.source1 = 22;
    operands.source2 = 23;
    let (masked_scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 7, operands);
    assert masked_scatter_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    operands.source1 = 24;
    operands.source2 = 25;
    let (gather_cas_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 8, operands);
    assert gather_cas_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.source0 = 21;
    operands.scalar0 = Zeros{PTO_XLEN} + 2;
    let (gmov_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 13, operands);
    assert gmov_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;
end;

func main() => integer
begin
    ResetProfileState();
    TestTlsuDecodedSelectorClosure();
    return 0;
end;
