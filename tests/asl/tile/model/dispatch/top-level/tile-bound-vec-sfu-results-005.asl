// PTO-TEST: {"id":"PTO-AVS-TILE-VEC-SFU-RESULTS-BOUND-005","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"TFMA produces an exact result","pass_condition":"the exact TFMA result assertion holds","related_sources":[]}
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
    TestTeplTfmaExactResult();
    return 0;
end;
