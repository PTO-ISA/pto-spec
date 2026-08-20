// PTO-TEST: {"id":"PTO-AVS-TILE-TLSU-BYTE-ROW-STRIDE-EXECUTION-005","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-ARCH-GM-ACCESS-001"],"kind":"execution","summary":"TLOAD and TSTORE use byte row strides for FP16 and FP32","pass_condition":"Second-row addresses add the encoded byte stride exactly once for load and store","related_sources":["asl/tile/model/memory/stride.asl","asl/tile/memory-and-data-movement/regular/TLOAD.asl","asl/tile/memory-and-data-movement/regular/TSTORE.asl"]}
func main() => integer
begin
    ResetProfileState();

    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    let fp32_load_base = Zeros{PTO_XLEN} + 0x100;
    Store(fp32_load_base, 4, Zeros{PTO_XLEN} + 0x3f800000);
    Store(fp32_load_base + 4, 4, Zeros{PTO_XLEN} + 0x40000000);
    Store(fp32_load_base + 64, 4, Zeros{PTO_XLEN} + 0x40400000);
    Store(fp32_load_base + 68, 4, Zeros{PTO_XLEN} + 0x40800000);
    TLOAD(0, fp32_load_base, Zeros{PTO_XLEN} + 64);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0x40800000;

    let fp32_store_base = Zeros{PTO_XLEN} + 0x200;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x40c00000);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x40e00000);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 0x41000000);
    TSTORE(fp32_store_base, Zeros{PTO_XLEN} + 64, 0);
    let fp32_stored00 = LoadUnsigned(fp32_store_base, 4);
    let fp32_stored01 = LoadUnsigned(fp32_store_base + 4, 4);
    let fp32_stored10 = LoadUnsigned(fp32_store_base + 64, 4);
    let fp32_stored11 = LoadUnsigned(fp32_store_base + 68, 4);
    assert fp32_stored00 == Zeros{PTO_XLEN} + 0x40a00000;
    assert fp32_stored01 == Zeros{PTO_XLEN} + 0x40c00000;
    assert fp32_stored10 == Zeros{PTO_XLEN} + 0x40e00000;
    assert fp32_stored11 == Zeros{PTO_XLEN} + 0x41000000;

    ConfigureTile(1, 128, 2, 2, 2, 2, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Any);
    let fp16_load_base = Zeros{PTO_XLEN} + 0x300;
    Store(fp16_load_base, 2, Zeros{PTO_XLEN} + 0x3c00);
    Store(fp16_load_base + 2, 2, Zeros{PTO_XLEN} + 0x4000);
    Store(fp16_load_base + 32, 2, Zeros{PTO_XLEN} + 0x4200);
    Store(fp16_load_base + 34, 2, Zeros{PTO_XLEN} + 0x4400);
    TLOAD(1, fp16_load_base, Zeros{PTO_XLEN} + 32);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(1, 1, 0) == Zeros{PTO_XLEN} + 0x4200;
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 0x4400;
    return 0;
end;
