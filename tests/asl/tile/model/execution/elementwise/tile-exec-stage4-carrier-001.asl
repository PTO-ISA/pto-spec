// PTO-TEST: {"id":"PTO-AVS-TILE-STAGE4-CARRIER-001","source":"asl/tile/model/execution/elementwise.asl","requirements":[],"kind":"execution","summary":"Stage 4 carrier bitwise and select operations preserve raw non-packed payloads","pass_condition":"BW32-NP legality, low-width scalar normalization, raw invalid patterns, and numeric rejection all hold","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCarrierOnlyDataTypeSupported(TileDataType_HiF8);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_E3M2);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_E2M3);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_TF32);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_HF32);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_FP16);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_BF16);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_FP32);
    assert TileCarrierOnlyDataTypeSupported(TileDataType_S32);
    assert !TileCarrierOnlyDataTypeSupported(TileDataType_FP64);
    assert !TileCarrierOnlyDataTypeSupported(TileDataType_U4X2);

    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    let invalid_left = Zeros{PTO_XLEN} + 0x3f800001;
    let invalid_right = Zeros{PTO_XLEN} + 0x00ff00f0;
    WriteTileElement(0, 0, 0, invalid_left);
    WriteTileElement(1, 0, 0, invalid_right);
    assert TileOperandsLegal_ExecuteTileBinary(
        TileBinary_AND, 2, 0, 1);
    ExecuteTileBinary(TileBinary_AND, 2, 0, 1);
    assert ReadTileElement(2, 0, 0) ==
        Zeros{PTO_XLEN} + 0x00800000;

    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_XOR, 3, 0, Zeros{PTO_XLEN} + 0xffffffff);
    ExecuteTileScalar(TileBinary_XOR, 3, 0,
        Zeros{PTO_XLEN} + 0xffffffff);
    assert ReadTileElement(3, 0, 0) ==
        Zeros{PTO_XLEN} + 0xc07ffffe;

    ConfigurePredicateTile(4, 128, 32, 1, 1, 1);
    ConfigureTile(5, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTilePredicateBit(4, 0, 0, TRUE);
    WriteTileElement(5, 0, 0, invalid_left);
    assert TileOperandsLegal_ExecuteTileSelectScalar(
        3, 4, 5, Zeros{PTO_XLEN} + 0x12345678);
    ExecuteTileSelectScalar(3, 4, 5, Zeros{PTO_XLEN} + 0x12345678);
    assert ReadTileElement(3, 0, 0) == invalid_left;

    for index = 6 to 7 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_TF32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(7, 0, 0, invalid_left);
    assert !InstructionContractOperandsLegal_TRELU(6, 7);
    assert !_Tiles[[6]].contents_defined;
    return 0;
end;
