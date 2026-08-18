<!-- GENERATED FROM: asl/arch/profile/reference-profile.asl -->
# Reference Profile

**Normative ASL source:** `asl/arch/profile/reference-profile.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-REFERENCE-PROFILE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/reference-profile.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-REFERENCE-PROFILE","surface":"arch","classification":["profile","reference-profile"],"depends_on":["PTO-ARCH-PROFILE-APPLICABILITY"]}
implementation func ReadMonotonicTime() => Word
begin
    return _SystemRegisters.cycle;
end;

implementation func FloatingExponential(value: real) => real
begin
    // PTO v0 fixes an 18-term Taylor reference algorithm. It is deterministic
    // executable evidence, not a promise of a host libm implementation.
    var result: real = 1.0;
    var term: real = 1.0;
    for index = 1 to 18 do
        term = (term * value) / Real(index);
        result = result + term;
    end;
    return result;
end;

implementation func FloatingRoundNearest(value: real) => integer
begin
    let lower = RoundDown(value);
    let fraction = value - Real(lower);
    if fraction < 0.5 then return lower;
    elsif fraction > 0.5 then return lower + 1;
    elsif lower MOD 2 == 0 then return lower;
    else return lower + 1;
    end;
end;

implementation func ScalarFPBinaryProfile(operation: FloatingBinaryOperation,
                                           rounding_mode: NumericRoundingMode,
                                           source_type: bits(5),
                                           left: Word, right: Word)
                                           => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(source_type);
    case operation of
        when FloatingBinary_ADD => return (left + right, Zeros{5});
        when FloatingBinary_SUB => return (left - right, Zeros{5});
        when FloatingBinary_MUL => return (MultiplyWord(left, right), Zeros{5});
        when FloatingBinary_DIV =>
            if ScalarFPCarrierIsZero(right, source_type) then
                return (Ones{PTO_XLEN}, Zeros{5} + 2);
            else return (DivideWordUnsigned(left, right), Zeros{5});
            end;
        // Scalar dispatch owns MIN/MAX NaN and signed-zero behavior. These
        // totality arms are not reached by decoded FMIN/FMAX.
        when FloatingBinary_MIN =>
            if SInt(left) <= SInt(right) then return (left, Zeros{5});
            else return (right, Zeros{5});
            end;
        when FloatingBinary_MAX =>
            if SInt(left) >= SInt(right) then return (left, Zeros{5});
            else return (right, Zeros{5});
            end;
    end;
end;

implementation func ScalarFPUnaryProfile(operation: FloatingUnaryOperation,
                                          rounding_mode: NumericRoundingMode,
                                          source_type: bits(5), value: Word)
                                          => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(source_type);
    case operation of
        when FloatingUnary_ABS =>
            if source_type == '00001' then
                return (ZeroExtend{PTO_XLEN}(value[30:0]), Zeros{5});
            else return (value AND (Zeros{PTO_XLEN} + 0x7fffffffffffffff), Zeros{5});
            end;
        when FloatingUnary_SQRT => return (value, Zeros{5});
        when FloatingUnary_EXP => return (value + 1, Zeros{5});
        when FloatingUnary_RECIP =>
            if ScalarFPCarrierIsZero(value, source_type) then
                return (Ones{PTO_XLEN}, Zeros{5} + 2);
            else return (DivideWordUnsigned(Ones{PTO_XLEN}, value), Zeros{5});
            end;
    end;
end;

implementation func ScalarFPFusedProfile(operation: FloatingFusedOperation,
                                          rounding_mode: NumericRoundingMode,
                                          source_type: bits(5), addend: Word,
                                          left: Word, right: Word)
                                          => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(source_type);
    let product = MultiplyWord(left, right);
    case operation of
        when FloatingFused_MADD => return (product + addend, Zeros{5});
        when FloatingFused_MSUB => return (product - addend, Zeros{5});
        when FloatingFused_NMADD =>
            return (Zeros{PTO_XLEN} - (product + addend), Zeros{5});
        when FloatingFused_NMSUB =>
            return (Zeros{PTO_XLEN} - (product - addend), Zeros{5});
    end;
end;

implementation func ScalarFPToIntegerProfile(
    rounding_mode: NumericRoundingMode, destination_type: bits(5),
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert ScalarIntegerTypeCodeSupported(destination_type);
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

implementation func ScalarFPConvertProfile(
    rounding_mode: NumericRoundingMode, destination_type: bits(5),
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert ScalarFPTypeCodeSupported(destination_type);
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

implementation func ScalarIntegerToFPProfile(
    rounding_mode: NumericRoundingMode, source_type: bits(5),
    destination_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert ScalarIntegerTypeCodeSupported(source_type);
    assert ScalarFPTypeCodeSupported(destination_type);
    return (value, Zeros{5});
end;

implementation func TileSquareRoot(value: Word) => Word
begin
    return value;
end;

implementation func TileLogarithm(value: Word) => Word
begin
    return value;
end;

implementation func TileReciprocal(value: Word) => Word
begin
    return DivideWordUnsigned(Ones{PTO_XLEN}, value);
end;

implementation func TileReciprocalSquareRoot(value: Word) => Word
begin
    return value;
end;

implementation func TileExponential(value: Word) => Word
begin
    return value + 1;
end;

implementation func TileProfileConvert(value: Word,
                                        source_type: TileDataType,
                                        destination_type: TileDataType,
                                        control: NumericExecutionControl)
                                        => (Word, bits(5))
begin
    if !TileDataTypeIsFloating(destination_type) then
        return (
            NormalizeTileInteger(value, destination_type),
            Zeros{5});
    end;
    return (value, Zeros{5});
end;

readonly implementation func AtomicAddress(address: Word,
                                            far: boolean) => Word
begin
    return address;
end;

readonly implementation func TranslateDataAddress(address: Word,
                                                  size_bytes: integer {1..262144},
                                                  write: boolean) => Word
begin
    return address;
end;

readonly implementation func DataAccessPermitted(address: Word,
                                                 size_bytes: integer {1..262144},
                                                 write: boolean) => boolean
begin
    let end_address = UInt(address) + size_bytes;
    if end_address > PTO_MODEL_MEMORY_BYTES then return FALSE; end;
    // PTO v0 assigns ACR0 and ACR1 full bounded-memory access. ACR2 through
    // ACR15 use the bounded 3072-byte application region.
    if CurrentACR() >= 2 then return end_address <= 3072;
    else return TRUE;
    end;
end;

implementation func SaveTrapContext(target: AccessControlRing,
                                    source: AccessControlRing)
begin
    _TrapContexts[[target]].valid = TRUE;
    _TrapContexts[[target]].source_acr = source;
    _TrapContexts[[target]].tpc = ReadTPC();
    _TrapContexts[[target]].bpc = ReadBPC();
    _TrapContexts[[target]].core_state = _SystemRegisters.core_state;
    _TrapContexts[[target]].bundle_argument = _BundleArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].bundle_active = _BundleActive;
    _TrapContexts[[target]].bundle_body_active = _BundleBodyActive;
    _TrapContexts[[target]].bundle_commit_target_set = _BundleCommitTargetSet;
    _TrapContexts[[target]].bundle_condition_set = _BundleConditionSet;
    _TrapContexts[[target]].system_block_terminal_pending =
        _SystemBlockTerminalPending;
    _TrapContexts[[target]].barg = _BARG;
    _TrapContexts[[target]].bundle_sequential_pc = _BundleSequentialPC;
    _TrapContexts[[target]].frame_stack_return_target =
        _FrameStackReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_dimension_present =
        _BundleDimensionPresent;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_zero_participation_seen =
        _BundleZeroParticipationSeen;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].bundle_data_attributes_present =
        _BundleDataAttributesPresent;
    _TrapContexts[[target]].bundle_hint = _BundleHint;
    _TrapContexts[[target]].bundle_fixed_point_attributes =
        _BundleFixedPointAttributes;
    _TrapContexts[[target]].memory_copy_template = _MemoryCopyTemplate;
    _TrapContexts[[target]].frame_template = _FrameTemplate;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].t_queue_valid = _TQueueValid;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].u_queue_valid = _UQueueValid;
    _TrapContexts[[target]].predicates = _PredicateRegisters;

    var ecstate = _SystemRegisters.core_state;
    ecstate[3:0] = AccessControlRingBits(source);
    ecstate[4] = if _BundleBodyActive then '1' else '0';
    PTOv0WriteContextRegister(target, 0x0f00, ecstate);

    var control: Word = Zeros{PTO_XLEN};
    control[3:0] = AccessControlRingBits(source);
    control[4] = '1';
    control[5] = if _BundleActive then '1' else '0';
    control[6] = if _BundleBodyActive then '1' else '0';
    control[10:7] = PTOv0BundleKindCode(_BARG.block_type);
    control[13:11] = PTOv0BundleTransferCode(_BARG.transfer_type);
    control[14] = if _BARG.taken then '1' else '0';
    PTOv0WriteContextRegister(target, 0x0f40, control);
    PTOv0WriteContextRegister(target, 0x0f41, ReadBPC());
    PTOv0WriteContextRegister(target, 0x0f42, _BARG.bpcn);
    PTOv0WriteContextRegister(target, 0x0f43, ReadTPC());
    PTOv0WriteContextRegister(target, 0x0f44, _ReturnAddress);
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        PTOv0WriteContextRegister(target, 0x0f45 + index,
            _TQueue[[index]]);
        PTOv0WriteContextRegister(target, 0x0f49 + index,
            _UQueue[[index]]);
    end;
    PTOv0WriteContextRegister(target, 0x0f4d, Zeros{PTO_XLEN});
    PTOv0WriteContextRegister(target, 0x0f4e, Zeros{PTO_XLEN});
end;

implementation func TileProfileFloatingModulo(data_type: TileDataType,
                                               left: Word, right: Word) => Word
begin
    let encoding = TileDataTypeToEncoding(data_type);
    if ScalarFPCarrierIsZero(right, encoding) then
        return Ones{PTO_XLEN};
    end;
    let quotient = DivideWordUnsigned(left, right);
    return left - MultiplyWord(quotient, right);
end;

implementation func TileProfileUnary(op: TileUnaryOperation,
                                      data_type: TileDataType,
                                      value: Word) => (Word, bits(5))
begin
    if TileUnaryUsesClosedElementwiseContract(op) then
        let (result, invalid) = TileFixedUnaryValue(
            op,
            data_type,
            value);
        return (
            result,
            if invalid then Zeros{5} + 1 else Zeros{5});
    end;
    return (
        TileUnaryValue(op, value),
        Zeros{5});
end;

implementation func TileProfileFloatingCompare(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, bits(5))
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let signaling_nan =
        left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN;
    if NumericValueClassIsNaN(left_class) ||
       NumericValueClassIsNaN(right_class) then
        return (
            comparison == TileComparison_NE,
            if signaling_nan then Zeros{5} + 1 else Zeros{5});
    end;
    let both_zero = NumericValueClassIsZero(left_class) &&
        NumericValueClassIsZero(right_class);
    let equal = both_zero || left == right;
    let left_less = if both_zero then FALSE else
        UInt(TileFloatingOrderKey(data_type, left)) <
        UInt(TileFloatingOrderKey(data_type, right));
    return (TileCompareBoolean(comparison, left_less, equal), Zeros{5});
end;

implementation func TileProfileReductionInitial(
    operation: TileReductionOperation,
    data_type: TileDataType,
    first: Word) => Word
begin
    return TileReductionInitialValue(
        operation,
        data_type,
        first);
end;

implementation func TileProfileReductionStep(
    operation: TileReductionOperation,
    data_type: TileDataType,
    accumulator: Word, value: Word) => (Word, boolean)
begin
    let (result, selected, -) = TileReductionStepWithFlags(
        operation,
        data_type,
        accumulator,
        value);
    return (result, selected);
end;

implementation func TileProfileMixedExpdifFP32(
    source_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    assert source_type == TileDataType_FP16 ||
           source_type == TileDataType_BF16;
    let (handled, discriminator_result) =
        HardwareNumericMixedExpdifDiscriminator(left, broadcast);
    if handled then return (discriminator_result, Zeros{5}); end;

    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        TileDataType_FP32,
        left,
        broadcast);
    let (special_handled, special_result, special_flags) =
        TileSFUUnarySpecialValue(
            TileUnary_EXP,
            TileDataType_FP32,
            difference);
    if special_handled then
        return (
            special_result,
            subtract_flags OR special_flags);
    end;

    let (profile_result, profile_flags) = TileProfileUnary(
        TileUnary_EXP,
        TileDataType_FP32,
        difference);
    return (
        profile_result,
        subtract_flags OR profile_flags);
end;
implementation func TileProfileExpand(op: TileExpandOperation,
                                      data_type: TileDataType,
                                      left: Word, broadcast: Word) => Word
begin
    return TileExpandValue(
        op,
        data_type,
        left,
        broadcast);
end;
implementation func TileProfileOrderLeft(left: Word, right: Word,
                                         descending: boolean,
                                         data_type: TileDataType) => boolean
begin
    if descending then return SInt(left) >= SInt(right);
    else return SInt(left) <= SInt(right);
    end;
end;

implementation func TileProfileValueIsNaN(value: Word,
                                           data_type: TileDataType) => boolean
begin
    // The deterministic raw-carrier reference profile has no NaN class.
    return FALSE;
end;

implementation func TileProfileMatrixAccumulate(
    accumulator: Word, left: Word, right: Word,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, control: NumericExecutionControl) => Word
begin
    return accumulator + MultiplyWord(left, right);
end;

implementation func TileProfileFusedMultiplyAdd(
    data_type: TileDataType,
    addend: Word,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    return ScalarFPFusedProfile(
        FloatingFused_MADD,
        DefaultNumericExecutionControl().rounding_mode,
        TileDataTypeToEncoding(data_type),
        addend,
        left,
        right);
end;

implementation func TileProfileFusedInvalidResult(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    let (available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    assert available;
    return (quiet_nan, Zeros{5} + 1);
end;

implementation func TileProfileMatrixBias(value: Word, bias: Word,
                                          destination_type: TileDataType,
                                          bias_type: TileDataType) => Word
begin
    return value + bias;
end;

implementation func TileProfileMatrixScaledAccumulate(
    accumulator: Word, left: Word, right: Word,
    left_scale: Word, right_scale: Word,
    left_scale_present: boolean, right_scale_present: boolean,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, left_scale_type: TileDataType,
    right_scale_type: TileDataType) => Word
begin
    let scaled_left = if left_scale_present then
        MultiplyWord(left, left_scale)
    else
        left;
    let scaled_right = if right_scale_present then
        MultiplyWord(right, right_scale)
    else
        right;
    return accumulator + MultiplyWord(scaled_left, scaled_right);
end;

// Matrix post-processing keeps conversion/activation arithmetic as a named
// profile hook.  PTO-v0's deterministic raw-carrier default preserves the
// payload; FP19, rounding, exceptional values, overflow, saturation, offsets,
// and output encodings remain an S5-T2 conformance obligation.
implementation func TileProfileMatrixPostProcess(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => Word
begin
    return value;
end;

// MaxAbs and max folding reuse the registered unary ABS and reduction MAX
// profile hooks instead of introducing a duplicate matrix-reduction policy.
implementation func TileProfileMatrixReductionStep(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => Word
begin
    let (lhs_abs, -) = TileFixedUnaryValue(
        TileUnary_ABS,
        data_type,
        current);
    let (rhs_abs, -) = TileFixedUnaryValue(
        TileUnary_ABS,
        data_type,
        candidate);
    let lhs = if max_abs then lhs_abs else current;
    let rhs = if max_abs then rhs_abs else candidate;
    let (selected, _) = TileProfileReductionStep(
        TileReduction_MAX, data_type, lhs, rhs);
    return selected;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
