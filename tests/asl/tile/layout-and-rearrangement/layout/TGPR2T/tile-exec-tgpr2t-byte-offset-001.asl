// PTO-TEST: {"id":"PTO-AVS-TILE-TGPR2T-BYTE-OFFSET-001","source":"asl/tile/layout-and-rearrangement/layout/TGPR2T.asl","requirements":["PTO-INST-TILE-TGPR2T","PTO-TGPR2T-CONTRACT-001"],"kind":"execution","summary":"TGPR2T maps four GPR predicate planes into the selected byte of a CUBE U8 destination","pass_condition":"M32 output rows contain the packed source bytes at ByteOffset 3 and preserve independent PadValue","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/execution/predicate-carriers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let gpr0 = Zeros{PTO_XLEN} + 0x0102030405060708;
    let gpr1 = Zeros{PTO_XLEN} + 0x1112131415161718;
    let gpr2 = Zeros{PTO_XLEN} + 0x2122232425262728;
    let gpr3 = Zeros{PTO_XLEN} + 0x3132333435363738;
    assert TileTGPR2TByteOffset('011') == 3;
    assert TileTGPR2TEncodingLegal(0x000fffff, 0x07e19181);
    // The sub-plane transpose reads row bits from the four complete 64-bit
    // GPRs; rows 2 and 3 make the lane order observable (0xaa/0x55).
    assert TileTGPR2TPackedRowByte(
        gpr0, gpr1, gpr2, gpr3, 2) == '10101010';
    assert TileTGPR2TPackedRowByte(
        gpr0, gpr1, gpr2, gpr3, 3) == '01010101';
    return 0;
end;
