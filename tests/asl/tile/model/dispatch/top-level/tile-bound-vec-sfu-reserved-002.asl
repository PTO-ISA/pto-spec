// PTO-TEST: {"id":"PTO-AVS-TILE-VEC-SFU-RESERVED-BOUND-002","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"reserved VEC and SFU selectors reject without effects","pass_condition":"reserved-selector rejection preserves the state fingerprint","related_sources":[]}
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

func ConfigureTeplDefaultCase() => TileInstructionOperands
begin
    for index = 0 to 5 do
        ConfigureTeplFilledTile(index as TileIndex, 2, 2,
            TileDataType_U64, (index + 1) as integer {0..65535});
    end;
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 0;
    operands.destination1 = 5;
    operands.source0 = 1;
    operands.source1 = 2;
    operands.source2 = 3;
    operands.source3 = 4;
    operands.scalar0 = Zeros{PTO_XLEN} + 2;
    operands.positive0 = 1;
    operands.positive1 = 1;
    operands.positive2 = 1;
    operands.positive3 = 1;
    operands.natural0 = 0;
    operands.natural1 = 0;
    operands.selected_byte = 3;
    operands.flag0 = FALSE;
    return operands;
end;

readonly func TeplTileFingerprint(index: TileIndex) => Word
begin
    var fingerprint = Zeros{PTO_XLEN};
    if _Tiles[[index]].allocated then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 1;
    end;
    if _Tiles[[index]].contents_defined then
        fingerprint = fingerprint + Zeros{PTO_XLEN} + 2;
    end;
    let bounded_capacity = if _Tiles[[index]].capacity_bytes > 262144 then
        262144 else _Tiles[[index]].capacity_bytes;
    fingerprint = fingerprint +
        NaturalToWord(bounded_capacity as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].rows * 3) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].columns * 5) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].valid_rows * 7) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].valid_columns * 11) as integer {0..262144});
    fingerprint = fingerprint +
        NaturalToWord((_Tiles[[index]].defined_valid_elements * 13)
            as integer {0..262144});
    for element = 0 to 15 do
        fingerprint = fingerprint +
            NaturalToWord((element + 17) as integer {0..262144});
        if _Tiles[[index]].defined_elements[element] == '1' then
            fingerprint = fingerprint +
                _Tiles[[index]].payload[[element as ModelTileElementIndex]] +
                NaturalToWord(((element + 1) * 257)
                    as integer {0..262144});
        end;
    end;
    return fingerprint;
end;

readonly func TeplStateFingerprint() => Word
begin
    var fingerprint = Zeros{PTO_XLEN};
    for index = 0 to 7 do
        fingerprint = fingerprint +
            TeplTileFingerprint(index as TileIndex) +
            NaturalToWord((index + 1) as integer {0..262144});
    end;
    return fingerprint;
end;

func TestTeplReservedSelectorRejection()
begin
    var rejected: integer {0..256} = 0;
    for selector = 0 to 127 do
        let code = Zeros{12} + selector;
        if DecodeTileOperation(TileDecode_TEPL, code) == PTO_TILE_OPERATION_COUNT then
            ResetProfileState();
            let operands = ConfigureTeplDefaultCase();
            let before = TeplStateFingerprint();
            ClearFault();
            let (status, value) = ExecuteTileInstruction(
                TileDecode_TEPL, code, operands);
            assert status == TileExecution_Rejected;
            assert value == Zeros{PTO_XLEN};
            assert _LastFault == Fault_IllegalInstruction;
            assert TeplStateFingerprint() == before;
            rejected = (rejected + 1) as integer {0..256};
        end;
    end;
    assert rejected == 43;
end;

func main() => integer
begin
    ResetProfileState();
    TestTeplReservedSelectorRejection();
    return 0;
end;
