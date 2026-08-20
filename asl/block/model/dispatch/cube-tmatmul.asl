// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL","surface":"block","classification":["model","dispatch","cube-tmatmul"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS","PTO-TILE-MODEL-EXECUTION-CUBE"]}

readonly func BundleCubeMatrixSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMatrix &&
           _BundleOperation.selector_valid &&
           TileMatrixFunctionAssigned(
               UInt(_BundleOperation.selector[4:0]));
end;

readonly func BundleTMATMULDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent then return TRUE; end;
    return _BundleDataAttributes.data_layout == Zeros{5} &&
           _BundleDataAttributes.pad_value == Zeros{2} &&
           _BundleDataAttributes.comparison_mode == Zeros{3} &&
           !_BundleDataAttributes.canonicalize;
end;

readonly func BundleTMATMULMasksAgree() => boolean
begin
    var seen = FALSE;
    var selected = Zeros{4};
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if seen && mask != selected then return FALSE; end;
            selected = mask;
            seen = TRUE;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid then
            let mask = _BundleSharedBindings[[binding]].pe_mask;
            if seen && mask != selected then return FALSE; end;
            selected = mask;
            seen = TRUE;
        end;
    end;
    return seen;
end;

readonly func BundleTMATMULSharedMasksAreZero() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].pe_mask != Zeros{4} then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleMatrixPostProcessSourceCount() => integer {0..3}
begin
    return
        (if _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init
         then 1 else 0) +
        (if BundleFPATRModeUsesVectorParameter(
               _BundleFixedPointAttributes.pre_quant_mode)
         then 1 else 0) +
        (if BundleFPATRReluModeUsesVectorParameter(
               _BundleFixedPointAttributes.relu_mode)
         then 1 else 0);
end;

readonly func BundleMatrixDestinationCount() => integer {1..3}
begin
    return 1 +
        (if _BundleFixedPointAttributes.row_max_en then 1 else 0) +
        (if _BundleFixedPointAttributes.group_max_en then 1 else 0);
end;

readonly func BundleMatrixDynamicBindingsComplete(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    shared_count: integer {0..4}) => boolean
begin
    if !_BundleFixedPointAttributes.valid ||
       !TileMatrixSharedSourceCountLegal(
           function, left_type, right_type, shared_count) then
        return FALSE;
    end;
    let mathematical_sources = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, shared_count);
    let expected_sources = mathematical_sources +
        BundleMatrixPostProcessSourceCount();
    return BundleLocalTileSourceCount() == expected_sources &&
           BundleLocalTileDestinationCount() ==
               BundleMatrixDestinationCount() &&
           BundleTileBindingStreamTerminated() &&
           BundleOperationScalarBindingSchemaLegal(operation) &&
           BundleOperationGPRBindingValuesLegal(operation);
end;

readonly func BundleMatrixPrimaryDestinationCapacityBytes()
    => integer {0,128,256,512,1024,2048,4096,8192}
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
        end;
    end;
    return 0;
end;

func ExecuteBundleTMATMULOperation() => boolean
begin
    // Zero-mask B.IOT/B.IOS commands do not install bindings.  Their sole
    // architectural trace is the participation marker, which exits before
    // descriptor, readiness, dimension, allocation, or payload inspection.
    if SelectedBundleTileMaskIsZero() &&
       BundleTMATMULSharedMasksAreZero() then
        return TRUE;
    end;

    if !_BundleFixedPointAttributes.valid then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;

    let decoded = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let function = UInt(_BundleOperation.selector[4:0]);
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    let shared_count = BundleSharedBindingCount();
    let matrix_types_legal = if TileMatrixFunctionUsesMX(function) then
        TileMXOperandPairLegal(left_type, right_type)
    else
        TileOrdinaryMatrixInputTypesSameClass(left_type, right_type);
    if !matrix_types_legal ||
       !BundleMatrixDynamicBindingsComplete(
           operation, function, left_type, right_type, shared_count) ||
       !BundleTMATMULDataAttributesLegal() ||
       !BundleTMATMULDimensionsLegal(shared_count) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleTMATMULMasksAgree() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;

    let m_raw = BundleCubeDimensionValue(BundleDimension_LB0);
    let n_raw = BundleCubeDimensionValue(BundleDimension_LB1);
    let k_raw = BundleCubeDimensionValue(BundleDimension_LB2);
    let m = m_raw as integer {1..65535};
    let n = n_raw as integer {1..65535};
    let k = k_raw as integer {1..65535};
    if TileMatrixFunctionIsGEMV(function) && m != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixSharedSchemasLegal(
           function, left_type, right_type,
           m, n, k, shared_count) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;

    let mathematical_sources = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, shared_count);
    let result_type = if TileMatrixFunctionUsesMX(function) then
        TileDataType_FP32
    else
        TileOrdinaryMatrixAccumulatorType(left_type, right_type);
    if !BundleMatrixPostProcessSourcesLegal(
           mathematical_sources, m, n, result_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleMatrixLocalMathematicalSourcesLegal(
           function, left_type, right_type, m, n, k, shared_count,
           result_type, BundleMatrixPrimaryDestinationCapacityBytes()) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (layout_found, primary_layout) =
        BundleMatrixCooperativeMLayout(
            function, right_type, m, shared_count);
    if !layout_found then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Every field, stream, Local/Shared descriptor, parameter payload, shape,
    // and capacity rule is now closed. Allocate the atomic destination group
    // before taking the first mathematical or scalar payload snapshot.
    if !ResolveBundleTMATMULDestination(
           m, n, result_type, TRUE, primary_layout) then
        return FALSE;
    end;

    let operands = BundleTileInstructionOperands(operation);
    var left = _Tiles[[0]];
    var right = _Tiles[[0]];
    var left_scale = _Tiles[[0]];
    var right_scale = _Tiles[[0]];
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    var accumulator: TileIndex = operands.destination0;
    var bias: TileIndex = operands.destination0;
    var local_ordinal: integer {0..5} = 0;
    var shared_ordinal: integer {0..4} = 0;

    if TileMatrixFunctionUsesAccumulator(function) then
        accumulator = BundleMatrixSourceAt(
            local_ordinal as integer {0..7});
        local_ordinal = (local_ordinal + 1) as integer {0..5};
    end;

    if shared_count == 0 then
        left = _Tiles[[BundleMatrixSourceAt(
            local_ordinal as integer {0..7})]];
        local_ordinal = (local_ordinal + 1) as integer {0..5};
        if left_scale_present then
            left_scale = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..7})]];
            local_ordinal = (local_ordinal + 1) as integer {0..5};
        end;
        right = _Tiles[[BundleMatrixSourceAt(
            local_ordinal as integer {0..7})]];
        local_ordinal = (local_ordinal + 1) as integer {0..5};
        if right_scale_present then
            right_scale = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..7})]];
            local_ordinal = (local_ordinal + 1) as integer {0..5};
        end;
    else
        let right_group = TileMatrixRightGroupSourceCount(
            function, right_type);
        if shared_count == right_group then
            left = _Tiles[[BundleMatrixSourceAt(
                local_ordinal as integer {0..7})]];
            local_ordinal = (local_ordinal + 1) as integer {0..5};
            if left_scale_present then
                left_scale = _Tiles[[BundleMatrixSourceAt(
                    local_ordinal as integer {0..7})]];
                local_ordinal = (local_ordinal + 1) as integer {0..5};
            end;
        else
            left = MaterializeBundleSharedMatrixPrimary(
                shared_ordinal as integer {0..3},
                m, k, left_type,
                _BundleFixedPointAttributes.trans_a);
            shared_ordinal = (shared_ordinal + 1) as integer {0..4};
            if left_scale_present then
                let scale_blocks = ((k + 31) DIVRM 32)
                    as integer {1..2048};
                left_scale = MaterializeBundleSharedMatrixSource(
                    shared_ordinal as integer {0..3},
                    m, scale_blocks, scale_blocks,
                    TileDataType_E8M0);
                shared_ordinal = (shared_ordinal + 1) as integer {0..4};
            end;
        end;
        right = MaterializeBundleSharedMatrixPrimary(
            shared_ordinal as integer {0..3},
            k, n, right_type,
            _BundleFixedPointAttributes.trans_b);
        shared_ordinal = (shared_ordinal + 1) as integer {0..4};
        if right_scale_present then
            let scale_blocks = ((k + 31) DIVRM 32)
                as integer {1..2048};
            right_scale = MaterializeBundleSharedMatrixSource(
                shared_ordinal as integer {0..3},
                scale_blocks, n, n, TileDataType_E8M0);
            shared_ordinal = (shared_ordinal + 1) as integer {0..4};
        end;
    end;

    if TileMatrixFunctionUsesBias(function) then
        bias = BundleMatrixSourceAt(
            local_ordinal as integer {0..7});
    end;

    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let shape_legal = if shared_count == 0 then
        TileMatrixCubeInfosMatchDimensions(left, right, m, n, k)
    else if shared_count == right_group then
        TileMatrixMixedInfosMatchDimensions(left, right, m, n, k)
    else
        TileMatrixInfosMatchDimensions(left, right, m, n, k);
    let operand_types_legal = left.data_type == left_type &&
        right.data_type == right_type;
    let scales_legal = !TileMatrixFunctionUsesMX(function) ||
        TileMatrixInfoOptionalScalesLegal(
            left, left_scale, left_scale_present,
            right, right_scale, right_scale_present);
    assert shape_legal && operand_types_legal && scales_legal;

    let accumulator_legal = !TileMatrixFunctionUsesAccumulator(function) ||
        TileMatrixLocalCubeAccumulatorSchemaLegal(
            accumulator, m, n, result_type, primary_layout,
            BundleMatrixPrimaryDestinationCapacityBytes());
    assert accumulator_legal;
    assert !TileMatrixFunctionUsesBias(function) ||
           TileMatrixInfoBiasLegal(
               left, right, bias, TileMatrixFunctionUsesMX(function));
    let destination = BundleMatrixDestinationAt(0);
    if TileMatrixFunctionUsesMX(function) then
        TMATMULMXSharedWithOptionalScales(
            destination, accumulator,
            left, left_scale, left_scale_present,
            right, right_scale, right_scale_present,
            bias, TileMatrixFunctionUsesBias(function),
            TileMatrixFunctionUsesAccumulator(function));
    else
        TMATMULShared(
            destination, accumulator, left, right, bias,
            TileMatrixFunctionUsesBias(function),
            TileMatrixFunctionUsesAccumulator(function));
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    if shared_count > 0 then
        ConsumeBundleSharedBindings(shared_count as integer {1..4});
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
