// PTO-TEST: {"id":"PTO-AVS-BLOCK-BINDER-IOS-PEMODE-MATRIX-005","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"Decoded B.IOS source paths exercise all eight PEMode encodings.","pass_condition":"Every decoded B.IOS source PEMode produces the fixed mask table, with encoded zero as the strict no-effect path and SizeCode zero retained.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/shared-bindings.asl"]}
pure func BinderMatrixStart() => bits(64)
begin
    return Zeros{64} + 0x00011181;
end;

pure func BinderMatrixShared(pe_mode: bits(3), shared_id: bits(8)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    for mode = 0 to 7 do
        let encoded_mode = (Zeros{3} + mode) as bits(3);
        ResetProfileState();
        let started = ExecuteCommandInstruction(BinderMatrixStart(), 32);
        let status = ExecuteCommandInstruction(
            BinderMatrixShared(encoded_mode,
                (Zeros{8} + mode) as bits(8)), 32);
        assert started == CommandExecution_Executed;
        assert status == CommandExecution_Executed;
        if mode == 0 then
            assert BundleSharedBindingCount() == 0;
        else
            assert BundleSharedBindingCount() == 1;
            assert _BundleSharedBindings[[0]].pe_mask ==
                PTOv0PEMaskOfPEMode(encoded_mode);
            assert _BundleSharedBindings[[0]].size_code == 0;
        end;
    end;
    return 0;
end;
