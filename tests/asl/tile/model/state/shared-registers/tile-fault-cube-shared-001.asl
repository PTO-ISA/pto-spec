// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-SHARED-REJECT-001","source":"asl/tile/model/state/shared-registers.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"Shared Tile schema preflight rejects persistent CUBE layouts before allocation or effects","pass_condition":"dense-looking M16 descriptor update and unallocated Shared read schema both reject while Shared capacity remains zero","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert configured;
    let cube = _Tiles[[0]];
    assert !SharedTileUpdateCompatible(Zeros{8}, cube, '0001');
    assert !SharedTileReadSchemaLegalAtCapacity(Zeros{8}, 16, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16, 512);
    assert !SharedTileRecord(Zeros{8}).descriptor_valid;
    assert SharedTileCapacityInUse() == 0;
    return 0;
end;
