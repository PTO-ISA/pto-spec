<!-- GENERATED FROM: asl/tile/model/state/feature-map-descriptors.asl -->
# Feature Map Descriptors

**Normative ASL source:** `asl/tile/model/state/feature-map-descriptors.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-purpose role=purpose-scope -->
## Purpose and scope

This unit owns `PTO-STATE-TILE-FEATURE-MAP`: one optional convolution feature-map descriptor for each of the 64 Local Tile registers. A feature-map descriptor records how a Tile's payload should be read as an image tensor, including filter, stride, dilation, and padding parameters.

It defines the descriptor record, a configure transition, an invalidate transition, a read helper, and a structural validity check.

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-concepts role=concepts-state -->
## Concepts and visible state

`_TileFeatureMapDescriptors` holds one `TileFeatureMapDescriptor` per Local register. Its fields are:

- `valid`, which says whether the descriptor may be used.
- `layout`, either `TileFeatureMapLayout_NC1HWC0` or `TileFeatureMapLayout_NDC1HWC0`.
- The tensor extents `batches`, `depth`, `channel_groups`, `height`, `width`, and `channels_per_group`.
- The window parameters `filter_height`, `filter_width`, `stride_height`, `stride_width`, `dilation_height`, and `dilation_width`.
- The border `pad_left`, `pad_right`, `pad_top`, and `pad_bottom`, with the `padding` value as a Word.
- `logical_channels`, the number of real channels, and `transposed`.

In the C1/C0 notation, channels are split into `channel_groups` groups of `channels_per_group` channels each.

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-rules role=rules-interactions -->
## Rules and interactions

`ConfigureTileFeatureMapDescriptor` asserts that the target register is allocated, then writes every field and sets `valid`.

`TileFeatureMapDescriptorStructurallyValid` returns TRUE only when all of these hold:

- The descriptor is valid and not transposed.
- An NC1HWC0 descriptor has `depth` equal to 1.
- `logical_channels` is at most `channel_groups x channels_per_group`.
- The physical element count, `batches x depth x channel_groups x height x width x channels_per_group`, fits both the Tile's logical element capacity and its `rows x columns` shape.

Design point: a feature map is a view of one allocation. `InvalidateTileFeatureMapDescriptor` is called by every Local allocation transition and by `ReleaseTile`, and reset clears `valid` for every register. A new shape or data type therefore never inherits a stale tensor view.

Design point: `logical_channels` may be smaller than `channel_groups x channels_per_group`. The validity check only bounds it from above, and the physical element count is always computed from the full grouped channel count.

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-boundaries role=boundaries -->
## Architectural boundaries

Within the current ASL tree, the only references to this state outside this unit are the allocation and release invalidations and the reset clear. No instruction owner calls the configure or validity helpers today.

The check validates structure only. It does not inspect `padding`, the window parameters, or payload definedness.

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-example role=example-usage -->
## Non-normative reading example

Take an FP16 Tile of 1024 bytes with 16 columns. Its derived rows are 1024 x 8 / (16 x 16) = 32, and its logical capacity is 512 elements.

Configure an NC1HWC0 descriptor with 1 batch, depth 1, 2 channel groups, height 4, width 4, 16 channels per group, and 20 logical channels.

- Depth is 1, as NC1HWC0 requires.
- 20 logical channels fit in 2 x 16 = 32 grouped channels.
- The physical count is 1 x 1 x 2 x 4 x 4 x 16 = 512, which fits both 512 logical elements and 32 x 16 shape elements.

The descriptor is structurally valid. Reallocating the register makes it invalid again.

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-related role=related-owners-navigation -->
## Related owners

- [Allocation](allocation.md) invalidates this descriptor on every allocation and release.
- [Local registers](local-registers.md) declares `_Tiles`, which this unit reads.
- [Descriptors](descriptors.md) supplies `TileLogicalElementCapacity`.
<!-- SUPPLEMENTARY-END -->

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
