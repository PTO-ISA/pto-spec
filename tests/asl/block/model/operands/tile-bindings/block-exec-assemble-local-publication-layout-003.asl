// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-LOCAL-PUBLICATION-LAYOUT-003","source":"asl/block/model/operands/tile-bindings.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001"],"kind":"execution","summary":"Finalized non-CUBE Local generations publish against parent CELL capacity rather than cube descriptor metadata.","pass_condition":"RowMajor and CUBE_N8 finalized Local generations with zero cube-cell metadata publish when their parent-cell coverage and readiness are complete.","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/state/types.asl"]}
func PrepareNonCube(slot: integer {0..63}, layout: TileLayout)
begin
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].open = TRUE;
    _LocalGenerations[[slot]].last_seen = TRUE;
    _LocalGenerations[[slot]].descriptor_finalized = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1000';
    _LocalGenerations[[slot]].parent_cell_count = 2;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.layout = layout;
    _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = 0;
    var covered = Zeros{2048};
    var ready = Zeros{2048};
    covered[0] = '1'; covered[1] = '1';
    ready[0] = '1'; ready[1] = '1';
    _LocalGenerations[[slot]].per_pe_covered_cells[[0]] = covered;
    _LocalGenerations[[slot]].per_pe_ready_cells[[0]] = ready;
end;
func main() => integer
begin
    ResetProfileState();
    PrepareNonCube(6, TileLayout_RowMajor);
    assert BundleLocalGenerationPEPublicationEligible(6, 0);

    PrepareNonCube(6, TileLayout_CUBE_N8);
    assert BundleLocalGenerationPEPublicationEligible(6, 0);
    return 0;
end;
