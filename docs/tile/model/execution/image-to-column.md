<!-- GENERATED FROM: asl/tile/model/execution/image-to-column.asl -->
# Image To Column

**Normative ASL source:** `asl/tile/model/execution/image-to-column.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-IMAGE-TO-COLUMN}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/image-to-column.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-IMAGE-TO-COLUMN","surface":"tile","classification":["model","execution","image-to-column"],"depends_on":["PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN"]}

func TIMG2COL(
    destination: TileIndex,
    source: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535})
begin
    assert TileOperandsLegal_TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
    let descriptor = ReadTileFeatureMapDescriptor(source);
    let source_tile = _Tiles[[source]];
    var result = _Tiles[[destination]];
    let output_height = TileImageToColumnOutputHeight(descriptor);
    let output_width = TileImageToColumnOutputWidth(descriptor);
    let rows_per_batch: integer =
        descriptor.depth * output_height * output_width;
    let rows_per_depth: integer = output_height * output_width;
    let columns_per_group: integer = descriptor.filter_height *
        descriptor.filter_width * descriptor.channels_per_group;
    let columns_per_filter_row: integer = descriptor.filter_width *
        descriptor.channels_per_group;

    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        let logical_row = position_m + row;
        let batch = logical_row DIVRM rows_per_batch;
        let batch_remainder = logical_row MOD rows_per_batch;
        let depth = batch_remainder DIVRM rows_per_depth;
        let depth_remainder = batch_remainder MOD rows_per_depth;
        let output_row = depth_remainder DIVRM output_width;
        let output_column = depth_remainder MOD output_width;
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let logical_column = position_k + column;
            let channel_group = logical_column DIVRM columns_per_group;
            let group_remainder = logical_column MOD columns_per_group;
            let filter_row = group_remainder DIVRM columns_per_filter_row;
            let filter_remainder = group_remainder MOD columns_per_filter_row;
            let filter_column =
                filter_remainder DIVRM descriptor.channels_per_group;
            let channel_in_group =
                filter_remainder MOD descriptor.channels_per_group;
            let logical_channel: integer = channel_group *
                descriptor.channels_per_group + channel_in_group;
            let padded_input_row: integer =
                output_row * descriptor.stride_height +
                filter_row * descriptor.dilation_height;
            let input_row = padded_input_row - descriptor.pad_top;
            let padded_input_column: integer =
                output_column * descriptor.stride_width +
                filter_column * descriptor.dilation_width;
            let input_column = padded_input_column - descriptor.pad_left;
            var value = TileRawElementValue(
                descriptor.padding,
                source_tile.data_type);
            if logical_channel < descriptor.logical_channels &&
               input_row >= 0 && input_row < descriptor.height &&
               input_column >= 0 && input_column < descriptor.width then
                let source_index = TileImageToColumnSourceIndex(
                    descriptor,
                    batch,
                    depth,
                    channel_group,
                    input_row,
                    input_column,
                    channel_in_group);
                value = TileReadLogicalElement(source_tile,
                    source_index as PackedTileElementIndex);
            end;
            let destination_index = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_index,
                value);
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    result.location = TileLocation_Matrix;
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
