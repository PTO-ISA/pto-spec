// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-ARG-U32-003","source":"asl/tile/model/execution/reduction.asl","requirements":["PTO-TCOLARGMAX-CONTRACT-001"],"kind":"execution","summary":"CUBE ARG reductions publish U32 indices into a destination with independently required capacity","pass_condition":"a U8 CUBE source executes a column ARGMAX into a larger U32 CUBE destination and an undersized destination is rejected","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/shape/cube-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source = ConfigureCubeTileForMaskWithPhysical(0, 4096, 16, 16,
        4, 8, TileDataType_U8, TileLayout_CUBE_M16, '0001');
    let destination = ConfigureCubeTileForMaskWithPhysical(1, 1024, 16, 8,
        1, 8, TileDataType_U32, TileLayout_CUBE_M16, '0001');
    assert source && destination;
    for row = 0 to 3 looplimit 4 do
        for column = 0 to 7 looplimit 8 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + (row as integer {0..65535}));
        end;
    end;
    ExecuteTileReduction(TileReduction_ARGMAX, TileAxis_Column, 1, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert !TileCubeDescriptorShapeAndPhysicalLegal(256, 16, 8, 1, 8,
        TileDataType_U32, TileLayout_CUBE_M16);
    return 0;
end;
