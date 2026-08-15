// PTO-TEST: {"id":"PTO-AVS-TILE-TLOG-E4M3ZERO-001","source":"asl/tile/elementwise-tile-tile/transcendental/TLOG.asl","requirements":["PTO-INST-TILE-TLOG"],"kind":"execution","summary":"TLOG maps E4M3 zero to canonical NaN","pass_condition":"E4M3 zero produces canonical NaN and records only DZ","related_sources":["asl/tile/model/execution/unary.asl","asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(
            index as TileIndex,
            128,
            1,
            1,
            1,
            1,
            TileDataType_E4M3,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});

    InstructionContractExecute_TLOG(1, 0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x7f;
    assert NumericStatusFlags() == Zeros{5} + 2;
    return 0;
end;
