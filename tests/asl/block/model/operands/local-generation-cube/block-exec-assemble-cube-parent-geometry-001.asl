// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"Local CUBE_M32 assembly separates writer descriptors from the finalized parent geometry and derives a common column/K prefix from CELL coverage.","pass_condition":"four 32x32 E2M1X2 writer descriptors with 512-byte envelopes at CELL offsets 0, 4, 8, and 12 finalize to one capacity-preserving 32x128 parent, including an ordered-independent terminal valid-column tail; a gap is rejected before publication.","related_sources":["asl/block/model/operands/local-generation.asl","asl/tile/model/state/allocation.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func InstallWriter(slot: integer {0..63}, ordinal: integer {0..15},
                   offset: integer {0..2047}, valid_columns: integer {1..65535},
                   pe_mask: bits(4))
begin
    _LocalGenerations[[slot]].writers[[ordinal]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].offset_cells = offset;
    _LocalGenerations[[slot]].writers[[ordinal]].cell_count = 4;
    _LocalGenerations[[slot]].writers[[ordinal]].destination = 1;
    _LocalGenerations[[slot]].writers[[ordinal]].pe_mask = pe_mask;
    _LocalGenerations[[slot]].writers[[ordinal]].ready = TRUE;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_rows = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].physical_columns = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_rows = 32;
    _LocalGenerations[[slot]].writers[[ordinal]].valid_columns = valid_columns;
    _LocalGenerations[[slot]].writers[[ordinal]].data_type =
        TileDataType_E2M1X2;
    _LocalGenerations[[slot]].writers[[ordinal]].predicate_basis_type =
        TileDataType_E2M1X2;
    _LocalGenerations[[slot]].writers[[ordinal]].layout = TileLayout_CUBE_M32;
end;

func PrepareGenerationWithCapacity(slot: integer {0..63},
                                   capacity_bytes: integer,
                                   parent_size_code: integer {1..12},
                                   parent_cell_count: integer {1..2048})
begin
    ClearBundleLocalGenerationState(slot);
    let configured = ConfigureCubeTileForMaskWithPhysical(1, capacity_bytes,
        32, 32, 32, 32, TileDataType_E2M1X2, TileLayout_CUBE_M32, '1111');
    assert configured;
    _LocalGenerations[[slot]].open = TRUE;
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].descriptor_finalized = FALSE;
    _LocalGenerations[[slot]].participant_mask = '1111';
    _LocalGenerations[[slot]].parent_size_code = parent_size_code;
    _LocalGenerations[[slot]].parent_cell_count = parent_cell_count;
    _LocalGenerations[[slot]].working_destination = 1;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = 1;
    _LocalGenerations[[slot]].parent_descriptor.object_kind = TileStorage_Numeric;
    _LocalGenerations[[slot]].parent_descriptor.participant_mask = '1111';
    _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = capacity_bytes;
    _LocalGenerations[[slot]].parent_descriptor.layout = TileLayout_CUBE_M32;
end;

func SetCoverage(slot: integer {0..63}, extent: integer {1..16})
begin
    for pe = 0 to 3 do
        var covered = Zeros{2048};
        for cell = 0 to 15 do
            if cell < extent then covered[cell] = '1'; end;
        end;
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = covered;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let slot: integer {0..63} = 7;
    PrepareGenerationWithCapacity(slot, 2048, 4, 16);
    InstallWriter(slot, 0, 8, 32, '1111');
    InstallWriter(slot, 1, 0, 32, '1111');
    InstallWriter(slot, 2, 4, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 3;
    SetCoverage(slot, 12);
    assert !_LocalGenerations[[slot]].descriptor_finalized;
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, '1111', FALSE, FALSE);
    InstallWriter(slot, 3, 12, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 4;
    for writer = 0 to 3 do
        assert _LocalGenerations[[slot]].writers[[writer]].physical_rows == 32 && _LocalGenerations[[slot]].writers[[writer]].physical_columns == 32 && _LocalGenerations[[slot]].writers[[writer]].valid_rows == 32 && _LocalGenerations[[slot]].writers[[writer]].valid_columns == 32 && _LocalGenerations[[slot]].writers[[writer]].cell_count == 4;
    end;
    SetCoverage(slot, 16);
    assert BundleLocalGenerationCubeFinalExtent(slot) == 16;
    FinalizeBundleLocalGenerationCube(slot);
    assert _LocalGenerations[[slot]].generation_identity_valid;
    assert _LocalGenerations[[slot]].descriptor_finalized;
    assert _Tiles[[1]].capacity_bytes == 2048;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 128;
    assert _Tiles[[1]].valid_rows == 32 && _Tiles[[1]].valid_columns == 128;
    assert _Tiles[[1]].cube_k_repeat == 16;
    assert _Tiles[[1]].cube_n_repeat == 1;
    assert _Tiles[[1]].cube_cell_count == 16;
    assert _Tiles[[1]].cube_storage_bytes == 2048;

    // The finalized descriptor, not ParentCapacity, is the whole-parent
    // consumer geometry. Local-A TMATMULMX source legality accepts M=32,K=128
    // only after LAST publishes the aggregate descriptor.
    _Tiles[[1]].contents_defined = TRUE;
    assert TileMatrixLocalMOperandSchemaLegal(
        1, 32, 128, TileDataType_E2M1X2);
    var ready_prefix = Zeros{2048};
    for cell = 0 to 15 do ready_prefix[cell] = '1'; end;
    for pe = 0 to 3 do
        _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = ready_prefix;
        _LocalGenerations[[slot]].per_pe_published[[pe]] = TRUE;
    end;
    _LocalGenerations[[slot]].last_seen = TRUE;
    let whole_ready = BundleConsumerDependencyRequiredRange(
        slot, 1, Zeros{PTO_XLEN}, 0, TRUE, '1111',
        Zeros{PTO_XLEN} + 0x328);
    assert whole_ready;
    let final_view = BundleCubeSubviewDescriptorOf(
        1, Zeros{PTO_XLEN} + 15, 1);
    let slack_view = BundleCubeSubviewDescriptorOf(
        1, Zeros{PTO_XLEN} + 16, 1);
    assert final_view.valid && final_view.valid_columns == 8;
    assert !slack_view.valid;

    // ParentCapacity is allocation metadata only.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    InstallWriter(slot, 1, 4, 32, '1111');
    InstallWriter(slot, 2, 8, 32, '1111');
    InstallWriter(slot, 3, 12, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 4;
    SetCoverage(slot, 16);
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, '0000', FALSE, TRUE);
    FinalizeBundleLocalGenerationCube(slot);
    assert _Tiles[[1]].capacity_bytes == 4096 && _Tiles[[1]].rows == 32 &&
           _Tiles[[1]].columns == 128 && _Tiles[[1]].cube_storage_bytes == 2048;

    // Only the terminal writer may carry a valid-column tail.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    InstallWriter(slot, 1, 4, 32, '1111');
    InstallWriter(slot, 2, 8, 32, '1111');
    InstallWriter(slot, 3, 12, 20, '1111');
    _LocalGenerations[[slot]].writer_count = 4;
    SetCoverage(slot, 16);
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, '0000', FALSE, TRUE);
    FinalizeBundleLocalGenerationCube(slot);
    assert _Tiles[[1]].columns == 128 && _Tiles[[1]].valid_columns == 116;

    // A physical CELL gap is illegal even when capacity can hold it.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    InstallWriter(slot, 1, 8, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 2;
    SetCoverage(slot, 4);
    var gapped = Zeros{2048};
    for cell = 8 to 15 do gapped[cell] = '1'; end;
    for pe = 0 to 3 do
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] =
            _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] OR gapped;
    end;
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, '1111', FALSE, FALSE);

    // Capacity slack is not required before or after finalization, while a
    // whole-parent consumer still waits for successful LAST.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 1;
    SetCoverage(slot, 4);
    _LocalGenerations[[slot]].last_seen = TRUE;
    var capacity_ready = Zeros{2048};
    for cell = 0 to 31 do capacity_ready[cell] = '1'; end;
    for pe = 0 to 3 do
        _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = capacity_ready;
    end;
    let pre_last_wait = BundleConsumerDependencyRequiredRange(
        slot, 1, Zeros{PTO_XLEN}, 0, TRUE, '1111',
        Zeros{PTO_XLEN} + 0x329);
    assert !pre_last_wait;

    // INIT_LAST must start at CELL zero, and a physical gap is never repaired
    // by unused ParentCapacity.
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 1, 4, 3, '1111', TRUE, FALSE);
    var gapped_prefix = Zeros{2048};
    for cell = 0 to 3 do gapped_prefix[cell] = '1'; end;
    for cell = 8 to 11 do gapped_prefix[cell] = '1'; end;
    for pe = 0 to 3 do
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = gapped_prefix;
    end;
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, Zeros{4}, FALSE, TRUE);

    // INIT_LAST may finalize at CELL zero with capacity slack, but a
    // nonzero INIT_LAST offset is rejected before publication.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 1;
    SetCoverage(slot, 4);
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 0, 4, 3, '1111', TRUE, FALSE);
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 4, 4, 3, '1111', TRUE, FALSE);

    // Same-PE overlap uses the range rule; replay is the exception.
    assert BundleLocalGenerationRangeOverlaps(0, 4, 2, 4);

    // Exact WriterSizeCode envelopes reject both undersized and oversized
    // fragment descriptors, and #326 row rules remain explicit.
    ResetProfileState();
    let oversized_writer = ConfigureCubeTileForMaskWithPhysical(1, 4096,
        32, 64, 32, 64, TileDataType_E2M1X2, TileLayout_CUBE_M32, '1111');
    assert oversized_writer;
    assert !BundleLocalGenerationCubeWriterLegal(1, 3);
    let undersized_writer = ConfigureCubeTileForMaskWithPhysical(1, 4096,
        32, 16, 32, 16, TileDataType_E2M1X2, TileLayout_CUBE_M32, '1111');
    assert undersized_writer;
    assert !BundleLocalGenerationCubeWriterLegal(1, 3);
    _Tiles[[1]].rows = 16;
    assert !BundleLocalGenerationCubeWriterLegal(1, 3);

    // Common writer metadata and per-PE final geometry are checked before any
    // descriptor installation.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    InstallWriter(slot, 1, 4, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 2;
    SetCoverage(slot, 8);
    _Tiles[[1]].data_type = TileDataType_FP16;
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 8, 4, 3, '1111', FALSE, FALSE);
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    InstallWriter(slot, 1, 4, 20, '1111');
    _LocalGenerations[[slot]].writer_count = 2;
    SetCoverage(slot, 8);
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 8, 4, 3, '0000', FALSE, TRUE);
    var pe0_prefix = Zeros{2048};
    var pe1_prefix = Zeros{2048};
    for cell = 0 to 15 do pe0_prefix[cell] = '1'; end;
    for cell = 0 to 11 do pe1_prefix[cell] = '1'; end;
    _LocalGenerations[[slot]].per_pe_covered_cells[[0]] = pe0_prefix;
    _LocalGenerations[[slot]].per_pe_covered_cells[[1]] = pe1_prefix;
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 8, 4, 3, Zeros{4}, FALSE, TRUE);

    // A failed LAST leaves the old descriptor and finalized bit untouched;
    // replay identity is idempotent and does not double-count coverage.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 0, 32, '1111');
    InstallWriter(slot, 1, 4, 32, '1111');
    InstallWriter(slot, 2, 8, 32, '1111');
    InstallWriter(slot, 3, 12, 32, '1111');
    _LocalGenerations[[slot]].writer_count = 4;
    SetCoverage(slot, 16);
    let old_rows = _Tiles[[1]].rows;
    let old_columns = _Tiles[[1]].columns;
    assert !_LocalGenerations[[slot]].descriptor_finalized;
    _Tiles[[1]].capacity_bytes = 512;
    assert !BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, Zeros{4}, FALSE, TRUE);
    assert !_LocalGenerations[[slot]].descriptor_finalized &&
           _Tiles[[1]].rows == old_rows && _Tiles[[1]].columns == old_columns;
    _Tiles[[1]].capacity_bytes = 4096;
    _LocalGenerations[[slot]].writers[[3]].identity.instruction_instance =
        Zeros{PTO_XLEN} + 0x328;
    _LocalGenerations[[slot]].writers[[3]].identity.execution_domain_token =
        _BundleExecutionDomainToken;
    assert BundleLocalGenerationReplay(slot, 12, 4,
        Zeros{PTO_XLEN} + 0x328, _BundleExecutionDomainToken);
    FinalizeBundleLocalGenerationCube(slot);
    let replay_cells = _Tiles[[1]].cube_cell_count;
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 0, 4, 3, Zeros{4}, FALSE, TRUE);
    assert _Tiles[[1]].cube_cell_count == replay_cells;

    // A subset/interleaved writer sequence still derives one common parent.
    ResetProfileState();
    PrepareGenerationWithCapacity(slot, 4096, 5, 32);
    InstallWriter(slot, 0, 8, 32, '1000');
    InstallWriter(slot, 1, 0, 32, '0100');
    InstallWriter(slot, 2, 4, 32, '1000');
    InstallWriter(slot, 3, 12, 32, '0100');
    _LocalGenerations[[slot]].participant_mask = '1100';
    _LocalGenerations[[slot]].writer_count = 4;
    for pe = 0 to 3 do
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = Zeros{2048};
    end;
    for cell = 0 to 15 do
        _LocalGenerations[[slot]].per_pe_covered_cells[[0]][cell] = '1';
        _LocalGenerations[[slot]].per_pe_covered_cells[[1]][cell] = '1';
    end;
    assert BundleLocalGenerationCubeFinalizationLegal(
        slot, 1, 12, 4, 3, Zeros{4}, FALSE, TRUE);
    FinalizeBundleLocalGenerationCube(slot);
    assert _Tiles[[1]].columns == 128 &&
           _LocalGenerations[[slot]].descriptor_finalized;

    return 0;
end;
