// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-SIZECODES-002","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded B.IOT destination paths cover every legal Local SizeCode.","pass_condition":"Codes 1 through 10 reach Local destination binding with the all-PE semantic mask.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func BIOTSizeCodeStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOTSizeCodeDestination(size_code: bits(4), pe_mode: bits(3))
        => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    for size = 1 to 10 do
        ResetProfileState();
        let started = ExecuteCommandInstruction(
            BIOTSizeCodeStart(Zeros{5} + 27), 32);
        let status = ExecuteCommandInstruction(
            BIOTSizeCodeDestination(
                (Zeros{4} + size) as bits(4), '111'), 32);
        assert started == CommandExecution_Executed;
        assert status == CommandExecution_Executed;
        assert _BundleTileBindings[[0]].destination_valid;
        assert _BundleTileBindings[[0]].destination_size == size;
        assert _BundleTileBindings[[0]].pe_mask == '1111';
    end;
    return 0;
end;
