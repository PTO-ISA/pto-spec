// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-RESERVED-SIZECODES-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"fault","summary":"Reserved Local B.IOT destination SizeCodes 13..15 remain illegal and distinct from the Local 11/12 boundary.","pass_condition":"Each reserved SizeCode faults before binding or Local allocation effects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func ReservedBIOTSizeCode(size_code: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '001';
    instruction[8:7] = '00';
    return instruction;
end;

func main() => integer
begin
    for reserved_code = 13 to 15 looplimit 3 do
        ResetProfileState();
        let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
        assert started == CommandExecution_Executed;
        let before_tpc = ReadTPC();
        let rejected = ExecuteCommandInstruction(
            ReservedBIOTSizeCode(reserved_code), 32);
        assert rejected == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert ReadTPC() == before_tpc;
        assert BundleTileBindingCount() == 0;
        assert !_BundleTileBindings[[0]].valid;
        assert TileCapacityInUse() == 0;
    end;
    return 0;
end;
