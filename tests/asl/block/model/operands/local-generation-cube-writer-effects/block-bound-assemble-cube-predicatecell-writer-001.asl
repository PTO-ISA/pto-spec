// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-PREDICATECELL-WRITER-BOUNDARIES-001","source":"asl/block/model/operands/local-generation-cube-writer-effects.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-TCMP-CONTRACT-001","PTO-CUBE-CELL-STATE-001"],"kind":"boundary","summary":"Local CUBE writer descriptor checks admit complete U8 PredicateCell parents and reject mismatched storage, basis, and capacity","pass_condition":"complete U16-basis PredicateCell parent, transient view, value admission, and indexed writer validator accept; ordinary Predicate storage, wrong operation basis, writer basis mismatch, and undersized parent fail at their descriptor or writer boundary","related_sources":["asl/tile/model/legality/destination-value-operations.asl","asl/block/model/operands/local-generation-cube.asl"]}
func main() => integer
begin
    ResetProfileState();
    let parent_ready = ConfigurePredicateCell(1, 256, 1, 2,
        TileDataType_U16, TileLayout_CUBE_M16);
    assert parent_ready;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let parent = _Tiles[[1]];
    assert TileCubeNumericOrPredicateCellDescriptorLegal(parent);
    assert TilePredicateCellValueDescriptorLegal(parent, TileDataType_U16);
    assert !TilePredicateCellValueDescriptorLegal(parent, TileDataType_U32);
    assert BundleLocalGenerationCubeWriterLegal(1, 1);
    let (view_legal, writer) = BundleLocalGenerationCubeWriterView(
        parent, 1, 0, 1, 2);
    assert view_legal;
    let writer_cells = (TileSizeCodeBytes(1) DIVRM PTO_TILE_CELL_BYTES)
        as integer {1..2048};
    assert BundleLocalGenerationCubeWriterValueLegal(
        parent, writer, 1, 0, writer_cells);

    var wrong_basis = writer;
    wrong_basis.predicate_basis_type = TileDataType_U32;
    assert !BundleLocalGenerationCubeWriterValueLegal(
        parent, wrong_basis, 1, 0, writer_cells);

    var ordinary_predicate = parent;
    ordinary_predicate.storage_kind = TileStorage_Predicate;
    assert !TileCubeNumericOrPredicateCellDescriptorLegal(
        ordinary_predicate);
    let (ordinary_view_legal, -) = BundleLocalGenerationCubeWriterView(
        ordinary_predicate, 1, 0, 1, 2);
    assert !ordinary_view_legal;
    assert !BundleLocalGenerationCubeWriterValueLegal(
        ordinary_predicate, writer, 1, 0, writer_cells);

    ResetProfileState();
    let undersized_ready = ConfigurePredicateCell(1, 128, 1, 2,
        TileDataType_U16, TileLayout_CUBE_M16);
    assert undersized_ready;
    let undersized_parent = _Tiles[[1]];
    assert TileCubeNumericOrPredicateCellDescriptorLegal(undersized_parent);
    let (capacity_view_legal, -) = BundleLocalGenerationCubeWriterView(
        undersized_parent, 2, 0, 1, 2);
    assert !capacity_view_legal;
    return 0;
end;
