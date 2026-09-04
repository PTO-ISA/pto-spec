// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-COOPERATIVE-001","source":"asl/block/model/dispatch/timg2col-schema.asl","requirements":["PTO-BSTART-TIMG2COL-COOPERATIVE-001"],"kind":"state-transition","summary":"Core-level TIMG2COL distribution uses 16/32-row quarters and preserves zero-row participation.","pass_condition":"Valid rows 65 distribute as 32,32,1,0 with contiguous row starts and valid rows 64 distribute as four 16-row participants.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl"]}
func main() => integer
begin
    assert BundleTIMG2COLMPerPE(64) == 16;
    assert BundleTIMG2COLValidRowForPE(64, 0) == 16;
    assert BundleTIMG2COLValidRowForPE(64, 3) == 16;
    assert BundleTIMG2COLMPerPE(65) == 32;
    assert BundleTIMG2COLValidRowForPE(65, 0) == 32;
    assert BundleTIMG2COLValidRowForPE(65, 1) == 32;
    assert BundleTIMG2COLValidRowForPE(65, 2) == 1;
    assert BundleTIMG2COLValidRowForPE(65, 3) == 0;
    assert BundleTIMG2COLRowStartForPE(65, 7, 0) == 7;
    assert BundleTIMG2COLRowStartForPE(65, 7, 1) == 39;
    assert BundleTIMG2COLRowStartForPE(65, 7, 2) == 71;
    assert BundleTIMG2COLRowStartForPE(65, 7, 3) == 72;
    assert BundleTIMG2COLValidRowForOutput(
        BundleTIMG2COLOutput_LocalM16, 64, 3) == 16;
    assert BundleTIMG2COLValidRowForOutput(
        BundleTIMG2COLOutput_LocalM32, 65, 2) == 1;
    assert BundleTIMG2COLRowStartForOutput(
        BundleTIMG2COLOutput_LocalM32, 65, 7, 2) == 71;
    assert BundleTIMG2COLDimensionRolesComplete(TRUE, TRUE, TRUE);
    assert !BundleTIMG2COLDimensionRolesComplete(TRUE, FALSE, TRUE);
    let (pe0_offset, pe0_bytes) = BundleTIMG2COLWriterRange(65, 7, 0, 64);
    let (pe2_offset, pe2_bytes) = BundleTIMG2COLWriterRange(65, 7, 2, 64);
    let (pe3_offset, pe3_bytes) = BundleTIMG2COLWriterRange(65, 7, 3, 64);
    assert pe0_offset == 448 && pe0_bytes == 2048;
    assert pe2_offset == 4544 && pe2_bytes == 64;
    assert pe3_offset == 4608 && pe3_bytes == 0;
    assert InstructionContractTIMG2COLCoreMaskLegal('1111');
    assert !InstructionContractTIMG2COLCoreMaskLegal('0111');
    return 0;
end;
