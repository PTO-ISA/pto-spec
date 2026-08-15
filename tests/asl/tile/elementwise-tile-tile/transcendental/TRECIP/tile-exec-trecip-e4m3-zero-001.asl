// PTO-TEST: {"id":"PTO-AVS-TILE-TRECIP-E4M3ZERO-001","source":"asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl","requirements":["PTO-INST-TILE-TRECIP"],"kind":"execution","summary":"TRECIP maps E4M3 signed zero to canonical NaN","pass_condition":"both E4M3 zero signs produce canonical NaN and record only DZ","related_sources":["asl/tile/model/execution/unary.asl","asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    for sign = 0 to 1 looplimit 2 do
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
        WriteTileElement(
            0,
            0,
            0,
            if sign == 0 then
                Zeros{PTO_XLEN}
            else
                Zeros{PTO_XLEN} + 0x80);

        InstructionContractExecute_TRECIP(1, 0);

        assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x7f;
        assert NumericStatusFlags() == Zeros{5} + 2;
    end;
    return 0;
end;
