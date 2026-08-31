// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-REINTERPRET-ENCODING-002","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-TADD-CONTRACT-001"],"kind":"fault","summary":"Numeric reinterpretation validates source encodings under the selected operation type","pass_condition":"TF32 TADD rejects U32-backed source bits that violate TF32 encoding even though the carrier widths and shapes match","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 8, 4, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        1, 128, 8, 4, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 8, 4, 1, 1, TileDataType_TF32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);

    assert !TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD, 2, 0, 1);
    return 0;
end;
