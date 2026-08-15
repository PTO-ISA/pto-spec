<!-- GENERATED FROM: asl/tile/model/execution/sorting.asl -->
# Sorting

**Normative ASL source:** `asl/tile/model/execution/sorting.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-SORTING}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/sorting.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-SORTING","surface":"tile","classification":["model","execution","sorting"],"depends_on":["PTO-TILE-MODEL-LEGALITY-SORTING"]}

func TSORT(
    destination: TileIndex,
    destination_indices: TileIndex,
    source: TileIndex,
    sort_width: integer {1..64},
    descending: boolean)
begin
    assert TileOperandsLegal_TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);

    let source_tile = _Tiles[[source]];
    let source_has_signaling_nan =
        TileSortSourceHasSignalingNaN(source);
    assert source_tile.valid_columns >= 1;
    let column_count =
        source_tile.valid_columns as integer {1..65535};
    var result_values = _Tiles[[destination]];
    var result_indices = _Tiles[[destination_indices]];
    var values = source_tile.payload;
    var indices: TilePayload;

    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            indices[[element]] =
                Zeros{PTO_XLEN} + (column MOD sort_width);
        end;

        let group_count: integer {1..65535} =
            ((column_count - 1) DIVRM sort_width) + 1;
        for group = 0 to group_count - 1 looplimit 65536 do
            let group_begin = (group * sort_width)
                as integer {0..65535};
            let group_end =
                if group_begin + sort_width < column_count then
                    group_begin + sort_width
                else
                    column_count;

            for sort_pass = 0 to 63 do
                for offset = 0 to 62 do
                    let left_column = group_begin + offset;
                    if left_column + 1 < group_end then
                        let left_element = TileLinearIndex(
                            source_tile,
                            row as integer {0..65535},
                            left_column as integer {0..65535});
                        let right_element = TileLinearIndex(
                            source_tile,
                            row as integer {0..65535},
                            (left_column + 1) as integer {0..65535});
                        if !TileSortLeftBefore(
                               values[[left_element]],
                               values[[right_element]],
                               descending,
                               source_tile.data_type) then
                            let left_value = values[[left_element]];
                            values[[left_element]] = values[[right_element]];
                            values[[right_element]] = left_value;

                            let left_index = indices[[left_element]];
                            indices[[left_element]] = indices[[right_element]];
                            indices[[right_element]] = left_index;
                        end;
                    end;
                end;
            end;
        end;
    end;

    result_values.payload = values;
    result_values = TileWithValidRegionDefined(result_values);
    result_values = TileWithPadding(result_values, TilePad_Null);
    result_values.location = TileLocation_Any;

    result_indices.payload = indices;
    result_indices = TileWithValidRegionDefined(result_indices);
    result_indices = TileWithPadding(result_indices, TilePad_Null);
    result_indices.location = TileLocation_Any;

    // Numeric status and both result Tiles are one non-faulting architectural
    // publication group.  Signaling NaNs remain stable sortable values and
    // set the sticky invalid flag instead of making the operation illegal.
    if source_has_signaling_nan then
        RecordNumericStatusFlags(Zeros{5} + 1);
    end;
    _Tiles[[destination]] = result_values;
    _Tiles[[destination_indices]] = result_indices;
end;

func TMRGSORT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    descending: boolean)
begin
    assert TileOperandsLegal_TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);

    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let source_has_signaling_nan =
        TileSortSourceHasSignalingNaN(source_left) ||
        TileSortSourceHasSignalingNaN(source_right);
    var result = _Tiles[[destination]];
    var left_column: integer {0..65535} = 0;
    var right_column: integer {0..65535} = 0;
    let output_columns =
        left_tile.valid_columns + right_tile.valid_columns;

    for output_column = 0 to output_columns - 1 looplimit 65536 do
        var take_left = right_column >= right_tile.valid_columns;
        if left_column < left_tile.valid_columns &&
           right_column < right_tile.valid_columns then
            let left_element = TileLinearIndex(
                left_tile,
                0,
                left_column);
            let right_element = TileLinearIndex(
                right_tile,
                0,
                right_column);
            take_left = TileSortLeftBefore(
                left_payload[[left_element]],
                right_payload[[right_element]],
                descending,
                left_tile.data_type);
        end;

        if take_left then
            let left_element = TileLinearIndex(
                left_tile,
                0,
                left_column);
            let output_element = TileLinearIndex(
                result,
                0,
                output_column as integer {0..65535});
            result.payload[[output_element]] = left_payload[[left_element]];
            left_column = (left_column + 1) as integer {0..65535};
        else
            let right_element = TileLinearIndex(
                right_tile,
                0,
                right_column);
            let output_element = TileLinearIndex(
                result,
                0,
                output_column as integer {0..65535});
            result.payload[[output_element]] = right_payload[[right_element]];
            right_column = (right_column + 1) as integer {0..65535};
        end;
    end;

    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    if source_has_signaling_nan then
        RecordNumericStatusFlags(Zeros{5} + 1);
    end;
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
