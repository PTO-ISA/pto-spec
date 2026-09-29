// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-OPERATION-VIEW-FAULTS-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"Reduction operation views reject width, packed, RCPE6M2, unsupported-type, malformed-encoding, and destination mismatches; Local CUBE ExecutionMask helper state is not legal for reductions.","pass_condition":"Only equal-width non-packed supported views pass; operation-type encoding failures and incompatible direct destinations reject, an active bundle without a resolvable BSTART type does not fall back, every valid source coordinate is encoding-checked without a mask, and helper-injected mask state rejects direct reduction operand legality regardless of its bit selection.","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/execution-mask-state.asl"]}
pure func TrowsumFaultOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func TrowargmaxFaultOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '01100';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

func TestReductionRejectsHelperMaskState()
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(
        1, 128, 16, 2, 3, 2, TileDataType_U32,
        TileLayout_CUBE_M16, '0001');
    let destination_configured = ConfigureCubeTileForMaskWithPhysical(
        2, 128, 16, 2, 3, 1, TileDataType_U32,
        TileLayout_CUBE_M16, '0001');
    assert configured && destination_configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3f800001);

    var active_low = Zeros{PTO_XLEN};
    active_low[0] = '1';
    CaptureBundleExecutionMaskGPR(
        active_low, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 3, 2);
    assert !TileReductionSourceLegalAs(1, TileDataType_TF32);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 2, 1);

    var malformed_active_low = Zeros{PTO_XLEN};
    malformed_active_low[16] = '1';
    CaptureBundleExecutionMaskGPR(
        malformed_active_low, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 3, 2);
    assert !TileReductionSourceLegalAs(1, TileDataType_TF32);

    ResetProfileState();
    let unmasked_configured = ConfigureCubeTileForMaskWithPhysical(
        1, 128, 16, 2, 3, 2, TileDataType_U32,
        TileLayout_CUBE_M16, '0001');
    assert unmasked_configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3f800001);
    assert !_BundleExecutionMask.valid;
    assert !TileReductionSourceLegalAs(1, TileDataType_TF32);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 32, 4, 2, 2,
        TileDataType_RCPE6M2, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 4);
    assert TileReductionAndExpansionDescriptorLegal(0);
    assert TileCarrierWidthCompatible(
        TileDataType_RCPE6M2, TileDataType_U8);
    assert !TileReductionSourceLegalAs(0, TileDataType_U8);

    ConfigureTile(1, 128, 8, 4, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    assert !TileReductionSourceLegalAs(1, TileDataType_TF32);

    ConfigureTile(2, 128, 64, 4, 1, 2,
        TileDataType_E2M1X2, TileLayout_RowMajor);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    assert !TileCarrierWidthCompatible(
        TileDataType_E2M1X2, TileDataType_U8);
    assert !TileReductionSourceLegalAs(2, TileDataType_U8);

    ConfigureTile(3, 128, 32, 4, 1, 1,
        TileDataType_U8, TileLayout_RowMajor);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    assert !TileCarrierWidthCompatible(
        TileDataType_U8, TileDataType_BF16);
    assert !TileReductionSourceLegalAs(3, TileDataType_BF16);

    ConfigureTile(4, 128, 16, 4, 1, 1,
        TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    assert !TileCarrierWidthCompatible(
        TileDataType_U16, TileDataType_FP32);
    assert !TileReductionSourceLegalAs(4, TileDataType_FP32);

    ResetProfileState();
    ConfigureTile(1, 128, 32, 4, 1, 2,
        TileDataType_U8, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x38);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40);
    ConfigureTile(2, 128, 32, 4, 1, 1,
        TileDataType_HiF8, TileLayout_RowMajor);
    let unsupported_started = ExecuteCommandInstruction(
        TrowsumFaultOperationViewStart(TileDataType_HiF8), 32);
    assert unsupported_started == CommandExecution_Executed;
    assert !TileVecArithmeticDataTypeSupported(TileDataType_HiF8);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 2, 1);

    ResetProfileState();
    ConfigureTile(1, 128, 16, 4, 2, 2,
        TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    let started = ExecuteCommandInstruction(
        TrowsumFaultOperationViewStart(TileDataType_BF16), 32);
    assert started == CommandExecution_Executed;
    ConfigureTile(2, 128, 16, 4, 2, 1,
        TileDataType_U16, TileLayout_RowMajor);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 2, 1);

    ResetProfileState();
    ConfigureTile(1, 128, 8, 4, 1, 3,
        TileDataType_S32, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    let arg_started = ExecuteCommandInstruction(
        TrowargmaxFaultOperationViewStart(TileDataType_FP32), 32);
    assert arg_started == CommandExecution_Executed;
    ConfigureTile(2, 128, 8, 4, 1, 1,
        TileDataType_S32, TileLayout_RowMajor);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_ARGMAX, TileAxis_Row, 2, 1);

    ResetProfileState();
    ConfigureTile(1, 128, 16, 4, 1, 1,
        TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 4, 1, 1,
        TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    _BundleActive = TRUE;
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileElement;
    _BundleOperation.data_type_valid = FALSE;
    assert BundleIsActive();
    let (resolved, -) = ResolveTileSelectedOperationType(
        TileDataType_U16);
    assert !resolved;
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 2, 1);

    TestReductionRejectsHelperMaskState();
    return 0;
end;
