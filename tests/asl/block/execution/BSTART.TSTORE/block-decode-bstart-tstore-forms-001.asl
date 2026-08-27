// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-FORMS-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"decode-negative","summary":"the former independent Shared partial-store carrier is reserved","pass_condition":"Function 1 remains the only accepted BSTART.TSTORE carrier","related_sources":["asl/arch/memory-model/global-memory-access.asl"]}
func main() => integer
begin
    assert DecodeCommandForm(Zeros{64} + 0x00111181, 32) == 50;
    assert DecodeCommandForm(Zeros{64} + 0x00e11181, 32) != 50;
    assert InstructionContractMatches_BSTART_TSTORE(
        CommandOperationOfForm(50));
    assert InstructionContractSharedMaskLegal_TSTORE(1, '0001');
    assert InstructionContractSharedMaskLegal_TSTORE(1, '1111');
    assert InstructionContractSharedMaskLegal_TSTORE(1, Zeros{4});
    return 0;
end;
