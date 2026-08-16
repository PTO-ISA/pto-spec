// PTO-TEST: {"id":"PTO-AVS-TILE-VEC-SFU-INDEX-CORNERS-BOUND-004","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"index, sort, histogram, and offset corner cases are effect safe","pass_condition":"corner-case results and no-effect assertions hold","related_sources":[]}
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

func FillTeplTile(index: TileIndex, seed: integer {0..65535})
begin
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let offset = (row * tile.valid_columns + column)
                as integer {0..65535};
            WriteTileElement(index, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + seed + offset + 1);
        end;
    end;
end;

func ConfigureTeplFilledTile(index: TileIndex, rows: integer {1..256},
                             columns: integer {1..256},
                             data_type: TileDataType,
                             seed: integer {0..65535})
begin
    ConfigureTeplTile(index, rows, columns, data_type);
    FillTeplTile(index, seed);
end;

func TestTeplIndexSortHistogramCorners()
begin
    ResetProfileState();
    ConfigureTeplTile(0, 2, 2, TileDataType_U16);
    ConfigureTeplFilledTile(1, 1, 2, TileDataType_U16, 10);
    ConfigureTeplTile(2, 1, 2, TileDataType_U16);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    var scatter = DefaultTileInstructionOperands();
    scatter.destination0 = 0;
    scatter.source0 = 1;
    scatter.source1 = 2;
    ClearFault();
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001110000', scatter);
    assert scatter_status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN};

    ResetProfileState();
    ConfigureTeplTile(0, 1, 4, TileDataType_FP32);
    ConfigureTeplTile(2, 1, 4, TileDataType_U32);
    ConfigureTeplTile(1, 1, 4, TileDataType_FP32);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x40800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 0x40000000);
    var sort = DefaultTileInstructionOperands();
    sort.destination0 = 0;
    sort.destination1 = 2;
    sort.source0 = 1;
    sort.sort_width = 2;
    sort.flag0 = TRUE;
    ClearFault();
    let (sort_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101100', sort);
    assert sort_status == TileExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x40800000;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0x40000000;

end;

func TestTeplInvalidIndexAndOffsetNoEffect()
begin
    ResetProfileState();
    ConfigureTeplFilledTile(0, 1, 2, TileDataType_U16, 90);
    ConfigureTeplFilledTile(1, 2, 2, TileDataType_U16, 10);
    ConfigureTeplTile(2, 1, 2, TileDataType_U32);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    var gather = DefaultTileInstructionOperands();
    gather.destination0 = 0;
    gather.source0 = 1;
    gather.source1 = 2;
    ClearFault();
    let (gather_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001101111', gather);
    assert gather_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 91;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 92;

    ResetProfileState();
    ConfigureTeplFilledTile(0, 2, 2, TileDataType_U64, 90);
    ConfigureTeplFilledTile(1, 1, 2, TileDataType_U64, 10);
    ConfigureTeplTile(2, 1, 2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    var scatter = DefaultTileInstructionOperands();
    scatter.destination0 = 0;
    scatter.source0 = 1;
    scatter.source1 = 2;
    ClearFault();
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000001110000', scatter);
    assert scatter_status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 91;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 94;
end;

func main() => integer
begin
    ResetProfileState();
    TestTeplIndexSortHistogramCorners();
    TestTeplInvalidIndexAndOffsetNoEffect();
    return 0;
end;
