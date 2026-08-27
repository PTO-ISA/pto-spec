// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-FORMS-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"decode-negative","summary":"former independent Shared TMOV movement encodings are reserved","pass_condition":"only the canonical BSTART.TMOV carrier decodes as form 47; former function encodings do not","related_sources":["asl/block/model/dispatch/shared-tlsu.asl"]}
func main() => integer
begin
    assert DecodeCommandForm(Zeros{64} + 0x00211181, 32) == 47;
    assert DecodeCommandForm(Zeros{64} + 0x00911181, 32) != 47;
    assert DecodeCommandForm(Zeros{64} + 0x00a11181, 32) != 47;
    assert DecodeCommandForm(Zeros{64} + 0x00b11181, 32) != 47;
    assert DecodeCommandForm(Zeros{64} + 0x00c11181, 32) != 47;
    assert InstructionContractMatches_BSTART_TMOV(
        CommandOperationOfForm(47));
    return 0;
end;
