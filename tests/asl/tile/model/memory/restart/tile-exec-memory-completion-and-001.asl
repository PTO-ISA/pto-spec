// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILEMEMORYCOMPLETIONANDRESTART-EXECUTION-001","source":"asl/tile/model/memory/restart.asl","requirements":[],"kind":"execution","summary":"Covers Tile Memory Completion And Restart.","pass_condition":"TestTileMemoryCompletionAndRestart completes without assertion failure","related_sources":[]}
func TestTileMemoryCompletionAndRestart()
begin
    ConfigureTile(14, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(15, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    Store(Zeros{PTO_XLEN} + 1024, 8, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 1032, 8, Zeros{PTO_XLEN} + 0x22);
    Store(Zeros{PTO_XLEN} + 1040, 8, Zeros{PTO_XLEN} + 0x33);
    var gather_operands = DefaultTileInstructionOperands();
    gather_operands.destination0 = 14;
    gather_operands.address = Zeros{PTO_XLEN} + 1024;
    gather_operands.source0 = 15;

    ExecuteTileFillScalar(14, Zeros{PTO_XLEN} + 0x5a);
    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN} + 3072);
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 16);
    ClearFault();
    let (first_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000100', gather_operands);
    assert first_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x5a;

    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 3072);
    ClearFault();
    let (middle_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000100', gather_operands);
    assert middle_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x5a;

    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 3072);
    ClearFault();
    let (last_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000100', gather_operands);
    assert last_status == TileExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x5a;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x5a;

    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 16);
    ClearFault();
    let (restart_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000100', gather_operands);
    assert restart_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(14, 0, 1) == Zeros{PTO_XLEN} + 0x22;
    assert ReadTileElement(14, 0, 2) == Zeros{PTO_XLEN} + 0x33;

    ConfigureTile(16, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(17, 256, 1, 4, 1, 3, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(16, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(17, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(17, 0, 1, Zeros{PTO_XLEN} + 2560);
    WriteTileElement(17, 0, 2, Zeros{PTO_XLEN} + 16);
    Store(Zeros{PTO_XLEN} + 1536, 8, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 1544, 8, Zeros{PTO_XLEN} + 0xbb);
    Store(Zeros{PTO_XLEN} + 1552, 8, Zeros{PTO_XLEN} + 0xcc);
    var scatter_operands = DefaultTileInstructionOperands();
    scatter_operands.address = Zeros{PTO_XLEN} + 1536;
    scatter_operands.source0 = 16;
    scatter_operands.source1 = 17;
    ClearFault();
    let (scatter_fault_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000101', scatter_operands);
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

    WriteTileElement(17, 0, 1, Zeros{PTO_XLEN} + 8);
    ClearFault();
    let (scatter_restart_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, '000000000101', scatter_operands);
    assert scatter_restart_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    let scatter_restart_first = LoadUnsigned(Zeros{PTO_XLEN} + 1536, 8);
    let scatter_restart_middle = LoadUnsigned(Zeros{PTO_XLEN} + 1544, 8);
    let scatter_restart_last = LoadUnsigned(Zeros{PTO_XLEN} + 1552, 8);
    assert scatter_restart_first == Zeros{PTO_XLEN} + 1;
    assert scatter_restart_middle == Zeros{PTO_XLEN} + 2;
    assert scatter_restart_last == Zeros{PTO_XLEN} + 3;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileMemoryCompletionAndRestart();
    return 0;
end;
