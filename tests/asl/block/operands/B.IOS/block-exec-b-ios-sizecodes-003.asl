// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-SIZECODES-003","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"Decoded B.IOS destination paths cover every legal Shared SizeCode.","pass_condition":"Codes 1 through 12 reach Shared destination binding with the all-PE semantic mask.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/shared-bindings.asl"]}
pure func BIOSSizeCodeStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOSSizeCodeDestination(size_code: bits(4), pe_mode: bits(3),
                                  shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    for size = 1 to 12 do
        ResetProfileState();
        let started = ExecuteCommandInstruction(
            BIOSSizeCodeStart(Zeros{5} + 24), 32);
        let status = ExecuteCommandInstruction(
            BIOSSizeCodeDestination(
                (Zeros{4} + size) as bits(4), '111',
                (Zeros{6} + size) as bits(6)), 32);
        assert started == CommandExecution_Executed;
        assert status == CommandExecution_Executed;
        assert _BundleSharedBindings[[0]].valid;
        assert _BundleSharedBindings[[0]].size_code == size;
        assert _BundleSharedBindings[[0]].pe_mask == '1111';
    end;
    return 0;
end;
