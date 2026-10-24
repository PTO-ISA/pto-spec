// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-M32-U8-PREFIX-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"M32/U8 Local assembly publishes a three-CELL valid prefix inside the exact four-CELL parent.","pass_condition":"Exact 256-byte and 128-byte writer fragments at offsets 0 and 2 publish a 32x12 valid prefix in a 32x16, 512-byte parent; the unwritten fourth CELL remains outside covered and ready prefixes.","related_sources":["asl/block/model/operands/local-generation.asl","asl/tile/model/state/allocation.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func InstallU8Writer(slot: integer {0..63}, ordinal: integer {0..15},
                     offset: integer {0..2047}, physical_columns: integer {1..16},
                     valid_columns: integer {1..16})
begin
    _LocalGenerations[[slot]].writers[[ordinal]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].offset_cells = offset;
    _LocalGenerations[[slot]].writers[[ordinal]].cell_count =
        (physical_columns DIVRM 4) as integer {1..4};
    _LocalGenerations[[slot]].writers[[ordinal]].destination = 1;
    _LocalGenerations[[slot]].writers[[ordinal]].pe_mask = '1111';
    _LocalGenerations[[slot]].writers[[ordinal]].ready = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_rows = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_columns =
        physical_columns;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_rows = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_columns = valid_columns;
    _LocalGenerations[[slot]].writers[[ordinal]].data_type = TileDataType_U8;
    _LocalGenerations[[slot]].writers[[ordinal]].predicate_basis_type =
        TileDataType_U8;
    _LocalGenerations[[slot]].writers[[ordinal]].layout = TileLayout_CUBE_M32;
end;

func main() => integer
begin
    let slot: integer {0..63} = 7;
    // A three-CELL M32/U8 prefix publishes valid 32x12 inside the exact
    // four-CELL 32x16 parent. The final physical CELL remains uncovered.
    ResetProfileState();
    let u8_parent = ConfigureCubeTileForMask(1, 512,
        32, 8, TileDataType_U8, TileLayout_CUBE_M32, '1111');
    assert u8_parent && _Tiles[[1]].columns == 16 &&
           _Tiles[[1]].cube_cell_count == 4 &&
           _Tiles[[1]].cube_storage_bytes == 512;
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].open = TRUE;
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1111';
    _LocalGenerations[[slot]].parent_size_code = 3;
    _LocalGenerations[[slot]].parent_cell_count = 4;
    _LocalGenerations[[slot]].working_destination = 1;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = 1;
    _LocalGenerations[[slot]].parent_descriptor.object_kind =
        TileStorage_Numeric;
    _LocalGenerations[[slot]].parent_descriptor.participant_mask = '1111';
    _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = 512;
    _LocalGenerations[[slot]].parent_descriptor.rows = 32;
    _LocalGenerations[[slot]].parent_descriptor.columns = 16;
    _LocalGenerations[[slot]].parent_descriptor.valid_rows = 32;
    _LocalGenerations[[slot]].parent_descriptor.valid_columns = 8;
    _LocalGenerations[[slot]].parent_descriptor.data_type = TileDataType_U8;
    _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type =
        TileDataType_U8;
    _LocalGenerations[[slot]].parent_descriptor.layout = TileLayout_CUBE_M32;
    _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = 4;
    _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = 1;
    _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = 4;
    _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes = 512;
    InstallU8Writer(slot, 0, 0, 8, 8);
    _LocalGenerations[[slot]].writer_count = 1;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    for pe = 0 to 3 do
        var covered = Zeros{2048};
        covered[0] = '1'; covered[1] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
    end;
    _BundleDimensionPresent[[0]] = FALSE;
    _BundleDimensionPresent[[1]] = FALSE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    assert BundleLocalGenerationCubeWriterLegal(1, 2);
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 2, 1, 1, '1111', FALSE, FALSE);
    InstallU8Writer(slot, 1, 2, 4, 4);
    _LocalGenerations[[slot]].writer_count = 2;
    for pe = 0 to 3 do
        var covered = _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
        covered[2] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
        _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = covered;
    end;
    FinalizeBundleLocalGenerationCube(slot);
    assert _Tiles[[1]].capacity_bytes == 512 &&
           _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 16 &&
           _Tiles[[1]].valid_rows == 32 &&
           _Tiles[[1]].valid_columns == 12 &&
           _Tiles[[1]].cube_cell_count == 4 &&
           _Tiles[[1]].cube_storage_bytes == 512;
    assert _LocalGenerations[[slot]].per_pe_covered_cells[[0]][3] == '0' &&
           _LocalGenerations[[slot]].per_pe_ready_cells[[0]][3] == '0';
    _LocalGenerations[[slot]].last_seen = TRUE;
    assert BundleLocalGenerationPEPublicationEligible(slot, 0);

    return 0;
end;
