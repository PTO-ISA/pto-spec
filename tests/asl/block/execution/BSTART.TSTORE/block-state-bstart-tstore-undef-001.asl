// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-UNDEF-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"state-transition","summary":"an unpublished Shared source waits without reading undefined payload","pass_condition":"pending Shared source produces no GM write and remains unpublished","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/memory/shared-movement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 42) as SharedTileID;
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;
    assert !SharedTilePublished(shared_tile_id);
    assert !SharedTileRecord(shared_tile_id).whole_parent_ready;
    return 0;
end;
