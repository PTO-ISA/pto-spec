// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-PEMODE-005","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"Decoded B.IOS source paths exercise all eight PEMode encodings.","pass_condition":"Every mode produces its fixed four-bit semantic mask, while encoded mode zero has no binding effect and retains source-only SizeCode zero.","related_sources":["asl/block/model/schema/profile-encoding.asl","asl/block/model/operands/shared-bindings.asl"]}
pure func BIOSPEModeStart() => bits(64)
begin
    return Zeros{64} + 0x00011181;
end;

pure func BIOSPEModeSource(pe_mode: bits(3), shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    for mode = 0 to 7 do
        let encoded_mode = (Zeros{3} + mode) as bits(3);
        ResetProfileState();
        let started = ExecuteCommandInstruction(BIOSPEModeStart(), 32);
        let status = ExecuteCommandInstruction(
            BIOSPEModeSource(encoded_mode,
                (Zeros{6} + mode) as bits(6)), 32);
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
