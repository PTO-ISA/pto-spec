// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-LOCAL-PER-PE-002","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001"],"kind":"execution","summary":"LAST validates coverage, publication, and whole-parent readiness independently for every INIT-selected PE instance.","pass_condition":"Disjoint per-PE intervals cannot combine into complete LAST coverage; after logical close PE0 publishes and serves a whole-parent consumer while PE1 remains pending, then PE1 writer completion publishes the aggregate generation without changing creation order.","related_sources":["asl/block/model/operands/portable-carriers.asl","asl/block/model/state/types.asl"]}
func main() => integer
begin
    ResetProfileState();
    let slot: integer {0..63} = 5;
    ClearBundleLocalGenerationState(slot);
    ConfigureTileForMask(1, 256, 2, 64, 2, 64,
        TileDataType_U8, TileLayout_RowMajor, '1100');
    _LocalGenerations[[slot]].open = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1100';
    _LocalGenerations[[slot]].parent_cell_count = 2;
    _LocalGenerations[[slot]].parent_size_code = 2;
    _LocalGenerations[[slot]].working_destination = 1;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = 1;

    var pe0_covered = Zeros{2048}; pe0_covered[0] = '1';
    var pe1_disjoint = Zeros{2048}; pe1_disjoint[1] = '1';
    _LocalGenerations[[slot]].per_pe_covered_cells[[0]] = pe0_covered;
    _LocalGenerations[[slot]].per_pe_covered_cells[[1]] = pe1_disjoint;
    let disjoint_last = BundleLocalGenerationCoverageComplete(
        slot, Zeros{PTO_XLEN} + 1, 1, '1000', FALSE, 0);
    assert !disjoint_last;

    var pe1_complete = Zeros{2048};
    pe1_complete[0] = '1'; pe1_complete[1] = '1';
    _LocalGenerations[[slot]].per_pe_covered_cells[[1]] = pe1_complete;
    let subset_last = BundleLocalGenerationCoverageComplete(
        slot, Zeros{PTO_XLEN} + 1, 1, '1000', FALSE, 0);
    assert subset_last;

    var all_ready = Zeros{2048}; all_ready[0] = '1'; all_ready[1] = '1';
    var first_ready = Zeros{2048}; first_ready[0] = '1';
    _LocalGenerations[[slot]].per_pe_ready_cells[[0]] = all_ready;
    _LocalGenerations[[slot]].per_pe_ready_cells[[1]] = first_ready;
    _LocalGenerations[[slot]].generation_instance = Zeros{PTO_XLEN} + 0x500;
    _LocalGenerations[[slot]].writer_count = 1;
    _LocalGenerations[[slot]].writers[[0]].valid = TRUE;
    _LocalGenerations[[slot]].writers[[0]].offset_cells = 1;
    _LocalGenerations[[slot]].writers[[0]].cell_count = 1;
    _LocalGenerations[[slot]].writers[[0]].destination = 1;
    _LocalGenerations[[slot]].writers[[0]].pe_mask = '0100';
    _LocalGenerations[[slot]].writers[[0]].ready = FALSE;
    _LocalGenerations[[slot]].writers[[0]].identity.execution_domain_token = 77;
    SetBundleTileBinding(0, TRUE, 1, 2, '1000',
        FALSE, FALSE, 0, 0, TRUE);
    _BundleTileBindings[[0]].destination_reused_by_generation = TRUE;
    _BundleTileBindings[[0]].parent_ref_valid = TRUE;
    _BundleTileBindings[[0]].parent_ref = 1;
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = FALSE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    _BundleTileBindings[[0]].destination_assemble.size_code = 1;
    _BundleTileBindings[[0]].destination_assemble.offset =
        Zeros{PTO_XLEN} + 1;
    CommitBundleLocalGeneration();
    assert _LocalGenerations[[slot]].closed &&
           !_LocalGenerations[[slot]].published;
    assert _LocalGenerations[[slot]].per_pe_closed[[0]] &&
           _LocalGenerations[[slot]].per_pe_closed[[1]] &&
           !_LocalGenerations[[slot]].per_pe_closed[[2]] &&
           !_LocalGenerations[[slot]].per_pe_closed[[3]];
    assert _LocalGenerations[[slot]].per_pe_published[[0]] &&
           !_LocalGenerations[[slot]].per_pe_published[[1]] &&
           !_LocalGenerations[[slot]].per_pe_published[[2]] &&
           !_LocalGenerations[[slot]].per_pe_published[[3]];
    let pe0_whole_ready = BundleConsumerDependencyRequiredRange(
        slot, 1, Zeros{PTO_XLEN}, 0, TRUE, '1000',
        Zeros{PTO_XLEN} + 0x504);
    let pe1_whole_waiting = BundleConsumerDependencyRequiredRange(
        slot, 1, Zeros{PTO_XLEN}, 0, TRUE, '0100',
        Zeros{PTO_XLEN} + 0x508);
    assert pe0_whole_ready && !pe1_whole_waiting;
    let pe1_completed = CompleteBundleLocalGenerationWriterEvent(
        slot, 77, 1, 1);
    assert pe1_completed && _LocalGenerations[[slot]].published;
    assert _LocalGenerations[[slot]].per_pe_published[[0]] &&
           _LocalGenerations[[slot]].per_pe_published[[1]];
    assert _LocalGenerations[[slot]].consumers[[1]].state ==
        BundleConsumerDependency_Eligible;
    return 0;
end;
