// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-LOCATION-003","source":"asl/tile/model/state/allocation.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"Persistent CUBE layouts are legal only in Local Matrix storage","pass_condition":"Vector configuration rejects without allocation and a location-mutated descriptor fails CUBE legality","related_sources":["asl/tile/model/legality/descriptor-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let invalid = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Vector);
    assert !invalid;
    assert !_Tiles[[0]].allocated;
    assert TileCapacityInUse() == 0;
    let configured = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert configured;
    assert TileCubeDescriptorLegal(_Tiles[[0]]);
    var wrong = _Tiles[[0]];
    wrong.location = TileLocation_Vector;
    assert !TileCubeDescriptorLegal(wrong);
    return 0;
end;
