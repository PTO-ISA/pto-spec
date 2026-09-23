// PTO-TEST: {"id":"PTO-AVS-TILE-MATRIX-VQUANT-DESC-001","source":"asl/tile/model/legality/matrix-postprocess.asl","requirements":["PTO-CUBE-AUX-CELLREG-001"],"kind":"boundary","summary":"vector quantization uses a 1 by N Local U64 descriptor with mode-owned bits only","pass_condition":"an FP19 scale plus S9 offset passes and one reserved low bit rejects","related_sources":["asl/block/attributes/B.FPATR.asl"]}

func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 256, 1, 9, TileDataType_U64,
        TileLayout_CUBE_N8);
    assert configured;
    ConfigureTile(1, 256, 1, 16, 1, 9, TileDataType_U64,
        TileLayout_RowMajor);
    let normal_parameter = MatrixQuantParameter(
        Zeros{19} + 0x400, Zeros{PTO_XLEN} + 1, 9);
    for column = 0 to 8 looplimit 9 do
        WriteTileElement(0, 0, column as integer {0..65535},
            normal_parameter);
    end;

    assert TileMatrixLocalVectorParameterSchemaLegal(0, 9);
    assert !TileMatrixLocalVectorParameterSchemaLegal(1, 9);
    assert TileMatrixVectorQuantContentsLegal(0, Zeros{6} + 2);
    WriteTileElement(0, 0, 0, normal_parameter + 1);
    assert !TileMatrixVectorQuantContentsLegal(0, Zeros{6} + 2);
    return 0;
end;
