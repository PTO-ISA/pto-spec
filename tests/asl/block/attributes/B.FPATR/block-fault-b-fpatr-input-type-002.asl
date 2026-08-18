// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-INPUT-TYPE-002","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"B.FPATR PreQuant modes accept only their assigned accumulator class","pass_condition":"S32, FP32, and U32 accumulator modes are separated before matrix effects","related_sources":["asl/tile/model/legality/matrix-postprocess.asl"]}
func main() => integer
begin
    assert BundleFPATRAccumulatorTypeLegal('000000', TileDataType_FP32);
    assert BundleFPATRAccumulatorTypeLegal('000000', TileDataType_S32);
    assert BundleFPATRAccumulatorTypeLegal('000000', TileDataType_U32);
    assert BundleFPATRAccumulatorTypeLegal('000011', TileDataType_S32);
    assert !BundleFPATRAccumulatorTypeLegal('000011', TileDataType_FP32);
    assert BundleFPATRAccumulatorTypeLegal('011000', TileDataType_FP32);
    assert !BundleFPATRAccumulatorTypeLegal('011000', TileDataType_S32);
    assert !BundleFPATRAccumulatorTypeLegal('011000', TileDataType_U32);
    assert !BundleFPATRAccumulatorTypeLegal('100111', TileDataType_U32);
    for raw = 0 to 63 do
        let code = Zeros{6} + raw;
        if BundleFPATRPreQuantModeLegal(code) then
            if raw == 0 then
                assert BundleFPATRAccumulatorTypeLegal(
                    code, TileDataType_FP32);
                assert BundleFPATRAccumulatorTypeLegal(
                    code, TileDataType_S32);
                assert BundleFPATRAccumulatorTypeLegal(
                    code, TileDataType_U32);
            else
                let expected_s32 = raw == 2 || raw == 3 ||
                    raw == 4 || raw == 5 || raw == 12 || raw == 13 ||
                    raw == 17 || raw == 18 || raw == 19 || raw == 20 ||
                    raw == 35 || raw == 39;
                assert BundleFPATRAccumulatorTypeLegal(
                    code,
                    if expected_s32 then TileDataType_S32
                    else TileDataType_FP32);
                assert !BundleFPATRAccumulatorTypeLegal(
                    code,
                    if expected_s32 then TileDataType_FP32
                    else TileDataType_S32);
                assert !BundleFPATRAccumulatorTypeLegal(
                    code, TileDataType_U32);
            end;
        end;
    end;
    return 0;
end;
