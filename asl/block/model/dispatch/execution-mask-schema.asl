// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","surface":"block","classification":["model","dispatch","execution-mask-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-TILE-MODEL-EXECUTION-MASK","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskOrdinaryTileSourceCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..9}
begin
    let decoded = TileOperationOfIndex(operation);
    let encoded_sources = BundleLocalTileSourceCount();
    if decoded == TileOperation_TGPR2T then return 0; end;
    if decoded == TileOperation_TCMP then return 2; end;
    if decoded == TileOperation_TCMPS then return 1; end;
    if decoded == TileOperation_TSEL then
        if encoded_sources <= 2 then return 2; end;
        if _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
           TileStorage_PredicateCell then return 3; end;
        return 2;
    end;
    if decoded == TileOperation_TSELS then
        if encoded_sources <= 1 then return 1; end;
        if _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
           TileStorage_PredicateCell then return 2; end;
        return 1;
    end;
    var count: integer {0..9} = 0;
    if TileOperandPresent(operation, TileOperand_source0) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source1) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source2) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source3) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source4) then count = (count + 1) as integer {0..9}; end;
    return count;
end;

readonly func BundleExecutionMaskTileSourceAt(ordinal: integer {0..31})
    => TileIndex
begin
    var seen: integer {0..31} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..31};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..31};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleExecutionMaskCoordinateSourceOrdinal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer {0..31}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TGATHER ||
       decoded == TileOperation_TSCATTER ||
       decoded == TileOperation_MSCATTER ||
       decoded == TileOperation_MSCATTER_MASK then
        return 1;
    end;
    return 0;
end;

readonly func BundleExecutionMaskCoordinateLayout(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileLayout
begin
    if BundleExecutionMaskOrdinaryTileSourceCount(operation) != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].layout;
    end;
    return CurrentBundleTileLayout();
end;

readonly func BundleExecutionMaskTileCarrierPresent(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationExecutionMaskEligible(operation) ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then return FALSE; end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if BundleLocalTileSourceCount() != ordinary + 1 then return FALSE; end;
    return _Tiles[[BundleExecutionMaskTileSourceAt(ordinary)]]
        .storage_kind == TileStorage_PredicateCell;
end;

readonly func BundleExecutionMaskTileCarrierSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleExecutionMaskTileCarrierPresent(operation) then return TRUE; end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    let predicate = BundleExecutionMaskTileSourceAt(ordinary);
    var consumer_layout = CurrentBundleTileLayout();
    var valid_rows: integer {1..65535} = 1;
    var valid_columns: integer {1..65535} = 1;
    if ordinary != 0 then
        let consumer = _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]];
        consumer_layout = consumer.layout;
        valid_rows = consumer.valid_rows as integer {1..65535};
        valid_columns = consumer.valid_columns as integer {1..65535};
    else
        let raw_columns = UInt(_BundleDimensions[[0]]);
        let raw_rows = UInt(_BundleDimensions[[1]]);
        if raw_columns < 1 || raw_columns > 65535 || raw_rows > 65535 then
            return FALSE;
        end;
        valid_columns = raw_columns as integer {1..65535};
        valid_rows = if raw_rows == 0 then 1 else raw_rows as integer {1..65535};
    end;
    return TileExecutionMaskPredicateCellShapeLegal(
        predicate, consumer_layout, valid_rows, valid_columns);
end;

readonly func BundleExecutionMaskGPRCarrierShapeLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    let coordinate_layout = BundleExecutionMaskCoordinateLayout(operation);
    if coordinate_layout != TileLayout_CUBE_M16 &&
       coordinate_layout != TileLayout_CUBE_M32 then return FALSE; end;
    var valid_rows: integer {1..65535} = 1;
    var valid_columns: integer {1..65535} = 1;
    if ordinary != 0 then
        let consumer = _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]];
        valid_rows = consumer.valid_rows as integer {1..65535};
        valid_columns = consumer.valid_columns as integer {1..65535};
    else
        let raw_columns = UInt(_BundleDimensions[[0]]);
        let raw_rows = UInt(_BundleDimensions[[1]]);
        if raw_columns < 1 || raw_columns > 65535 || raw_rows > 65535 then
            return FALSE;
        end;
        valid_columns = raw_columns as integer {1..65535};
        valid_rows = if raw_rows == 0 then 1 else raw_rows as integer {1..65535};
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let words = BundleExecutionMaskGPRWordCount(operation);
    return valid_rows <= TileCubePredicateRowBits(coordinate_layout) &&
           valid_columns <= TileCubePredicateFieldCount(
               data_type, coordinate_layout) * words;
end;

func MarkSelectedBundleExecutionMaskCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    _BundleExecutionMask.valid = FALSE;
    _BundleExecutionMask.carrier = BundleExecutionMask_None;
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) ||
           !BundleExecutionMaskGPRCarrierShapeLegal(operation) then
            return FALSE;
        end;
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
        _BundleExecutionMask.word_count =
            BundleExecutionMaskGPRWordCount(operation);
        _BundleExecutionMask.layout =
            BundleExecutionMaskCoordinateLayout(operation);
        if BundleExecutionMaskOrdinaryTileSourceCount(operation) == 0 then
            let raw_rows = UInt(_BundleDimensions[[1]]);
            let raw_columns = UInt(_BundleDimensions[[0]]);
            _BundleExecutionMask.valid_rows = if raw_rows == 0 then 1
                else raw_rows as integer {1..65535};
            _BundleExecutionMask.valid_columns =
                raw_columns as integer {1..65535};
        else
            let consumer = BundleExecutionMaskTileSourceAt(
                BundleExecutionMaskCoordinateSourceOrdinal(operation));
            _BundleExecutionMask.valid_rows = _Tiles[[consumer]].valid_rows;
            _BundleExecutionMask.valid_columns =
                _Tiles[[consumer]].valid_columns;
        end;
        _BundleExecutionMask.invert = _BundleDataAttributes.execution_mask_invert;
        _BundleExecutionMask.zero_inactive = _BundleDataAttributes.execution_mask_zero;
        return TRUE;
    end;
    if BundleExecutionMaskTileCarrierPresent(operation) then
        if !BundleExecutionMaskTileCarrierSchemaLegal(operation) then return FALSE; end;
        let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
        let predicate = BundleExecutionMaskTileSourceAt(ordinary);
        let tile = _Tiles[[predicate]];
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_PredicateTile;
        _BundleExecutionMask.predicate_tile = predicate;
        _BundleExecutionMask.predicate_source_ordinal = ordinary;
        _BundleExecutionMask.word_count = 0;
        _BundleExecutionMask.layout = tile.layout;
        _BundleExecutionMask.valid_rows = tile.valid_rows;
        _BundleExecutionMask.valid_columns = tile.valid_columns;
        _BundleExecutionMask.invert = _BundleDataAttributes.execution_mask_invert;
        _BundleExecutionMask.zero_inactive = _BundleDataAttributes.execution_mask_zero;
    end;
    return TRUE;
end;

func CaptureSelectedBundleExecutionMask(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    if _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
        let ordinal = _BundleExecutionMask.predicate_source_ordinal;
        let predicate = _BundleExecutionMask.predicate_tile;
        let layout = _BundleExecutionMask.layout;
        let rows = _BundleExecutionMask.valid_rows;
        let columns = _BundleExecutionMask.valid_columns;
        CaptureBundleExecutionMaskPredicateTile(
            predicate, layout,
            rows as integer {1..65535},
            columns as integer {1..65535});
        _BundleExecutionMask.predicate_source_ordinal = ordinal;
        return TRUE;
    end;
    let operation_sources = BundleExecutionMaskOperationGPRSourceCount(operation);
    let mask_low = ReadScalarRegisterOperand(
        BundleExecutionMaskGPRSourceSelector(operation_sources));
    let mask_high = if _BundleExecutionMask.word_count == 2 then
        ReadScalarRegisterOperand(
            BundleExecutionMaskGPRSourceSelector(
                (operation_sources + 1) as integer {0..5}))
        else Zeros{PTO_XLEN};
    let layout = _BundleExecutionMask.layout;
    let rows = _BundleExecutionMask.valid_rows;
    let columns = _BundleExecutionMask.valid_columns;
    let words = _BundleExecutionMask.word_count;
    CaptureBundleExecutionMaskGPR(
        mask_low, mask_high, words as integer {1..2}, layout,
        rows as integer {1..65535},
        columns as integer {1..65535});
    return TRUE;
end;

func PrepareSelectedBundleExecutionMaskMerge(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleExecutionMask.valid || _BundleExecutionMask.zero_inactive then
        return TRUE;
    end;
    var destination_binding: integer {0..15} = 0;
    var destination_found = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            destination_binding = binding as integer {0..15};
            destination_found = TRUE;
        end;
    end;
    if !destination_found then return TRUE; end;
    let hand = UInt(_BundleTileBindings[[destination_binding]].destination_hand)
        as integer {0..3};
    if _TileRelativeValid[[hand]][0] == '0' then return FALSE; end;
    let base = _TileRelativeOrder[[hand]][[0]];
    let tile = _Tiles[[base]];
    if !tile.allocated || !tile.contents_defined ||
       !TileCubeDescriptorLegal(tile) then return FALSE; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    if TileOperationOfIndex(operation) == TileOperation_TCMP ||
       TileOperationOfIndex(operation) == TileOperation_TCMPS then
        if !TilePredicateCellDescriptorLegal(base) then return FALSE; end;
    else
        let data_type = TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
        if tile.storage_kind != TileStorage_Numeric ||
           tile.data_type != data_type then return FALSE; end;
    end;
    _BundleExecutionMask.merge_base = base;
    _BundleExecutionMask.merge_base_valid = TRUE;
    return TRUE;
end;
