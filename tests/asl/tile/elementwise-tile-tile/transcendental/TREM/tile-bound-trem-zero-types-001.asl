// PTO-TEST: {"id":"PTO-AVS-TILE-TREM-ZERO-TYPES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TREM.asl","requirements":["PTO-INST-TILE-TREM"],"kind":"boundary","summary":"TREM rejects integer zero divisors but admits floating zero to the numeric profile","pass_condition":"S64 is assigned but its zero divisor fails operand legality while FP32 zero remains a legal profile input","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTREMZero(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1, data_type,
            TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
end;

func main() => integer
begin
    assert InstructionContractDataTypeLegal_TREM(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TREM(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TREM(TileDataType_HiF8);

    ResetProfileState();
    ConfigureTREMZero(TileDataType_S64);
    assert !InstructionContractOperandsLegal_TREM(2, 0, 1);

    ResetProfileState();
    ConfigureTREMZero(TileDataType_FP32);
    assert InstructionContractOperandsLegal_TREM(2, 0, 1);
    return 0;
end;
