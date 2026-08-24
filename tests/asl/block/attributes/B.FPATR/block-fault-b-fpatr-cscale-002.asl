// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-CSCALE-FAULT-002","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-CUBE-CSCALE-001","PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"CScale rejects every reserved, missing, surplus, alias, opcode, and accumulator-class misuse before effects.","pass_condition":"Bit10, disabled-surplus, enabled-missing, CScale/output alias, non-ACC use, and non-FP32 ACC each reject without destination allocation or source mutation.","related_sources":["asl/block/model/dispatch/matrix-scale.asl","asl/tile/model/legality/matrix-operands.asl"]}

func PrepareFP16ACC(c_scale_enabled: boolean,
                    include_scale: boolean,
                    scale_index: TileIndex)
begin
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x40800000);
    if include_scale then
        let scale_ready = ConfigureCubeTileForMask(scale_index, 128, 1, 1,
            TileDataType_U8, TileLayout_CUBE_M32,
            TileLocation_Matrix, '1111');
        assert scale_ready;
        WriteTileElement(scale_index, 0, 0, Zeros{PTO_XLEN} + 1);
        MarkTileValidRegionDefined(scale_index);
    end;
    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        FALSE, FALSE, c_scale_enabled);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 3, 1, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, include_scale,
        2, scale_index, TRUE);
end;

func main() => integer
begin
    ResetProfileState();
    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    let reserved = ExecuteCommandInstruction(
        Zeros{64} + 0x00002423, 32);
    assert reserved == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;

    ResetProfileState();
    PrepareFP16ACC(TRUE, FALSE, 4);
    let missing = ExecuteBundleTileOperation();
    assert !missing && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;

    ResetProfileState();
    PrepareFP16ACC(FALSE, TRUE, 4);
    let surplus = ExecuteBundleTileOperation();
    assert !surplus && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;

    ResetProfileState();
    PrepareFP16ACC(TRUE, TRUE, 0);
    assert !BundleMatrixCScaleDestinationIndicesDistinct(3);
    let alias = ExecuteBundleTileOperation();
    assert !alias && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;

    ResetProfileState();
    let local_a = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let local_b = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let local_scale = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_U8, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert local_a && local_b && local_scale;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(4);
    var plain_start: bits(64) = Zeros{64} + 0x00031181;
    plain_start[31:27] = Zeros{5} + 4;
    let plain_started = ExecuteCommandInstruction(plain_start, 32);
    assert plain_started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        FALSE, FALSE, TRUE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 4, 0, TRUE);
    let wrong_function = ExecuteBundleTileOperation();
    assert !wrong_function && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;

    ResetProfileState();
    let int_a = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_U16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let int_b = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_U8, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let int_c = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let int_scale = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_U8, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert int_a && int_b && int_c && int_scale;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(4);
    var int_start: bits(64) = Zeros{64} + 0x00231181;
    int_start[31:27] = Zeros{5} + 26;
    let int_started = ExecuteCommandInstruction(int_start, 32);
    assert int_started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        FALSE, FALSE, TRUE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 3, 1, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 2, 4, TRUE);
    let non_fp32 = ExecuteBundleTileOperation();
    assert !non_fp32 && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    return 0;
end;
