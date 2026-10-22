// PTO-UNIT: {"classification":["model","dispatch","destination-operation"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION","surface":"block"}
func ResolveBundleTileDestinationsForOperationAndWriterEffects(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    let empty_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    // CUBE matrix handlers own the primary CUBE destination and allocation; leave it unresolved for the authoritative M/N/layout/type handler because generic RowMajor resolution would mark it allocated and prevent conversion.
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix then
        return (TRUE, empty_effects);
    end;
    let decoded_operation = TileOperationOfIndex(operation);
    if decoded_operation == TileOperation_TLEA then
        let (type_valid, destination_type) = ResolveBundleEffectiveDataType();
        if !type_valid then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, empty_effects);
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
        let columns = BundleDestinationPhysicalColumns(FALSE, 0)
            as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, valid_rows, valid_columns, columns, TRUE, destination_type);
    end;
    if decoded_operation == TileOperation_TPERMUTE ||
       decoded_operation == TileOperation_TSHUF ||
       decoded_operation == TileOperation_TPACK ||
       decoded_operation == TileOperation_TUNPACK then
        return (ResolveBundleCellRearrangementDestination(operation),
                empty_effects);
    end;
    if TileOperationUsesSourceBackingDestination(decoded_operation) then
        let source = BundleTileSourceIndex(0, FALSE);
        return ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(FALSE, 0, 0, 0,
            TRUE, _Tiles[[source]].data_type);
    end;
    if TileOperationUsesClosedTCVTSchema(operation) then
        let source = BundleTileSourceIndex(0, FALSE);
        if _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
           _Tiles[[source]].layout == TileLayout_CUBE_M32 then
            return ResolveBundleTCVTCubeDestinationWithWriterEffects();
        end;
    end;
    if TileOperationUsesClosedReductionSchema(operation) then
        let source = _BundleTileBindings[[0]].source0;
        let source_tile = _Tiles[[source]];
        let row_reduction =
            TileOperationUsesClosedRowReductionSchema(operation);
        let destination_type =
            if TileReductionOperationReturnsIndex(operation) then
                TileDataType_U32
            else
                source_tile.data_type;
        let valid_rows =
            if row_reduction then source_tile.valid_rows else 1;
        let valid_columns =
            if row_reduction then 1 else source_tile.valid_columns;
        let columns =
            if row_reduction then 1 else source_tile.columns;
        return ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE,
            valid_rows,
            valid_columns,
            columns,
            TRUE,
            destination_type);
    end;
    if TileOperationUsesClosedTCMPSchema(operation) ||
       TileOperationUsesClosedTCMPSSchema(operation) then
        let (operation_type_valid, operation_type) =
            ResolveBundleEffectiveDataType();
        if !operation_type_valid then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, empty_effects);
        end;
        return (ResolveBundlePredicateDestination(operation_type),
                empty_effects);
    end;
    if (TileOperationUsesClosedTSELSchema(operation) ||
        TileOperationUsesClosedTSELSSchema(operation)) &&
       SelectedBundleComparisonCUBE(
           BundleComparisonSelectTrueSource(operation)) then
        return (ResolveBundleCUBESelectDestination(operation), empty_effects);
    end;
    if decoded_operation == TileOperation_TEXPDIF then
        let (types_legal, -, destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, empty_effects);
        end;
        let valid_columns = BundleDestinationValidColumns(FALSE, 0)
            as integer {1..65535};
        let valid_rows = BundleDestinationValidRows(FALSE, 0)
            as integer {1..65535};
        let columns = BundleDestinationPhysicalColumns(FALSE, 0)
            as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if TileExpansionOperationIsExponentialDifference(operation) then
        let (types_legal, -, destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, empty_effects);
        end;
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
        let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if !TileOperationUsesClosedBinarySchema(operation) &&
       !TileOperationUsesClosedUnarySchema(operation) &&
       !TileOperationUsesClosedTFMASchema(operation) &&
       !TileOperationUsesClosedGenerationSchema(operation) &&
       !TileOperationUsesClosedExpansionSchema(operation) &&
       !TileOperationUsesClosedTCVTSchema(operation) &&
       !TileOperationUsesClosedComparisonSchema(operation) &&
       !TileOperationUsesClosedTileScalarSchema(operation) then
        return (ResolveBundleTileDestinations(), empty_effects);
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = BundleDestinationPhysicalColumns(FALSE, 0)
        as integer {1..65535};
    let (legal, effects) = ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
        TRUE, valid_rows, valid_columns, columns, FALSE, TileDataType_FP64);
    return (legal, effects);
end;

func ResolveBundleTileDestinationsForOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let (legal, -) = ResolveBundleTileDestinationsForOperationAndWriterEffects(
        operation);
    return legal;
end;
