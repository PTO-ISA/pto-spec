// PTO-TEST: {"id":"PTO-AVS-TILE-ARG-REDUCTION-LOCAL64-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMIN.asl","requirements":["PTO-TROWARGMIN-CONTRACT-001","PTO-TROWARGMAX-CONTRACT-001","PTO-TCOLARGMIN-CONTRACT-001","PTO-TCOLARGMAX-CONTRACT-001","PTO-LOCAL-TILE-B64-APPLICABILITY-001"],"kind":"execution","summary":"M32 64-bit arg reductions preserve signed/unsigned/FP64 comparisons, earliest ties and U32 result indices.","pass_condition":"All four axis/minmax combinations return independent index goldens for all three 64-bit source types with narrower U32 destinations.","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
func ArgReductionLocal64(data_type: TileDataType, axis: TileAxis,
    maximum: boolean, expected: Word)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(1, 512, 2, 2, data_type, TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTileForMaskWithColumns(0, 256,
        (if axis == TileAxis_Row then 2 else 1),
        2, (if axis == TileAxis_Row then 1 else 2),
        TileDataType_U32, TileLayout_CUBE_M32, '0001');
    assert source_ready && destination_ready;
    for row = 0 to 1 do
        WriteTileElement(1, row as integer {0..65535}, 0,
            (if data_type == TileDataType_FP64 then Zeros{PTO_XLEN} + 0x4020000000000000 else Zeros{PTO_XLEN} + 8));
        WriteTileElement(1, row as integer {0..65535}, 1,
            (if data_type == TileDataType_FP64 then Zeros{PTO_XLEN} + 0xc000000000000000
             else if data_type == TileDataType_S64 then Ones{PTO_XLEN} - 1
             else Zeros{PTO_XLEN} + 0x8000000000000000));
    end;
    ExecuteTileReduction(
        (if maximum then TileReduction_ARGMAX else TileReduction_ARGMIN),
        axis, 0, 1);
    assert _Tiles[[0]].data_type == TileDataType_U32;
    assert ReadTileElement(0, 0, 0) == expected;
    assert ReadTileElement(0, (if axis == TileAxis_Row then 1 else 0),
        (if axis == TileAxis_Row then 0 else 1)) == expected;
end;

func main() => integer
begin
    ArgReductionLocal64(TileDataType_FP64, TileAxis_Row, FALSE, Zeros{PTO_XLEN} + 1);
    ArgReductionLocal64(TileDataType_FP64, TileAxis_Row, TRUE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_FP64, TileAxis_Column, FALSE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_FP64, TileAxis_Column, TRUE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_S64, TileAxis_Row, FALSE, Zeros{PTO_XLEN} + 1);
    ArgReductionLocal64(TileDataType_S64, TileAxis_Row, TRUE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_S64, TileAxis_Column, FALSE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_S64, TileAxis_Column, TRUE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_U64, TileAxis_Row, FALSE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_U64, TileAxis_Row, TRUE, Zeros{PTO_XLEN} + 1);
    ArgReductionLocal64(TileDataType_U64, TileAxis_Column, FALSE, Zeros{PTO_XLEN} + 0);
    ArgReductionLocal64(TileDataType_U64, TileAxis_Column, TRUE, Zeros{PTO_XLEN} + 0);
    return 0;
end;
