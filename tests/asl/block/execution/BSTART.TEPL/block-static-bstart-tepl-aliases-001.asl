// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TEPL-ALIASES-001","source":"asl/block/execution/BSTART.TEPL.asl","requirements":["PTO-INST-BLOCK-BSTART-TEPL","PTO-INST-BLOCK-BSTART-VEC","PTO-INST-BLOCK-BSTART-SFU"],"kind":"static-invariant","summary":"The unchanged TEPL carrier accepts both canonical engine aliases without changing raw encoding ownership.","pass_condition":"TEPL accepts representative VEC and SFU operations, while each canonical alias accepts only its assigned engine.","related_sources":["asl/arch/overview/instruction-classification.asl"]}
func main() => integer
begin
    // TADD is operation index 0 and is assigned to VEC.
    assert InstructionContractAcceptsTileOperation_BSTART_TEPL(0);
    assert InstructionContractAcceptsTileOperation_BSTART_VEC(0);
    assert !InstructionContractAcceptsTileOperation_BSTART_SFU(0);

    // TEXP is operation index 16 and is assigned to SFU.
    assert InstructionContractAcceptsTileOperation_BSTART_TEPL(16);
    assert !InstructionContractAcceptsTileOperation_BSTART_VEC(16);
    assert InstructionContractAcceptsTileOperation_BSTART_SFU(16);
    return 0;
end;
