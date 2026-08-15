// PTO-TEST: {"id":"PTO-AVS-TILE-TRSQRT-INFINITY-001","source":"asl/tile/elementwise-tile-tile/transcendental/TRSQRT.asl","requirements":["PTO-INST-TILE-TRSQRT"],"kind":"execution","summary":"TRSQRT maps positive infinity to positive zero","pass_condition":"FP32 positive infinity produces positive zero without numeric status flags","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x7f800000);
    InstructionContractExecute_TRSQRT(1, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
