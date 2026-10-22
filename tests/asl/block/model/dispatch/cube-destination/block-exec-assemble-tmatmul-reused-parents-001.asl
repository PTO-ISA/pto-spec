// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-TMATMUL-REUSED-PARENTS-001","source":"asl/block/model/dispatch/cube-destination.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"Committed TMATMUL reuses a full primary Local parent and rejects a mixed fresh-output/GroupMax ParentRef stream before effects","pass_condition":"a primary TMATMUL writes N=4 then N=2 to a retained 16x8 parent with independent numeric goldens; a fresh GroupMax producer publishes its two-column parent; a subsequent encoded stream combining fresh primary/RowMax with GroupMax ParentRef faults structurally before allocation or matrix effects","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/descriptor-legality.asl","asl/tile/model/execution/postprocess.asl"]}
pure func AssembledMatrixStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func AssembledMatrixStop() => bits(64)
begin
    return Zeros{64} + 1;
end;

pure func AssembledMatrixFP16Value(value: integer {1..16}) => Word
begin
    case value of
        when 1 => return Zeros{PTO_XLEN} + 0x3c00;
        when 2 => return Zeros{PTO_XLEN} + 0x4000;
        when 3 => return Zeros{PTO_XLEN} + 0x4200;
        when 4 => return Zeros{PTO_XLEN} + 0x4400;
        when 5 => return Zeros{PTO_XLEN} + 0x4500;
        when 6 => return Zeros{PTO_XLEN} + 0x4600;
        when 7 => return Zeros{PTO_XLEN} + 0x4700;
        when 8 => return Zeros{PTO_XLEN} + 0x4800;
        when 9 => return Zeros{PTO_XLEN} + 0x4880;
        when 10 => return Zeros{PTO_XLEN} + 0x4900;
        when 11 => return Zeros{PTO_XLEN} + 0x4980;
        when 12 => return Zeros{PTO_XLEN} + 0x4a00;
        when 13 => return Zeros{PTO_XLEN} + 0x4a80;
        when 14 => return Zeros{PTO_XLEN} + 0x4b00;
        when 15 => return Zeros{PTO_XLEN} + 0x4b80;
        when 16 => return Zeros{PTO_XLEN} + 0x4c00;
    end;
end;

func SetMatrixWriterRange(binding: integer {0..2},
                          writer_size: integer {1..5},
                          offset: integer {0..15},
                          init: boolean, last: boolean)
begin
    _BundleTileBindings[[binding]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[binding]].destination_assemble.init = init;
    _BundleTileBindings[[binding]].destination_assemble.last = last;
    _BundleTileBindings[[binding]].destination_assemble.size_code =
        writer_size as integer {1..12};
    _BundleTileBindings[[binding]].destination_assemble.offset =
        Zeros{PTO_XLEN} + offset;
end;

func CompleteMatrixLocalWriter(destination: TileIndex,
                               domain: integer, offset: integer {0..15},
                               cells: integer {1..16}, last: boolean)
begin
    let slot_value = BundleLocalGenerationSlotForDestination(destination);
    assert slot_value < 64;
    let slot = slot_value as integer {0..63};
    let writer_index = (_LocalGenerations[[slot]].writer_count - 1)
        as integer {0..15};
    assert _LocalGenerations[[slot]].writers[[writer_index]].valid &&
           _LocalGenerations[[slot]].writers[[writer_index]].offset_cells ==
               offset;
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, domain, offset, cells);
    assert ready && _LocalGenerations[[slot]].writers[[writer_index]].ready;
    if last then
        assert _LocalGenerations[[slot]].closed &&
               _LocalGenerations[[slot]].last_seen &&
               _LocalGenerations[[slot]].descriptor_finalized;
        let extent_value = BundleLocalGenerationCubeFinalExtent(slot);
        assert extent_value == _LocalGenerations[[slot]].parent_cell_count;
        let extent = extent_value as integer {1..2048};
        for pe = 0 to 3 do
            if _LocalGenerations[[slot]].participant_mask[
                   PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                for cell = 0 to extent - 1 looplimit 2048 do
                    assert _LocalGenerations[[slot]]
                        .per_pe_covered_cells[[pe]][cell] == '1';
                    assert _LocalGenerations[[slot]]
                        .per_pe_ready_cells[[pe]][cell] == '1';
                end;
                assert BundleLocalGenerationPEPublicationEligible(slot, pe);
            end;
        end;
        assert BundleLocalGenerationPublicationEligible(slot);
        assert _LocalGenerations[[slot]].published;
    else
        assert !_LocalGenerations[[slot]].published &&
               _LocalGenerations[[slot]].open;
    end;
end;

readonly func ReadMatrixCubeElement(index: TileIndex,
                                    row: integer {0..65535},
                                    column: integer {0..65535}) => Word
begin
    let tile = _Tiles[[index]];
    assert TileLayoutIsCube(tile.layout);
    let element = TileCubePayloadIndex(tile, row, column)
        as PackedTileElementIndex;
    assert TileLogicalElementDefined(tile, element);
    return TileReadLogicalElement(tile, element);
end;

func main() => integer
begin
    // Reuse the primary parent after a full-width N=4 writer. The second
    // matrix operation has N=2 and a separate terminal CELL range.
    ResetProfileState();
    let small_a = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let n4_b = ConfigureCubeTileForMask(5, 128, 1, 4,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let n2_b = ConfigureCubeTileForMask(7, 128, 1, 2,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let row_input = ConfigureCubeTileForMask(6, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert small_a && n4_b && n2_b && row_input;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(5, 0, column,
            AssembledMatrixFP16Value((column + 1) as integer {1..16}));
    end;
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(7, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
    let primary_start = ExecuteCommandInstruction(AssembledMatrixStart(), 32);
    assert primary_start == CommandExecution_Executed;
    let primary_init_domain = _BundleExecutionDomainToken;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, TRUE, 4, 5, FALSE);
    AddBundleTileBinding(TRUE, 1, 3, '1111', TRUE, FALSE, 6, 0, FALSE);
    AddBundleTileBinding(TRUE, 2, 3, '1111', FALSE, FALSE, 0, 0, TRUE);
    SetMatrixWriterRange(0, 2, 0, TRUE, FALSE);

    // The next BSTART commits exactly one primary operation, leaving INIT open.
    let primary_continue_start =
        ExecuteCommandInstruction(AssembledMatrixStart(), 32);
    assert primary_continue_start == CommandExecution_Executed &&
           _LastFault == Fault_None;
    let reused_primary = 0 as TileIndex;
    let primary_slot_value =
        BundleLocalGenerationSlotForDestination(reused_primary);
    assert primary_slot_value < 64;
    let primary_slot = primary_slot_value as integer {0..63};
    assert _Tiles[[reused_primary]].capacity_bytes == 512 &&
           _Tiles[[reused_primary]].rows == 16 &&
           _Tiles[[reused_primary]].columns == 8 &&
           _Tiles[[reused_primary]].valid_columns == 4;
    assert TileElementDefined(reused_primary, 0, 0) &&
           TileElementDefined(reused_primary, 0, 3);
    CompleteMatrixLocalWriter(reused_primary, primary_init_domain,
        0, 2, FALSE);

    let primary_continue_domain = _BundleExecutionDomainToken;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0000', FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, TRUE, 4, 7, TRUE);
    _BundleTileBindings[[0]].parent_ref_valid = TRUE;
    _BundleTileBindings[[0]].parent_ref_relative = FALSE;
    _BundleTileBindings[[0]].parent_ref = reused_primary;
    SetMatrixWriterRange(0, 2, 2, FALSE, TRUE);
    assert BundleLocalTileParentRefIsFinal();
    assert BundleAssembleOutputStructureLegal();
    let primary_stop = ExecuteCommandInstruction(AssembledMatrixStop(), 32);
    assert primary_stop == CommandExecution_Executed &&
           _LastFault == Fault_None;
    CompleteMatrixLocalWriter(reused_primary, primary_continue_domain,
        2, 2, TRUE);
    assert TileElementDefined(reused_primary, 0, 0);
    assert TileElementDefined(reused_primary, 0, 3);
    assert TileElementDefined(reused_primary, 0, 4);
    assert TileElementDefined(reused_primary, 0, 5);
    assert _Tiles[[reused_primary]].capacity_bytes == 512 &&
           _Tiles[[reused_primary]].rows == 16 &&
           _Tiles[[reused_primary]].columns == 8 &&
           TileLayoutIsCube(_Tiles[[reused_primary]].layout) &&
           _Tiles[[reused_primary]].valid_rows == 1 &&
           _Tiles[[reused_primary]].valid_columns == 6 &&
           ReadMatrixCubeElement(reused_primary, 0, 0) ==
               Zeros{PTO_XLEN} + 0x40000000 &&
           ReadMatrixCubeElement(reused_primary, 0, 3) ==
               Zeros{PTO_XLEN} + 0x41000000 &&
           ReadMatrixCubeElement(reused_primary, 0, 4) ==
               Zeros{PTO_XLEN} + 0x40000000 &&
           ReadMatrixCubeElement(reused_primary, 0, 5) ==
               Zeros{PTO_XLEN} + 0x40800000;

    // A fresh GroupMax producer publishes both groups with the full parent
    // descriptor retained. Its next bundle tests the encoded mixed structure
    // rejected by the existing single-ParentRef output contract.
    ResetProfileState();
    let group_a = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let n16_b = ConfigureCubeTileForMask(5, 256, 1, 16,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let n8_b = ConfigureCubeTileForMask(7, 128, 1, 8,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let group_row_input = ConfigureCubeTileForMask(6, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert group_a && n16_b && n8_b && group_row_input;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    for column = 0 to 15 looplimit 16 do
        WriteTileElement(5, 0, column,
            AssembledMatrixFP16Value((column + 1) as integer {1..16}));
    end;
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(7, 0, column,
            AssembledMatrixFP16Value((column + 1) as integer {1..16}));
    end;
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
    let group_start = ExecuteCommandInstruction(AssembledMatrixStart(), 32);
    assert group_start == CommandExecution_Executed;
    let group_init_domain = _BundleExecutionDomainToken;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 4, '1111', TRUE, TRUE, 4, 5, FALSE);
    AddBundleTileBinding(TRUE, 1, 3, '1111', FALSE, FALSE, 0, 0, FALSE);
    AddBundleTileBinding(TRUE, 2, 2, '1111', TRUE, FALSE, 6, 0, TRUE);
    SetMatrixWriterRange(2, 2, 0, TRUE, TRUE);

    // Commit the first GroupMax matrix before registering readiness.
    let group_continue_start =
        ExecuteCommandInstruction(AssembledMatrixStart(), 32);
    assert group_continue_start == CommandExecution_Executed &&
           _LastFault == Fault_None;
    let reused_group = 32 as TileIndex;
    let group_slot_value = BundleLocalGenerationSlotForDestination(reused_group);
    assert group_slot_value < 64;
    let group_slot = group_slot_value as integer {0..63};
    assert _Tiles[[reused_group]].capacity_bytes == 256 &&
           _Tiles[[reused_group]].rows == 16 &&
           _Tiles[[reused_group]].columns == 4 &&
           TileLayoutIsCube(_Tiles[[reused_group]].layout) &&
           _Tiles[[reused_group]].valid_columns == 2;
    assert TileElementDefined(reused_group, 0, 0) &&
           TileElementDefined(reused_group, 0, 1);
    CompleteMatrixLocalWriter(reused_group, group_init_domain, 0, 2, TRUE);
    assert _Tiles[[reused_group]].valid_rows == 1 &&
           _Tiles[[reused_group]].valid_columns == 2 &&
           ReadMatrixCubeElement(reused_group, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41800000 &&
           ReadMatrixCubeElement(reused_group, 0, 1) ==
               Zeros{PTO_XLEN} + 0x42000000;

    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 4, '1111', TRUE, TRUE, 4, 7, FALSE);
    AddBundleTileBinding(TRUE, 1, 3, '1111', FALSE, FALSE, 0, 0, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, FALSE, 6, 0, TRUE);
    _BundleTileBindings[[2]].parent_ref_valid = TRUE;
    _BundleTileBindings[[2]].parent_ref_relative = FALSE;
    _BundleTileBindings[[2]].parent_ref = reused_group;
    SetMatrixWriterRange(2, 1, 1, FALSE, TRUE);
    assert !BundleAssembleOutputStructureLegal();
    let group_stop = ExecuteCommandInstruction(AssembledMatrixStop(), 32);
    assert group_stop == CommandExecution_Rejected &&
           _LastFault == Fault_BundleControl;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert TileElementDefined(reused_group, 0, 0) &&
           TileElementDefined(reused_group, 0, 1);
    assert _Tiles[[reused_group]].capacity_bytes == 256 &&
           _Tiles[[reused_group]].rows == 16 &&
           _Tiles[[reused_group]].columns == 4 &&
           TileLayoutIsCube(_Tiles[[reused_group]].layout) &&
           _Tiles[[reused_group]].valid_rows == 1 &&
           _Tiles[[reused_group]].valid_columns == 2 &&
           ReadMatrixCubeElement(reused_group, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41800000 &&
           ReadMatrixCubeElement(reused_group, 0, 1) ==
               Zeros{PTO_XLEN} + 0x42000000;
    return 0;
end;
