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
    assert !IsZero(value);
    return DivideWordUnsigned(Ones{PTO_XLEN}, value);
end;

implementation func TileExponential(value: Word) => Word
begin
    return value + 1;
end;

implementation func TileExpDifference(left: Word, right: Word) => Word
begin
    return left - right;
end;

implementation func TileProfileConvert(value: Word,
                                        source_type: TileDataType,
                                        destination_type: TileDataType,
                                        control: NumericExecutionControl) => Word
begin
    if !TileDataTypeIsFloating(destination_type) then
        return NormalizeTileInteger(value, destination_type);
    end;
    return value;
end;

implementation func TileProfileQuantize(value: Word, scale: Word,
                                         zero_point: Word,
                                         source_type: TileDataType,
                                         destination_type: TileDataType,
                                         control: NumericExecutionControl) => Word
begin
    assert !IsZero(scale);
    return NormalizeTileInteger(DivideWordUnsigned(value, scale) + zero_point,
        destination_type);
end;

implementation func TileProfileDequantize(value: Word, scale: Word,
                                           zero_point: Word,
                                           source_type: TileDataType,
                                           destination_type: TileDataType,
                                           control: NumericExecutionControl) => Word
begin
    return MultiplyWord(value - zero_point, scale);
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
    _TrapContexts[[target]].bundle_kind = _BundleKind;
    _TrapContexts[[target]].bundle_transfer = _BundleTransfer;
    _TrapContexts[[target]].bundle_condition = _BundleCondition;
    _TrapContexts[[target]].bundle_target = _BundleTarget;
    _TrapContexts[[target]].bundle_fallthrough = _BundleFallthrough;
    _TrapContexts[[target]].bundle_return_target = _BundleReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_body_address = _BundleBodyAddress;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].bundle_fixed_point_attributes =
        _BundleFixedPointAttributes;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].execution_mask = _ExecutionMask;
    _TrapContexts[[target]].predicates = _PredicateRegisters;

    var ecstate = _SystemRegisters.core_state;
    ecstate[3:0] = Zeros{4} + source;
    ecstate[4] = if _BundleBodyActive then '1' else '0';
    PTOv0WriteContextRegister(target, 0x0f00, ecstate);

    var control: Word = Zeros{PTO_XLEN};
    control[3:0] = Zeros{4} + source;
    control[4] = '1';
    control[5] = if _BundleActive then '1' else '0';
    control[6] = if _BundleBodyActive then '1' else '0';
    control[10:7] = PTOv0BundleKindCode(_BundleKind);
    control[13:11] = PTOv0BundleTransferCode(_BundleTransfer);
    control[14] = if _BundleCondition then '1' else '0';
    PTOv0WriteContextRegister(target, 0x0f40, control);
    PTOv0WriteContextRegister(target, 0x0f41, ReadBPC());
    PTOv0WriteContextRegister(target, 0x0f42, _BundleTarget);
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

implementation func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    var control = PTOv0ReadContextRegister(target, 0x0f40);
    let ecstate = PTOv0ReadContextRegister(target, 0x0f00);
    let recovered_bpc = PTOv0ReadContextRegister(target, 0x0f41);
    let recovered_tpc = PTOv0ReadContextRegister(target, 0x0f43);
    if !_TrapContexts[[target]].valid || control[4] == '0' ||
       !PTOv0EBARGControlLegal(control) ||
       control[3:0] != ecstate[3:0] ||
       recovered_bpc[0] == '1' || recovered_tpc[0] == '1' then
        return FALSE;
    end;
    WriteTPC(recovered_tpc);
    WriteBPC(recovered_bpc);
    _SystemRegisters.core_state = ecstate;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = control[5] == '1';
    _BundleBodyActive = control[6] == '1';
    _BundleKind = PTOv0BundleKindOf(control[10:7]);
    _BundleTransfer = PTOv0BundleTransferOf(control[13:11]);
    _BundleCondition = control[14] == '1';
    _BundleTarget = PTOv0ReadContextRegister(target, 0x0f42);
    _BundleReturnTarget = _TrapContexts[[target]].bundle_return_target;
    _BundleBodyAddress = recovered_bpc;
    _ReturnAddress = PTOv0ReadContextRegister(target, 0x0f44);
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleFallthrough = _TrapContexts[[target]].bundle_fallthrough;
    _BundleOperation = _TrapContexts[[target]].bundle_operation;
    _BundleDimensions = _TrapContexts[[target]].bundle_dimensions;
    _BundleScalarBindings = _TrapContexts[[target]].bundle_scalar_bindings;
    _BundleTileBindings = _TrapContexts[[target]].bundle_tile_bindings;
    _BundleSharedBindings = _TrapContexts[[target]].bundle_shared_bindings;
    _BundleControlAttributes =
        _TrapContexts[[target]].bundle_control_attributes;
    _BundleDataAttributes = _TrapContexts[[target]].bundle_data_attributes;
    _BundleFixedPointAttributes =
        _TrapContexts[[target]].bundle_fixed_point_attributes;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = PTOv0ReadContextRegister(target, 0x0f45 + index);
        _UQueue[[index]] = PTOv0ReadContextRegister(target, 0x0f49 + index);
    end;
    _ExecutionMask = _TrapContexts[[target]].execution_mask;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = UInt(ecstate[3:0]) as AccessControlRing;
    control[4] = '0';
    PTOv0WriteContextRegister(target, 0x0f40, control);
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;

implementation func TileProfileBinary(op: TileBinaryOperation,
                                       data_type: TileDataType,
                                       left: Word, right: Word) => Word
begin
    return TileBinaryValue(op, left, right);
end;

implementation func TileProfileUnary(op: TileUnaryOperation,
                                      data_type: TileDataType,
                                      value: Word) => Word
begin
    return TileUnaryValue(op, value);
end;

implementation func TileProfileCompare(comparison: TileComparison,
                                        data_type: TileDataType,
                                        left: Word, right: Word) => Word
begin
    return TileCompareValue(comparison, left, right);
end;

implementation func TileProfileReductionInitial(
    op: TileReductionOperation, data_type: TileDataType, first: Word) => Word
begin
    return ReductionInitial(op, first);
end;

implementation func TileProfileReductionStep(
    op: TileReductionOperation, data_type: TileDataType,
    accumulator: Word, value: Word) => (Word, boolean)
begin
    case op of
        when TileReduction_SUM => return (accumulator + value, FALSE);
        when TileReduction_PRODUCT =>
            return (MultiplyWord(accumulator, value), FALSE);
        when TileReduction_MIN, TileReduction_ARGMIN =>
            if SInt(value) < SInt(accumulator) then return (value, TRUE);
            else return (accumulator, FALSE);
            end;
        when TileReduction_MAX, TileReduction_ARGMAX =>
            if SInt(value) > SInt(accumulator) then return (value, TRUE);
            else return (accumulator, FALSE);
            end;
    end;
end;

implementation func TileProfileExpand(op: TileExpandOperation,
                                      data_type: TileDataType,
                                      left: Word, broadcast: Word) => Word
begin
    return TileExpandValue(op, left, broadcast);
end;

implementation func TileProfilePartialValue(op: TilePartialOperation,
                                             data_type: TileDataType,
                                             left: Word, right: Word) => Word
begin
    return TilePartialValue(op, left, right);
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
    right_type: TileDataType) => Word
begin
    return accumulator + MultiplyWord(left, right);
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
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, left_scale_type: TileDataType,
    right_scale_type: TileDataType) => Word
begin
    let scaled_left = MultiplyWord(left, left_scale);
    let scaled_right = MultiplyWord(right, right_scale);
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
    let lhs = if max_abs then TileProfileUnary(
        TileUnary_ABS, data_type, current) else current;
    let rhs = if max_abs then TileProfileUnary(
        TileUnary_ABS, data_type, candidate) else candidate;
    let (selected, _) = TileProfileReductionStep(
        TileReduction_MAX, data_type, lhs, rhs);
    return selected;
end;
