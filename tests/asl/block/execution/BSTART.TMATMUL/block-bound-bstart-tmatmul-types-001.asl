// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-TYPES-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-BSTART-TMATMUL-CONTRACT-001","PTO-TMATMUL-CONTRACT-001"],"kind":"boundary","summary":"TMATMUL closes its opcode-specific input and result type sets.","pass_condition":"Supported floating, signed, and unsigned pairs map to FP32, S32, and U32; unsupported and cross-class pairs reject.","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func main() => integer
begin
    assert TileOrdinaryMatrixInputTypesSameClass(
        TileDataType_FP16, TileDataType_E4M3);
    assert TileOrdinaryMatrixAccumulatorType(
        TileDataType_FP16, TileDataType_E4M3) == TileDataType_FP32;
    assert TileOrdinaryMatrixInputTypesSameClass(
        TileDataType_S16, TileDataType_S4X2);
    assert TileOrdinaryMatrixAccumulatorType(
        TileDataType_S16, TileDataType_S4X2) == TileDataType_S32;
    assert TileOrdinaryMatrixInputTypesSameClass(
        TileDataType_U16, TileDataType_U4X2);
    assert TileOrdinaryMatrixAccumulatorType(
        TileDataType_U16, TileDataType_U4X2) == TileDataType_U32;
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_FP64);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_E8M0);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_HiF4X2);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_S64);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_S32);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_U64);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_U32);
    assert !TileOrdinaryMatrixInputTypesSameClass(
        TileDataType_FP16, TileDataType_S16);
    return 0;
end;
