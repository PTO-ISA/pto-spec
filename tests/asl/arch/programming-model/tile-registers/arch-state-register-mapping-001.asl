// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTTILEREGISTERMAPPING-STATE-TRANSITION-001","source":"asl/arch/programming-model/tile-registers.asl","requirements":[],"kind":"state-transition","summary":"Covers Tile Register Mapping.","pass_condition":"TestTileRegisterMapping completes without assertion failure","related_sources":[]}
func TestTileRegisterMapping()
begin
    assert TileHandOf(0) == TileHand_T;
    assert TileHandOf(15) == TileHand_T;
    assert TileHandOf(16) == TileHand_U;
    assert TileHandOf(32) == TileHand_M;
    assert TileHandOf(63) == TileHand_N;
    assert TileIndexWithinHand(0) == 1;
    assert TileIndexWithinHand(63) == 16;

    assert !TileCapacityIsLegal(0);
    assert TileCapacityIsLegal(128);
    assert TileCapacityIsLegal(256);
    assert TileCapacityIsLegal(262144);
    assert SharedTileCapacityIsLegal(262144);
    assert TileCapacityIsLegal(8192);
    assert !TileCapacityIsLegal(192);
    assert !TileCapacityIsLegal(32);
    assert TileSizeCodeBytes(1) == 128;
    assert TileSizeCodeBytes(7) == 8192;
    assert TileSizeCodeBytes(10) == 65536;
    assert TileSizeCodeBytes(12) == 262144;
    assert !TileSizeCodeIsLegal(0);
    assert TileSizeCodeIsLegal(12);
    assert !TileSizeCodeIsLegal(13);
    assert LocalTileSizeCodeIsLegal(10);
    assert LocalTileSizeCodeIsLegal(12);
    assert !LocalTileSizeCodeIsLegal(13);

    assert TileElementBits(TileDataType_FP64) == 64;
    assert TileElementBits(TileDataType_FP32) == 32;
    assert TileElementBits(TileDataType_TF32) == 32;
    assert TileElementBits(TileDataType_HF32) == 32;
    assert TileElementBits(TileDataType_FP16) == 16;
    assert TileElementBits(TileDataType_BF16) == 16;
    assert TileElementBits(TileDataType_HiF8) == 8;
    assert TileElementBits(TileDataType_E4M3) == 8;
    assert TileElementBits(TileDataType_E5M2) == 8;
    assert TileElementBits(TileDataType_E3M2) == 8;
    assert TileElementBits(TileDataType_E2M3) == 8;
    assert TileElementBits(TileDataType_E2M1X2) == 4;
    assert TileElementBits(TileDataType_E1M2X2) == 4;
    assert TileElementBits(TileDataType_E8M0) == 8;
    assert TileElementBits(TileDataType_HiF4X2) == 4;
    assert TileElementBits(TileDataType_S8) == 8;
    assert TileElementBits(TileDataType_U8) == 8;
    assert TileElementBits(TileDataType_S16) == 16;
    assert TileElementBits(TileDataType_U16) == 16;
    assert TileElementBits(TileDataType_S32) == 32;
    assert TileElementBits(TileDataType_U32) == 32;
    assert TileElementBits(TileDataType_S64) == 64;
    assert TileElementBits(TileDataType_U64) == 64;
    assert TileElementBits(TileDataType_S4X2) == 4;
    assert TileElementBits(TileDataType_U4X2) == 4;

    for code = 0 to 31 looplimit 32 do
        let encoded = (Zeros{5} + code) as TileDataTypeEncoding;
        let expected = (0 <= code && code <= 14) ||
                       (16 <= code && code <= 20) ||
                       (24 <= code && code <= 28);
        assert TileDataTypeEncodingValid(encoded) == expected;
    end;
    assert TileDataTypeFromEncoding(Zeros{5}) == TileDataType_FP64;
    assert TileDataTypeFromEncoding(Zeros{5} + 1) == TileDataType_FP32;
    assert TileDataTypeFromEncoding(Zeros{5} + 2) == TileDataType_TF32;
    assert TileDataTypeFromEncoding(Zeros{5} + 3) == TileDataType_HF32;
    assert TileDataTypeFromEncoding(Zeros{5} + 4) == TileDataType_FP16;
    assert TileDataTypeFromEncoding(Zeros{5} + 5) == TileDataType_BF16;
    assert TileDataTypeFromEncoding(Zeros{5} + 6) == TileDataType_HiF8;
    assert TileDataTypeFromEncoding(Zeros{5} + 7) == TileDataType_E4M3;
    assert TileDataTypeFromEncoding(Zeros{5} + 8) == TileDataType_E5M2;
    assert TileDataTypeFromEncoding(Zeros{5} + 9) == TileDataType_E3M2;
    assert TileDataTypeFromEncoding(Zeros{5} + 10) == TileDataType_E2M3;
    assert TileDataTypeFromEncoding(Zeros{5} + 11) ==
        TileDataType_E2M1X2;
    assert TileDataTypeFromEncoding(Zeros{5} + 12) ==
        TileDataType_E1M2X2;
    assert TileDataTypeFromEncoding(Zeros{5} + 13) == TileDataType_E8M0;
    assert TileDataTypeFromEncoding(Zeros{5} + 14) ==
        TileDataType_HiF4X2;
    assert TileDataTypeFromEncoding(Zeros{5} + 16) == TileDataType_S64;
    assert TileDataTypeFromEncoding(Zeros{5} + 17) == TileDataType_S32;
    assert TileDataTypeFromEncoding(Zeros{5} + 18) == TileDataType_S16;
    assert TileDataTypeFromEncoding(Zeros{5} + 19) == TileDataType_S8;
    assert TileDataTypeFromEncoding(Zeros{5} + 20) == TileDataType_S4X2;
    assert TileDataTypeFromEncoding(Zeros{5} + 24) == TileDataType_U64;
    assert TileDataTypeFromEncoding(Zeros{5} + 25) == TileDataType_U32;
    assert TileDataTypeFromEncoding(Zeros{5} + 26) == TileDataType_U16;
    assert TileDataTypeFromEncoding(Zeros{5} + 27) == TileDataType_U8;
    assert TileDataTypeFromEncoding(Zeros{5} + 28) == TileDataType_U4X2;
    assert !TileDataTypeEncodingValid(Zeros{5} + 15);
    assert TileStorageBytes(1, 1, TileDataType_U4X2) == 1;
    assert TileStorageBytes(1, 2, TileDataType_U4X2) == 1;
    assert TileStorageBytes(1, 3, TileDataType_U4X2) == 2;
    assert TileStorageBytes(2, 2, TileDataType_U64) == 32;
    assert TileStorageFitsCapacity(32, 8, TileDataType_U8, 256);
    assert !TileStorageFitsCapacity(33, 1, TileDataType_U64, 256);
end;
func main() => integer
begin
    ResetProfileState();
    TestTileRegisterMapping();
    return 0;
end;
