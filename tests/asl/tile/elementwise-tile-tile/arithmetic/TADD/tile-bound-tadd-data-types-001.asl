// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-DATA-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD"],"kind":"boundary","summary":"TADD accepts its sixteen numeric element types and rejects non-profile carriers","pass_condition":"the accepted FP and integer set passes while HiF8 is rejected before effects","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/legality/dtype-layout.asl"]}
func ConfigureBinaryType(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1, data_type,
            TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
end;

func main() => integer
begin
    assert TileVecArithmeticDataTypeSupported(TileDataType_FP64);
    assert TileVecArithmeticDataTypeSupported(TileDataType_FP32);
    assert TileVecArithmeticDataTypeSupported(TileDataType_TF32);
    assert TileVecArithmeticDataTypeSupported(TileDataType_HF32);
    assert TileVecArithmeticDataTypeSupported(TileDataType_FP16);
    assert TileVecArithmeticDataTypeSupported(TileDataType_BF16);
    assert TileVecArithmeticDataTypeSupported(TileDataType_E4M3);
    assert TileVecArithmeticDataTypeSupported(TileDataType_E5M2);
    assert TileVecArithmeticDataTypeSupported(TileDataType_S64);
    assert TileVecArithmeticDataTypeSupported(TileDataType_S32);
    assert TileVecArithmeticDataTypeSupported(TileDataType_S16);
    assert TileVecArithmeticDataTypeSupported(TileDataType_S8);
    assert TileVecArithmeticDataTypeSupported(TileDataType_U64);
    assert TileVecArithmeticDataTypeSupported(TileDataType_U32);
    assert TileVecArithmeticDataTypeSupported(TileDataType_U16);
    assert TileVecArithmeticDataTypeSupported(TileDataType_U8);
    assert !TileVecArithmeticDataTypeSupported(TileDataType_HiF8);
    assert !TileVecArithmeticDataTypeSupported(TileDataType_U4X2);

    ResetProfileState();
    ConfigureBinaryType(TileDataType_FP32);
    assert TileOperandsLegal_ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);

    ResetProfileState();
    ConfigureBinaryType(TileDataType_U8);
    assert TileOperandsLegal_ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);

    ResetProfileState();
    ConfigureBinaryType(TileDataType_HiF8);
    assert !TileOperandsLegal_ExecuteTileBinary(TileBinary_ADD, 2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
