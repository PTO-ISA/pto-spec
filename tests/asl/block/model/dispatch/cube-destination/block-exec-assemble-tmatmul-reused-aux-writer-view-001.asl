// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-TMATMUL-REUSED-AUX-WRITER-VIEW-001","source":"asl/block/model/dispatch/cube-destination.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"Helper-only RowMax reuse keeps the full backing parent while deriving the current auxiliary writer view","pass_condition":"the value-level continuation plan retains a 16x8 FP32 parent and derives a one-valid-column, two-physical-column writer at its exact range; merging the updated writer preserves neighboring parent data; this helper witness is not an encoded reachable mixed-output continuation","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(1, 512, 16, 8,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    let auxiliary = ConfigureCubeTileForMask(2, 512, 16, 8,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert configured && auxiliary;
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(1, 0, column,
            Zeros{PTO_XLEN} + (0x3f800000 + column));
        WriteTileElement(2, 0, column,
            Zeros{PTO_XLEN} + (0x40000000 + column));
    end;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);

    SetBundleTileBinding(0, TRUE, 1, 3, '1111',
        FALSE, FALSE, 0, 0, FALSE);
    SetBundleTileBinding(1, TRUE, 2, 3, '1111',
        FALSE, FALSE, 0, 0, TRUE);
    for binding = 0 to 1 looplimit 2 do
        _BundleTileBindings[[binding]].destination_reused_by_generation = TRUE;
        _BundleTileBindings[[binding]].destination_assemble.valid = TRUE;
        _BundleTileBindings[[binding]].destination_assemble.init = FALSE;
        _BundleTileBindings[[binding]].destination_assemble.last = TRUE;
        _BundleTileBindings[[binding]].destination_assemble.size_code = 1;
        _BundleTileBindings[[binding]].destination_assemble.offset =
            Zeros{PTO_XLEN} + 2;
    end;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, TRUE, FALSE, FALSE, FALSE);

    let (admitted, writer_effects) =
        ResolveBundleTMATMULDestinationWithWriterEffects(
            16, 2, TileDataType_FP32, TRUE,
            TileLayout_CUBE_M16, '1111');
    assert admitted && _LastFault == Fault_None &&
           writer_effects.count == 2;
    assert _BundleTileBindings[[0]].destination_reused_by_generation &&
           _BundleTileBindings[[1]].destination_reused_by_generation;
    let primary = writer_effects.entries[[0]];
    let row_max = writer_effects.entries[[1]];
    assert primary.active && primary.destination == 1 &&
           primary.parent.capacity_bytes == 512 &&
           primary.parent.rows == 16 && primary.parent.columns == 8 &&
           primary.writer.capacity_bytes == 128 &&
           primary.writer.rows == 16 && primary.writer.columns == 2 &&
           primary.writer.valid_rows == 16 &&
           primary.writer.valid_columns == 2;
    assert row_max.active && row_max.destination == 2 &&
           row_max.parent.capacity_bytes == 512 &&
           row_max.parent.rows == 16 && row_max.parent.columns == 8 &&
           row_max.writer.capacity_bytes == 128 &&
           row_max.writer.rows == 16 && row_max.writer.columns == 2 &&
           row_max.writer.valid_rows == 16 &&
           row_max.writer.valid_columns == 1;

    let writer_element = TileLogicalLinearIndex(row_max.writer, 0, 0);
    let output = TileInfoWithLogicalElement(row_max.writer, writer_element,
        Zeros{PTO_XLEN} + 0x41000000);
    let updated_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
        writer_effects, 2, output);
    FinishBundleLocalGenerationCubeWriterEffects(updated_effects);
    assert _Tiles[[1]].capacity_bytes == 512 &&
           _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 8 &&
           _Tiles[[1]].valid_columns == 8 &&
           ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000 &&
           ReadTileElement(1, 0, 7) == Zeros{PTO_XLEN} + 0x3f800007;
    assert _Tiles[[2]].capacity_bytes == 512 &&
           _Tiles[[2]].rows == 16 && _Tiles[[2]].columns == 8 &&
           _Tiles[[2]].valid_columns == 8 &&
           ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x40000000 &&
           ReadTileElement(2, 0, 4) == Zeros{PTO_XLEN} + 0x41000000 &&
           ReadTileElement(2, 0, 6) == Zeros{PTO_XLEN} + 0x40000006 &&
           ReadTileElement(2, 0, 7) == Zeros{PTO_XLEN} + 0x40000007;
    return 0;
end;
