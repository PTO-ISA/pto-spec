// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-LAYOUT-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT gives every assigned Layout code an explicit source and destination physical layout","pass_condition":"all thirteen assigned transformations map to ND, DN, ZN, or NZ and no assigned transformation is implementation-defined","related_sources":["asl/block/model/state/control-state.asl","asl/tile/model/definedness/elements.asl"]}
func AssertTCVTLayout(
    data_layout: TileDataLayout,
    source_layout: TileLayout,
    destination_layout: TileLayout)
begin
    assert TileDataLayoutSourceLayout(data_layout) == source_layout;
    assert TileDataLayoutDestinationLayout(data_layout) == destination_layout;
end;

func main() => integer
begin
    AssertTCVTLayout(
        TileDataLayout_NORM,
        TileLayout_RowMajor,
        TileLayout_RowMajor);
    AssertTCVTLayout(
        TileDataLayout_ND2DN,
        TileLayout_RowMajor,
        TileLayout_ColumnMajor);
    AssertTCVTLayout(
        TileDataLayout_ND2ZN,
        TileLayout_RowMajor,
        TileLayout_ZN);
    AssertTCVTLayout(
        TileDataLayout_ND2NZ,
        TileLayout_RowMajor,
        TileLayout_NZ);
    AssertTCVTLayout(
        TileDataLayout_DN2ND,
        TileLayout_ColumnMajor,
        TileLayout_RowMajor);
    AssertTCVTLayout(
        TileDataLayout_DN2ZN,
        TileLayout_ColumnMajor,
        TileLayout_ZN);
    AssertTCVTLayout(
        TileDataLayout_DN2NZ,
        TileLayout_ColumnMajor,
        TileLayout_NZ);
    AssertTCVTLayout(
        TileDataLayout_ZN2ND,
        TileLayout_ZN,
        TileLayout_RowMajor);
    AssertTCVTLayout(
        TileDataLayout_ZN2DN,
        TileLayout_ZN,
        TileLayout_ColumnMajor);
    AssertTCVTLayout(
        TileDataLayout_ZN2NZ,
        TileLayout_ZN,
        TileLayout_NZ);
    AssertTCVTLayout(
        TileDataLayout_NZ2ND,
        TileLayout_NZ,
        TileLayout_RowMajor);
    AssertTCVTLayout(
        TileDataLayout_NZ2DN,
        TileLayout_NZ,
        TileLayout_ColumnMajor);
    AssertTCVTLayout(
        TileDataLayout_NZ2ZN,
        TileLayout_NZ,
        TileLayout_ZN);
    return 0;
end;
