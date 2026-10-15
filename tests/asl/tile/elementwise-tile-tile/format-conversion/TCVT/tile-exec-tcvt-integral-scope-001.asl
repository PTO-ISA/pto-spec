// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-SCOPE-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-COMMON-CONVERSION-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"TCVT integral rounding stays within its operation-type domain and preserves public/common conversion behavior","pass_condition":"Cross-type, integer, reduced-format and non-new RTO conversions keep independent common results; FP16 operation semantics use a different equal-width backing without retagging it; public conversion ordinals retain their mappings and unchanged shared conversion remains non-integral","related_sources":["asl/tile/model/numeric/formats.asl","asl/tile/model/numeric/reference-conversion.asl","asl/tile/model/numeric/e8m0-conversion.asl","asl/scalar/model/fsu/arithmetic.asl"]}
pure func TCVTScopeStart(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x09b19181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func TCVTScopeDATR(data_type: TileDataType, mode: bits(3))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = TileDataTypeToEncoding(data_type);
    instruction[17:15] = mode;
    return instruction;
end;

pure func TCVTScopeCapacity(data_type: TileDataType)
    => integer {256..1024}
begin
    if data_type == TileDataType_FP16 ||
       data_type == TileDataType_BF16 then
        return 512;
    elsif data_type == TileDataType_E4M3 ||
          data_type == TileDataType_E5M2 then
        return 256;
    end;
    return 1024;
end;

func RunTCVTScopePair(
    source_type: TileDataType,
    destination_type: TileDataType,
    source_value: Word,
    mode_code: bits(3),
    mode: NumericRoundingMode,
    expected_value: Word,
    expected_flags: bits(5)) => boolean
begin
    ResetProfileState();
    ConfigureTile(
        0, TCVTScopeCapacity(source_type), 16, 16, 1, 1,
        source_type, TileLayout_RowMajor);
    ConfigureTile(
        1, TCVTScopeCapacity(destination_type), 16, 16, 1, 1,
        destination_type, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, source_value);
    let started = ExecuteCommandInstruction(
        TCVTScopeStart(source_type), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(
        TCVTScopeDATR(destination_type, mode_code), 32);
    assert attributes == CommandExecution_Executed;
    let control = NumericExecutionControl {
        rounding_mode = mode,
        saturating = FALSE
    };
    assert TileDescriptorLegal(0) && TileDescriptorLegal(1);
    assert TileTCVTSourceContentsDefined(0);
    assert TileTCVTSourceEncodingsValidAs(0, source_type);
    assert TileCarrierWidthCompatible(source_type, source_type);
    assert HardwareTCVTTypePairSupported(source_type, destination_type);
    assert HardwareTCVTRoundingModeSupported(
        source_type, destination_type, mode);
    if !TileOperandsLegal_TCVT(1, 0, control) then
        return FALSE;
    end;
    InstructionContractExecute_TCVT(1, 0, control);
    assert _LastFault == Fault_None;
    return ReadTileElement(1, 0, 0) == expected_value &&
           NumericStatusFlags() == expected_flags;
end;

func RunTCVTOperationTypeOverBacking()
begin
    ResetProfileState();
    ConfigureTile(
        0, 512, 16, 16, 1, 1, TileDataType_BF16,
        TileLayout_RowMajor);
    ConfigureTile(
        1, 512, 16, 16, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor);
    // This raw value is FP16 2.75 even though the backing descriptor is BF16.
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x4180);
    let started = ExecuteCommandInstruction(
        TCVTScopeStart(TileDataType_FP16), 32);
    let attributes = ExecuteCommandInstruction(
        TCVTScopeDATR(TileDataType_FP16, '001'), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    let source_before = _Tiles[[0]];
    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    assert TileDescriptorLegal(0) && TileDescriptorLegal(1);
    assert TileTCVTSourceContentsDefined(0);
    assert TileTCVTSourceEncodingsValidAs(0, TileDataType_FP16);
    assert TileCarrierWidthCompatible(
        TileDataType_BF16, TileDataType_FP16);
    assert HardwareTCVTTypePairSupported(
        TileDataType_FP16, TileDataType_FP16);
    assert HardwareTCVTRoundingModeSupported(
        TileDataType_FP16, TileDataType_FP16, NumericRound_RNE);
    assert _Tiles[[0]].valid_rows == _Tiles[[1]].valid_rows;
    assert _Tiles[[0]].valid_columns == _Tiles[[1]].valid_columns;
    assert _Tiles[[0]].rows == _Tiles[[1]].rows;
    assert _Tiles[[0]].columns == _Tiles[[1]].columns;
    assert !TileLayoutIsCube(_Tiles[[1]].layout);
    assert !CurrentBundleCanonicalize();
    assert _Tiles[[0]].layout == CurrentBundleTileSourceLayout();
    assert _Tiles[[1]].layout == CurrentBundleTileLayout();
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);
    assert _LastFault == Fault_None;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x4200;
    assert NumericStatusFlags() == Zeros{5} + 0x10;
    assert _Tiles[[0]].data_type == TileDataType_BF16;
    assert _Tiles[[0]].layout == source_before.layout;
    assert _Tiles[[0]].capacity_bytes == source_before.capacity_bytes;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x4180;
end;

func TestPublicConversionOrdinals()
begin
    let (none_valid, none_selection) =
        DecodePublicConversionRoundingSelection('000');
    let (rint_valid, rint_selection) =
        DecodePublicConversionRoundingSelection('001');
    let (round_valid, round_selection) =
        DecodePublicConversionRoundingSelection('010');
    let (floor_valid, floor_selection) =
        DecodePublicConversionRoundingSelection('011');
    let (ceil_valid, ceil_selection) =
        DecodePublicConversionRoundingSelection('100');
    let (trunc_valid, trunc_selection) =
        DecodePublicConversionRoundingSelection('101');
    let (odd_valid, odd_selection) =
        DecodePublicConversionRoundingSelection('110');
    let (reserved_valid, -) =
        DecodePublicConversionRoundingSelection('111');
    assert none_valid && none_selection.use_operation_default;
    assert rint_valid && rint_selection.rounding_mode == NumericRound_RNE;
    assert round_valid && round_selection.rounding_mode == NumericRound_RNA;
    assert floor_valid && floor_selection.rounding_mode == NumericRound_RTM;
    assert ceil_valid && ceil_selection.rounding_mode == NumericRound_RTP;
    assert trunc_valid && trunc_selection.rounding_mode == NumericRound_RTZ;
    assert odd_valid && odd_selection.rounding_mode == NumericRound_RTO;
    assert !reserved_valid;

    let (rne, rne_flags) = ReferenceTCVTRoundIntegral(
        Zeros{PTO_XLEN} + 0x40300000, TileDataType_FP32,
        rint_selection.rounding_mode, FALSE);
    let (rna, rna_flags) = ReferenceTCVTRoundIntegral(
        Zeros{PTO_XLEN} + 0x40300000, TileDataType_FP32,
        round_selection.rounding_mode, FALSE);
    let (rtm, rtm_flags) = ReferenceTCVTRoundIntegral(
        Zeros{PTO_XLEN} + 0x40300000, TileDataType_FP32,
        floor_selection.rounding_mode, FALSE);
    let (rtp, rtp_flags) = ReferenceTCVTRoundIntegral(
        Zeros{PTO_XLEN} + 0x40300000, TileDataType_FP32,
        ceil_selection.rounding_mode, FALSE);
    let (rtz, rtz_flags) = ReferenceTCVTRoundIntegral(
        Zeros{PTO_XLEN} + 0x40300000, TileDataType_FP32,
        trunc_selection.rounding_mode, FALSE);
    assert rne == Zeros{PTO_XLEN} + 0x40400000 &&
           rne_flags == Zeros{5} + 0x10;
    assert rna == Zeros{PTO_XLEN} + 0x40400000 &&
           rna_flags == Zeros{5} + 0x10;
    assert rtm == Zeros{PTO_XLEN} + 0x40000000 &&
           rtm_flags == Zeros{5} + 0x10;
    assert rtp == Zeros{PTO_XLEN} + 0x40400000 &&
           rtp_flags == Zeros{5} + 0x10;
    assert rtz == Zeros{PTO_XLEN} + 0x40000000 &&
           rtz_flags == Zeros{5} + 0x10;
    assert !HardwareTCVTRoundingModeSupported(
        TileDataType_FP32, TileDataType_FP32,
        odd_selection.rounding_mode);
end;

func TestCommonAndScalarConversionRemainOrdinary()
begin
    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    let (common, common_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x40300000,
        TileDataType_FP32, TileDataType_FP32, control);
    let (tile, tile_flags) = TileProfileConvert(
        Zeros{PTO_XLEN} + 0x40300000,
        TileDataType_FP32, TileDataType_FP32, control);
    let (scalar, scalar_flags) = ScalarFPConvertProfile(
        NumericRound_RNE,
        TileDataTypeToEncoding(TileDataType_FP32) as bits(5),
        TileDataTypeToEncoding(TileDataType_FP32) as bits(5),
        Zeros{PTO_XLEN} + 0x40300000);
    assert common == Zeros{PTO_XLEN} + 0x40300000 &&
           common_flags == Zeros{5};
    assert tile == Zeros{PTO_XLEN} + 0x40300000 &&
           tile_flags == Zeros{5};
    assert scalar == Zeros{PTO_XLEN} + 0x40300000 &&
           scalar_flags == Zeros{5};
end;

func main() => integer
begin
    // Cross-type FP16->BF16 retains fractional conversion and its NX result.
    let fp16_bf16_ok = RunTCVTScopePair(
        TileDataType_FP16, TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x4166, '010', NumericRound_RTZ,
        Zeros{PTO_XLEN} + 0x402c, Zeros{5} + 0x10);
    assert fp16_bf16_ok;
    // FP32->FP16 remains ordinary format conversion despite an explicit mode.
    let fp32_fp16_ok = RunTCVTScopePair(
        TileDataType_FP32, TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x40300000, '100', NumericRound_RTP,
        Zeros{PTO_XLEN} + 0x4180, Zeros{5});
    assert fp32_fp16_ok;
    // FP->integer still uses its existing common conversion semantics.
    let fp32_s32_ok = RunTCVTScopePair(
        TileDataType_FP32, TileDataType_S32,
        Zeros{PTO_XLEN} + 0x40300000, '010', NumericRound_RTZ,
        Zeros{PTO_XLEN} + 2, Zeros{5} + 0x10);
    assert fp32_s32_ok;
    // Reduced formats stay outside the specialization; RTO remains accepted
    // for these pairs and exact 2.75 remains fractional and unchanged.
    let fp32_tf32_ok = RunTCVTScopePair(
        TileDataType_FP32, TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x40300000, '110', NumericRound_RTO,
        Zeros{PTO_XLEN} + 0x40300000, Zeros{5});
    assert fp32_tf32_ok;
    let fp32_hf32_ok = RunTCVTScopePair(
        TileDataType_FP32, TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x40300000, '110', NumericRound_RTO,
        Zeros{PTO_XLEN} + 0x40300000, Zeros{5});
    assert fp32_hf32_ok;
    let fp32_e4m3_ok = RunTCVTScopePair(
        TileDataType_FP32, TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x40300000, '001', NumericRound_RNE,
        Zeros{PTO_XLEN} + 0x43, Zeros{5});
    assert fp32_e4m3_ok;
    let fp32_e5m2_ok = RunTCVTScopePair(
        TileDataType_FP32, TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x40300000, '001', NumericRound_RNE,
        Zeros{PTO_XLEN} + 0x42, Zeros{5} + 0x10);
    assert fp32_e5m2_ok;
    // RTO remains accepted for an unrelated legal pair.
    let fp16_fp32_rto_ok = RunTCVTScopePair(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x4180, '110', NumericRound_RTO,
        Zeros{PTO_XLEN} + 0x40300000, Zeros{5});
    assert fp16_fp32_rto_ok;
    RunTCVTOperationTypeOverBacking();
    TestPublicConversionOrdinals();
    TestCommonAndScalarConversionRemainOrdinary();
    return 0;
end;
