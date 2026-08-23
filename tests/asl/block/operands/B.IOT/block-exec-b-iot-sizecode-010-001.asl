// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-SIZECODE-010-001","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"A decoded B.IOT destination retains the assigned SizeCode 10 mapping.","pass_condition":"The normal command path records a 64 KiB Local destination binding while the extended SizeCodes remain independently covered.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/tile-bindings.asl","asl/tile/model/state/descriptors.asl"]}
pure func BundleTestB_IOTSizeCode10(size_code: bits(4),
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
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    let boundary = BundleTestB_IOTSizeCode10('1010', '001', '00');
    assert started == CommandExecution_Executed;
    assert DecodeCommandForm(boundary, 32) == 8;
    let boundary_status = ExecuteCommandInstruction(boundary, 32);
    assert boundary_status == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination_size == 10;
    assert _BundleTileBindings[[0]].pe_mask == '1000';
    assert BundleTileDestinationSizeBytes(0) == 65536;
    return 0;
end;
