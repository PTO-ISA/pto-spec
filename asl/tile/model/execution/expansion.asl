// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Predicated expansion reads and validates source coordinates only when the mapped output coordinate is active. A broadcast element is read only if at least one active output consumes it; inactive outputs use the common MERGE/ZERO rule and contribute no numeric flags. Integer division-by-zero checks apply only to active outputs.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-EXPANSION","surface":"tile","classification":["model","execution","expansion"],"depends_on":["PTO-TILE-MODEL-EXECUTION-EXPDIF","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
// PTO-REQ-TEPL-EXPAND-001: exact typed row and column broadcast operations.

pure func TileExpandBinaryOperation(
    operation: TileExpandOperation) => TileBinaryOperation
begin
    case operation of
        when TileExpand_ADD =>
            return TileBinary_ADD;
        when TileExpand_SUB =>
            return TileBinary_SUB;
        when TileExpand_MUL =>
            return TileBinary_MUL;
        when TileExpand_DIV =>
            return TileBinary_DIV;
        when TileExpand_MAX =>
            return TileBinary_MAX;
        when TileExpand_MIN =>
            return TileBinary_MIN;
        otherwise =>
            unreachable;
    end;
end;

func TileExpandValueWithTypesAndFlags(
    operation: TileExpandOperation,
    source_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    if operation == TileExpand_COPY then
        return (broadcast, Zeros{5});
    end;

    if operation == TileExpand_EXPDIF then
        return TileExpdifValueWithTypesAndFlags(
            source_type, destination_type, left, broadcast);
    end;

    return TileProfileBinaryWithFlags(
        TileExpandBinaryOperation(operation),
        destination_type,
        left,
        broadcast);
end;

func TileProfileExpand(op: TileExpandOperation,
                                      data_type: TileDataType,
                                      left: Word, broadcast: Word) => Word
begin
    return TileExpandValue(
        op,
        data_type,
        left,
        broadcast);
end;

func TileExpandValueWithFlags(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    return TileExpandValueWithTypesAndFlags(
        operation,
        data_type,
        data_type,
        left,
        broadcast);
end;

func TileExpandValue(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => Word
begin
    let (result, -) = TileExpandValueWithFlags(
        operation,
        data_type,
        left,
        broadcast);
    return result;
end;

func ExecuteTileExpand(op: TileExpandOperation, axis: TileAxis,
                       destination: TileIndex, source: TileIndex,
                       broadcast_source: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileExpand(
        op,
        axis,
        destination,
        source,
        broadcast_source);

    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    var result_tile = _Tiles[[destination]];
    let expdif = op == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(result_tile.data_type);
    assert operation_type_valid;
    let source_operation_type = if expdif && !BundleTileOperationSelected() then
        source_tile.data_type else selected_type;
    let destination_operation_type = if expdif then
        result_tile.data_type else selected_type;
    var accumulated_flags = Zeros{5};

    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let broadcast_row = if axis == TileAxis_Row then row else 0;
                let broadcast_column = if axis == TileAxis_Row then 0 else column;
                let broadcast_element = TileLogicalLinearIndex(broadcast_tile,
                    broadcast_row as integer {0..65535},
                    broadcast_column as integer {0..65535});
                var left = TileReadLogicalElement(broadcast_tile,
                    broadcast_element);
                if op != TileExpand_COPY then
                    let source_element = TileLogicalLinearIndex(
                        source_tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    left = TileReadLogicalElement(source_tile, source_element);
                end;
                let (value, element_flags) = TileExpandValueWithTypesAndFlags(
                    op,
                    source_operation_type,
                    destination_operation_type,
                    left,
                    TileReadLogicalElement(broadcast_tile, broadcast_element));
                result_tile = TileInfoWithLogicalElement(result_tile,
                    destination_element, value);
                accumulated_flags = accumulated_flags OR element_flags;
            else
                let value = BundleExecutionMaskDestinationValue(
                    result_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
            end;
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
