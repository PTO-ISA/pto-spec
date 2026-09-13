// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-WEIGHT-LEGALITY-001","source":"asl/block/model/dispatch/weight-to-shared-execution.asl","requirements":["PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001","PTO-BSTART-TLOAD-WEIGHT-SOURCE-001","PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001"],"kind":"fault","summary":"Weight TLOAD rejects malformed layouts, records, parameters, types, bounds, and destinations before effects.","pass_condition":"A zero PE mask remains a strict no-op before weight-mode validation; unassigned or reserved layouts, missing, surplus, or misordered B.IOR records, malformed fixed B.DATR fields, reserved ShapeGPR bits, unsupported inherited type, invalid bounds, insufficient destination capacity, unaligned KStart, and B.IOT destination all fault before payload or allocation effects; a failed replacement preserves the previously published Shared generation.","related_sources":["asl/block/model/dispatch/weight-to-shared-schema.asl","asl/block/model/operands/weight-to-shared-parameters.asl"]}
func WeightNegStart(data_type: integer {0..31}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + data_type;
    return instruction;
end;

func WeightNegDATR(layout: integer {0..31}, data_type: integer {0..31},
                   pad: integer {0..3}, cmode: integer {0..7},
                   rmode: integer {0..7}, sat: boolean,
                   canonicalize: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[11:7] = Zeros{5} + layout;
    instruction[24:20] = Zeros{5} + data_type;
    instruction[28:27] = Zeros{2} + pad;
    instruction[31:29] = Zeros{3} + cmode;
    instruction[17:15] = Zeros{3} + rmode;
    instruction[26] = if sat then '1' else '0';
    instruction[25] = if canonicalize then '1' else '0';
    return instruction;
end;

func WeightNegIOR(source0: integer {0..31}, source1: integer {0..31},
                  source2: integer {0..31}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

func WeightNegShared(size_code: integer {0..12}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + size_code;
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

func WeightNegZeroShared() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = '0001';
    instruction[11:9] = '000';
    return instruction;
end;

func WeightNegLocal() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

func WeightNegSetup(start_type: integer {0..31}, shape: Word,
                    start: Word, layout: integer {0..31},
                    size_code: integer {0..12}, valid_col: integer {0..65535},
                    valid_row: integer {0..65535}, total_col: integer {0..65535},
                    source0: integer {0..31}, source1: integer {0..31},
                    source2: integer {0..31}, ior_count: integer {0..2},
                    use_local: boolean) => boolean
begin
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, shape);
    WriteGPR(4, start);
    let started = ExecuteCommandInstruction(WeightNegStart(start_type), 32);
    let datr = ExecuteCommandInstruction(
        WeightNegDATR(layout, 31, 0, 0, 0, FALSE, FALSE), 32);
    assert started == CommandExecution_Executed;
    assert datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_col);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_row);
    SetBundleDimension(2, Zeros{PTO_XLEN} + total_col);
    if use_local then
        let destination = ExecuteCommandInstruction(WeightNegLocal(), 32);
        assert destination == CommandExecution_Executed;
    else
        let destination = ExecuteCommandInstruction(
            WeightNegShared(size_code), 32);
        assert destination == CommandExecution_Executed;
    end;
    if ior_count >= 1 then
        let ior = ExecuteCommandInstruction(
            WeightNegIOR(source0, source1, source2), 32);
        assert ior == CommandExecution_Executed;
    end;
    if ior_count == 2 then
        let surplus = ExecuteCommandInstruction(
            WeightNegIOR(source0, source1, source2), 32);
        assert surplus == CommandExecution_Executed;
    end;
    return TRUE;
end;

func RejectLayoutCommand(layout: integer {0..31}) => boolean
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{64} + 3 + (1 << 16) + (1 << 32) + (1 << 40));
    WriteGPR(4, Zeros{PTO_XLEN});
    let started = ExecuteCommandInstruction(WeightNegStart(4), 32);
    let datr = ExecuteCommandInstruction(
        WeightNegDATR(layout, 31, 0, 0, 0, FALSE, FALSE), 32);
    assert started == CommandExecution_Executed;
    return datr != CommandExecution_Executed && CoreTileCapacityInUse() == 0;
end;

func RejectSurplusIORCommand() => boolean
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{64} + 3 + (1 << 16) + (1 << 32) + (1 << 40));
    WriteGPR(4, Zeros{PTO_XLEN});
    let started = ExecuteCommandInstruction(WeightNegStart(4), 32);
    let datr = ExecuteCommandInstruction(
        WeightNegDATR(10, 31, 0, 0, 0, FALSE, FALSE), 32);
    assert started == CommandExecution_Executed &&
           datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let destination = ExecuteCommandInstruction(WeightNegShared(8), 32);
    let first = ExecuteCommandInstruction(WeightNegIOR(2, 3, 4), 32);
    let surplus = ExecuteCommandInstruction(WeightNegIOR(2, 3, 4), 32);
    assert destination == CommandExecution_Executed &&
           first == CommandExecution_Executed;
    return surplus != CommandExecution_Executed && CoreTileCapacityInUse() == 0;
end;

func AssertLegalityFault() => boolean
begin
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let rejected = !completed && _LastFault == Fault_TileLegality &&
        _MemoryEventCount == 0 && CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return rejected;
end;

func AssertLegalityFaultWithPrior(shared_tile_id: SharedTileID,
                                  initial_value: Word) => boolean
begin
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let rejected = !completed && _LastFault == Fault_TileLegality &&
        _MemoryEventCount == 0 && SharedTilePublished(shared_tile_id) &&
        ReadSharedTileWord(shared_tile_id, 0) == initial_value;
    StopMemoryEventCapture();
    return rejected;
end;

func InstallPriorShared(shared_tile_id: SharedTileID) => Word
begin
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x77);
    InstallSharedTile(shared_tile_id, _Tiles[[0]], '0001');
    return ReadSharedTileWord(shared_tile_id, 0);
end;

func main() => integer
begin
    let valid_shape = Zeros{64} + 3 + (1 << 16) + (1 << 32) + (1 << 40);
    let valid_start = Zeros{64};
    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;

    // The zero PE mask remains a strict no-op before all weight validation.
    ResetProfileState();
    let zero_started = ExecuteCommandInstruction(WeightNegStart(4), 32);
    let zero_datr = ExecuteCommandInstruction(
        WeightNegDATR(10, 31, 1, 0, 0, FALSE, FALSE), 32);
    let zero_shared = ExecuteCommandInstruction(WeightNegZeroShared(), 32);
    assert zero_started == CommandExecution_Executed;
    assert zero_datr == CommandExecution_Executed;
    assert zero_shared == CommandExecution_Executed;
    let zero_result = AssertLegalityFault();
    assert !zero_result;
    assert _LastFault == Fault_None && _MemoryEventCount == 0;

    // Fixed B.DATR fields fault before effects.
    ResetProfileState();
    let fixed_setup = WeightNegSetup(4, valid_shape, valid_start, 10, 8,
        16, 1, 16, 2, 3, 4, 1, FALSE);
    assert fixed_setup;
    ClearBundleHeaderState();
    let bad_datr = ExecuteCommandInstruction(
        WeightNegDATR(10, 31, 1, 0, 0, FALSE, FALSE), 32);
    assert bad_datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let destination = ExecuteCommandInstruction(WeightNegShared(8), 32);
    let ior = ExecuteCommandInstruction(WeightNegIOR(2, 3, 4), 32);
    assert destination == CommandExecution_Executed &&
           ior == CommandExecution_Executed;
    let malformed_result = AssertLegalityFault();
    assert malformed_result;

    // Unassigned and reserved layout codes are rejected at B.DATR decode before
    // a weight bundle can create payload or allocation effects.
    let unassigned_result = RejectLayoutCommand(2);
    assert unassigned_result;
    let reserved_layout_result = RejectLayoutCommand(5);
    assert reserved_layout_result;
    let reserved_weight_layout_12_result = RejectLayoutCommand(12);
    assert reserved_weight_layout_12_result;
    let reserved_weight_layout_13_result = RejectLayoutCommand(13);
    assert reserved_weight_layout_13_result;

    // B.IOR schema is complete: missing, surplus, and misordered records reject.
    ResetProfileState();
    let missing_ior_setup = WeightNegSetup(4, valid_shape, valid_start, 10, 8,
        16, 1, 16, 2, 3, 4, 0, FALSE);
    assert missing_ior_setup;
    let missing_ior_result = AssertLegalityFault();
    assert missing_ior_result;
    let surplus_ior_result = RejectSurplusIORCommand();
    assert surplus_ior_result;
    ResetProfileState();
    let misordered_ior_setup = WeightNegSetup(4, valid_shape, valid_start, 10,
        8, 16, 1, 16, 3, 2, 4, 1, FALSE);
    assert misordered_ior_setup;
    let misordered_ior_result = AssertLegalityFault();
    assert misordered_ior_result;

    // Invalid N/K bounds and non-power-of-two total columns reject preflight.
    ResetProfileState();
    let col_bound_setup = WeightNegSetup(4, valid_shape, valid_start, 10, 8,
        32, 1, 16, 2, 3, 4, 1, FALSE);
    assert col_bound_setup;
    let col_bound_result = AssertLegalityFault();
    assert col_bound_result;
    ResetProfileState();
    let row_bound_setup = WeightNegSetup(4, valid_shape, valid_start, 10, 8,
        16, 2, 16, 2, 3, 4, 1, FALSE);
    assert row_bound_setup;
    let row_bound_result = AssertLegalityFault();
    assert row_bound_result;
    ResetProfileState();
    let dimension_bound_setup = WeightNegSetup(4, valid_shape, valid_start, 10,
        8, 16, 1, 3, 2, 3, 4, 1, FALSE);
    assert dimension_bound_setup;
    let dimension_bound_result = AssertLegalityFault();
    assert dimension_bound_result;

    // A legal shape that exceeds the encoded Shared capacity rejects early.
    ResetProfileState();
    let large_shape = Zeros{64} + 3 + (16 << 16) + (1 << 32) + (1 << 40);
    let capacity_setup = WeightNegSetup(4, large_shape, valid_start, 10, 1,
        16, 16, 16, 2, 3, 4, 1, FALSE);
    assert capacity_setup;
    let capacity_result = AssertLegalityFault();
    assert capacity_result;

    // A failed replacement preserves the previously published Shared value.
    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 2, Zeros{PTO_XLEN} + 7);
    let initial_setup = WeightNegSetup(4, valid_shape, valid_start, 10, 8,
        16, 1, 16, 2, 3, 4, 1, FALSE);
    assert initial_setup;
    let initial_completed = ExecuteBundleTileOperation();
    assert initial_completed;
    assert SharedTilePublished(shared_tile_id);
    let replacement_value = ReadSharedTileWord(shared_tile_id, 0);
    ClearBundleHeaderState();
    let reserved_shape = valid_shape OR (Zeros{64} + (1 << 48));
    let reserved_setup = WeightNegSetup(4, reserved_shape, valid_start, 10, 8,
        16, 1, 16, 2, 3, 4, 1, FALSE);
    assert reserved_setup;
    let replacement_result = AssertLegalityFaultWithPrior(
        shared_tile_id, replacement_value);
    assert replacement_result;
    // Unsupported inherited type, unaligned KStart, and B.IOT destination.
    ResetProfileState();
    let unsupported_setup = WeightNegSetup(0, valid_shape, valid_start, 10, 8,
        16, 1, 16, 2, 3, 4, 1, FALSE);
    assert unsupported_setup;
    let unsupported_result = AssertLegalityFault();
    assert unsupported_result;
    ResetProfileState();
    let unaligned_setup = WeightNegSetup(4, valid_shape,
        Zeros{64} + (1 << 32), 10, 8, 16, 1, 16, 2, 3, 4, 1, FALSE);
    assert unaligned_setup;
    let unaligned_result = AssertLegalityFault();
    assert unaligned_result;
    ResetProfileState();
    let local_setup = WeightNegSetup(4, valid_shape, valid_start, 10, 8,
        16, 1, 16, 2, 3, 4, 1, TRUE);
    assert local_setup;
    let local_result = AssertLegalityFault();
    assert local_result;
    return 0;
end;
