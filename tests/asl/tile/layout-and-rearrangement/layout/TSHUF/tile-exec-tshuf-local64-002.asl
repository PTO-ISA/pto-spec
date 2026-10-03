// PTO-TEST: {"id":"PTO-AVS-TILE-TSHUF-LOCAL64-002","source":"asl/tile/layout-and-rearrangement/layout/TSHUF.asl","requirements":["PTO-TSHUF-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"M32 64-bit TSHUF applies independent controls to the low and high raw words.","pass_condition":"Distinct low and high controls select different source rows and publish one coherent U64 logical element.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 256, 2, 1, TileDataType_U64, TileLayout_CUBE_M32);
    let controls_ready = ConfigureCubeTile(
        1, 256, 2, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        2, 256, 2, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert source_ready && controls_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xaaaabbbb11112222);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0xccccdddd33334444);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN});
    assert TileOperandsLegal_TSHUF(
        2, 0, 1, Zeros{PTO_XLEN} + 0x00000000);
    TSHUF(2, 0, 1, Zeros{PTO_XLEN} + 0x00000000);
    assert ReadTileElement(2, 1, 0) ==
        Zeros{PTO_XLEN} + 0xccccdddd11112222;
    return 0;
end;
