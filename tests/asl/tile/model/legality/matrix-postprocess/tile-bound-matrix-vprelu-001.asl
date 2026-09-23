// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-VPRELU-DESC-001","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":["PTO-CUBE-AUX-CELLREG-001"],"kind":"boundary","summary":"vector PReLU uses one finite nonnegative FP19 value per output column","pass_condition":"zero and positive one pass while a nonzero bit above the low nineteen-bit carrier rejects","related_sources":["asl/block/attributes/B.FPATR.asl"]}

func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 256, 1, 9, TileDataType_U64,
        TileLayout_CUBE_N8);
    assert configured;
    ConfigureTile(1, 256, 1, 16, 1, 9, TileDataType_U64,
        TileLayout_RowMajor);
    for column = 0 to 8 looplimit 9 do
        WriteTileElement(0, 0, column as integer {0..65535},
            Zeros{PTO_XLEN});
    end;

    assert TileMatrixLocalVectorParameterSchemaLegal(0, 9);
    assert !TileMatrixLocalVectorParameterSchemaLegal(1, 9);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x0001fc00);
    assert TileMatrixVectorReluContentsLegal(0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x00080000);
    assert !TileMatrixVectorReluContentsLegal(0);
    return 0;
end;
