// PTO-TEST: {"id":"PTO-AVS-TILE-VEC-SFU-RESULTS-BOUND-005","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"merge and TFMA produce exact ordered results","pass_condition":"duplicate ordering and exact result assertions hold","related_sources":[]}
func ConfigureTeplTile(index: TileIndex, rows: integer {1..256},
                       columns: integer {1..256}, data_type: TileDataType)
begin
    // Ordinary totality cases share a compact 4 x 32 physical shape. The
    // histogram destination alone needs 256 physical columns. Capacity scales
    // with element width so mixed-type operations retain matching descriptors.
    let physical_columns: integer {1..256} = if columns > 32 then 256 else 32;
    let capacity_bytes = (physical_columns * 4 *
        TileElementBytes(data_type)) as integer {0..262144};
    ConfigureTile(index, capacity_bytes, rows, physical_columns, rows, columns,
        data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTeplMergeDuplicateOrdering()
begin
    ResetProfileState();
    ConfigureTeplTile(0, 1, 5, TileDataType_FP32);
    ConfigureTeplTile(1, 1, 3, TileDataType_FP32);
    ConfigureTeplTile(2, 1, 2, TileDataType_FP32);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x40400000);
    var merge = DefaultTileInstructionOperands();
    merge.destination0 = 0;
    merge.source0 = 1;
    merge.source1 = 2;
    ClearFault();
    let (ascending_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101101', merge);
    assert ascending_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(0, 0, 4) == Zeros{PTO_XLEN} + 0x40400000;

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    merge.flag0 = TRUE;
    ClearFault();
    let (descending_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101101', merge);
    assert descending_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(0, 0, 4) == Zeros{PTO_XLEN} + 0x3f800000;
end;

func TestTeplTfmaExactResult()
begin
    ResetProfileState();
    ConfigureTeplTile(0, 1, 1, TileDataType_U64);
    ConfigureTeplTile(1, 1, 1, TileDataType_U64);
    ConfigureTeplTile(2, 1, 1, TileDataType_U64);
    ConfigureTeplTile(3, 1, 1, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    TFMA(0, 1, 2, 3);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 11;
end;

func main() => integer
begin
    ResetProfileState();
    TestTeplMergeDuplicateOrdering();
    TestTeplTfmaExactResult();
    return 0;
end;
