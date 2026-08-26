// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-PUBLISH-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV","PTO-INST-BLOCK-B-ASSEMBLE"],"kind":"state-transition","summary":"canonical Shared TMOV uses ordinary Function 2 and B.ASSEMBLE rather than independent movement modes","pass_condition":"former insert and publish carriers are reserved while the Shared generation state remains parent-level","related_sources":["asl/block/operands/B.ASSEMBLE.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert DecodeCommandForm(Zeros{64} + 0x00911181, 32) != 47;
    assert DecodeCommandForm(Zeros{64} + 0x00a11181, 32) != 47;
    let shared_tile_id = (Zeros{6} + 7) as SharedTileID;
    assert !SharedTileRecord(shared_tile_id).whole_parent_ready;
    assert !SharedTilePublished(shared_tile_id);
    return 0;
end;
