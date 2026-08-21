// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-SIZECODE-012-001","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"A decoded B.IOS destination accepts SizeCode 12 and rejects every reserved destination SizeCode.","pass_condition":"The normal command path records a 256 KiB Shared destination and rejects SizeCodes 13..15 before effects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/shared-bindings.asl","asl/tile/model/state/shared-registers.asl"]}
pure func BundleTestB_IOSSizeCode(size_code: bits(4),
                                  pe_mode: bits(3),
                                  shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    assert TileSizeCodeBytes(12) == 262144;
    assert SharedTileCapacityIsLegal(262144);
    assert !TileCapacityIsLegal(131072);
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    let boundary = BundleTestB_IOSSizeCode('1100', '111', Zeros{8} + 7);
    assert started == CommandExecution_Executed;
    assert DecodeCommandForm(boundary, 32) == 52;
    let boundary_status = ExecuteCommandInstruction(boundary, 32);
    assert boundary_status == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].valid;
    assert _BundleSharedBindings[[0]].shared_id == Zeros{8} + 7;
    assert _BundleSharedBindings[[0]].size_code == 12;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';

    for reserved_code = 13 to 15 looplimit 3 do
        let reserved = BundleTestB_IOSSizeCode(
            (Zeros{4} + reserved_code) as bits(4), '111',
            (Zeros{8} + reserved_code) as bits(8));
        let reserved_status = ExecuteCommandInstruction(reserved, 32);
        assert DecodeCommandForm(reserved, 32) == 52;
        assert reserved_status == CommandExecution_Rejected;
        assert _LastFault == Fault_IllegalInstruction;
        assert _BundleSharedBindings[[1]].valid == FALSE;
        ClearFault();
    end;
    return 0;
end;
