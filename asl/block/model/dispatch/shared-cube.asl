// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE","surface":"block","classification":["model","dispatch","shared-cube"],"depends_on":["PTO-BLOCK-MODEL-FAULTS-ROLLBACK"]}
readonly func BundleSharedCubeSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMatrix &&
           _BundleOperation.selector_valid && BundleSharedBindingCount() > 0;
end;

readonly func BundleSharedCubeTransposeLegal(shared_count: integer {0..4})
                                                     => boolean
begin
    if shared_count == 0 then
        return !_BundleFixedPointAttributes.trans_a &&
               !_BundleFixedPointAttributes.trans_b;
    end;
    if shared_count == 1 then
        // The accepted one-Shared schema is Local A plus Shared B.
        return !_BundleFixedPointAttributes.trans_a;
    end;
    if shared_count == 2 then return TRUE; end;
    return FALSE;
end;

func TransposeSharedMatrix(input: TileInfo) => TileInfo
begin
    assert !TileLayoutIsCube(input.layout);
    var result = input;
    let new_rows = input.valid_columns;
    let new_columns = input.valid_rows;
    let physical_rows = DerivedTileRows(input.capacity_bytes,
        new_columns, input.data_type);
    assert physical_rows != 0;
    result.rows = physical_rows;
    result.columns = new_columns;
    result.valid_rows = new_rows;
    result.valid_columns = new_columns;
    result.storage_rows = physical_rows;
    result.storage_columns = new_columns;
    result.storage_bytes = TileStorageBytes(physical_rows, new_columns,
        input.data_type) as integer {0..262144};
    result.capacity_bytes = input.capacity_bytes;
    result.cube_k_repeat = 0;
    result.cube_n_repeat = 0;
    result.cube_cell_count = 0;
    result.layout = TileLayout_RowMajor;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    var payload: TilePayload = input.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(input,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLinearIndex(result,
                column as integer {0..65535}, row as integer {0..65535});
            payload[[destination_element]] = input.payload[[source_element]];
            result.defined_elements[destination_element] = '1';
        end;
    end;
    result.payload = payload;
    result.defined_valid_elements =
        (new_rows * new_columns) as integer {0..16384};
    result.contents_defined = input.contents_defined;
    return result;
end;

func NormalizeSharedMatrix(input: TileInfo, transpose: boolean) => TileInfo
begin
    if transpose then return TransposeSharedMatrix(input); end;
    return input;
end;

func NormalizeSharedGroupRows(input: TileInfo) => TileInfo
begin
    let encoded = TileMatrixEncodedGroupM();
    if encoded == 0 || encoded > 128 then return input; end;
    let rows = TileCubeGroupPEValidM(encoded, 0);
    if rows == 0 || rows >= input.valid_rows then return input; end;
    var result = input;
    result.valid_rows = rows;
    result.defined_valid_elements =
        (rows * result.valid_columns) as integer {0..16384};
    result.contents_defined = input.contents_defined;
    return result;
end;

readonly func BundleSharedCubeSchemaLegal(function: integer {0..31},
                                           shared_count: integer {0..4},
                                           local_count: integer {0..32})
                                           => boolean
begin
    if !_BundleFixedPointAttributes.valid then return FALSE; end;
    let post_sources =
        (if _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init
         then 1 else 0) +
        (if BundleFPATRModeUsesVectorParameter(
               _BundleFixedPointAttributes.pre_quant_mode)
         then 1 else 0) +
        (if BundleFPATRReluModeUsesVectorParameter(
               _BundleFixedPointAttributes.relu_mode)
         then 1 else 0);
    if function == 0 then
        return (shared_count == 1 && local_count == 1 + post_sources) ||
               (shared_count == 2 && local_count == 0 + post_sources);
    elsif function == 1 then
        return (shared_count == 1 && local_count == 2 + post_sources) ||
               (shared_count == 2 && local_count == 1 + post_sources);
    elsif function == 2 then
        return (shared_count == 1 && local_count == 2 + post_sources) ||
               (shared_count == 2 && local_count == 1 + post_sources);
    elsif function == 4 then
        return (shared_count == 2 && local_count == 2 + post_sources) ||
               (shared_count == 4 && local_count == 0 + post_sources);
    elsif function == 5 then
        return (shared_count == 2 && local_count == 3 + post_sources) ||
               (shared_count == 4 && local_count == 1 + post_sources);
    elsif function == 6 then
        return (shared_count == 2 && local_count == 3 + post_sources) ||
               (shared_count == 4 && local_count == 1 + post_sources);
    else
        return FALSE;
    end;
end;

readonly func BundleSharedCubeDescriptorsReady(count: integer {1..4}) => boolean
begin
    for ordinal = 0 to count - 1 looplimit 4 do
        if BundleSharedBindingIsDestination(ordinal as integer {0..3}) ||
           BundleSharedBindingMask(ordinal as integer {0..3}) != '1111' then
            return FALSE;
        end;
        let shared_id = BundleSharedBindingId(
            ordinal as integer {0..3});
        if !SharedTileDescriptorLegal(shared_id) then return FALSE; end;
    end;
    return TRUE;
end;

readonly func BundleSharedMasksAreZero(count: integer {1..4}) => boolean
begin
    for ordinal = 0 to count - 1 looplimit 4 do
        if BundleSharedBindingMask(ordinal as integer {0..3}) != Zeros{4} then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func ExecuteBundleSharedCubeOperation() => boolean
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    let shared_count = BundleSharedBindingCount();
    let local_count = BundleLocalTileSourceCount();
    let post_destinations =
        (if _BundleFixedPointAttributes.row_max_en then 1 else 0) +
        (if _BundleFixedPointAttributes.group_max_en then 1 else 0);
    if BundleSharedMasksAreZero(shared_count as integer {1..4}) &&
       SelectedBundleTileMaskIsZero() then
        return TRUE;
    end;
    // Matrix CUBE participation is a complete-bundle contract.  Missing
    // B.FPATR is a bundle-control fault and must be reported before any
    // operand resolution, destination allocation, or shared-binding consume.
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
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleSharedCubeSchemaLegal(function, shared_count, local_count) ||
       BundleLocalTileDestinationCount() != 1 + post_destinations ||
       !BundleTileBindingStreamTerminated() ||
       !SelectedBundleTileDataAttributesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleSharedCubeTransposeLegal(shared_count) ||
       _BundleTileBindings[[0]].pe_mask != '1111' ||
       !BundleSharedCubeDescriptorsReady(shared_count as integer {1..4}) ||
       !ResolveBundleTileDestinations() then
        if _LastFault == Fault_None then
            SetFault(Fault_TileLegality, ReadTPC());
        end;
        return FALSE;
    end;
    let operands = BundleTileInstructionOperands(operation);
    let destination = operands.destination0;
    var left = _Tiles[[0]];
    var right = _Tiles[[0]];
    var left_scale = _Tiles[[0]];
    var right_scale = _Tiles[[0]];
    var accumulator: TileIndex = destination;
    var bias: TileIndex = destination;
    var use_bias = FALSE;
    var accumulate = FALSE;
    if function <= 2 then
        if shared_count == 1 then
            right = NormalizeSharedMatrix(
                MaterializeSharedTile(BundleSharedBindingId(0), '1111'),
                _BundleFixedPointAttributes.trans_b);
            if function == 0 then
                left = _Tiles[[operands.source0]];
            elsif function == 1 then
                left = _Tiles[[operands.source0]];
                bias = operands.source1;
                use_bias = TRUE;
            else
                accumulator = operands.source0;
                left = _Tiles[[operands.source1]];
                accumulate = TRUE;
            end;
        else
            left = NormalizeSharedGroupRows(NormalizeSharedMatrix(
                MaterializeSharedTile(BundleSharedBindingId(0), '1111'),
                _BundleFixedPointAttributes.trans_a));
            right = NormalizeSharedMatrix(
                MaterializeSharedTile(BundleSharedBindingId(1), '1111'),
                _BundleFixedPointAttributes.trans_b);
            if function == 1 then
                bias = operands.source0;
                use_bias = TRUE;
            elsif function == 2 then
                accumulator = operands.source0;
                accumulate = TRUE;
            end;
        end;
        if !TileOrdinaryMatrixInfosLegal(left, right) ||
           !TileMatrixInfoDestinationLegal(destination, left, right) ||
           (use_bias && !TileMatrixInfoBiasLegal(left, right, bias, FALSE)) ||
           (accumulate && !TileMatrixInfoAccumulatorLegal(
               destination, accumulator, left, right)) then
            RollBackBundleTileDestinations();
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        TMATMULShared(destination, accumulator, left, right,
            bias, use_bias, accumulate);
    else
        if shared_count == 2 then
            right = NormalizeSharedMatrix(
                MaterializeSharedTile(BundleSharedBindingId(0), '1111'),
                _BundleFixedPointAttributes.trans_b);
            right_scale = MaterializeSharedTile(
                BundleSharedBindingId(1), '1111');
            if function == 4 then
                left = _Tiles[[operands.source0]];
                left_scale = _Tiles[[operands.source1]];
            elsif function == 5 then
                left = _Tiles[[operands.source0]];
                left_scale = _Tiles[[operands.source1]];
                bias = operands.source2;
                use_bias = TRUE;
            else
                accumulator = operands.source0;
                left = _Tiles[[operands.source1]];
                left_scale = _Tiles[[operands.source2]];
                accumulate = TRUE;
            end;
        else
            left = NormalizeSharedGroupRows(NormalizeSharedMatrix(
                MaterializeSharedTile(BundleSharedBindingId(0), '1111'),
                _BundleFixedPointAttributes.trans_a));
            left_scale = NormalizeSharedGroupRows(MaterializeSharedTile(
                BundleSharedBindingId(1), '1111'));
            right = NormalizeSharedMatrix(
                MaterializeSharedTile(BundleSharedBindingId(2), '1111'),
                _BundleFixedPointAttributes.trans_b);
            right_scale = MaterializeSharedTile(
                BundleSharedBindingId(3), '1111');
            if function == 5 then
                bias = operands.source0;
                use_bias = TRUE;
            elsif function == 6 then
                accumulator = operands.source0;
                accumulate = TRUE;
            end;
        end;
        if !TileMatrixInfoScalesLegal(left, left_scale, right, right_scale) ||
           !TileMatrixInfoDestinationLegal(destination, left, right) ||
           (use_bias && !TileMatrixInfoBiasLegal(left, right, bias, TRUE)) ||
           (accumulate && !TileMatrixInfoAccumulatorLegal(
               destination, accumulator, left, right)) then
            RollBackBundleTileDestinations();
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        TMATMULMXShared(destination, accumulator, left, left_scale,
            right, right_scale, bias, use_bias, accumulate);
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    ConsumeBundleSharedBindings(shared_count as integer {1..4});
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
