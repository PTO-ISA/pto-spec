<!-- GENERATED FROM: asl/tile/model/state/feature-map-descriptors.asl -->
# Feature Map Descriptors

**Normative ASL source:** `asl/tile/model/state/feature-map-descriptors.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/feature-map-descriptors.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS","surface":"tile","classification":["model","state","feature-map-descriptors"],"depends_on":["PTO-TILE-MODEL-STATE-LOCAL-REGISTERS"]}
// PTO-STATE: {"id":"PTO-STATE-TILE-FEATURE-MAP","classification":["tile","feature-map"],"scope":"core","owner":"PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS","members":["_TileFeatureMapDescriptors"],"depends_on":["PTO-STATE-TILE-LOCAL"]}

type TileFeatureMapLayout of enumeration {
    TileFeatureMapLayout_NC1HWC0,
    TileFeatureMapLayout_NDC1HWC0
};

type TileFeatureMapDescriptor of record {
    valid: boolean,
    layout: TileFeatureMapLayout,
    batches: integer {1..65535},
    depth: integer {1..65535},
    channel_groups: integer {1..65535},
    height: integer {1..65535},
    width: integer {1..65535},
    channels_per_group: integer {1..65535},
    filter_height: integer {1..65535},
    filter_width: integer {1..65535},
    stride_height: integer {1..65535},
    stride_width: integer {1..65535},
    dilation_height: integer {1..65535},
    dilation_width: integer {1..65535},
    pad_left: integer {0..65535},
    pad_right: integer {0..65535},
    pad_top: integer {0..65535},
    pad_bottom: integer {0..65535},
    logical_channels: integer {1..65535},
    padding: Word,
    transposed: boolean
};

var _TileFeatureMapDescriptors :
    array [[PTO_TILE_REGISTER_COUNT]] of TileFeatureMapDescriptor;

readonly func ReadTileFeatureMapDescriptor(
    index: TileIndex) => TileFeatureMapDescriptor
begin
    return _TileFeatureMapDescriptors[[index]];
end;

func InvalidateTileFeatureMapDescriptor(index: TileIndex)
begin
    _TileFeatureMapDescriptors[[index]].valid = FALSE;
end;

func ConfigureTileFeatureMapDescriptor(
    index: TileIndex,
    layout: TileFeatureMapLayout,
    batches: integer {1..65535},
    depth: integer {1..65535},
    channel_groups: integer {1..65535},
    height: integer {1..65535},
    width: integer {1..65535},
    channels_per_group: integer {1..65535},
    filter_height: integer {1..65535},
    filter_width: integer {1..65535},
    stride_height: integer {1..65535},
    stride_width: integer {1..65535},
    dilation_height: integer {1..65535},
    dilation_width: integer {1..65535},
    pad_left: integer {0..65535},
    pad_right: integer {0..65535},
    pad_top: integer {0..65535},
    pad_bottom: integer {0..65535},
    logical_channels: integer {1..65535},
    padding: Word,
    transposed: boolean)
begin
    assert _Tiles[[index]].allocated;
    _TileFeatureMapDescriptors[[index]].valid = TRUE;
    _TileFeatureMapDescriptors[[index]].layout = layout;
    _TileFeatureMapDescriptors[[index]].batches = batches;
    _TileFeatureMapDescriptors[[index]].depth = depth;
    _TileFeatureMapDescriptors[[index]].channel_groups = channel_groups;
    _TileFeatureMapDescriptors[[index]].height = height;
    _TileFeatureMapDescriptors[[index]].width = width;
    _TileFeatureMapDescriptors[[index]].channels_per_group =
        channels_per_group;
    _TileFeatureMapDescriptors[[index]].filter_height = filter_height;
    _TileFeatureMapDescriptors[[index]].filter_width = filter_width;
    _TileFeatureMapDescriptors[[index]].stride_height = stride_height;
    _TileFeatureMapDescriptors[[index]].stride_width = stride_width;
    _TileFeatureMapDescriptors[[index]].dilation_height = dilation_height;
    _TileFeatureMapDescriptors[[index]].dilation_width = dilation_width;
    _TileFeatureMapDescriptors[[index]].pad_left = pad_left;
    _TileFeatureMapDescriptors[[index]].pad_right = pad_right;
    _TileFeatureMapDescriptors[[index]].pad_top = pad_top;
    _TileFeatureMapDescriptors[[index]].pad_bottom = pad_bottom;
    _TileFeatureMapDescriptors[[index]].logical_channels = logical_channels;
    _TileFeatureMapDescriptors[[index]].padding = padding;
    _TileFeatureMapDescriptors[[index]].transposed = transposed;
end;

readonly func TileFeatureMapDescriptorStructurallyValid(
    index: TileIndex) => boolean
begin
    let descriptor = ReadTileFeatureMapDescriptor(index);
    if !descriptor.valid || descriptor.transposed then
        return FALSE;
    end;
    if descriptor.layout == TileFeatureMapLayout_NC1HWC0 &&
       descriptor.depth != 1 then
        return FALSE;
    end;
    if descriptor.logical_channels >
       descriptor.channel_groups * descriptor.channels_per_group then
        return FALSE;
    end;
    let physical_elements: integer = descriptor.batches * descriptor.depth *
        descriptor.channel_groups * descriptor.height * descriptor.width *
        descriptor.channels_per_group;
    return physical_elements <=
               TileLogicalElementCapacity(_Tiles[[index]].capacity_bytes,
                   _Tiles[[index]].data_type) &&
           physical_elements <=
               _Tiles[[index]].rows * _Tiles[[index]].columns;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
