// PTO-TEST: {"id":"PTO-AVS-TILE-TDIVS-ZERO-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TDIVS.asl","requirements":["PTO-INST-TILE-TDIVS"],"kind":"boundary","summary":"TDIVS rejects integer zero divisors but admits floating signed zero","pass_condition":"U32 zero rejects while FP32 positive and negative zero pass operand legality","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTDIVSOperands(data_type: TileDataType)
begin
    ConfigureTile(
        0,
        128,
        8,
        2,
        1,
        2,
        data_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        data_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTDIVSOperands(TileDataType_U32);
    assert !TileOperandsLegal_ExecuteTileScalar(
        TileBinary_DIV,
        1,
        0,
        Zeros{PTO_XLEN});

    ResetProfileState();
    ConfigureTDIVSOperands(TileDataType_FP32);
    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_DIV,
        1,
        0,
        Zeros{PTO_XLEN});
    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_DIV,
        1,
        0,
        Zeros{PTO_XLEN} + 0x80000000);
    return 0;
end;
