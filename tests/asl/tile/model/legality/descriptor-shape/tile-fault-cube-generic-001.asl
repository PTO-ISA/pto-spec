// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-GENERIC-001","source":"asl/tile/model/legality/descriptor-shape.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"fault","summary":"CUBE descriptors are legal state but remain unavailable to generic Tile consumers","pass_condition":"a dense-looking M16 FP16 descriptor passes CUBE legality while generic indexing and descriptor legality reject it","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert configured;
    let tile = _Tiles[[0]];
    assert TileCubeDescriptorLegal(tile);
    assert !TileGenericIndexingPermitted(tile);
    assert !TileDescriptorLegal(0);
    assert !TileSourceContentsDefined(0);
    return 0;
end;
