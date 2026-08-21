// PTO-TEST: {"id":"PTO-AVS-BLOCK-BINDER-IOS-SIZECODE-MATRIX-003","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"Decoded B.IOS destination paths cover every legal Shared SizeCode.","pass_condition":"Each decoded B.IOS SizeCode 1..12 reaches the normal Shared binding state with the all-PE semantic mask.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/shared-bindings.asl"]}
pure func BinderMatrixStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BinderMatrixShared(size_code: bits(4), pe_mode: bits(3),
                             shared_id: bits(8)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    for size = 1 to 12 do
        ResetProfileState();
        let started = ExecuteCommandInstruction(
            BinderMatrixStart(Zeros{5} + 24), 32);
        let status = ExecuteCommandInstruction(
            BinderMatrixShared(
                (Zeros{4} + size) as bits(4), '111',
                (Zeros{8} + size) as bits(8)), 32);
        assert started == CommandExecution_Executed;
        assert status == CommandExecution_Executed;
        assert _BundleSharedBindings[[0]].valid;
        assert _BundleSharedBindings[[0]].size_code == size;
        assert _BundleSharedBindings[[0]].pe_mask == '1111';
    end;
    return 0;
end;
