// PTO-TEST: {"id":"PTO-AVS-TILE-GPR-MASK-EIGHT-BIT-001","source":"asl/tile/model/execution/predicate-carriers.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"CUBE Predicate-GPR comparison carrier uses two words for every supported 8-bit operation type","pass_condition":"U8, S8, E4M3, and E5M2 CUBE_M16 comparisons produce equivalent low/high predicate words using the canonical coordinate map","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/block/model/dispatch/comparison-schema.asl"]}
func CheckEightBitPredicateGPRType(data_type: TileDataType)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        10, 128, 1, 8, data_type, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        11, 128, 1, 8, data_type, TileLayout_CUBE_M16);
    assert left_ready && right_ready;
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN});
        WriteTileElement(11, 0, column, Zeros{PTO_XLEN});
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    assert TileCubePredicateGPRDataTypeSupported(data_type);
    assert TileCubePredicateGPRShapeLegalAs(10, data_type);
    let low = TileCompareCUBEToGPRAs(
        10, 11, TileComparison_EQ, FALSE, data_type);
    let high = TileCompareCUBEToGPRAs(
        10, 11, TileComparison_EQ, TRUE, data_type);
    for column = 0 to 7 looplimit 8 do
        assert TileCubePredicateGPRBit(
            low, high, TileLayout_CUBE_M16, 0, column);
    end;
end;

func main() => integer
begin
    CheckEightBitPredicateGPRType(TileDataType_U8);
    CheckEightBitPredicateGPRType(TileDataType_S8);
    CheckEightBitPredicateGPRType(TileDataType_E4M3);
    CheckEightBitPredicateGPRType(TileDataType_E5M2);
    return 0;
end;
