// PTO-TEST: {"id":"PTO-AVS-ARCH-ENCODING-OWNERSHIP-VECTOR-ROOT-001","source":"asl/arch/overview/encoding-ownership.asl","requirements":["PTO-ARCH-ENCODING-OWNERSHIP-001"],"kind":"boundary","summary":"The Linx-only 64-bit vector root is reserved by its first-word opcode.","pass_condition":"Every first word with low seven bits 0x7f is reserved and nearby PTO roots are not.","related_sources":["asl/arch/overview/instruction-classification.asl"]}
func main() => integer
begin
    assert LinxVectorRoot64Reserved(Zeros{32} + 0x0000007f);
    assert LinxVectorRoot64Reserved(Zeros{32} + 0xffffffff);
    assert !LinxVectorRoot64Reserved(Zeros{32} + 0x0000000f);
    assert !LinxVectorRoot64Reserved(Zeros{32} + 0x00000013);
    return 0;
end;
