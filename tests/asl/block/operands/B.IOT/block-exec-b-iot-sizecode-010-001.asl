// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-SIZECODE-010-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"A decoded B.IOT destination accepts SizeCode 10 and rejects every reserved destination SizeCode.","pass_condition":"The normal command path records a 64 KiB Local destination binding and rejects SizeCodes 11..15 before effects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/tile-bindings.asl","asl/tile/model/state/descriptors.asl"]}
pure func BundleTestB_IOTSizeCode(size_code: bits(4),
                                  pe_mode: bits(3),
                                  destination: bits(2)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[8:7] = destination;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    assert TileSizeCodeBytes(10) == 65536;
    assert LocalTileSizeCodeIsLegal(10);
    assert !LocalTileSizeCodeIsLegal(11);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    let boundary = BundleTestB_IOTSizeCode('1010', '001', '00');
    assert started == CommandExecution_Executed;
    assert DecodeCommandForm(boundary, 32) == 8;
    let boundary_status = ExecuteCommandInstruction(boundary, 32);
    assert boundary_status == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination_size == 10;
    assert _BundleTileBindings[[0]].pe_mask == '1000';
    assert BundleTileDestinationSizeBytes(0) == 65536;

    for reserved_code = 11 to 15 looplimit 5 do
        let reserved = BundleTestB_IOTSizeCode(
            (Zeros{4} + reserved_code) as bits(4), '001', '00');
        let reserved_status = ExecuteCommandInstruction(reserved, 32);
        assert DecodeCommandForm(reserved, 32) == 8;
        assert reserved_status == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert BundleTileBindingCount() == 1;
        ClearFault();
    end;
    return 0;
end;
