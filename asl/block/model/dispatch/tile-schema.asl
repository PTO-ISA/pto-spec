// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","surface":"block","classification":["model","dispatch","tile-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-TILE-MODEL-EXECUTION-UNARY"]}
func BundleTileInstructionOperands(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    var destination_count: integer = 0;
    var source_count: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].destination_valid then
                if destination_count == 0 then
                    operands.destination0 =
                        _BundleTileBindings[[binding]].destination;
                elsif destination_count == 1 then
                    operands.destination1 =
                        _BundleTileBindings[[binding]].destination;
                elsif destination_count == 2 then
                    operands.destination2 =
                        _BundleTileBindings[[binding]].destination;
                else
                    SetFault(Fault_TileLegality, ReadTPC());
                    return operands;
                end;
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                case source_count of
                    when 0 => operands.source0 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 1 => operands.source1 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 2 => operands.source2 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 3 => operands.source3 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 4 => operands.source4 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 5 => operands.source5 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 6 => operands.source6 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    when 7 => operands.source7 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                    otherwise => unreachable;
                end;
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                case source_count of
                    when 0 => operands.source0 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 1 => operands.source1 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 2 => operands.source2 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 3 => operands.source3 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 4 => operands.source4 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 5 => operands.source5 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 6 => operands.source6 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    when 7 => operands.source7 =
                        BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                    otherwise => unreachable;
                end;
                source_count = source_count + 1;
            end;
        end;
    end;
    // B.IOR inputs are resolved in one architectural order so that optional
    // fields pack densely into RegSrc0..RegSrc2.  TLOAD/TSTORE retain their
    // omission-only dense-row stride default.
    if TileOperandPresent(operation, TileOperand_address) then
        if _BundleScalarBindings[[0]].valid then
            operands.address = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_address) as integer {0..2}));
        end;
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        if _BundleScalarBindings[[0]].valid then
            operands.scalar0 = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_scalar0) as integer {0..2}));
        elsif TileOperationOfIndex(operation) == TileOperation_TQUANT ||
              TileOperationOfIndex(operation) == TileOperation_TDEQUANT then
            operands.scalar0 = Zeros{PTO_XLEN} + 0x3f800000;
        elsif TileOperationOfIndex(operation) == TileOperation_TLOAD ||
              TileOperationOfIndex(operation) == TileOperation_TSTORE then
            // Regular TLSU omission derives a byte pitch from the resolved
            // physical column count and transfer data type. TPREFETCH retains
            // its separately owned logical-element stride contract.
            let tstore = TileOperationOfIndex(operation) ==
                TileOperation_TSTORE;
            let columns = BundleDestinationPhysicalColumns(
                tstore, operands.source0);
            operands.scalar0 = TileDenseRowStrideBytes(
                columns,
                TileDataTypeFromEncoding(
                    CurrentBundleTileOperationDataTypeCode()
                        as TileDataTypeEncoding));
        elsif TileOperandPresent(operation, TileOperand_address) then
            operands.scalar0 = _BundleDimensions[[2]];
        end;
    end;
    if TileOperandPresent(operation, TileOperand_scalar1) &&
       _BundleScalarBindings[[0]].valid then
        operands.scalar1 = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(
                BundleOperationGPRInputSlot(
                    operation, TileOperand_scalar1) as integer {0..2}));
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        if _BundleScalarBindings[[0]].valid then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_diagonal) as integer {0..2}));
            // Raw conversion is performed only after the complete-bundle
            // preflight has proved the signed value lies in the ASL domain.
            operands.diagonal = SInt(raw) as integer {-65535..65535};
        end;
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        if _BundleScalarBindings[[0]].valid then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    BundleOperationGPRInputSlot(
                        operation, TileOperand_flag0) as integer {0..2}));
            // Raw booleans accept exactly zero and one; legality is checked
            // before this constrained assignment during bundle commit.
            operands.flag0 = UInt(raw) == 1;
        end;
    end;
    // Matrix post-processing scalar descriptors consume the next dense B.IOR
    // slots after any mathematical scalar controls.  Matrix operations do not
    // currently have scalar0/scalar1 controls, so these are RegSrc0/RegSrc1.
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid &&
       _BundleScalarBindings[[0]].valid then
        var post_slot: integer {0..2} = 0;
        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            operands.post_quant_param = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(post_slot));
            post_slot = (post_slot + 1) as integer {0..2};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            operands.post_lrelu_param = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(post_slot));
        end;
    end;
    let dimension0 = UInt(_BundleDimensions[[0]]);
    let dimension1 = UInt(_BundleDimensions[[1]]);
    let dimension2 = UInt(_BundleDimensions[[2]]);
    if dimension0 <= 65535 then
        operands.natural0 = dimension0 as integer {0..65535};
        if dimension0 != 0 then
            operands.positive0 = dimension0 as integer {1..65535};
        end;
    end;
    if dimension1 <= 65535 then
        operands.natural1 = dimension1 as integer {0..65535};
        if dimension1 != 0 then
            operands.positive1 = dimension1 as integer {1..65535};
        end;
    end;
    if dimension2 >= 1 && dimension2 <= 65535 then
        operands.positive2 = dimension2 as integer {1..65535};
    end;
    if dimension0 <= 262144 then
        operands.byte_count = dimension0 as integer {0..262144};
    end;
    if dimension0 >= 1 && dimension0 <= 64 then
        operands.sort_width = dimension0 as integer {1..64};
    end;
    operands.selected_byte = UInt(_BundleDataAttributes.pad_value)
        as integer {0..3};
    case UInt(_BundleDataAttributes.comparison_mode) of
        when 0 => operands.comparison = TileComparison_EQ;
        when 1 => operands.comparison = TileComparison_NE;
        when 2 => operands.comparison = TileComparison_LT;
        when 3 => operands.comparison = TileComparison_GT;
        when 4 => operands.comparison = TileComparison_LE;
        when 5 => operands.comparison = TileComparison_GE;
        otherwise => operands.comparison = TileComparison_EQ;
    end;
    // Generic boolean operands are operation controls, not aliases of the
    // numeric saturation bit. Numeric consumers receive the separate typed
    // control below; other bundle operations retain their operation default.
    operands.numeric_control = DecodeBundleRoundingSelection(
        _BundleDataAttributes.rounding_mode);
    operands.numeric_control.saturating = _BundleDataAttributes.saturating;
    return operands;
end;

func SelectedBundleTileDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // Inherited/default values are operation inputs, not explicitly encoded
    // nonzero B.DATR fields.  Applicability therefore examines field values
    // only when the optional command was present.
    let explicit_c_mode = if _BundleDataAttributesPresent then
        _BundleDataAttributes.comparison_mode else Zeros{3};
    let explicit_pad = if _BundleDataAttributesPresent then
        _BundleDataAttributes.pad_value else Zeros{2};
    let explicit_saturating = _BundleDataAttributesPresent &&
        _BundleDataAttributes.saturating;
    let explicit_canonicalize = _BundleDataAttributesPresent &&
        _BundleDataAttributes.canonicalize;
    let explicit_data_type = if _BundleDataAttributesPresent then
        _BundleDataAttributes.data_type else Zeros{5};
    let explicit_rounding = if _BundleDataAttributesPresent then
        _BundleDataAttributes.rounding_mode else Zeros{3};
    let explicit_layout = if _BundleDataAttributesPresent then
        _BundleDataAttributes.data_layout else Zeros{5};
    if !TileOperationDATRFieldsLegal(
        operation, explicit_c_mode, explicit_pad, explicit_saturating,
        explicit_canonicalize, explicit_data_type, explicit_rounding,
        explicit_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let datr_legal = if matrix then
        _BundleFixedPointAttributes.valid &&
        BundleFPATRDATRFieldsLegal(
            _BundleFixedPointAttributes.pre_quant_mode,
            _BundleDataAttributes.rounding_mode,
            _BundleDataAttributes.saturating)
    else
        TileOperationDATRFieldsLegal(
            operation,
            explicit_c_mode,
            explicit_pad,
            explicit_saturating,
            explicit_canonicalize,
            explicit_data_type,
            explicit_rounding,
            explicit_layout);
    if !datr_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let decoded_operation = TileOperationOfIndex(operation);
    if (decoded_operation == TileOperation_TLOAD ||
        decoded_operation == TileOperation_TSTORE) &&
       !TileDataLayoutIsCubeConversion(explicit_layout) &&
       explicit_pad != Zeros{2} then
        // PadValue is assigned to the explicit Local CUBE conversion form.
        // Ordinary and Shared TLOAD/TSTORE retain their zero-only union rule.
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _BundleDataAttributesPresent &&
       _BundleDataAttributes.pad_value != Zeros{2} &&
       TileOperationDATRPadUnion(operation) ==
           TileDATRPadUnion_MustZero then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

readonly func SelectedBundleTileMasksLegal() => boolean
begin
    var first_mask = Zeros{4};
    var first_mask_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if first_mask_seen && mask != first_mask then return FALSE; end;
            first_mask = mask;
            first_mask_seen = TRUE;
        end;
    end;
    return TRUE;
end;

readonly func SelectedBundleTileMaskIsZero() => boolean
begin
    var seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            seen = TRUE;
            if _BundleTileBindings[[binding]].pe_mask != Zeros{4} then
                return FALSE;
            end;
        end;
    end;
    return seen || (_BundleZeroParticipationSeen &&
        BundleTileBindingCount() == 0 && BundleSharedBindingCount() == 0);
end;

readonly func BundleTileBindingCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;

pure func TileOperationUsesClosedBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADD ||
           decoded == TileOperation_TSUB ||
           decoded == TileOperation_TMUL ||
           decoded == TileOperation_TDIV ||
           decoded == TileOperation_TREM ||
           decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMIN;
end;

readonly func SelectedBundleClosedBinarySchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedBinarySchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 then
        return FALSE;
    end;
    if !_BundleTileBindings[[0]].destination_valid ||
       _BundleTileBindings[[0]].destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !_BundleTileBindings[[0]].source0_valid ||
       !_BundleTileBindings[[0]].source1_valid ||
       !_BundleTileBindings[[0]].last then return FALSE; end;
    if !_BundleDimensionPresent[[0]] ||
       UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then return FALSE; end;
    for dimension = 1 to 2 looplimit 2 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) < 1 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileVecArithmeticDataTypeSupported(data_type) &&
           CurrentBundleTileLayout() == TileLayout_RowMajor;
end;

pure func TileOperationUsesClosedUnarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TABS ||
           decoded == TileOperation_TNOT ||
           decoded == TileOperation_TNEG ||
           decoded == TileOperation_TRELU;
end;

readonly func SelectedBundleClosedUnarySchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedUnarySchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid || binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid || binding.source1_valid || !binding.last then
        return FALSE;
    end;
    if !_BundleDimensionPresent[[0]] ||
       UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) < 1 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;
    let decoded = TileOperationOfIndex(operation);
    let unary = if decoded == TileOperation_TABS then TileUnary_ABS
                else if decoded == TileOperation_TNOT then TileUnary_NOT
                else if decoded == TileOperation_TNEG then TileUnary_NEG
                else TileUnary_RELU;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileUnaryDataTypeSupported(unary, data_type) &&
           CurrentBundleTileLayout() == TileLayout_RowMajor;
end;

pure func TileOperationUsesClosedTFMASchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TFMA;
end;

readonly func SelectedBundleClosedTFMASchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTFMASchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 2 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid then
        return FALSE;
    end;

    let multiplicands = _BundleTileBindings[[0]];
    let result = _BundleTileBindings[[1]];
    if multiplicands.destination_valid ||
       !multiplicands.source0_valid ||
       !multiplicands.source1_valid ||
       multiplicands.last then
        return FALSE;
    end;
    if !result.destination_valid ||
       result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(1) ||
       !result.source0_valid ||
       result.source1_valid ||
       !result.last then
        return FALSE;
    end;
    if !_BundleDimensionPresent[[0]] ||
       UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) < 1 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileFusedMultiplyAddDataTypeSupported(data_type) &&
           CurrentBundleTileLayout() == TileLayout_RowMajor;
end;

readonly func BundleLocalTileSourceCount() => integer {0..32}
begin
    var count: integer {0..32} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                count = (count + 1) as integer {0..32};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                count = (count + 1) as integer {0..32};
            end;
        end;
    end;
    return count;
end;

readonly func BundleLocalTileDestinationCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;

readonly func BundleTileBindingStreamTerminated() => boolean
begin
    var binding_count: integer {0..16} = 0;
    var seen_last = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if seen_last then return FALSE; end;
            binding_count = (binding_count + 1) as integer {0..16};
            if _BundleTileBindings[[binding]].last then
                seen_last = TRUE;
            end;
        end;
    end;
    return binding_count > 0 && seen_last;
end;
