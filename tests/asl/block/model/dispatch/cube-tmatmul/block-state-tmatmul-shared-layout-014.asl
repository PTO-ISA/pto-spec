// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-LAYOUT-014","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"state-transition","summary":"Cooperative Matrix resolves one deterministic Local CUBE destination layout","pass_condition":"right-only inherits A all-Shared ACC inherits C and all-Shared non-ACC selects M16 through M16 then M32 through M32","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/dispatch/cube-destination.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 13, 1,
        TileDataType_U16, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert a_ready;
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, FALSE, 1, 0, TRUE);
    let (right_only_found, right_only_layout) =
        BundleMatrixCooperativeMLayout(
            0, TileDataType_U16, 13, 1);
    assert right_only_found;
    assert right_only_layout == TileLayout_CUBE_M32;

    ResetProfileState();
    let (m16_found, m16_layout) = BundleMatrixCooperativeMLayout(
        0, TileDataType_U16, 16, 2);
    let (m17_found, m17_layout) = BundleMatrixCooperativeMLayout(
        0, TileDataType_U16, 17, 2);
    let (m33_found, m33_layout) = BundleMatrixCooperativeMLayout(
        0, TileDataType_U16, 33, 2);
    assert m16_found && m16_layout == TileLayout_CUBE_M16;
    assert m17_found && m17_layout == TileLayout_CUBE_M32;
    assert !m33_found;

    ResetProfileState();
    let c_ready = ConfigureCubeTileForMask(2, 128, 13, 1,
        TileDataType_U32, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert c_ready;
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, FALSE, 2, 0, TRUE);
    let (acc_found, acc_layout) = BundleMatrixCooperativeMLayout(
        2, TileDataType_U16, 13, 2);
    assert acc_found;
    assert acc_layout == TileLayout_CUBE_M32;
    return 0;
end;
