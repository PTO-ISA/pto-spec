// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-TMATMUL-REUSED-AUX-WRITER-VIEW-001","source":"asl/block/model/dispatch/cube-destination.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"Helper-only RowMax reuse keeps the full backing parent while deriving the current auxiliary writer view","pass_condition":"the value-level continuation plan retains a 16x8 FP32 parent and derives a one-valid-column, two-physical-column writer at its exact range; merging the updated writer preserves neighboring parent data; this helper witness is not an encoded reachable mixed-output continuation","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(1, 512, 1, 8,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert configured;
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(1, 0, column,
            Zeros{PTO_XLEN} + (0x3f800000 + column));
    end;

    SetBundleTileBinding(0, TRUE, 1, 3, '1111',
        FALSE, FALSE, 0, 0, TRUE);
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = FALSE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    _BundleTileBindings[[0]].destination_assemble.size_code = 1;
    _BundleTileBindings[[0]].destination_assemble.offset =
        Zeros{PTO_XLEN} + 3;

    let (begun, writer_effects) =
        BeginBundleLocalGenerationCubeWriterEffects(1, 1);
    assert begun && writer_effects.count == 1;
    let effect = writer_effects.entries[[0]];
    assert effect.active && effect.destination == 1 &&
           effect.offset_cells == 3;
    let writer = effect.writer;
    assert writer.capacity_bytes == 128 && writer.rows == 16 &&
           writer.columns == 2 && writer.valid_rows == 1 &&
           writer.valid_columns == 1;
    assert _Tiles[[1]].capacity_bytes == 512 &&
           _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 8 &&
           _Tiles[[1]].valid_columns == 8;

    let writer_element = TileLogicalLinearIndex(writer, 0, 0);
    let output = TileInfoWithLogicalElement(writer, writer_element,
        Zeros{PTO_XLEN} + 0x41000000);
    let updated_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
        writer_effects, 1, output);
    FinishBundleLocalGenerationCubeWriterEffects(updated_effects);
    assert _Tiles[[1]].capacity_bytes == 512 &&
           _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 8 &&
           _Tiles[[1]].valid_columns == 8 &&
           ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000 &&
           ReadTileElement(1, 0, 6) == Zeros{PTO_XLEN} + 0x41000000 &&
           ReadTileElement(1, 0, 7) == Zeros{PTO_XLEN} + 0x3f800007;
    return 0;
end;
