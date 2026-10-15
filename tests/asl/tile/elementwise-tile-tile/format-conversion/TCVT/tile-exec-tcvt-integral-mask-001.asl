// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-MASK-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-DATR-FIELDS-001","PTO-INST-BLOCK-B-IOT","PTO-B-DIM-WRITE-001"],"kind":"execution","summary":"Encoded CUBE TCVT masks suppress inactive integral conversion reads and flags","pass_condition":"CUBE_M16 and CUBE_M32 encoded bundles exercise MERGE, ZERO, PredInv, active NX and NV, inactive exceptional and undefined sources, all-inactive publication, RTO preflight, and zero-PE no-op precedence","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/execution/execution-mask.asl","asl/tile/model/numeric/formats.asl"]}
pure func MaskTCVTStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x09b19181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP16);
    return instruction;
end;

pure func MaskTCVTDATR(zero_inactive: boolean, invert: boolean,
    rounding: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = TileDataTypeToEncoding(TileDataType_FP16);
    instruction[17:15] = rounding;
    instruction[14] = if invert then '1' else '0';
    instruction[13] = if zero_inactive then '1' else '0';
    return instruction;
end;

pure func MaskTCVTDimension(index: integer {0..2}, value: integer {1..16})
    => bits(64)
begin
    var instruction = if index == 0 then Zeros{64} + 0x00000043
        else if index == 1 then Zeros{64} + 0x00001043
        else Zeros{64} + 0x00002043;
    instruction[31:20] = Zeros{12} + value;
    return instruction;
end;

pure func MaskTCVTBinding(source0: bits(6), source1: bits(6),
    source1_valid: boolean, pe_mode: bits(3)) => bits(64)
begin
    var instruction = if source1_valid then Zeros{64} + 0x00004013
        else Zeros{64} + 0x00005013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = pe_mode;
    return instruction;
end;

func PrepareMaskTCVTInputs(layout: TileLayout, source0: Word,
    source1: Word, source1_defined: boolean,
    mask0: bits(8), mask1: bits(8))
begin
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_FP16, layout);
    let mask_ready = ConfigurePredicateCell(
        11, 128, 1, 2, TileDataType_FP16, layout);
    assert source_ready && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    WriteTileElement(10, 0, 0, source0);
    if source1_defined then
        WriteTileElement(10, 0, 1, source1);
        MarkTileValidRegionDefined(10);
    end;
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + UInt(mask0));
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + UInt(mask1));
    MarkTileValidRegionDefined(11);
end;

func PrepareMaskTCVTMergeBase(layout: TileLayout, first: Word,
    second: Word)
begin
    let base_ready = ConfigureCubeTile(
        12, 128, 1, 2, TileDataType_FP16, layout);
    assert base_ready;
    InstallRelativeTileFixture(0, 12);
    WriteTileElement(12, 0, 0, first);
    WriteTileElement(12, 0, 1, second);
    MarkTileValidRegionDefined(12);
end;

func RunMaskedIntegralTCVT(layout: TileLayout, zero_inactive: boolean,
    invert: boolean, source0: Word, source1: Word,
    source1_defined: boolean, mask0: bits(8), mask1: bits(8),
    merge_base: boolean, base0: Word, base1: Word,
    pe_mode: bits(3)) => TileIndex
begin
    ResetProfileState();
    PrepareMaskTCVTInputs(layout, source0, source1, source1_defined,
        mask0, mask1);
    if merge_base then
        PrepareMaskTCVTMergeBase(layout, base0, base1);
    end;
    let started = ExecuteCommandInstruction(MaskTCVTStart(), 32);
    let attributes = ExecuteCommandInstruction(
        MaskTCVTDATR(zero_inactive, invert, '001'), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    for dimension = 0 to 2 do
        let value = if dimension == 0 then 2
            else if dimension == 1 then 1 else 1;
        let set_dimension = ExecuteCommandInstruction(
            MaskTCVTDimension(dimension, value), 32);
        assert set_dimension == CommandExecution_Executed;
    end;
    let bound = ExecuteCommandInstruction(
        MaskTCVTBinding(Zeros{6} + 10, Zeros{6} + 11, TRUE,
            pe_mode), 32);
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    return _BundleTileBindings[[0]].destination;
end;

func TestZeroAndInactiveExceptionalSuppression(layout: TileLayout)
begin
    let destination = RunMaskedIntegralTCVT(
        layout, TRUE, FALSE,
        Zeros{PTO_XLEN} + 0x4180, Zeros{PTO_XLEN} + 0x7c01,
        TRUE, '00000001', '00000000', FALSE,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, '001');
    assert _Tiles[[destination]].allocated;
    assert _Tiles[[destination]].layout == layout;
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4200;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == '10000';
    assert ReadTileElement(10, 0, 1) == Zeros{PTO_XLEN} + 0x7c01;
end;

func TestPredInvActiveSignalingNaN(layout: TileLayout)
begin
    let destination = RunMaskedIntegralTCVT(
        layout, TRUE, TRUE,
        Zeros{PTO_XLEN} + 0x4180, Zeros{PTO_XLEN} + 0x7c01,
        TRUE, '00000001', '00000000', FALSE,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, '001');
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x7e00;
    assert NumericStatusFlags() == '00001';
end;

func TestMergeAndUndefinedInactiveSource()
begin
    let destination = RunMaskedIntegralTCVT(
        TileLayout_CUBE_M32, FALSE, FALSE,
        Zeros{PTO_XLEN} + 0x4180, Zeros{PTO_XLEN}, FALSE,
        '00000001', '00000000', TRUE,
        Zeros{PTO_XLEN} + 0x4400, Zeros{PTO_XLEN} + 0x4600, '001');
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4200;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x4600;
    assert !TileElementDefined(10, 0, 1);
    assert NumericStatusFlags() == '10000';
end;

func TestAllInactivePublication(layout: TileLayout)
begin
    let destination = RunMaskedIntegralTCVT(
        layout, TRUE, FALSE,
        Zeros{PTO_XLEN} + 0x4180, Zeros{PTO_XLEN} + 0x7c01,
        TRUE, '00000000', '00000000', FALSE,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, '001');
    assert _Tiles[[destination]].allocated;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert _Tiles[[destination]].contents_defined;
    assert NumericStatusFlags() == Zeros{5};
end;

func TestAllInactiveRTOPreflight()
begin
    ResetProfileState();
    PrepareMaskTCVTInputs(TileLayout_CUBE_M16,
        Zeros{PTO_XLEN} + 0x4180, Zeros{PTO_XLEN} + 0x4200,
        TRUE, '00000000', '00000000');
    _SystemRegisters.core_state[36:32] = '00100';
    let started = ExecuteCommandInstruction(MaskTCVTStart(), 32);
    let attributes = ExecuteCommandInstruction(
        MaskTCVTDATR(TRUE, FALSE, '110'), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    for dimension = 0 to 2 do
        let value = if dimension == 0 then 2
            else if dimension == 1 then 1 else 1;
        let set_dimension = ExecuteCommandInstruction(
            MaskTCVTDimension(dimension, value), 32);
        assert set_dimension == CommandExecution_Executed;
    end;
    let bound = ExecuteCommandInstruction(
        MaskTCVTBinding(Zeros{6} + 10, Zeros{6} + 11, TRUE, '001'), 32);
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _BundleExecutionMask.valid;
    assert !BundleExecutionMaskHasActiveCoordinate();
    assert !_Tiles[[0]].allocated;
    assert _Tiles[[10]].data_type == TileDataType_FP16;
    assert _Tiles[[10]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 0x4180;
    assert NumericStatusFlags() == '00100';
end;

func TestZeroPEStrictNoOp()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_FP16, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        12, 128, 1, 2, TileDataType_FP16, TileLayout_CUBE_M16);
    assert source_ready && destination_ready;
    InstallRelativeTileFixture(10, 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x4180);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x4200);
    MarkTileValidRegionDefined(10);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 0x4400);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 0x4600);
    MarkTileValidRegionDefined(12);
    InstallRelativeTileFixture(0, 12);
    _SystemRegisters.core_state[36:32] = '00001';
    let started = ExecuteCommandInstruction(MaskTCVTStart(), 32);
    let attributes = ExecuteCommandInstruction(
        MaskTCVTDATR(FALSE, FALSE, '110'), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    // No dimensions or source allocation are needed after encoded PE_MASK=0000.
    let bound = ExecuteCommandInstruction(
        MaskTCVTBinding(Zeros{6} + 10, Zeros{6} + 11, TRUE, '000'), 32);
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _BundleZeroParticipationSeen;
    assert BundleTileBindingCount() == 0;
    assert _Tiles[[10]].allocated &&
           _Tiles[[10]].data_type == TileDataType_FP16 &&
           _Tiles[[10]].layout == TileLayout_CUBE_M16 &&
           _Tiles[[10]].capacity_bytes == 128 &&
           _Tiles[[10]].valid_rows == 1 &&
           _Tiles[[10]].valid_columns == 2;
    assert _Tiles[[12]].allocated &&
           _Tiles[[12]].data_type == TileDataType_FP16 &&
           _Tiles[[12]].layout == TileLayout_CUBE_M16 &&
           _Tiles[[12]].capacity_bytes == 128 &&
           _Tiles[[12]].valid_rows == 1 &&
           _Tiles[[12]].valid_columns == 2;
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 0x4180 &&
           ReadTileElement(10, 0, 1) == Zeros{PTO_XLEN} + 0x4200;
    assert ReadTileElement(12, 0, 0) == Zeros{PTO_XLEN} + 0x4400 &&
           ReadTileElement(12, 0, 1) == Zeros{PTO_XLEN} + 0x4600;
    assert NumericStatusFlags() == '00001';
end;

func main() => integer
begin
    TestZeroAndInactiveExceptionalSuppression(TileLayout_CUBE_M16);
    TestPredInvActiveSignalingNaN(TileLayout_CUBE_M16);
    TestMergeAndUndefinedInactiveSource();
    TestAllInactivePublication(TileLayout_CUBE_M32);
    TestAllInactiveRTOPreflight();
    TestZeroPEStrictNoOp();
    return 0;
end;
