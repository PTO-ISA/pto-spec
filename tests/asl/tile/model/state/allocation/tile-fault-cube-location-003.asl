// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-DESCRIPTOR-003","source":"asl/tile/model/state/allocation.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"CUBE descriptor legality depends on layout geometry rather than producer residency","pass_condition":"An undersized CUBE allocation rejects without allocation and a malformed valid shape fails CUBE legality","related_sources":["asl/tile/model/legality/descriptor-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let invalid = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16);
    assert !invalid;
    assert !_Tiles[[0]].allocated;
    assert TileCapacityInUse() == 0;
    let configured = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16);
    assert configured;
    assert TileCubeDescriptorLegal(_Tiles[[0]]);
    var wrong = _Tiles[[0]];
    wrong.valid_rows = 17;
    assert !TileCubeDescriptorLegal(wrong);
    return 0;
end;
