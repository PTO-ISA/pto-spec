// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-PHYSICAL-ELEMENTS-004","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"boundary","summary":"CUBE physical storage spans the full 32,768-element model bound","pass_condition":"aligned M16 U4X2 physical envelopes above 16,384 elements and at exactly 32,768 elements are legal, while the next aligned envelope is rejected","related_sources":["asl/tile/model/state/allocation.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCubePhysicalStorageElements(
        TileLayout_CUBE_M16, 16, 1040, TileDataType_U4X2) == 16640;
    assert TileCubeDescriptorShapeAndPhysicalLegal(
        8320, 16, 1040, 1, 1,
        TileDataType_U4X2, TileLayout_CUBE_M16);

    assert TileCubePhysicalStorageElements(
        TileLayout_CUBE_M16, 16, 2048, TileDataType_U4X2) == 32768;
    assert TileCubeDescriptorShapeAndPhysicalLegal(
        16384, 16, 2048, 1, 1,
        TileDataType_U4X2, TileLayout_CUBE_M16);

    assert TileCubePhysicalStorageElements(
        TileLayout_CUBE_M16, 16, 2064, TileDataType_U4X2) == 0;
    assert !TileCubeDescriptorShapeAndPhysicalLegal(
        16512, 16, 2064, 1, 1,
        TileDataType_U4X2, TileLayout_CUBE_M16);
    return 0;
end;
