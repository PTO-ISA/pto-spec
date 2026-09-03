// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPANDS-CUBE-LAYOUT-002","source":"asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl","requirements":["PTO-TEXPANDS-CONTRACT-001","PTO-B-DATR-FIELDS-001"],"kind":"execution","summary":"TEXPANDS uses direct B.DATR Layout 29 and 31 to allocate and fill CUBE_M32 and CUBE_M16 destinations without a Tile source.","pass_condition":"two-column U32 TEXPANDS bundles with Layout 29 and 31 publish defined destinations in the selected CUBE layout with the scalar value in every valid logical element.","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/block/model/state/control-state.asl"]}
pure func TEXPANDSCubeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xdbb19181;
    return instruction;
end;

func TestTEXPANDSCubeLayout(layout_code: bits(5), layout: TileLayout)
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1ff);
    let started = ExecuteCommandInstruction(TEXPANDSCubeStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(DTYPE_NONE, layout_code,
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == layout;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].contents_defined;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 0xff;
end;

func main() => integer
begin
    TestTEXPANDSCubeLayout(Zeros{5} + 29, TileLayout_CUBE_M32);
    TestTEXPANDSCubeLayout(Zeros{5} + 31, TileLayout_CUBE_M16);
    return 0;
end;
