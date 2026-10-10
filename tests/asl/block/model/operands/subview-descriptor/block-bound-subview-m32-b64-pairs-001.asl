// PTO-TEST: {"id":"PTO-AVS-BLOCK-SUBVIEW-M32-B64-PAIRS-001","source":"asl/block/model/operands/subview-descriptor.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"boundary","summary":"M32 b64 subviews preserve complete low/high CELL pairs.","pass_condition":"Even offsets with an even two-CELL capacity select one logical column, including the final pair, while an odd offset or one-CELL capacity rejects before materialization.","related_sources":["asl/tile/model/shape/cube-double-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(
        0, 1024, 32, 4, TileDataType_U64,
        TileLayout_CUBE_M32, '0001');
    assert configured;
    let first = BundleCubeSubviewDescriptorOf(
        0, Zeros{PTO_XLEN}, 2);
    let second = BundleCubeSubviewDescriptorOf(
        0, Zeros{PTO_XLEN} + 2, 2);
    let last = BundleCubeSubviewDescriptorOf(
        0, Zeros{PTO_XLEN} + 6, 2);
    let odd_offset = BundleCubeSubviewDescriptorOf(
        0, Zeros{PTO_XLEN} + 1, 2);
    let half_pair = BundleCubeSubviewDescriptorOf(
        0, Zeros{PTO_XLEN}, 1);
    assert first.valid && first.origin_column == 0 &&
           first.valid_columns == 1 && first.cell_count == 2 &&
           first.capacity_bytes == 256;
    assert second.valid && second.origin_column == 1 &&
           second.valid_columns == 1 && second.cell_count == 2;
    assert last.valid && last.origin_column == 3 &&
           last.valid_columns == 1 && last.cell_count == 2;
    assert !odd_offset.valid && !half_pair.valid;
    return 0;
end;
