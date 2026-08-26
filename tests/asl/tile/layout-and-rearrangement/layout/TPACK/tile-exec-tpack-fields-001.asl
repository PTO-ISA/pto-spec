// PTO-TEST: {"id":"PTO-AVS-TILE-TPACK-FIELDS-001","source":"asl/tile/layout-and-rearrangement/layout/TPACK.asl","requirements":["PTO-TPACK-CONTRACT-001","PTO-INST-TILE-TPACK"],"kind":"execution","summary":"TPACK assembles two low-order byte fields per U32 word.","pass_condition":"The destination contains the selected source fields with zeroed upper bits.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_3 = ConfigureCubeTile(3, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + 0x00001234);
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 0x00abcdef);
    end;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xcdef1234;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 0xcdef1234;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000301);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xabcdef34;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000103);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xef001234;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000101);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x0000ef34;
    let configured_4 = ConfigureCubeTile(4, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_5 = ConfigureCubeTile(5, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_6 = ConfigureCubeTile(6, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(4, row, column, Zeros{PTO_XLEN} + 0x00001234);
            WriteTileElement(5, row, column, Zeros{PTO_XLEN} + 0x00abcdef);
        end;
    end;
    TPACK(6, 4, 5, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 0xcdef1234;
    assert ReadTileElement(6, 0, 1) == Zeros{PTO_XLEN} + 0xcdef1234;
    assert !TileOperandsLegal_TPACK(6, 4, 5, Zeros{PTO_XLEN} + 0x00000100);
    return 0;
end;
