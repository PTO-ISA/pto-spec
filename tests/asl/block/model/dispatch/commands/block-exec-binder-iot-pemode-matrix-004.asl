// PTO-TEST: {"id":"PTO-AVS-BLOCK-BINDER-IOT-PEMODE-MATRIX-004","source":"asl/block/model/dispatch/commands.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Decoded B.IOT source paths exercise all eight PEMode encodings.","pass_condition":"Every decoded B.IOT source PEMode produces the fixed mask table, with encoded zero as the strict no-effect path.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/tile-bindings.asl"]}
pure func BinderMatrixStart() => bits(64)
begin
    return Zeros{64} + 0x00011181;
end;

pure func BinderMatrixLocalSource(pe_mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    for mode = 0 to 7 do
        let encoded_mode = (Zeros{3} + mode) as bits(3);
        ResetProfileState();
        let started = ExecuteCommandInstruction(BinderMatrixStart(), 32);
        let status = ExecuteCommandInstruction(
            BinderMatrixLocalSource(encoded_mode), 32);
        assert started == CommandExecution_Executed;
        assert status == CommandExecution_Executed;
        if mode == 0 then
            assert BundleTileBindingCount() == 0;
        else
            assert BundleTileBindingCount() == 1;
            assert _BundleTileBindings[[0]].pe_mask ==
                PTOv0PEMaskOfPEMode(encoded_mode);
        end;
    end;
    return 0;
end;
