// PTO-TEST: {"id":"PTO-AVS-TILE-TPACK-UNPACK-LOCAL64-002","source":"asl/tile/layout-and-rearrangement/layout/TPACK.asl","requirements":["PTO-TPACK-CONTRACT-001","PTO-TUNPACK-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"TPACK and TUNPACK join complete raw-word pairs into M32 U64 destinations.","pass_condition":"Two source words form one U64 element, U64 unpack preserves both raw planes, an odd source-word tail rejects, and independently masked planes publish one coherent MERGE result without reading the inactive word.","related_sources":["asl/tile/layout-and-rearrangement/layout/TUNPACK.asl","asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let right_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let packed_ready = ConfigureCubeTile(
        2, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    let unpacked_ready = ConfigureCubeTile(
        3, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert left_ready && right_ready && packed_ready && unpacked_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x00002211);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x00006655);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x00004433);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x00008877);
    assert TileOperandsLegal_TPACK(
        2, 0, 1, Zeros{PTO_XLEN} + 0x00000202);
    TPACK(2, 0, 1, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(2, 0, 0) ==
        Zeros{PTO_XLEN} + 0x8877665544332211;
    assert TileOperandsLegal_TUNPACK(
        3, 2, Zeros{PTO_XLEN} + 0x00000400);
    TUNPACK(3, 2, Zeros{PTO_XLEN} + 0x00000400);
    assert ReadTileElement(3, 0, 0) ==
        Zeros{PTO_XLEN} + 0x8877665544332211;

    let odd_source_ready = ConfigureCubeTile(
        4, 512, 1, 3, TileDataType_U32, TileLayout_CUBE_M32);
    let odd_destination_ready = ConfigureCubeTile(
        5, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert odd_source_ready && odd_destination_ready;
    assert !TileOperandsLegal_TUNPACK(
        5, 4, Zeros{PTO_XLEN} + 0x00000400);

    let merge_ready = ConfigureCubeTile(
        6, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert merge_ready;
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0xdeadbeef00000000);
    var execution_mask = Zeros{PTO_XLEN};
    execution_mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M32, 1, 2);
    _BundleExecutionMask.merge_base = 6;
    _BundleExecutionMask.merge_base_valid = TRUE;
    _Tiles[[0]] = TileInfoWithLogicalElementAndDefined(
        _Tiles[[0]], TileLogicalLinearIndex(_Tiles[[0]], 0, 1),
        Zeros{PTO_XLEN} + 0x00006655, FALSE);
    _Tiles[[1]] = TileInfoWithLogicalElementAndDefined(
        _Tiles[[1]], TileLogicalLinearIndex(_Tiles[[1]], 0, 1),
        Zeros{PTO_XLEN} + 0x00008877, FALSE);
    assert TileOperandsLegal_TPACK(
        2, 0, 1, Zeros{PTO_XLEN} + 0x00000202);
    TPACK(2, 0, 1, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(2, 0, 0) ==
        Zeros{PTO_XLEN} + 0xdeadbeef44332211;
    return 0;
end;
