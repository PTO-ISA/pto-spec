// PTO-TEST: {"id":"PTO-AVS-TILE-TLOG-ZERO-001","source":"asl/tile/elementwise-tile-tile/transcendental/TLOG.asl","requirements":["PTO-INST-TILE-TLOG"],"kind":"execution","summary":"TLOG reports divide-by-zero for a floating zero","pass_condition":"FP32 positive zero produces negative infinity and records only DZ","related_sources":["asl/tile/model/execution/unary.asl","asl/arch/state/numeric-status.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    InstructionContractExecute_TLOG(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0xff800000;
    assert NumericStatusFlags() == Zeros{5} + 2;
    return 0;
end;
