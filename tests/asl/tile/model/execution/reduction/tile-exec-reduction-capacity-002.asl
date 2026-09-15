// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-CAPACITY-002","source":"asl/tile/model/execution/reduction.asl","requirements":["PTO-TROWSUM-CONTRACT-001"],"kind":"execution","summary":"Row reductions accept both baseline and larger legal source capacities","pass_condition":"2048-byte and 4096-byte M16 sources execute row SUM and publish the same numerical result","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/state/allocation.asl"]}
func FillSource(index: TileIndex)
begin
    for row = 0 to 15 looplimit 16 do
        WriteTileElement(index, row, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(index, row, 1, Zeros{PTO_XLEN} + 4);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let source_2048 = ConfigureCubeTile(0, 2048, 16, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    let destination_2048 = ConfigureCubeTile(1, 128, 16, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    let source_4096 = ConfigureCubeTile(2, 4096, 16, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    let destination_4096 = ConfigureCubeTile(3, 128, 16, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert source_2048 && destination_2048 && source_4096 && destination_4096;
    FillSource(0);
    FillSource(2);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 1, 0);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 3, 2);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
