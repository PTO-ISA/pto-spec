// PTO-TEST: {"id":"PTO-AVS-TILE-TRECIP-ZERO-001","source":"asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl","requirements":["PTO-INST-TILE-TRECIP"],"kind":"boundary","summary":"TRECIP admits floating zero and rejects integer carriers","pass_condition":"an FP32 zero source passes complete operand legality while the same U64 descriptor rejects","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func ConfigureReciprocalTiles(data_type: TileDataType)
begin
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(
            index as TileIndex,
            128,
            1,
            1,
            1,
            1,
            data_type,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(
        0,
        0,
        0,
        Zeros{PTO_XLEN});
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureReciprocalTiles(TileDataType_FP32);
    assert InstructionContractOperandsLegal_TRECIP(
        1,
        0);

    ResetProfileState();
    ConfigureReciprocalTiles(TileDataType_U64);
    assert !InstructionContractOperandsLegal_TRECIP(
        1,
        0);
    return 0;
end;
