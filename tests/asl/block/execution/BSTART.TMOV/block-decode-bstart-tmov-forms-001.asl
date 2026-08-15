// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-FORMS-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"decode-positive","summary":"all five TMOV carriers retain one formal mnemonic contract","pass_condition":"Local copy, INSERT, PUBLISH, BROADCAST, and EXTRACT decode to BSTART.TMOV","related_sources":["asl/block/model/dispatch/shared-tlsu.asl"]}
func main() => integer
begin
    assert DecodeCommandForm(Zeros{64} + 0x00211181, 32) == 47;
    assert DecodeCommandForm(Zeros{64} + 0x00911181, 32) == 47;
    assert DecodeCommandForm(Zeros{64} + 0x00a11181, 32) == 47;
    assert DecodeCommandForm(Zeros{64} + 0x00b11181, 32) == 47;
    assert DecodeCommandForm(Zeros{64} + 0x00c11181, 32) == 47;
    assert InstructionContractMatches_BSTART_TMOV(
        CommandOperationOfForm(47));
    return 0;
end;
