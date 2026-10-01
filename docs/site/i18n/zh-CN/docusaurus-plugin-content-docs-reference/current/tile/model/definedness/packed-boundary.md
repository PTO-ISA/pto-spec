<!-- GENERATED FROM: asl/tile/model/definedness/packed-boundary.asl -->
# Packed Boundary

**Normative ASL source:** `asl/tile/model/definedness/packed-boundary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-definedness-packed-boundary-purpose role=purpose-scope -->
## 用途与范围

本单元定义模型如何存储逻辑元素个数大于其载荷数组的 Tile，以及具有四位元素的 Tile。它把每个逻辑元素映射到一个 64 位载体 Word 的某个通道，并为该元素单独保存一个已定义性位。

它还定义 E2M1X2 和 E1M2X2 的行配对存储，包括奇数行末尾的填充通道。

<!-- PTO-READER-BLOCK: tile-model-definedness-packed-boundary-concepts role=concepts-state -->
## 概念与可见状态

载体是一个 64 位载荷 Word。它容纳 `64 / element_bits` 个逻辑元素：16 个四位元素、8 个八位元素、4 个十六位元素、2 个三十二位元素或 1 个六十四位元素。`TilePackedCarrierIndex` 是元素索引除以该个数的商，`TilePackedLaneIndex` 是余数。

对于具有四位类型、或物理元素多于 `PTO_MODEL_TILE_ELEMENTS` 个的非 CUBE Tile，`TileUsesPackedCarrierRepresentation` 为 TRUE。这样的 Tile 在 `packed_defined_elements` 中记录已定义性，该位图有 524288 位。

设计要点：载体表示使每个被接受的 256 KiB 描述符都可以表示，而无需一个含 524288 个 Word 的 `TileInfo`。524288 是一个 256 KiB 四位 Tile 的逻辑元素个数，当每个 Word 承载多个元素时，32768 个载荷 Word 就足够。`PTO_MODEL_TILE_ELEMENTS` 是模型界限，而不是架构层面的元素上限。

<!-- PTO-READER-BLOCK: tile-model-definedness-packed-boundary-rules role=rules-interactions -->
## 规则与交互

`TileReadLogicalElement` 和 `TileInfoWithLogicalElementAndDefined` 自动选择表示方式。使用载体表示时，它们只读取或替换所选的通道和位。否则，它们对每个元素使用一个载荷 Word 和一个 `defined_elements` 位。

对于使用行内配对的打包四位 RowMajor Tile，线性索引为 `(row x pair_columns + column / 2) x 2 + column mod 2`，其中 `pair_columns` 为 `(columns + 1) / 2` 向下取整。其他打包 Tile 使用普通的 RowMajor、ColumnMajor、ZN 或 NZ 顺序。

设计要点：E2M1X2 和 E1M2X2 在一行内把相邻列配对。当列数为奇数时，最后一对的第二个通道是物理行填充。让配对保持在行内，可以防止该填充通道与下一行的第一个元素形成别名。

设计要点：该填充通道是存储，而不是逻辑元素。`TilePackedRowPaddingColumn` 使第 `columns` 列可以作为已定义性查询被寻址，而元素已定义性所有者总是把它报告为未定义。`ApplyTilePadding` 仍然可以用填充值写入它。

<!-- PTO-READER-BLOCK: tile-model-definedness-packed-boundary-boundaries role=boundaries -->
## 架构边界

CUBE 布局从不使用这种表示；它们有自己的 CELL 索引方式。

`HiF4X2`、`S4X2` 和 `U4X2` 是四位类型并使用载体，但它们不使用行内配对。

`TileWithPackedZeroValidRegionDefined` 和 `TileWithPackedZeroSelectedMaxRegionDefined` 是加载路径和 Shared 搬运路径在每个加载字节都为零时使用的捷径。源注释说明前者是可执行模型的快速路径，绝不是架构层面的替代表示；它产生的结果与普通加载相同。

<!-- PTO-READER-BLOCK: tile-model-definedness-packed-boundary-example role=example-usage -->
## 非规范阅读示例

一个 E2M1X2 RowMajor Tile 有 5 列。每行有 3 对，即 6 个通道。

| 元素 | 线性索引 | 载体 | 通道 |
| --- | --- | --- | --- |
| 第 0 行，第 4 列 | 4 | 0 | 4 |
| 第 0 行，填充通道 | 5 | 0 | 5 |
| 第 1 行，第 0 列 | 6 | 0 | 6 |
| 第 2 行，第 4 列 | 16 | 1 | 0 |

第 1 行从索引 6 而不是 5 开始，因为第 0 行的填充通道被保留。每个载体容纳 16 个通道，因此索引 16 开始第二个载体。

一个具有 65536 个物理元素的 FP32 Tile（一个 256 KiB Shared Tile）超过 32768，因此也使用载体，每个 Word 2 个元素。

<!-- PTO-READER-BLOCK: tile-model-definedness-packed-boundary-related role=related-owners-navigation -->
## 相关所有者

- [元素已定义性](elements.md)在这些辅助函数之上构建通用读取、写入和填充。
- [行与列](../shape/rows-columns.md)使用 `PackedTileRowStorageBytes` 推导行数。
- [类型](../state/types.md)定义 `PackedTileDefinedElements`。
- [加载与存储](../memory/load-store.md)使用零加载捷径。
- [打包数据类型](../../../arch/data-types/packed.md)描述打包格式。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/definedness/packed-boundary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","surface":"tile","classification":["model","definedness","packed-boundary"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
// Large logical Tiles use the existing 32768 Word payload slots as complete
// carriers. One carrier holds 16, 8, 4, 2, or 1 logical elements according to
// element width. The companion definedness map is total, so every accepted
// 256 KiB descriptor is representable without a 524288-Word TileInfo.
pure func PackedTileDataTypeIsFourBit(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_HiF4X2 ||
           data_type == TileDataType_S4X2 ||
           data_type == TileDataType_U4X2;
end;

// E2M1X2 and E1M2X2 are the packed-X2 formats whose canonical ordinary
// storage pairs adjacent logical columns within each row.  The other four-bit
// types retain their existing generic packed representation.
pure func PackedTileDataTypeUsesRowLocalPairs(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2;
end;

pure func PackedTileRowPairColumns(
    columns: integer {1..65535}) => integer {1..32768}
begin
    return ((columns + 1) DIVRM 2) as integer {1..32768};
end;

pure func PackedTileRowStorageBytes(
    columns: integer {1..65535}, data_type: TileDataType) => integer
begin
    assert PackedTileDataTypeUsesRowLocalPairs(data_type);
    return PackedTileRowPairColumns(columns);
end;

// Return the first packed element of one row-local pair.  The second lane of
// the final pair is physical row padding when the logical column count is
// odd; keeping the pair base row-local prevents that padding from aliasing the
// next row.
readonly func TilePackedRowPairIndex(
    tile: TileInfo,
    row: integer {0..65535},
    pair: integer {0..65535}) => PackedTileElementIndex
begin
    assert tile.layout == TileLayout_RowMajor;
    assert PackedTileDataTypeUsesRowLocalPairs(tile.data_type);
    assert tile.columns > 0;
    let pair_columns = PackedTileRowPairColumns(
        tile.columns as integer {1..65535});
    assert row < tile.rows && pair < pair_columns;
    var index: integer = (row * pair_columns + pair) * 2;
    assert index < PackedTileLogicalCapacity(
        tile.capacity_bytes, tile.data_type);
    return index as PackedTileElementIndex;
end;

readonly func TilePackedRowSlackIndex(
    tile: TileInfo, row: integer {0..65535}) => PackedTileElementIndex
begin
    assert tile.columns MOD 2 == 1;
    return (TilePackedRowPairIndex(tile, row,
        PackedTileRowPairColumns(tile.columns as integer {1..65535}) - 1) + 1)
        as PackedTileElementIndex;
end;

readonly func TilePackedRowsHavePhysicalSlack(tile: TileInfo) => boolean
begin
    return tile.layout == TileLayout_RowMajor &&
           PackedTileDataTypeUsesRowLocalPairs(tile.data_type) &&
           tile.columns MOD 2 == 1;
end;

// The lane immediately past an odd physical column count is the second lane of
// the final row-local pair.  It is storage, not a logical element, so it is
// addressable as a definedness query and is always reported undefined.
readonly func TilePackedRowPaddingColumn(tile: TileInfo,
                                        row: integer {0..65535},
                                        column: integer {0..65535}) => boolean
begin
    return TilePackedRowsHavePhysicalSlack(tile) &&
           row < tile.rows && column == tile.columns;
end;

readonly func TileInfoWithPackedRowSlack(
    tile: TileInfo, row: integer {0..65535}, value: Word,
    defined: boolean) => TileInfo
begin
    return TileInfoWithLogicalElementAndDefined(tile,
        TilePackedRowSlackIndex(tile, row), value, defined);
end;

pure func PackedTileElementBits(data_type: TileDataType) => integer {4,8,16,32,64}
begin
    return TileElementBits(data_type);
end;

pure func PackedTileElementsPerCarrier(
    data_type: TileDataType) => integer {1,2,4,8,16}
begin
    return (64 DIVRM PackedTileElementBits(data_type))
        as integer {1,2,4,8,16};
end;

readonly func PackedTileLogicalCapacity(capacity_bytes: integer {0..262144},
                                        data_type: TileDataType)
                                        => integer {1..524288}
begin
    assert capacity_bytes > 0;
    return ((capacity_bytes * 8) DIVRM PackedTileElementBits(data_type))
        as integer {1..524288};
end;

readonly func TilePackedCarrierIndex(data_type: TileDataType,
                                     element: PackedTileElementIndex)
    => PackedTileCarrierIndex
begin
    var carrier: integer = 0;
    carrier = element DIVRM PackedTileElementsPerCarrier(data_type);
    assert carrier < PTO_MODEL_TILE_ELEMENTS;
    return carrier as PackedTileCarrierIndex;
end;

readonly func TilePackedLaneIndex(data_type: TileDataType,
                                  element: PackedTileElementIndex)
    => PackedTileLaneIndex
begin
    var lane: integer = 0;
    lane = element MOD PackedTileElementsPerCarrier(data_type);
    assert lane <= 15;
    return lane as PackedTileLaneIndex;
end;

pure func PackedTileNibbleFromWord(word: Word,
                                  nibble: PackedTileLaneIndex) => bits(4)
begin
    case nibble of
        when 0 => return word[3:0];
        when 1 => return word[7:4];
        when 2 => return word[11:8];
        when 3 => return word[15:12];
        when 4 => return word[19:16];
        when 5 => return word[23:20];
        when 6 => return word[27:24];
        when 7 => return word[31:28];
        when 8 => return word[35:32];
        when 9 => return word[39:36];
        when 10 => return word[43:40];
        when 11 => return word[47:44];
        when 12 => return word[51:48];
        when 13 => return word[55:52];
        when 14 => return word[59:56];
        when 15 => return word[63:60];
    end;
end;

pure func PackedTileWordWithNibble(word: Word,
                                  nibble: PackedTileLaneIndex,
                                  value: Word) => Word
begin
    var result = word;
    case nibble of
        when 0 => result[3:0] = value[3:0];
        when 1 => result[7:4] = value[3:0];
        when 2 => result[11:8] = value[3:0];
        when 3 => result[15:12] = value[3:0];
        when 4 => result[19:16] = value[3:0];
        when 5 => result[23:20] = value[3:0];
        when 6 => result[27:24] = value[3:0];
        when 7 => result[31:28] = value[3:0];
        when 8 => result[35:32] = value[3:0];
        when 9 => result[39:36] = value[3:0];
        when 10 => result[43:40] = value[3:0];
        when 11 => result[47:44] = value[3:0];
        when 12 => result[51:48] = value[3:0];
        when 13 => result[55:52] = value[3:0];
        when 14 => result[59:56] = value[3:0];
        when 15 => result[63:60] = value[3:0];
    end;
    return result;
end;

pure func PackedTileElementFromWord(word: Word,
                                    lane: PackedTileLaneIndex,
                                    data_type: TileDataType) => Word
begin
    let element_bits = PackedTileElementBits(data_type);
    if element_bits == 4 then
        return ZeroExtend{PTO_XLEN}(PackedTileNibbleFromWord(word, lane));
    elsif element_bits == 8 then
        assert lane <= 7;
        if lane == 0 then return ZeroExtend{PTO_XLEN}(word[7:0]);
        elsif lane == 1 then return ZeroExtend{PTO_XLEN}(word[15:8]);
        elsif lane == 2 then return ZeroExtend{PTO_XLEN}(word[23:16]);
        elsif lane == 3 then return ZeroExtend{PTO_XLEN}(word[31:24]);
        elsif lane == 4 then return ZeroExtend{PTO_XLEN}(word[39:32]);
        elsif lane == 5 then return ZeroExtend{PTO_XLEN}(word[47:40]);
        elsif lane == 6 then return ZeroExtend{PTO_XLEN}(word[55:48]);
        else return ZeroExtend{PTO_XLEN}(word[63:56]);
        end;
    elsif element_bits == 16 then
        assert lane <= 3;
        if lane == 0 then return ZeroExtend{PTO_XLEN}(word[15:0]);
        elsif lane == 1 then return ZeroExtend{PTO_XLEN}(word[31:16]);
        elsif lane == 2 then return ZeroExtend{PTO_XLEN}(word[47:32]);
        else return ZeroExtend{PTO_XLEN}(word[63:48]);
        end;
    elsif element_bits == 32 then
        assert lane <= 1;
        if lane == 0 then return ZeroExtend{PTO_XLEN}(word[31:0]);
        else return ZeroExtend{PTO_XLEN}(word[63:32]);
        end;
    end;
    assert element_bits == 64 && lane == 0;
    return word;
end;

pure func PackedTileWordWithElement(word: Word,
                                    lane: PackedTileLaneIndex,
                                    data_type: TileDataType,
                                    value: Word) => Word
begin
    let element_bits = PackedTileElementBits(data_type);
    if element_bits == 4 then
        return PackedTileWordWithNibble(word, lane, value);
    end;
    var result = word;
    if element_bits == 8 then
        assert lane <= 7;
        if lane == 0 then result[7:0] = value[7:0];
        elsif lane == 1 then result[15:8] = value[7:0];
        elsif lane == 2 then result[23:16] = value[7:0];
        elsif lane == 3 then result[31:24] = value[7:0];
        elsif lane == 4 then result[39:32] = value[7:0];
        elsif lane == 5 then result[47:40] = value[7:0];
        elsif lane == 6 then result[55:48] = value[7:0];
        else result[63:56] = value[7:0];
        end;
    elsif element_bits == 16 then
        assert lane <= 3;
        if lane == 0 then result[15:0] = value[15:0];
        elsif lane == 1 then result[31:16] = value[15:0];
        elsif lane == 2 then result[47:32] = value[15:0];
        else result[63:48] = value[15:0];
        end;
    elsif element_bits == 32 then
        assert lane <= 1;
        if lane == 0 then result[31:0] = value[31:0];
        else result[63:32] = value[31:0];
        end;
    else
        assert element_bits == 64 && lane == 0;
        result = value;
    end;
    return result;
end;

readonly func ZeroPackedTileDefinedElements() => PackedTileDefinedElements
begin
    return Zeros{524288};
end;

readonly func TilePackedLinearIndex(tile: TileInfo,
                                    row: integer {0..65535},
                                    column: integer {0..65535})
                                    => PackedTileElementIndex
begin
    assert !TileLayoutIsCube(tile.layout);
    assert row < tile.rows && column < tile.columns;
    var index: integer = 0;
    if tile.layout == TileLayout_RowMajor then
        if PackedTileDataTypeUsesRowLocalPairs(tile.data_type) then
            let pair_columns = PackedTileRowPairColumns(
                tile.columns as integer {1..65535});
            index = (row * pair_columns + (column DIVRM 2)) * 2 +
                    (column MOD 2);
        else
            index = row * tile.columns + column;
        end;
    elsif tile.layout == TileLayout_ColumnMajor then
        index = column * tile.rows + row;
    else
        let inner_elements = (256 DIV PackedTileElementBits(tile.data_type))
            as integer {4,8,16,32,64};
        let block_rows: integer = tile.rows DIVRM 16;
        let block_columns: integer = tile.columns DIVRM inner_elements;
        let block_row: integer = row DIVRM 16;
        let block_column: integer = column DIVRM inner_elements;
        let inner_row: integer = row MOD 16;
        let inner_column: integer = column MOD inner_elements;
        let block_elements: integer = 16 * inner_elements;
        if tile.layout == TileLayout_ZN then
            index = (block_row * block_columns + block_column) *
                    block_elements + inner_column * 16 + inner_row;
        else
            assert tile.layout == TileLayout_NZ;
            index = (block_column * block_rows + block_row) *
                    block_elements + inner_row * inner_elements +
                    inner_column;
        end;
    end;
    assert index < PackedTileLogicalCapacity(tile.capacity_bytes,
                                              tile.data_type);
    return index as PackedTileElementIndex;
end;

readonly func TileUsesPackedCarrierRepresentation(tile: TileInfo) => boolean
begin
    return !TileLayoutIsCube(tile.layout) &&
           (PackedTileDataTypeIsFourBit(tile.data_type) ||
            tile.rows * tile.columns > PTO_MODEL_TILE_ELEMENTS);
end;

readonly func TileLogicalElementDefined(tile: TileInfo,
                                        element: PackedTileElementIndex)
                                        => boolean
begin
    if TileUsesPackedCarrierRepresentation(tile) then
        return tile.packed_defined_elements[element] == '1';
    end;
    return tile.defined_elements[element as ModelTileElementIndex] == '1';
end;

readonly func TileReadLogicalElement(tile: TileInfo,
                                     element: PackedTileElementIndex) => Word
begin
    if TileUsesPackedCarrierRepresentation(tile) then
        let carrier = TilePackedCarrierIndex(tile.data_type, element);
        let lane = TilePackedLaneIndex(tile.data_type, element);
        return PackedTileElementFromWord(
            tile.payload[[carrier]], lane, tile.data_type);
    end;
    return tile.payload[[element as ModelTileElementIndex]];
end;

// A newly allocated decoded TLOAD destination may have a complete physical
// packed shape while every selected GM byte is zero.  This helper preserves
// the ordinary TLOAD result (zero payload, full valid-region definedness) in
// one carrier-state update; it is used only by the executable model's
// zero-stride fast path, never as an architectural alternate representation.
func TileWithPackedZeroValidRegionDefined(tile: TileInfo) => TileInfo
begin
    assert PackedTileDataTypeIsFourBit(tile.data_type);
    assert tile.valid_rows == tile.rows && tile.valid_columns == tile.columns;
    assert tile.rows * tile.columns ==
        PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type);
    var result = tile;
    result.packed_defined_elements = Ones{524288};
    result.defined_valid_elements =
        (tile.valid_rows * tile.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;

func TileWithPackedZeroSelectedMaxRegionDefined(tile: TileInfo,
                                                pe_mask: bits(4)) => TileInfo
begin
    assert PackedTileDataTypeIsFourBit(tile.data_type);
    assert tile.capacity_bytes == 262144;
    assert tile.valid_rows == tile.rows && tile.valid_columns == tile.columns;
    assert tile.rows * tile.columns ==
        PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type);
    var result = tile;
    result.packed_defined_elements = Zeros{524288};
    if pe_mask[PTOPEMaskBitOfPEIdentity(0)] == '1' then
        result.packed_defined_elements[0 +: 131072] = Ones{131072};
    end;
    if pe_mask[PTOPEMaskBitOfPEIdentity(1)] == '1' then
        result.packed_defined_elements[131072 +: 131072] = Ones{131072};
    end;
    if pe_mask[PTOPEMaskBitOfPEIdentity(2)] == '1' then
        result.packed_defined_elements[262144 +: 131072] = Ones{131072};
    end;
    if pe_mask[PTOPEMaskBitOfPEIdentity(3)] == '1' then
        result.packed_defined_elements[393216 +: 131072] = Ones{131072};
    end;
    result.defined_valid_elements =
        (tile.valid_rows * tile.valid_columns) as integer {0..524288};
    result.contents_defined = pe_mask == '1111';
    return result;
end;

readonly func TileInfoWithLogicalElementAndDefined(tile: TileInfo,
                                                   element: PackedTileElementIndex,
                                                   value: Word,
                                                   defined: boolean) => TileInfo
begin
    var result = tile;
    if TileUsesPackedCarrierRepresentation(tile) then
        let carrier = TilePackedCarrierIndex(tile.data_type, element);
        let lane = TilePackedLaneIndex(tile.data_type, element);
        result.payload[[carrier]] = PackedTileWordWithElement(
            tile.payload[[carrier]], lane, tile.data_type, value);
        result.packed_defined_elements[element] =
            if defined then '1' else '0';
    else
        result.payload[[element as ModelTileElementIndex]] = value;
        result.defined_elements[element as ModelTileElementIndex] =
            if defined then '1' else '0';
    end;
    return result;
end;

readonly func TileInfoWithLogicalElement(tile: TileInfo,
                                         element: PackedTileElementIndex,
                                         value: Word) => TileInfo
begin
    return TileInfoWithLogicalElementAndDefined(tile, element, value, TRUE);
end;

func WriteTileLogicalElement(index: TileIndex,
                             element: PackedTileElementIndex,
                             value: Word)
begin
    _Tiles[[index]] = TileInfoWithLogicalElement(
        _Tiles[[index]], element, value);
end;

readonly func ReadTileLogicalElement(index: TileIndex,
                                     element: PackedTileElementIndex) => Word
begin
    let tile = _Tiles[[index]];
    assert TileLogicalElementDefined(tile, element);
    return TileReadLogicalElement(tile, element);
end;
```
<!-- GENERATED-ASL-END: unit -->
