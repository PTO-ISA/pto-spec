// PTO-TEST: {"id":"PTO-AVS-TILE-TSQRT-NEGATIVE-001","source":"asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl","requirements":["PTO-INST-TILE-TSQRT"],"kind":"execution","summary":"TSQRT rejects a negative numeric operand through floating status","pass_condition":"FP32 negative one produces canonical quiet NaN and records invalid","related_sources":["asl/tile/model/execution/unary.asl","asl/arch/state/numeric-status.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xbf800000);
    InstructionContractExecute_TSQRT(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7fc00000;
    assert NumericStatusFlags() == Zeros{5} + 1;
    return 0;
end;
