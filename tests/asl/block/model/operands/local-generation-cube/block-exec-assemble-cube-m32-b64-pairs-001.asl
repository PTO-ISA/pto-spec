// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-M32-B64-PAIRS-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"M32 b64 local generation publishes only complete double-CELL column groups.","pass_condition":"Two ordered two-CELL U64 writers finalize a 32x2 parent with four CELLs and 512 bytes, while odd offsets and half-pair writers reject before descriptor publication.","related_sources":["asl/tile/model/shape/cube-double-cell.asl","asl/tile/model/state/allocation.asl"]}
func InstallB64Writer(
    slot: integer {0..63}, ordinal: integer {0..15},
    offset: integer {0..2047})
begin
    _LocalGenerations[[slot]].writers[[ordinal]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].offset_cells = offset;
    _LocalGenerations[[slot]].writers[[ordinal]].cell_count = 2;
    _LocalGenerations[[slot]].writers[[ordinal]].destination = 1;
    _LocalGenerations[[slot]].writers[[ordinal]].pe_mask = '1111';
    _LocalGenerations[[slot]].writers[[ordinal]].ready = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_rows = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_columns = 1;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_rows = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_columns = 1;
    _LocalGenerations[[slot]].writers[[ordinal]].data_type = TileDataType_U64;
    _LocalGenerations[[slot]].writers[[ordinal]].predicate_basis_type =
        TileDataType_U64;
    _LocalGenerations[[slot]].writers[[ordinal]].layout = TileLayout_CUBE_M32;
end;

func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(
        1, 512, 32, 1, 32, 1,
        TileDataType_U64, TileLayout_CUBE_M32, '1111');
    assert configured;
    let slot: integer {0..63} = 11;
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1111';
    _LocalGenerations[[slot]].working_destination = 1;
    InstallB64Writer(slot, 0, 0);
    _LocalGenerations[[slot]].writer_count = 1;
    for pe = 0 to 3 do
        var covered = Zeros{2048};
        covered[0] = '1';
        covered[1] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
    end;
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 2, 2, 2, '1111', FALSE, FALSE);
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 1, 2, 2, '1111', FALSE, FALSE);
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 2, 1, 1, '1111', FALSE, FALSE);

    InstallB64Writer(slot, 1, 2);
    _LocalGenerations[[slot]].writer_count = 2;
    for pe = 0 to 3 do
        var covered = _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
        covered[2] = '1';
        covered[3] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
    end;
    FinalizeBundleLocalGenerationCube(slot);
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 2;
    assert _Tiles[[1]].valid_rows == 32 && _Tiles[[1]].valid_columns == 2;
    assert _Tiles[[1]].cube_k_repeat == 2;
    assert _Tiles[[1]].cube_n_repeat == 1;
    assert _Tiles[[1]].cube_cell_count == 4;
    assert _Tiles[[1]].cube_storage_bytes == 512;
    return 0;
end;
