<!-- GENERATED FROM: asl/tile/model/legality/operand-schema.asl -->
# Operand Schema

**Normative ASL source:** `asl/tile/model/legality/operand-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/operand-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","surface":"tile","classification":["model","legality","operand-schema"],"depends_on":["PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY"]}
readonly func TileOperandsLegal_ExecuteTileBinary(
    op: TileBinaryOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    if !TileShapeAndTypeMatch(source_left, source_right) ||
       !TileShapeAndTypeMatch(destination, source_left) then return FALSE; end;
    if op == TileBinary_DIV || op == TileBinary_REM then
        return TilePayloadNonzero(source_right);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_ExecuteTileUnary(
    op: TileUnaryOperation, destination: TileIndex, source: TileIndex) => boolean
begin
    if !TileShapeAndTypeMatch(destination, source) then return FALSE; end;
    if op == TileUnary_RECIP || op == TileUnary_RSQRT then
        return TilePayloadNonzero(source);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileScalar(
    op: TileBinaryOperation, destination: TileIndex,
    source: TileIndex, scalar: Word) => boolean
begin
    if !TileShapeAndTypeMatch(destination, source) then return FALSE; end;
    return (op != TileBinary_DIV && op != TileBinary_REM) || !IsZero(scalar);
end;

readonly func TileOperandsLegal_ExecuteTileCompare(
    destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    return TileShapeAndTypeMatch(source_left, source_right) &&
           TileLogicalShapeMatch(destination, source_left);
end;

readonly func TileOperandsLegal_ExecuteTileCompareScalar(
    destination: TileIndex, source: TileIndex, scalar: Word,
    comparison: TileComparison) => boolean
begin
    return TileLogicalShapeMatch(destination, source);
end;

readonly func TileOperandsLegal_ExecuteTileSelect(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex) => boolean
begin
    return TileShapeAndTypeMatch(source_true, source_false) &&
           TileLogicalShapeMatch(mask, source_true) &&
           TileShapeAndTypeMatch(destination, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalar(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word) => boolean
begin
    return TileLogicalShapeMatch(destination, source_true) &&
           TileLogicalShapeMatch(mask, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileReduction(
    op: TileReductionOperation, axis: TileAxis,
    destination: TileIndex, source: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source) ||
       _Tiles[[source]].valid_rows == 0 ||
       _Tiles[[source]].valid_columns == 0 then return FALSE; end;
    if axis == TileAxis_Row then
        return _Tiles[[destination]].valid_rows >= _Tiles[[source]].valid_rows &&
               _Tiles[[destination]].valid_columns >= 1;
    else
        return _Tiles[[destination]].valid_rows >= 1 &&
               _Tiles[[destination]].valid_columns >= _Tiles[[source]].valid_columns;
    end;
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    op: TileExpandOperation, axis: TileAxis, destination: TileIndex,
    source: TileIndex, broadcast_source: TileIndex) => boolean
begin
    if !TileShapeAndTypeMatch(destination, source) ||
       !TileDescriptorLegal(broadcast_source) ||
       _Tiles[[broadcast_source]].data_type != _Tiles[[source]].data_type then
        return FALSE;
    end;
    let shape_legal = if axis == TileAxis_Row then
        _Tiles[[broadcast_source]].valid_rows >= _Tiles[[source]].valid_rows &&
        _Tiles[[broadcast_source]].valid_columns >= 1
    else
        _Tiles[[broadcast_source]].valid_rows >= 1 &&
        _Tiles[[broadcast_source]].valid_columns >= _Tiles[[source]].valid_columns;
    if !shape_legal then return FALSE; end;
    return op != TileExpand_DIV ||
           TileBroadcastPayloadNonzero(axis, source, broadcast_source);
end;

readonly func TileOperandsLegal_TCI(
    destination: TileIndex, start: Word, descending: boolean) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_TTRI(
    destination: TileIndex, upper: boolean,
    diagonal: integer {-65535..65535}) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_TFILLPAD(
    destination: TileIndex, source: TileIndex, padding: Word) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows >= _Tiles[[source]].valid_rows &&
           _Tiles[[destination]].columns >= _Tiles[[source]].valid_columns;
end;

readonly func TileOperandsLegal_TCVT(destination: TileIndex,
                                     source: TileIndex,
                                     control: NumericExecutionControl) => boolean
begin
    return TileLogicalShapeMatch(destination, source);
end;

readonly func TileOperandsLegal_TQUANT(destination: TileIndex,
                                       source: TileIndex, scale: Word,
                                       zero_point: Word,
                                       control: NumericExecutionControl) => boolean
begin
    return TileLogicalShapeMatch(destination, source) && !IsZero(scale);
end;

readonly func TileOperandsLegal_TDEQUANT(destination: TileIndex,
                                         source: TileIndex, scale: Word,
                                         zero_point: Word,
                                         control: NumericExecutionControl) => boolean
begin
    return TileLogicalShapeMatch(destination, source);
end;

readonly func TileOperandsLegal_TEXTRACT(
    destination: TileIndex, source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           row_offset + _Tiles[[destination]].valid_rows <=
               _Tiles[[source]].valid_rows &&
           column_offset + _Tiles[[destination]].valid_columns <=
               _Tiles[[source]].valid_columns;
end;

readonly func TileOperandsLegal_TINSERT(
    destination: TileIndex, source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileDescriptorLegal(destination) &&
           _Tiles[[destination]].contents_defined &&
           TileDescriptorLegal(source) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           row_offset + _Tiles[[source]].valid_rows <=
               _Tiles[[destination]].valid_rows &&
           column_offset + _Tiles[[source]].valid_columns <=
               _Tiles[[destination]].valid_columns;
end;

readonly func TileOperandsLegal_TTRANS(destination: TileIndex,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].valid_rows == _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].valid_columns == _Tiles[[source]].valid_rows &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TRESHAPE(destination: TileIndex,
                                         source: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows * _Tiles[[destination]].columns ==
               _Tiles[[source]].rows * _Tiles[[source]].columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns ==
               _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TCONCAT(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, axis: TileAxis) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) ||
       _Tiles[[destination]].data_type != _Tiles[[source_left]].data_type ||
       _Tiles[[destination]].data_type != _Tiles[[source_right]].data_type then
        return FALSE;
    end;
    if axis == TileAxis_Row then
        return _Tiles[[source_left]].valid_columns ==
                   _Tiles[[source_right]].valid_columns &&
               _Tiles[[destination]].valid_rows ==
                   _Tiles[[source_left]].valid_rows +
                   _Tiles[[source_right]].valid_rows &&
               _Tiles[[destination]].valid_columns ==
                   _Tiles[[source_left]].valid_columns;
    else
        return _Tiles[[source_left]].valid_rows ==
                   _Tiles[[source_right]].valid_rows &&
               _Tiles[[destination]].valid_rows ==
                   _Tiles[[source_left]].valid_rows &&
               _Tiles[[destination]].valid_columns ==
                   _Tiles[[source_left]].valid_columns +
                   _Tiles[[source_right]].valid_columns;
    end;
end;

readonly func TileOperandsLegal_TGATHER(destination: TileIndex,
                                        source: TileIndex,
                                        indices: TileIndex) => boolean
begin
    if !TileLogicalShapeMatch(destination, indices) ||
       !TileDescriptorLegal(source) ||
       _Tiles[[destination]].data_type != _Tiles[[source]].data_type then
        return FALSE;
    end;
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    return TileIndexPayloadWithin(indices, source_extent);
end;

readonly func TileOperandsLegal_TSCATTER(destination: TileIndex,
                                         source: TileIndex,
                                         indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !_Tiles[[destination]].contents_defined ||
       !TileDescriptorLegal(source) ||
       !TileLogicalShapeMatch(source, indices) ||
       _Tiles[[destination]].data_type != _Tiles[[source]].data_type then
        return FALSE;
    end;
    let destination_extent: integer =
        _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns;
    return TileIndexPayloadWithin(indices, destination_extent);
end;

readonly func TileOperandsLegal_TINTERLEAVE(
    destination: TileIndex, source_even: TileIndex,
    source_odd: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_even) ||
       !TileDescriptorLegal(source_odd) then return FALSE; end;
    let extent: integer =
        _Tiles[[source_even]].valid_rows * _Tiles[[source_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 &&
           extent == _Tiles[[source_odd]].valid_rows *
                     _Tiles[[source_odd]].valid_columns &&
           _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns == extent * 2 &&
           _Tiles[[destination]].data_type == _Tiles[[source_even]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_odd]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source_even]].layout &&
           _Tiles[[destination]].layout == _Tiles[[source_odd]].layout;
end;

readonly func TileOperandsLegal_TDEINTERLEAVE(
    destination_even: TileIndex, destination_odd: TileIndex,
    source: TileIndex) => boolean
begin
    if destination_even == destination_odd then return FALSE; end;
    if !TileDescriptorLegal(destination_even) ||
       !TileDescriptorLegal(destination_odd) ||
       !TileDescriptorLegal(source) then return FALSE; end;
    let extent: integer = _Tiles[[destination_even]].valid_rows *
                          _Tiles[[destination_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 &&
           extent == _Tiles[[destination_odd]].valid_rows *
                     _Tiles[[destination_odd]].valid_columns &&
           _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns ==
               extent * 2 &&
           _Tiles[[destination_even]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_odd]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_even]].layout == _Tiles[[source]].layout &&
           _Tiles[[destination_odd]].layout == _Tiles[[source]].layout;
end;

readonly func TileOperandsLegal_TIMG2COL(
    destination: TileIndex, source: TileIndex,
    kernel_rows: integer {1..65535},
    kernel_columns: integer {1..65535},
    stride_rows: integer {1..65535},
    stride_columns: integer {1..65535},
    pad_rows: integer {0..65535},
    pad_columns: integer {0..65535}, padding: Word) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source) ||
       _Tiles[[source]].valid_rows + 2 * pad_rows < kernel_rows ||
       _Tiles[[source]].valid_columns + 2 * pad_columns < kernel_columns then
        return FALSE;
    end;
    let output_rows: integer =
        (((_Tiles[[source]].valid_rows + 2 * pad_rows) - kernel_rows)
            DIVRM stride_rows) + 1;
    let output_columns: integer =
        (((_Tiles[[source]].valid_columns + 2 * pad_columns) - kernel_columns)
            DIVRM stride_columns) + 1;
    let patch_count: integer = output_rows * output_columns;
    let patch_elements: integer = kernel_rows * kernel_columns;
    return patch_count <= 65535 && patch_elements <= 65535 &&
           _Tiles[[destination]].valid_rows == patch_count &&
           _Tiles[[destination]].valid_columns == patch_elements;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
