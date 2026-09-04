// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-STATIC-001","source":"asl/block/execution/BSTART.TIMG2COL.asl","requirements":["PTO-BSTART-TIMG2COL-CONTRACT-001"],"kind":"static-invariant","summary":"The frozen BSTART.TIMG2COL owner exposes the Function-28 carrier contract and six layout modes.","pass_condition":"The handler, layout applicability, DATR applicability, and core mask witnesses agree with the accepted owner.","related_sources":["asl/block/attributes/B.DATR.asl","asl/block/attributes/B.DIM.asl"]}
func main() => integer
begin
    assert InstructionContractHandler_BSTART_TIMG2COL() ==
        CommandHandler_ExecuteBundleStart;
    assert InstructionContractTIMG2COLLayoutLegal(Zeros{5} + 0);
    assert InstructionContractTIMG2COLLayoutLegal(Zeros{5} + 6);
    assert InstructionContractTIMG2COLLayoutLegal(Zeros{5} + 21);
    assert InstructionContractTIMG2COLLayoutLegal(Zeros{5} + 22);
    assert InstructionContractTIMG2COLLayoutLegal(Zeros{5} + 29);
    assert InstructionContractTIMG2COLLayoutLegal(Zeros{5} + 31);
    assert InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_NORM);
    assert InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_DN2ND);
    assert InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_ND2M16);
    assert InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_ND2M32);
    assert InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_CUBE_M16);
    assert InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_CUBE_M32);
    assert !InstructionContractTIMG2COLLayoutModeLegal(TileDataLayout_ND2DN);
    assert InstructionContractB_DATR_TIMG2COLFieldsLegal(
        TileDataLayout_ND2M32, DTYPE_NONE, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    assert !InstructionContractB_DATR_TIMG2COLFieldsLegal(
        TileDataLayout_ND2DN, DTYPE_NONE, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    assert !InstructionContractB_DATR_TIMG2COLFieldsLegal(
        TileDataLayout_ND2M32, Zeros{5} + 27, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert BundleTIMG2COLOutputMatchesLayout(
        TileDataLayout_ND2M16, BundleTIMG2COLOutput_LocalM16);
    assert BundleTIMG2COLOutputMatchesLayout(
        TileDataLayout_CUBE_M32, BundleTIMG2COLOutput_LocalM32);
    return 0;
end;
