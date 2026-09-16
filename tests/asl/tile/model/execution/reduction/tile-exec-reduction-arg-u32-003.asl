// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-ARG-U32-003","source":"asl/tile/model/execution/reduction.asl","requirements":["PTO-TCOLARGMAX-CONTRACT-001"],"kind":"execution","summary":"CUBE ARG reductions from U8 and U16 sources publish U32 indices into independently sized destinations","pass_condition":"both U8 and U16 CUBE sources execute column ARGMAX into a larger U32 CUBE destination, while an undersized U32 destination is rejected without capacity consumption","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/shape/cube-cell.asl"]}
func TestArgSource(data_type: TileDataType)
begin
    ResetProfileState();
    let source = ConfigureCubeTileForMaskWithPhysical(0, 512, 16, 16,
        4, 8, data_type, TileLayout_CUBE_M16, '0001');
    let destination = ConfigureCubeTileForMaskWithPhysical(1, 1024, 16, 8,
        1, 8, TileDataType_U32, TileLayout_CUBE_M16, '0001');
    assert source && destination;
    assert _Tiles[[0]].data_type == data_type;
    let capacity_before = TileCapacityInUseForPE(0);
    let undersized = ConfigureCubeTileForMaskWithPhysical(2, 128, 16, 8,
        1, 8, TileDataType_U32, TileLayout_CUBE_M16, '0001');
    assert !undersized;
    assert !_Tiles[[2]].allocated;
    assert TileCapacityInUseForPE(0) == capacity_before;
    for row = 0 to 3 looplimit 4 do
        for column = 0 to 7 looplimit 8 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + (row as integer {0..65535}));
        end;
    end;
    ExecuteTileReduction(TileReduction_ARGMAX, TileAxis_Column, 1, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert _Tiles[[1]].data_type == TileDataType_U32;
    assert _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 8;
    assert !TileCubeDescriptorShapeAndPhysicalLegal(128, 16, 8, 1, 8,
        TileDataType_U32, TileLayout_CUBE_M16);
end;

func main() => integer
begin
    TestArgSource(TileDataType_U8);
    TestArgSource(TileDataType_U16);
    return 0;
end;
