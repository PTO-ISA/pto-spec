// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","surface":"tile","classification":["model","execution","predicate-carriers"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-MASK","PTO-TILE-MODEL-STATE-ALLOCATION","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
// PTO-REQ-TEPL-PREDICATE-CARRIER-001: CUBE predicate carriers and explicit ExecutionMask.
// Eligible Local CUBE_M16/CUBE_M32 TileOps use an explicit ExecutionMask
// operand represented either by the existing one/two-word GPR mapping or by a
// canonical U8 TileStorage_PredicateCell with 0x00/0x01 values. PredicateCell
// consumer compatibility uses logical layout and valid rows and columns;
// generic ExecutionMask consumption MUST NOT require the producer's
// predicate_basis_type to equal the consumer operation type. Generic GPR
// binding schemas use TileOperationExecutionMaskEligible as the exact 91-op
// applicability set, excluding reductions, contractions, GMOV, and TPREFETCH.
// The carrier is
// snapshotted before an overlapping predicate destination is allocated or
// published. Effective activity is PE_MASK[pe] AND (mask_bit XOR PredInv),
// with PredInv and inactive ZERO/MERGE selected by B.DATR. Inactive effects
// MUST not read element-only source payloads, contribute numeric status, probe
// or fault on memory, or modify a destination except to preserve its old value
// (MERGE) or write zero (ZERO). No implicit mask state, packed-i1 storage,
// P0..P7 consumption, or mask stack is introduced.

readonly func TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
    source: TileIndex, scalar: Word, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    if !TileCubePredicateGPRDataTypeSupported(operation_type) ||
       !TileCubePredicateGPRShapeLegalAs(source, operation_type) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    return TileCubeNumericSourceLegalAs(source, operation_type) &&
           TileNumericEncodingValid(
               operation_type, TileRawElementValue(scalar, operation_type));
end;
readonly func TileOperandsLegal_ExecuteTileCompareCUBEScalarGPR(
    source: TileIndex, scalar: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
               source, scalar, operation_type);
end;

readonly func TileOperandsLegal_ExecuteTileSelectCUBEGPRAs(
    destination: TileIndex, source_true: TileIndex, source_false: TileIndex,
    operation_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, operation_type) &&
           TileCubeNumericShapeMatch(source_true, source_false) &&
           TileCubeNumericContentsDefined(source_true) &&
           TileCubeNumericContentsDefined(source_false) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_true]].data_type, operation_type) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_false]].data_type, operation_type) &&
           TileCubeDescriptorLegal(_Tiles[[destination]]) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].data_type == operation_type &&
           TileCubeNumericShapeMatch(destination, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileSelectCUBEGPR(
    destination: TileIndex, source_true: TileIndex, source_false: TileIndex)
    => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileSelectCUBEGPRAs(
               destination, source_true, source_false, operation_type);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAs(
    destination: TileIndex, source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, operation_type) &&
           TileCubeNumericContentsDefined(source_true) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_true]].data_type, operation_type) &&
           TileCubeDescriptorLegal(_Tiles[[destination]]) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].data_type == operation_type &&
           TileCubeNumericShapeMatch(destination, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalarCUBEGPR(
    destination: TileIndex, source_true: TileIndex, scalar_false: Word)
    => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAs(
               destination, source_true, scalar_false, operation_type);
end;

func TileCompareCUBEScalarToGPRAs(source: TileIndex, scalar: Word,
                                  comparison: TileComparison,
                                  high: boolean,
                                  operation_type: TileDataType) => Word
begin
    assert TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
        source, scalar, operation_type);
    let tile = _Tiles[[source]];
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    let rows = TileCubePredicateRowBits(tile.layout);
    let fields = TileCubePredicateFieldCount(operation_type, tile.layout);
    let base = TileCubePredicateColumnBase(operation_type, tile.layout, high);
    var result = TilePredicateGPRPaddingValue();
    var flags = Zeros{5};
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < tile.valid_columns then
            for row = 0 to rows - 1 looplimit 32 do
                if row < tile.valid_rows &&
                   BundleExecutionMaskActiveAt(
                       tile.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let (predicate, element_flags) = TileCompareElement(
                        comparison, operation_type,
                        TileReadLogicalElement(tile, element),
                        normalized_scalar);
                    flags = flags OR element_flags;
                    result[row + field * rows] = if predicate then '1' else '0';
                end;
            end;
        end;
    end;
    RecordNumericStatusFlags(flags);
    return result;
end;
func TileCompareCUBEScalarToGPR(source: TileIndex, scalar: Word,
                                comparison: TileComparison,
                                high: boolean) => Word
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    assert operation_type_valid;
    return TileCompareCUBEScalarToGPRAs(
        source, scalar, comparison, high, operation_type);
end;

func TileExecutionMaskPredicateGPRResult(
    result: Word, old_value: Word, data_type: TileDataType,
    layout: TileLayout, valid_rows: integer {1..65535},
    valid_columns: integer {1..65535}, high: boolean) => Word
begin
    if !_BundleExecutionMask.valid then return result; end;
    var masked = result;
    let rows = TileCubePredicateRowBits(layout);
    let fields = TileCubePredicateFieldCount(data_type, layout);
    let base = TileCubePredicateColumnBase(data_type, layout, high);
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < valid_columns then
            for row = 0 to rows - 1 looplimit 32 do
                if row < valid_rows &&
                   !BundleExecutionMaskActiveAt(
                       layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let bit_index = (row + field * rows)
                        as integer {0..63};
                    masked[bit_index] = if _BundleExecutionMask.zero_inactive
                        then '0' else old_value[bit_index];
                end;
            end;
        end;
    end;
    return masked;
end;

func ExecuteTileSelectCUBEGPRAs(destination: TileIndex, mask_low: Word,
                                mask_high: Word, source_true: TileIndex,
                                source_false: TileIndex,
                                operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileSelectCUBEGPRAs(
        destination, source_true, source_false, operation_type);
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    var result = _Tiles[[destination]];
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   true_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let selected = TileCubePredicateGPRBit(
                    mask_low, mask_high, true_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
                value = if selected then
                    TileReadLogicalElement(true_tile, element)
                    else TileReadLogicalElement(false_tile, element);
            else
                value = BundleExecutionMaskDestinationValue(
                    true_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(result, element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelectCUBEGPR(destination: TileIndex, mask_low: Word,
                              mask_high: Word, source_true: TileIndex,
                              source_false: TileIndex)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    assert operation_type_valid;
    ExecuteTileSelectCUBEGPRAs(
        destination, mask_low, mask_high, source_true, source_false,
        operation_type);
end;

func ExecuteTileSelectScalarCUBEGPRAs(
    destination: TileIndex, mask_low: Word, mask_high: Word,
    source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAs(
        destination, source_true, scalar_false, operation_type);
    let true_tile = _Tiles[[source_true]];
    let normalized_scalar = TileRawElementValue(scalar_false,
        operation_type);
    var result = _Tiles[[destination]];
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   true_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let selected = TileCubePredicateGPRBit(
                    mask_low, mask_high, true_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
                value = if selected then
                    TileReadLogicalElement(true_tile, element)
                    else normalized_scalar;
            else
                value = BundleExecutionMaskDestinationValue(
                    true_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(result, element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelectScalarCUBEGPR(destination: TileIndex, mask_low: Word,
                                    mask_high: Word, source_true: TileIndex,
                                    scalar_false: Word)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    assert operation_type_valid;
    ExecuteTileSelectScalarCUBEGPRAs(
        destination, mask_low, mask_high, source_true, scalar_false,
        operation_type);
end;

pure func TileTGPR2TEncodingLegal(mask: integer, match: integer) => boolean
begin
    return mask == 0x000fffff && match == 0x07e19181;
end;

pure func TileTGPR2TRModeLegal(raw_rmode: bits(3)) => boolean
begin
    return raw_rmode[2] == '0';
end;

pure func TileTGPR2TByteOffset(raw_rmode: bits(3)) => integer {0..3}
begin
    assert TileTGPR2TRModeLegal(raw_rmode);
    return UInt(raw_rmode[1:0]) as integer {0..3};
end;

readonly func TileTGPR2TEffectivePadValue() => TilePadValue
begin
    return if _BundleDataAttributesPresent then CurrentBundlePadValue()
        else TilePad_Zero;
end;

readonly func TileTGPR2TPadLegal() => boolean
begin
    let pad = TileTGPR2TEffectivePadValue();
    return pad == TilePad_Zero || pad == TilePad_Max;
end;

pure func TileTGPR2TPredicateBit(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    plane: integer {0..15}, row: integer {0..31}) => bit
begin
    // M32 packs two 32-bit predicate planes per complete 64-bit GPR.
    assert row < 32;
    let word = plane DIVRM 2;
    let half = plane MOD 2;
    let within = half * 32 + row;
    if word == 0 then return gpr0[within]; end;
    if word == 1 then return gpr1[within]; end;
    if word == 2 then return gpr2[within]; end;
    return gpr3[within];
end;

pure func TileTGPR2TPredicateBitM16(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    plane: integer {0..15}, row: integer {0..15}) => bit
begin
    // M16 packs four 16-bit predicate planes per complete 64-bit GPR.
    let word = plane DIVRM 4;
    let quarter = plane MOD 4;
    let within = quarter * 16 + row;
    if word == 0 then return gpr0[within]; end;
    if word == 1 then return gpr1[within]; end;
    if word == 2 then return gpr2[within]; end;
    return gpr3[within];
end;

pure func TileTGPR2TPackedRowByte(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    row: integer {0..31}) => bits(8)
begin
    var result = Zeros{8};
    for bit_index = 0 to 7 looplimit 8 do
        result[bit_index] = TileTGPR2TPredicateBit(
            gpr0, gpr1, gpr2, gpr3, bit_index as integer {0..15}, row);
    end;
    return result;
end;

pure func TileTGPR2TPackedRowHalf(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    row: integer {0..15}, high: boolean) => bits(8)
begin
    var result = Zeros{8};
    let plane_base = if high then 8 else 0;
    for bit_index = 0 to 7 looplimit 8 do
        let plane = (plane_base + bit_index) as integer {0..15};
        result[bit_index] = TileTGPR2TPredicateBitM16(
            gpr0, gpr1, gpr2, gpr3, plane, row);
    end;
    return result;
end;

readonly func TileOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    if source0 >= PTO_ABSOLUTE_GPR_COUNT ||
       source1 >= PTO_ABSOLUTE_GPR_COUNT ||
       source2 >= PTO_ABSOLUTE_GPR_COUNT ||
       source3 >= PTO_ABSOLUTE_GPR_COUNT ||
       !TileCubeDescriptorLegal(_Tiles[[destination]]) ||
       _Tiles[[destination]].storage_kind != TileStorage_Numeric ||
       _Tiles[[destination]].data_type != TileDataType_U8 ||
       !TileLayoutIsCube(_Tiles[[destination]].layout) ||
       !TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) ||
       !TileTGPR2TPadLegal() then
        return FALSE;
    end;
    let tile = _Tiles[[destination]];
    return (tile.layout == TileLayout_CUBE_M32 &&
            tile.valid_rows == 32 && tile.valid_columns == 4) ||
           (tile.layout == TileLayout_CUBE_M16 &&
            tile.valid_rows == 16 && tile.valid_columns == 8);
end;

func TGPR2T(destination: TileIndex, source0: TileIndex, source1: TileIndex,
            source2: TileIndex, source3: TileIndex)
begin
    assert TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    let gpr0 = ReadGPR(source0 as GPRIndex);
    let gpr1 = ReadGPR(source1 as GPRIndex);
    let gpr2 = ReadGPR(source2 as GPRIndex);
    let gpr3 = ReadGPR(source3 as GPRIndex);
    let selected_pad = TileTGPR2TEffectivePadValue();
    var result = TileWithPadding(_Tiles[[destination]], selected_pad);
    let pad = TilePadValueForDataType(selected_pad,
        result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 32 do
        for column = 0 to result.valid_columns - 1 looplimit 8 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let value = if BundleExecutionMaskActiveAt(
                result.layout, row as integer {0..65535},
                column as integer {0..65535}) then pad else
                BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            result = TileInfoWithLogicalElementAndDefined(
                result, index, value, TRUE);
        end;
    end;
    let offset = TileTGPR2TByteOffset(
        _BundleDataAttributes.rounding_mode);
    if result.layout == TileLayout_CUBE_M32 then
        for row = 0 to 31 looplimit 32 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, offset);
            var value = Zeros{PTO_XLEN};
            value[7:0] = TileTGPR2TPackedRowByte(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..31});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535}, offset) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, index, value, TRUE);
            end;
        end;
    else
        for row = 0 to 15 looplimit 16 do
            let pair_start = (offset * 2) as integer {0..6};
            let low = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start);
            let high = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start + 1);
            var low_value = Zeros{PTO_XLEN};
            low_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, FALSE);
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   pair_start) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, low, low_value, TRUE);
            end;
            var high_value = Zeros{PTO_XLEN};
            high_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, TRUE);
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   pair_start + 1) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, high, high_value, TRUE);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    _Tiles[[destination]] = result;
end;

pure func TileOperationExecutionMaskEligible(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return            decoded == TileOperation_MGATHER || decoded == TileOperation_MGATHER_ADD || decoded == TileOperation_MGATHER_AND || decoded == TileOperation_MGATHER_CAS || decoded == TileOperation_MGATHER_DEC ||
           decoded == TileOperation_MGATHER_EXCH || decoded == TileOperation_MGATHER_INC || decoded == TileOperation_MGATHER_MASK || decoded == TileOperation_MGATHER_MAX || decoded == TileOperation_MGATHER_MIN ||
           decoded == TileOperation_MGATHER_OR || decoded == TileOperation_MGATHER_XOR || decoded == TileOperation_MSCATTER || decoded == TileOperation_MSCATTER_ADD || decoded == TileOperation_MSCATTER_AND ||
           decoded == TileOperation_MSCATTER_DEC || decoded == TileOperation_MSCATTER_INC || decoded == TileOperation_MSCATTER_MASK || decoded == TileOperation_MSCATTER_MAX || decoded == TileOperation_MSCATTER_MIN ||
           decoded == TileOperation_MSCATTER_OR || decoded == TileOperation_MSCATTER_POPC || decoded == TileOperation_MSCATTER_XOR || decoded == TileOperation_TABS || decoded == TileOperation_TADD ||
           decoded == TileOperation_TADDS || decoded == TileOperation_TAND || decoded == TileOperation_TANDS || decoded == TileOperation_TCI || decoded == TileOperation_TCMP ||
           decoded == TileOperation_TCMPS || decoded == TileOperation_TCOLEXPAND || decoded == TileOperation_TCOLEXPANDADD || decoded == TileOperation_TCOLEXPANDDIV || decoded == TileOperation_TCOLEXPANDEXPDIF ||
           decoded == TileOperation_TCOLEXPANDMAX || decoded == TileOperation_TCOLEXPANDMIN || decoded == TileOperation_TCOLEXPANDMUL || decoded == TileOperation_TCOLEXPANDSUB || decoded == TileOperation_TCVT ||
           decoded == TileOperation_TDIV || decoded == TileOperation_TDIVS || decoded == TileOperation_TEXP || decoded == TileOperation_TEXPANDS || decoded == TileOperation_TFMA ||
           decoded == TileOperation_TGATHER || decoded == TileOperation_TGPR2T || decoded == TileOperation_TLOAD || decoded == TileOperation_TLOG || decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMAXS || decoded == TileOperation_TMIN || decoded == TileOperation_TMINS || decoded == TileOperation_TMOV || decoded == TileOperation_TMUL ||
           decoded == TileOperation_TMULS || decoded == TileOperation_TNEG || decoded == TileOperation_TNOT || decoded == TileOperation_TOR || decoded == TileOperation_TORS ||
           decoded == TileOperation_TPACK || decoded == TileOperation_TPERMUTE || decoded == TileOperation_TRECIP || decoded == TileOperation_TRELU || decoded == TileOperation_TREM ||
           decoded == TileOperation_TREMS || decoded == TileOperation_TROWEXPAND || decoded == TileOperation_TROWEXPANDADD || decoded == TileOperation_TROWEXPANDDIV || decoded == TileOperation_TROWEXPANDEXPDIF ||
           decoded == TileOperation_TROWEXPANDMAX || decoded == TileOperation_TROWEXPANDMIN || decoded == TileOperation_TROWEXPANDMUL || decoded == TileOperation_TROWEXPANDSUB || decoded == TileOperation_TRSQRT ||
           decoded == TileOperation_TSCATTER || decoded == TileOperation_TSEL || decoded == TileOperation_TSELS || decoded == TileOperation_TSHL || decoded == TileOperation_TSHLS ||
           decoded == TileOperation_TSHR || decoded == TileOperation_TSHRS || decoded == TileOperation_TSHUF || decoded == TileOperation_TSQRT || decoded == TileOperation_TSTORE ||
           decoded == TileOperation_TSUB || decoded == TileOperation_TSUBS || decoded == TileOperation_TTRI || decoded == TileOperation_TUNPACK || decoded == TileOperation_TXOR ||
           decoded == TileOperation_TXORS;
end;
