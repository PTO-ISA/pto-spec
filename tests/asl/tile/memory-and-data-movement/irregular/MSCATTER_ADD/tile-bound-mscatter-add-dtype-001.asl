// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-ADD-DTYPE-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER_ADD.asl","requirements":["PTO-ATOM-RED-TYPE-LEGALITY-001"],"kind":"boundary","summary":"MSCATTER_ADD retains its operation-specific ValueTile datatype matrix.","pass_condition":"Packed U4X2 and unsupported U8 ValueTiles are rejected by direct GM reduction legality before effects.","related_sources":["asl/tile/model/memory/gm-atom-red.asl","asl/tile/model/memory/gm-atom-red-execution.asl"]}
func RejectValueType(value_type: TileDataType)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 2, 1, 1, value_type,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    assert !TileOperandsLegal_GM_RED_VALUE(
        GMReduction_ADD, Zeros{PTO_XLEN}, 0, 1, TilePad_Null);
end;

func main() => integer
begin
    RejectValueType(TileDataType_U4X2);
    RejectValueType(TileDataType_U8);
    return 0;
end;
