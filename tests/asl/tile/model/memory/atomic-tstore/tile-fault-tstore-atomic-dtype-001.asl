// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-DTYPE-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ATOM-RED-TYPE-LEGALITY-001"],"kind":"fault","summary":"Atomic TSTORE enforces the complete GM reduction dtype matrix","pass_condition":"an independent 8-by-all-assigned-dtypes oracle matches GMReductionOperationDataTypeLegal, every admitted operation/type pair executes through encoded Function 1 with one Atomic event and exact result, and representative excluded pairs reject without effects","related_sources":["asl/tile/model/memory/gm-atom-red.asl","asl/tile/model/memory/atomic-tstore.asl"]}

pure func AtomicDTypeMatrixExpected(mode: integer {0..7},
                                    encoding: integer {0..31}) => boolean
begin
    if mode == 0 then
        return encoding == 0 || encoding == 1 || encoding == 4 ||
               encoding == 5 || encoding == 17 || encoding == 24 ||
               encoding == 25;
    elsif mode == 1 || mode == 2 then
        return encoding == 16 || encoding == 17 || encoding == 24 ||
               encoding == 25;
    elsif mode >= 3 && mode <= 5 then
        return encoding == 24 || encoding == 25;
    end;
    return encoding == 25;
end;

func CheckAtomicDTypeMatrix()
begin
    for mode = 0 to 7 do
        for encoding = 0 to 28 do
            let code = Zeros{5} + encoding;
            if TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
                let data_type = TileDataTypeFromEncoding(
                    code as TileDataTypeEncoding);
                let expected = AtomicDTypeMatrixExpected(mode, encoding);
                let actual = GMReductionOperationDataTypeLegal(
                    GMReductionOperationForTStoreMode(
                        (Zeros{3} + mode) as bits(3)), data_type);
                assert actual == expected;
            end;
        end;
    end;
end;

pure func AtomicDTypeStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func AtomicDTypeDATR(mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = mode;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func AtomicDTypeSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicDTypeAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunAtomicDType(mode: bits(3), data_type: TileDataType,
                    initial: Word, input: Word, expected: Word,
                    should_complete: boolean) => boolean
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, input);
    let bytes = TileMemoryElementBytes(data_type);
    let target = Zeros{PTO_XLEN} + 0x280;
    Store(target, bytes, initial);
    WriteGPR(2, target);
    WriteGPR(3, Zeros{PTO_XLEN} + bytes);
    let start = ExecuteCommandInstruction(AtomicDTypeStart(data_type), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let datr = ExecuteCommandInstruction(AtomicDTypeDATR(mode), 32);
    let binding = ExecuteCommandInstruction(AtomicDTypeSource(), 32);
    let address = ExecuteCommandInstruction(AtomicDTypeAddress(), 32);
    let setup_valid = start == CommandExecution_Executed &&
        datr == CommandExecution_Executed &&
        binding == CommandExecution_Executed &&
        address == CommandExecution_Executed &&
        BundleTileBindingCount() == 1 &&
        _BundleOperation.selector[4:0] == Zeros{5} + 1;
    if !setup_valid then return FALSE; end;
    let (type_valid, resolved_type) = ResolveBundleEffectiveDataType();
    let selected_type_valid = BundleAtomicTStoreSelected() && type_valid &&
        resolved_type == data_type &&
        TileRegularTLSUDataTypeSupported(data_type);
    if !selected_type_valid then return FALSE; end;
    let reduction = GMReductionOperationForTStoreMode(mode);
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let binding_schema_valid = BundleOperationBindingsComplete(operation) &&
        BundleOperationGPRBindingValuesLegal(operation) &&
        BundleExecutionMaskDataAttributesLegal(operation);
    if !binding_schema_valid then return FALSE; end;
    let type_matrix_matches =
        GMReductionOperationDataTypeLegal(reduction, data_type) ==
        should_complete;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    if should_complete then
        if !completed || _LastFault != Fault_None ||
           _MemoryEventCount != 1 then
            StopMemoryEventCapture();
            return FALSE;
        end;
        let event = _MemoryEvents[[0 as MemoryEventIndex]];
        let event_valid = event.active && event.committed &&
            event.kind == MemoryEvent_Atomic && event.address == target;
        StopMemoryEventCapture();
        let actual = LoadUnsigned(target, bytes);
        return type_matrix_matches && event_valid && actual == expected;
    else
        let rejected = !completed && _LastFault == Fault_TileLegality &&
            _MemoryEventCount == 0;
        StopMemoryEventCapture();
        let actual = LoadUnsigned(target, bytes);
        return type_matrix_matches && rejected && actual == initial;
    end;
end;

func main() => integer
begin
    CheckAtomicDTypeMatrix();

    // Every admitted operation/type pair executes through encoded Function 1.
    let fp32_add = RunAtomicDType('000', TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN} + 0x40000000,
        Zeros{PTO_XLEN} + 0x40400000, TRUE);
    assert fp32_add;
    let fp16_add = RunAtomicDType('000', TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN} + 0x3c00,
        Zeros{PTO_XLEN} + 0x4000, TRUE);
    assert fp16_add;
    let bf16_add = RunAtomicDType('000', TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN} + 0x3f80,
        Zeros{PTO_XLEN} + 0x4000, TRUE);
    assert bf16_add;
    let fp64_add = RunAtomicDType('000', TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x3ff00000_00000000,
        Zeros{PTO_XLEN} + 0x3ff00000_00000000,
        Zeros{PTO_XLEN} + 0x40000000_00000000, TRUE);
    assert fp64_add;
    let s32_add = RunAtomicDType('000', TileDataType_S32,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert s32_add;
    let u32_add = RunAtomicDType('000', TileDataType_U32,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert u32_add;
    let u64_add = RunAtomicDType('000', TileDataType_U64,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert u64_add;

    let s32_min = RunAtomicDType('001', TileDataType_S32,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert s32_min;
    let s64_min = RunAtomicDType('001', TileDataType_S64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert s64_min;
    let u32_min = RunAtomicDType('001', TileDataType_U32,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert u32_min;
    let u64_min = RunAtomicDType('001', TileDataType_U64,
        Zeros{PTO_XLEN} + 0x30, Zeros{PTO_XLEN} + 0x0f,
        Zeros{PTO_XLEN} + 0x0f, TRUE);
    assert u64_min;
    let s32_max = RunAtomicDType('010', TileDataType_S32,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert s32_max;
    let s64_max = RunAtomicDType('010', TileDataType_S64,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert s64_max;
    let u32_max = RunAtomicDType('010', TileDataType_U32,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert u32_max;
    let u64_max = RunAtomicDType('010', TileDataType_U64,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert u64_max;

    let u32_and = RunAtomicDType('011', TileDataType_U32,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert u32_and;
    let u64_and = RunAtomicDType('011', TileDataType_U64,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1, TRUE);
    assert u64_and;
    let u32_or = RunAtomicDType('100', TileDataType_U32,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 3, TRUE);
    assert u32_or;
    let u64_or = RunAtomicDType('100', TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 3, TRUE);
    assert u64_or;
    let u32_xor = RunAtomicDType('101', TileDataType_U32,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert u32_xor;
    let u64_xor = RunAtomicDType('101', TileDataType_U64,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert u64_xor;

    let u32_inc = RunAtomicDType('110', TileDataType_U32,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 5, TRUE);
    assert u32_inc;
    let u32_dec = RunAtomicDType('111', TileDataType_U32,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 3, TRUE);
    assert u32_dec;

    // Existing matrix excludes FP32 MIN/MAX and signed 64-bit ADD.
    let fp32_min_rejected = RunAtomicDType('001', TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN} + 0x40000000,
        Zeros{PTO_XLEN} + 0x3f800000, FALSE);
    assert fp32_min_rejected;
    let fp32_max_rejected = RunAtomicDType('010', TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN} + 0x40000000,
        Zeros{PTO_XLEN} + 0x40000000, FALSE);
    assert fp32_max_rejected;
    let s64_add_rejected = RunAtomicDType('000', TileDataType_S64,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 5, FALSE);
    assert s64_add_rejected;
    return 0;
end;
