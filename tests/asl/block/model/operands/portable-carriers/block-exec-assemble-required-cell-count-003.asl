// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-REQUIRED-CELL-COUNT-003","source":"asl/block/model/operands/portable-carriers.asl","requirements":["PTO-B-ASSEMBLE-CONSUMER-READINESS-001"],"kind":"execution","summary":"A 32-cell WholeParent dependency stores its exact cardinality and becomes eligible after selected-PE publication.","pass_condition":"Registration creates one non-faulting waiting dependency with exactly cells 0..31 and count 32; after those cells become ready and the selected PE is published, the same record becomes eligible.","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/state/types.asl"]}
func main() => integer
begin
    ResetProfileState();
    let slot: integer {0..63} = 5;
    ClearBundleLocalGenerationState(slot);
    _LocalGenerations[[slot]].open = FALSE;
    _LocalGenerations[[slot]].closed = TRUE;
    _LocalGenerations[[slot]].generation_identity_valid = TRUE;
    _LocalGenerations[[slot]].participant_mask = '1000';
    _LocalGenerations[[slot]].generation_instance =
        Zeros{PTO_XLEN} + 0x314;
    _LocalGenerations[[slot]].parent_size_code = 6;
    _LocalGenerations[[slot]].parent_cell_count =
        BundleLocalGenerationCellCount(6);
    _LocalGenerations[[slot]].working_destination = 1;
    _LocalGenerations[[slot]].last_seen = TRUE;
    _LocalGenerations[[slot]].per_pe_closed[[0]] = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = 1;
    _LocalGenerations[[slot]].parent_descriptor.participant_mask = '1000';
    _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = 4096;

    let waiting = BundlePrepareConsumerSource(
        1, FALSE, Zeros{PTO_XLEN}, 0, '1000');
    assert !waiting && _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].consumer_count == 1;
    assert _LocalGenerations[[slot]].consumers[[0]].valid &&
           _LocalGenerations[[slot]].consumers[[0]].state ==
               BundleConsumerDependency_Waiting &&
           _LocalGenerations[[slot]].consumers[[0]].mode ==
               BundleConsumerDependency_WholeParent &&
           _LocalGenerations[[slot]].consumers[[0]].source == 1 &&
           _LocalGenerations[[slot]].consumers[[0]].participant_mask == '1000';
    assert _LocalGenerations[[slot]].consumers[[0]].required_cell_count == 32;
    for cell = 0 to 31 do
        assert _LocalGenerations[[slot]].consumers[[0]].required_cells[cell] ==
            '1';
    end;
    for cell = 32 to 2047 do
        assert _LocalGenerations[[slot]].consumers[[0]].required_cells[cell] ==
            '0';
    end;

    var ready = Zeros{2048};
    for cell = 0 to 31 do
        ready[cell] = '1';
    end;
    _LocalGenerations[[slot]].per_pe_ready_cells[[0]] = ready;
    _LocalGenerations[[slot]].per_pe_published[[0]] = TRUE;
    let eligible = BundlePrepareConsumerSource(
        1, FALSE, Zeros{PTO_XLEN}, 0, '1000');
    assert eligible && _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].consumer_count == 1 &&
           _LocalGenerations[[slot]].consumers[[0]].state ==
               BundleConsumerDependency_Eligible &&
           _LocalGenerations[[slot]].consumers[[0]].required_cell_count == 32;
    return 0;
end;
