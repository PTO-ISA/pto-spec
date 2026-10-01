<!-- GENERATED FROM: asl/tile/model/state/feature-map-descriptors.asl -->
# Feature Map Descriptors

**Normative ASL source:** `asl/tile/model/state/feature-map-descriptors.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `PTO-STATE-TILE-FEATURE-MAP`：为 64 个 Local Tile 寄存器中的每一个提供一个可选的卷积特征图描述符。特征图描述符记录应如何把 Tile 的载荷读作图像张量，包括滤波器、步长、膨胀和填充参数。

它定义描述符记录、一个配置转换、一个失效转换、一个读取辅助函数和一个结构有效性检查。

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-concepts role=concepts-state -->
## 概念与可见状态

`_TileFeatureMapDescriptors` 为每个 Local 寄存器保存一个 `TileFeatureMapDescriptor`。其字段为：

- `valid`，表示该描述符是否可以使用。
- `layout`，取值为 `TileFeatureMapLayout_NC1HWC0` 或 `TileFeatureMapLayout_NDC1HWC0`。
- 张量范围 `batches`、`depth`、`channel_groups`、`height`、`width` 和 `channels_per_group`。
- 窗口参数 `filter_height`、`filter_width`、`stride_height`、`stride_width`、`dilation_height` 和 `dilation_width`。
- 边界 `pad_left`、`pad_right`、`pad_top` 和 `pad_bottom`，以及作为 Word 的 `padding` 值。
- `logical_channels`（真实通道数）以及 `transposed`。

在 C1/C0 记法中，通道被划分为 `channel_groups` 个组，每组 `channels_per_group` 个通道。

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-rules role=rules-interactions -->
## 规则与交互

`ConfigureTileFeatureMapDescriptor` 断言目标寄存器已分配，然后写入每个字段并设置 `valid`。

`TileFeatureMapDescriptorStructurallyValid` 仅在以下条件全部成立时返回 TRUE：

- 描述符有效且未转置。
- NC1HWC0 描述符的 `depth` 等于 1。
- `logical_channels` 至多为 `channel_groups x channels_per_group`。
- 物理元素数 `batches x depth x channel_groups x height x width x channels_per_group` 既不超过 Tile 的逻辑元素容量，也不超过其 `rows x columns` 形状。

设计要点：特征图是某一次分配的视图。每个 Local 分配转换和 `ReleaseTile` 都会调用 `InvalidateTileFeatureMapDescriptor`，复位也会清除每个寄存器的 `valid`。因此新的形状或数据类型永远不会继承陈旧的张量视图。

设计要点：`logical_channels` 可以小于 `channel_groups x channels_per_group`。有效性检查只限制其上界，物理元素数始终按完整的分组通道数计算。

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-boundaries role=boundaries -->
## 架构边界

在当前 ASL 树中，本单元之外对该状态的引用只有分配与释放时的失效操作以及复位清除。目前没有任何指令所有者调用配置或有效性辅助函数。

该检查只验证结构。它不检查 `padding`、窗口参数或载荷已定义性。

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-example role=example-usage -->
## 非规范阅读示例

取一个 1024 字节、16 列的 FP16 Tile。其推导行数为 1024 x 8 / (16 x 16) = 32，逻辑容量为 512 个元素。

配置一个 NC1HWC0 描述符：1 个 batch、depth 1、2 个通道组、height 4、width 4、每组 16 个通道，以及 20 个逻辑通道。

- depth 为 1，符合 NC1HWC0 的要求。
- 20 个逻辑通道可以放入 2 x 16 = 32 个分组通道。
- 物理元素数为 1 x 1 x 2 x 4 x 4 x 16 = 512，既不超过 512 个逻辑元素，也不超过 32 x 16 个形状元素。

该描述符在结构上有效。重新分配该寄存器会使它再次无效。

<!-- PTO-READER-BLOCK: tile-model-state-feature-map-descriptors-related role=related-owners-navigation -->
## 相关所有者

- [分配](allocation.md)在每次分配和释放时使该描述符失效。
- [Local 寄存器](local-registers.md)声明本单元读取的 `_Tiles`。
- [描述符](descriptors.md)提供 `TileLogicalElementCapacity`。
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
