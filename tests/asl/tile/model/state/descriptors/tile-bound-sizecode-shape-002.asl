// PTO-TEST: {"id":"PTO-AVS-TILE-SIZECODE-SHAPE-002","source":"asl/tile/model/state/descriptors.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"Every assigned SizeCode has an exact U64 physical-row boundary.","pass_condition":"For each SizeCode, the derived one-column U64 row count exactly consumes capacity, while one additional physical row is rejected.","related_sources":["asl/tile/model/shape/valid-region.asl","asl/arch/features/tile-allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    for code = 1 to 12 looplimit 12 do
        let capacity_bytes = TileSizeCodeBytes(
            code as integer {1..12});
        let rows = DerivedTileRows(
            capacity_bytes, 1, TileDataType_U64);
        assert rows == capacity_bytes DIVRM 8;
        assert TileDescriptorShapeLegal(
            capacity_bytes, 1, rows, 1, TileDataType_U64);
        assert TileShapeMatchesCapacity(
            capacity_bytes, rows, 1, TileDataType_U64);
        assert !TileDescriptorShapeLegal(
            capacity_bytes, 1,
            (rows + 1) as integer {0..65535},
            1, TileDataType_U64);
        assert !TileShapeMatchesCapacity(
            capacity_bytes,
            (rows - 1) as integer {0..65535},
            1, TileDataType_U64);
    end;
    return 0;
end;
