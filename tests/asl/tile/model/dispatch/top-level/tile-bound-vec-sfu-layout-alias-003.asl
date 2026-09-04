// PTO-TEST: {"id":"PTO-AVS-TILE-VEC-SFU-LAYOUT-ALIAS-BOUND-003","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"VEC and SFU raw carriers enforce layout rules","pass_condition":"carrier and layout assertions hold","related_sources":[]}
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

func TestTeplRawCarrierAndLayoutPolicy()
begin
    assert TileTeplRawCarrierTypeSupported(TileDataType_FP64);
    assert TileTeplRawCarrierTypeSupported(TileDataType_FP32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_TF32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_HF32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_FP16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_BF16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_HiF8);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E4M3);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E5M2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E3M2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E2M3);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E2M1X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E1M2X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_E8M0);
    assert TileTeplRawCarrierTypeSupported(TileDataType_HiF4X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S64);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S8);
    assert TileTeplRawCarrierTypeSupported(TileDataType_S4X2);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U64);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U32);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U16);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U8);
    assert TileTeplRawCarrierTypeSupported(TileDataType_U4X2);

    ResetProfileState();
    ConfigureTeplFilledTile(0, 1, 1, TileDataType_U64, 90);
    ConfigureTeplFilledTile(1, 1, 1, TileDataType_U64, 1);
    ConfigureTeplFilledTile(2, 1, 1, TileDataType_U64, 2);
    _Tiles[[1]].layout = TileLayout_ImplementationDefined;
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.source0 = 1;
    operands.source1 = 2;
    ClearFault();
    let (status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, '000000000000', operands);
    assert status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 91;
end;

func main() => integer
begin
    ResetProfileState();
    TestTeplRawCarrierAndLayoutPolicy();
    return 0;
end;
