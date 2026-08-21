// PTO-TEST: {"id":"PTO-AVS-BLOCK-BINDER-IOT-SIZECODE-MATRIX-002","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded B.IOT destination paths cover every legal Local SizeCode.","pass_condition":"Each decoded B.IOT SizeCode 1..10 reaches the normal Local binding state with the all-PE semantic mask.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func BinderMatrixStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BinderMatrixLocalDestination(size_code: bits(4),
                                       pe_mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    // Every B.IOT destination SizeCode reaches the decoded Local binding state.
    for size = 1 to 10 do
        ResetProfileState();
        let started = ExecuteCommandInstruction(
            BinderMatrixStart(Zeros{5} + 27), 32);
        let status = ExecuteCommandInstruction(
            BinderMatrixLocalDestination(
                (Zeros{4} + size) as bits(4), '111'), 32);
        assert started == CommandExecution_Executed;
        assert status == CommandExecution_Executed;
        assert _BundleTileBindings[[0]].destination_valid;
        assert _BundleTileBindings[[0]].destination_size == size;
        assert _BundleTileBindings[[0]].pe_mask == '1111';
    end;
    return 0;
end;
