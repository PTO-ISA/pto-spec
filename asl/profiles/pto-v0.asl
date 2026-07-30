// PTO-REQ-PROFILE-001: concrete PTO v0 reference profile for every registered
// numeric, memory, time, reset, and access-control-ring boundary.

implementation func ResetProfileState()
begin
    for index = 0 to PTO_ABSOLUTE_GPR_COUNT - 1 do
        _GPR[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = Zeros{PTO_XLEN};
        _UQueue[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        _PredicateRegisters[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_MODEL_MEMORY_BYTES - 1 do
        _Memory[[index]] = Zeros{8};
    end;
    // Only 0x0f00..0x0fb7 is architecturally defined by the current extended
    // system-register catalog; the larger array is verification backing.
    for index = 0x0f00 to 0x0fb7 do
        _ExtendedSystemRegisters[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        _Tiles[[index]].allocated = FALSE;
        _Tiles[[index]].contents_defined = FALSE;
        _Tiles[[index]].capacity_bytes = 0;
        _Tiles[[index]].rows = 0;
        _Tiles[[index]].columns = 0;
        _Tiles[[index]].valid_rows = 0;
        _Tiles[[index]].valid_columns = 0;
        _Tiles[[index]].data_type = TileDataType_U64;
        _Tiles[[index]].layout = TileLayout_RowMajor;
        _Tiles[[index]].location = TileLocation_Any;
    end;
    _Accumulator.live = FALSE;
    _Accumulator.logical_data_type = TileDataType_U64;
    _Accumulator.info.allocated = FALSE;
    _Accumulator.info.contents_defined = FALSE;
    _Accumulator.info.capacity_bytes = 0;
    _Accumulator.info.rows = 0;
    _Accumulator.info.columns = 0;
    _Accumulator.info.valid_rows = 0;
    _Accumulator.info.valid_columns = 0;
    _Accumulator.info.data_type = TileDataType_U64;
    _Accumulator.info.layout = TileLayout_RowMajor;
    _Accumulator.info.location = TileLocation_Any;
    _PC = Zeros{PTO_XLEN};
    _BPC = Zeros{PTO_XLEN};
    _BlockActive = FALSE;
    _BlockBodyActive = FALSE;
    ResetBlockControlState();
    _ReturnAddress = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _ReservationValid = FALSE;
    _ReservationAddress = Zeros{PTO_XLEN};
    _ReservationSize = 1;
    ResetMemoryExecution();
    _LastFencePredecessor = Zeros{4};
    _LastFenceSuccessor = Zeros{4};
    _DataCacheEpoch = 0;
    _InstructionCacheEpoch = 0;
    _BlockCacheEpoch = 0;
    _TLBEpoch = 0;
    _BlockHintEpoch = 0;
    _ArchitectureRequestEpoch = 0;
    _LastControlRequest = ExecutionControl_SendEvent;
    _ControlRequestOperand = Zeros{PTO_XLEN};
    _BreakpointTag = Zeros{5};
    for ring = 0 to PTO_ACR_COUNT - 1 do
        _ACRTrapAsynchronous[[ring]] = FALSE;
        _ACRTrapArgumentValid[[ring]] = FALSE;
        _ACRTrapCause[[ring]] = Zeros{24};
        _ACRTrapNumber[[ring]] = Zeros{6};
        _ACRTrapArgument0[[ring]] = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].valid = FALSE;
        _TrapContexts[[ring]].source_acr = 0;
        _TrapContexts[[ring]].tpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].core_state = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].block_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].commit_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].block_active = FALSE;
        _TrapContexts[[ring]].block_body_active = FALSE;
        for queue_index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
            _TrapContexts[[ring]].t_queue[[queue_index]] = Zeros{PTO_XLEN};
            _TrapContexts[[ring]].u_queue[[queue_index]] = Zeros{PTO_XLEN};
        end;
        _TrapContexts[[ring]].accumulator = _Accumulator;
    end;
    _SystemRegisters.thread_ptr = Zeros{PTO_XLEN};
    _SystemRegisters.global_ptr = Zeros{PTO_XLEN};
    _SystemRegisters.core_state = Zeros{PTO_XLEN};
    _SystemRegisters.core_id = Zeros{PTO_XLEN};
    _SystemRegisters.thread_id = Zeros{PTO_XLEN};
    _SystemRegisters.vendor = Zeros{PTO_XLEN};
    _SystemRegisters.version = Zeros{PTO_XLEN} + 1;
    _SystemRegisters.core_feature = Zeros{PTO_XLEN};
    _SystemRegisters.core_feature_enable = Zeros{PTO_XLEN};
    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} +
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    _SystemRegisters.blocknum = Zeros{PTO_XLEN};
    _SystemRegisters.blockid = Zeros{PTO_XLEN};
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
    _CurrentACR = 0;
    ClearFault();
end;

readonly implementation func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // Base registers are available at every level. Context, translation, and
    // debug register families are ACR0-only in the PTO v0 profile.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;

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
                                           rounding_mode: bits(3),
                                           source_type: bits(5),
                                           left: Word, right: Word)
                                           => (Word, bits(5))
begin
    assert UInt(rounding_mode) <= 4;
    assert ScalarFPTypeCodeSupported(source_type);
    case operation of
        when FloatingBinary_ADD => return (left + right, Zeros{5});
        when FloatingBinary_SUB => return (left - right, Zeros{5});
        when FloatingBinary_MUL => return (MultiplyWord(left, right), Zeros{5});
        when FloatingBinary_DIV =>
            if IsZero(right) then return (Ones{PTO_XLEN}, Zeros{5} + 2);
            else return (DivideWordUnsigned(left, right), Zeros{5});
            end;
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
                                          rounding_mode: bits(3),
                                          source_type: bits(5), value: Word)
                                          => (Word, bits(5))
begin
    assert UInt(rounding_mode) <= 4;
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
            if IsZero(value) then return (Ones{PTO_XLEN}, Zeros{5} + 2);
            else return (DivideWordUnsigned(Ones{PTO_XLEN}, value), Zeros{5});
            end;
    end;
end;

implementation func ScalarFPFusedProfile(operation: FloatingFusedOperation,
                                          rounding_mode: bits(3),
                                          source_type: bits(5), addend: Word,
                                          left: Word, right: Word)
                                          => (Word, bits(5))
begin
    assert UInt(rounding_mode) <= 4;
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
    rounding_mode: bits(3), destination_type: bits(5),
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert UInt(rounding_mode) <= 4;
    assert ScalarIntegerTypeCodeSupported(destination_type);
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

implementation func ScalarFPConvertProfile(
    rounding_mode: bits(3), destination_type: bits(5),
    source_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert UInt(rounding_mode) <= 4;
    assert ScalarFPTypeCodeSupported(destination_type);
    assert ScalarFPTypeCodeSupported(source_type);
    return (value, Zeros{5});
end;

implementation func ScalarIntegerToFPProfile(
    rounding_mode: bits(3), source_type: bits(5),
    destination_type: bits(5), value: Word) => (Word, bits(5))
begin
    assert UInt(rounding_mode) <= 4;
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
                                        destination_type: TileDataType) => Word
begin
    if !TileDataTypeIsFloating(destination_type) then
        return NormalizeTileInteger(value, destination_type);
    end;
    return value;
end;

implementation func TileProfileQuantize(value: Word, scale: Word,
                                         zero_point: Word,
                                         source_type: TileDataType,
                                         destination_type: TileDataType) => Word
begin
    assert !IsZero(scale);
    return NormalizeTileInteger(DivideWordUnsigned(value, scale) + zero_point,
        destination_type);
end;

implementation func TileProfileDequantize(value: Word, scale: Word,
                                           zero_point: Word,
                                           source_type: TileDataType,
                                           destination_type: TileDataType) => Word
begin
    return MultiplyWord(value - zero_point, scale);
end;

readonly implementation func AtomicAddress(address: Word,
                                            far: boolean) => Word
begin
    return address;
end;

implementation func TranslateDataAddress(address: Word,
                                         size_bytes: integer {1..262144},
                                         write: boolean) => Word
begin
    return address;
end;

implementation func DataAccessPermitted(address: Word,
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
    _TrapContexts[[target]].block_argument = _BlockArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].block_active = _BlockActive;
    _TrapContexts[[target]].block_body_active = _BlockBodyActive;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TrapContexts[[target]].t_queue[[index]] = _TQueue[[index]];
        _TrapContexts[[target]].u_queue[[index]] = _UQueue[[index]];
    end;
    _TrapContexts[[target]].accumulator = _Accumulator;
end;

implementation func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    if !_TrapContexts[[target]].valid then
        return FALSE;
    end;
    WriteTPC(_TrapContexts[[target]].tpc);
    WriteBPC(_TrapContexts[[target]].bpc);
    _SystemRegisters.core_state = _TrapContexts[[target]].core_state;
    _BlockArgument = _TrapContexts[[target]].block_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BlockActive = _TrapContexts[[target]].block_active;
    _BlockBodyActive = _TrapContexts[[target]].block_body_active;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = _TrapContexts[[target]].t_queue[[index]];
        _UQueue[[index]] = _TrapContexts[[target]].u_queue[[index]];
    end;
    _Accumulator = _TrapContexts[[target]].accumulator;
    _CurrentACR = _TrapContexts[[target]].source_acr;
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

implementation func TileProfileAxpy(destination_value: Word,
                                     source_value: Word, scalar: Word,
                                     data_type: TileDataType) => Word
begin
    return destination_value + MultiplyWord(scalar, source_value);
end;

implementation func TileProfilePReLU(value: Word, negative_slope: Word,
                                     data_type: TileDataType) => Word
begin
    if SInt(value) < 0 then
        return MultiplyWord(value, negative_slope);
    else
        return value;
    end;
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
