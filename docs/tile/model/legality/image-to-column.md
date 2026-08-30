<!-- GENERATED FROM: asl/tile/model/legality/image-to-column.asl -->
# Image To Column

**Normative ASL source:** `asl/tile/model/legality/image-to-column.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/image-to-column.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN","surface":"tile","classification":["model","legality","image-to-column"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS"]}

readonly func TileImageToColumnOutputHeight(
    descriptor: TileFeatureMapDescriptor) => integer
begin
    let receptive_height: integer =
        descriptor.dilation_height * (descriptor.filter_height - 1) + 1;
    if descriptor.height + descriptor.pad_top + descriptor.pad_bottom <
       receptive_height then
        return 0;
    end;
    let padded_height: integer =
        descriptor.height + descriptor.pad_top + descriptor.pad_bottom;
    return ((padded_height - receptive_height) DIVRM
            descriptor.stride_height) + 1;
end;

readonly func TileImageToColumnOutputWidth(
    descriptor: TileFeatureMapDescriptor) => integer
begin
    let receptive_width: integer =
        descriptor.dilation_width * (descriptor.filter_width - 1) + 1;
    if descriptor.width + descriptor.pad_left + descriptor.pad_right <
       receptive_width then
        return 0;
    end;
    let padded_width: integer =
        descriptor.width + descriptor.pad_left + descriptor.pad_right;
    return ((padded_width - receptive_width) DIVRM
            descriptor.stride_width) + 1;
end;

readonly func TileImageToColumnSourceIndex(
    descriptor: TileFeatureMapDescriptor,
    batch: integer,
    depth: integer,
    channel_group: integer,
    input_row: integer,
    input_column: integer,
    channel_in_group: integer) => integer
begin
    return (((((batch * descriptor.depth + depth) *
                descriptor.channel_groups + channel_group) *
               descriptor.height + input_row) *
              descriptor.width + input_column) *
             descriptor.channels_per_group) + channel_in_group;
end;

readonly func TileImageToColumnReferencedSourcesDefined(
    source: TileIndex,
    destination: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535},
    output_height: integer,
    output_width: integer) => boolean
begin
    let descriptor = ReadTileFeatureMapDescriptor(source);
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    let rows_per_batch: integer =
        descriptor.depth * output_height * output_width;
    let rows_per_depth: integer = output_height * output_width;
    let columns_per_group: integer = descriptor.filter_height *
        descriptor.filter_width * descriptor.channels_per_group;
    let columns_per_filter_row: integer = descriptor.filter_width *
        descriptor.channels_per_group;

    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        let logical_row = position_m + row;
        let batch = logical_row DIVRM rows_per_batch;
        let batch_remainder = logical_row MOD rows_per_batch;
        let depth = batch_remainder DIVRM rows_per_depth;
        let depth_remainder = batch_remainder MOD rows_per_depth;
        let output_row = depth_remainder DIVRM output_width;
        let output_column = depth_remainder MOD output_width;
        for column = 0 to destination_tile.valid_columns - 1
            looplimit 65536 do
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
                if source_index >= TileLogicalElementCapacity(
                       source_tile.capacity_bytes, source_tile.data_type) ||
                   !TileLogicalElementDefined(source_tile,
                       source_index as PackedTileElementIndex) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TIMG2COL(
    destination: TileIndex,
    source: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileFeatureMapDescriptorStructurallyValid(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let descriptor = ReadTileFeatureMapDescriptor(source);
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid ||
       !TileCarrierWidthCompatible(source_tile.data_type, operation_type) ||
       destination_tile.data_type != source_tile.data_type ||
       destination_tile.layout != TileLayout_RowMajor ||
       source_tile.layout != TileLayout_RowMajor ||
       destination_tile.location != TileLocation_Matrix ||
       source_tile.location != TileLocation_Matrix then
        return FALSE;
    end;
    let output_height = TileImageToColumnOutputHeight(descriptor);
    let output_width = TileImageToColumnOutputWidth(descriptor);
    if output_height <= 0 || output_width <= 0 then
        return FALSE;
    end;
    let logical_rows: integer = descriptor.batches * descriptor.depth *
        output_height * output_width;
    let logical_columns: integer = descriptor.channel_groups *
        descriptor.filter_height * descriptor.filter_width *
        descriptor.channels_per_group;
    if position_m + destination_tile.valid_rows > logical_rows ||
       position_k + destination_tile.valid_columns > logical_columns then
        return FALSE;
    end;
    return TileImageToColumnReferencedSourcesDefined(
        source,
        destination,
        position_m,
        position_k,
        output_height,
        output_width);
end;
```
<!-- GENERATED-ASL-END: unit -->
