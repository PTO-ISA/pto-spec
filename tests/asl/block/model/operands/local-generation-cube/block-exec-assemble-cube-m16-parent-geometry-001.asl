// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-M16-PARENT-GEOMETRY-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"Local CUBE_M16 finalization preserves the one-physical-M-block rule while extending only the column/K CELL prefix.","pass_condition":"four 16x32 E2M1X2 writer fragments with 256-byte envelopes finalize to one 16x128 parent without using ParentCapacity as geometry.","related_sources":["asl/block/model/operands/local-generation-cube.asl","asl/tile/model/state/allocation.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func InstallM16Writer(slot: integer {0..63}, ordinal: integer {0..15},
                      offset: integer {0..2047})
begin
    _LocalGenerations[[slot]].writers[[ordinal]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].offset_cells = offset;
    _LocalGenerations[[slot]].writers[[ordinal]].cell_count = 2;
    _LocalGenerations[[slot]].writers[[ordinal]].destination = 1;
    _LocalGenerations[[slot]].writers[[ordinal]].pe_mask = '1111';
    _LocalGenerations[[slot]].writers[[ordinal]].ready = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_rows = 16;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_columns = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_rows = 12;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_columns = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].data_type =
        TileDataType_E2M1X2;
    _LocalGenerations[[slot]].writers[[ordinal]].predicate_basis_type =
        TileDataType_E2M1X2;
    _LocalGenerations[[slot]].writers[[ordinal]].layout = TileLayout_CUBE_M16;
end;

func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(1, 2048,
        16, 32, 12, 32, TileDataType_E2M1X2, TileLayout_CUBE_M16, '1111');
    assert configured;
    let slot: integer {0..63} = 9;
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1111';
    _LocalGenerations[[slot]].parent_size_code = 4;
    _LocalGenerations[[slot]].parent_cell_count = 16;
    _LocalGenerations[[slot]].working_destination = 1;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = 1;
    _LocalGenerations[[slot]].parent_descriptor.object_kind = TileStorage_Numeric;
    _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = 2048;
    _LocalGenerations[[slot]].parent_descriptor.participant_mask = '1111';
    _LocalGenerations[[slot]].parent_descriptor.layout = TileLayout_CUBE_M16;
    InstallM16Writer(slot, 0, 6);
    InstallM16Writer(slot, 1, 0);
    InstallM16Writer(slot, 2, 2);
    InstallM16Writer(slot, 3, 4);
    _LocalGenerations[[slot]].writer_count = 4;
    for pe = 0 to 3 do
        var covered = Zeros{2048};
        for cell = 0 to 7 do covered[cell] = '1'; end;
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
    end;
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 6, 2, 2, Zeros{4}, FALSE, TRUE);
    FinalizeBundleLocalGenerationCube(slot);
    assert _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 128;
    assert _Tiles[[1]].valid_rows == 12 && _Tiles[[1]].valid_columns == 128;
    assert _Tiles[[1]].cube_k_repeat == 8 &&
           _Tiles[[1]].cube_n_repeat == 1 &&
           _Tiles[[1]].cube_cell_count == 8 &&
           _Tiles[[1]].cube_storage_bytes == 1024;
    assert _Tiles[[1]].capacity_bytes == 2048;
    return 0;
end;
