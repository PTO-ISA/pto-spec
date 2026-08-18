// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-DTYPE-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-TILE-TLOAD"],"kind":"boundary","summary":"BSTART.TLOAD accepts Stage 4 BW32-NP and packed-X2 data codes but excludes B64.","pass_condition":"B8, B16, B32, and packed-X2 field values execute while B64 and reserved values reject before effects.","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
pure func TLoadDataTypeWord(code: integer {0..31}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + code;
    return instruction;
end;

pure func TLoadDataTypeReserved(code: integer {0..31}) => boolean
begin
    return code == 0 || code == 15 || code == 16 ||
        (21 <= code && code <= 24) || code >= 29;
end;

func main() => integer
begin
    for code = 0 to 31 looplimit 32 do
        ResetProfileState();
        let status = ExecuteCommandInstruction(TLoadDataTypeWord(code), 32);
        assert InstructionContractDataTypeLegal_TLOAD(Zeros{5} + code) ==
            !TLoadDataTypeReserved(code);
        if TLoadDataTypeReserved(code) then
            assert status == CommandExecution_Rejected;
            assert !_BundleActive;
        else
            assert status == CommandExecution_Executed;
            assert _BundleActive;
        end;
    end;
    return 0;
end;
