<!-- GENERATED FROM: asl/tile/model/legality/memory-schema.asl -->
# Memory Schema

**Normative ASL source:** `asl/tile/model/legality/memory-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义 Tile 移动、常规加载与存储、预取以及索引 gather 与 scatter 的操作数合法性谓词。`PTO-INSTRUCTION` 元数据把它们列为合法性处理器：

- `TileOperandsLegal_TMOV` 用于 TMOV。
- `TileOperandsLegal_TLOAD` 与 `TileOperandsLegal_TSTORE` 用于 TLOAD 与 TSTORE。
- `TileOperandsLegal_TPREFETCH` 用于 TPREFETCH。
- `TileOperandsLegal_MGATHER`、`TileOperandsLegal_MSCATTER`、`TileOperandsLegal_MGATHER_MASK` 与 `TileOperandsLegal_MSCATTER_MASK` 用于四种索引转移。

它还定义了 `TileOperandsLegal_MGATHER_CAS` 以及共享的已定义性辅助函数 `IndexedTLSUExecutionMaskContentsDefined`。

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-concepts role=concepts-state -->
## 概念与可见状态

所有谓词都是 `readonly`。它们读取 Tile 描述符、Tile 载荷已定义性以及指令束 ExecutionMask，不访问内存。

索引 Tile 为每次转移保存一个相对基地址的字节位移。掩码 Tile 为每个元素保存一个 U8 值，该值必须是 0 或 1。打包四位数据 Tile 每个字节保存两个元素，因此一个索引覆盖一对数据元素。

`IndexedTLSUExecutionMaskContentsDefined` 首先要求 `IndexedTLSUNumericDescriptorLegal`。没有 ExecutionMask 时它返回 `contents_defined`。存在掩码时，该 Tile 必须与掩码的布局和有效行数相同，其有效列数必须等于掩码的有效列数，打包类型则为其两倍。随后每个活动坐标都必须已定义；对打包类型，该对中的两个半字节都必须已定义。

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-rules role=rules-interactions -->
## 规则与交互

`TileOperandsLegal_TMOV` 用 `ResolveTileCarrierOperationType` 解析操作类型，要求逻辑形状与存储种类匹配、源同位宽，并要求目标后备类型等于源后备类型。

设计要点：TMOV 是唯一使 `TileOperationUsesSourceBackingDestination` 为 TRUE 的操作。目标以源的后备类型分配，而合法性要求二者相等，因此 TMOV 复制原始位，从不重新标记类型。

TLOAD 与 TSTORE 要求描述符合法，且类型被 `TileRegularTLSUDataTypeSupported` 接受。该表列出 25 种类型，包括五种打包类型。E6M2 与 RCPE6M2 不在其中。

索引转移要求：

- 数据 Tile 为 RowMajor、CUBE_M16 或 CUBE_M32 的数值 Tile，且数据、索引与掩码 Tile 的布局一致。
- 索引类型为 S32、U32、S64 或 U64。
- 有效行数相等，有效列数满足 `IndexedTLSUDataShapeMatchesIndex`：相等，或对打包数据类型为索引列数的两倍。
- 对带掩码的形式，掩码须以索引 Tile 的有效形状通过 `IndexedTLSUPredicateValuesLegal`。

`TileOperandsLegal_MGATHER_CAS` 要求数据为非打包类型，且目标、期望值与替换值 Tile 的数据类型相同。

TPREFETCH 没有 Tile 操作数。其谓词要求 `ValidCol <= Col`、`Col` 为 2 的幂，且 `ValidRow x ValidCol` 不超过 `PTO_MODEL_TILE_ELEMENTS`。六参数形式还要求 `TileCarrierOrPackedBaselineDataTypeSupported`，它排除 64 位类型。

设计要点：源与索引载荷在任何内存请求之前检查已定义性。在 ExecutionMask 下只有活动坐标必须已定义，因此非活动通道可以保存未定义值而不导致指令束被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-boundaries role=boundaries -->
## 架构边界

这些谓词在预检中运行。在 MGATHER、MGATHER_MASK 与 MGATHER_CAS 的指令束分派路径中，目标先被解析；若随后谓词失败，目标分配被回滚，并在 gather 读取内存之前产生 `Fault_TileLegality`。

它们只检查操作数。地址转换、权限与内存故障属于内存单元。

元数据把 `GM_ATOM_CAS` 列为 MGATHER_CAS 的合法性处理器。指令束分派路径调用本单元的 `TileOperandsLegal_MGATHER_CAS`，并另外把数据类型限制为 U16、U32 或 U64。

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-example role=example-usage -->
## 非规范阅读示例

一个 MGATHER 目标为 U4X2、RowMajor，有效区域为 8 x 32。索引 Tile 为 S32、RowMajor，有效区域为 8 x 16。没有 ExecutionMask。

- 有效行数匹配：8 与 8。
- U4X2 是打包类型，因此数据列数必须为偶数且等于 2 x 16 = 32。满足。
- S32 是合法的索引类型，两个 Tile 都是 RowMajor。
- 由于没有掩码，索引 Tile 必须完全已定义。

8 x 16 = 128 个索引元素中的每一个覆盖一对 4 位目标元素。若目标有效列数为 16，则不满足配对规则，指令束会被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-memory-schema-related role=related-owners-navigation -->
## 相关所有者

- [索引布局](indexed-layout.md) 定义索引描述符、索引类型与形状配对辅助函数。
- [谓词载体](predicate-carriers.md) 定义 `IndexedTLSUPredicateValuesLegal`。
- [数据类型与布局表](dtype-layout.md) 定义 TLOAD 与 TPREFETCH 的类型表。
- [Gather 与 scatter](../memory/gather-scatter.md) 执行索引转移。
- [MGATHER 分派](../../../block/model/dispatch/tlsu-mgather.md) 展示谓词在指令束中的运行位置。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/memory-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","surface":"tile","classification":["model","legality","memory-schema"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
readonly func IndexedTLSUExecutionMaskContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSUNumericDescriptorLegal(index) then return FALSE; end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows then
        return FALSE;
    end;
    if TileDataTypeIsFourBit(tile.data_type) then
        if tile.valid_columns !=
           2 * _BundleExecutionMask.valid_columns then return FALSE; end;
    elsif tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to _BundleExecutionMask.valid_rows - 1 looplimit 65536 do
        for column = 0 to _BundleExecutionMask.valid_columns - 1
            looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let first_column = if TileDataTypeIsFourBit(tile.data_type)
                    then 2 * column else column;
                let first = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                if !TileLogicalElementDefined(tile, first) then
                    return FALSE;
                end;
                if TileDataTypeIsFourBit(tile.data_type) then
                    let second = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    if !TileLogicalElementDefined(tile, second) then
                        return FALSE;
                    end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TMOV(destination: TileIndex,
                                     source: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    return operation_type_valid &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].storage_kind ==
               _Tiles[[source]].storage_kind &&
           TileCarrierWidthCompatible(
               _Tiles[[source]].data_type, operation_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TLOAD(destination: TileIndex,
                                      base_address: Word,
                                      row_stride_bytes: Word) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileRegularTLSUDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_TSTORE(base_address: Word,
                                       row_stride_bytes: Word,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(source) &&
           TileRegularTLSUDataTypeSupported(
               _Tiles[[source]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[destination]].valid_rows,
               _Tiles[[destination]].valid_columns,
               _Tiles[[indices]].valid_rows,
               _Tiles[[indices]].valid_columns,
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER(
        destination, base_address, indices, TilePad_Null);
end;

readonly func TileOperandsLegal_MSCATTER(
    base_address: Word, source: TileIndex, indices: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(source) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[source]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
               _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
               _Tiles[[source]].data_type) &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout;
end;

readonly func TileOperandsLegal_MGATHER_MASK(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    mask: TileIndex, pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUPredicateValuesLegal(mask) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[destination]].valid_rows,
               _Tiles[[destination]].valid_columns,
               _Tiles[[indices]].valid_rows,
               _Tiles[[indices]].valid_columns,
               _Tiles[[destination]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MSCATTER_MASK(
    base_address: Word, source: TileIndex, indices: TileIndex,
    mask: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(source) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUPredicateValuesLegal(mask) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[source]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
               _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
               _Tiles[[source]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout &&
           _Tiles[[source]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[expected]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[expected]].valid_columns &&
           _Tiles[[destination]].valid_rows ==
               _Tiles[[replacement]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[replacement]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[expected]].data_type &&
           _Tiles[[destination]].data_type ==
               _Tiles[[replacement]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[expected]].layout &&
           _Tiles[[destination]].layout == _Tiles[[replacement]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    expected: TileIndex, replacement: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER_CAS(destination, base_address,
        indices, expected, replacement, TilePad_Null);
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, row_stride_elements: Word,
    valid_columns: integer {1..65535},
    valid_rows: integer {1..65535},
    columns: integer {1..65535}) => boolean
begin
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, row_stride_elements: Word,
    valid_columns: integer {1..65535},
    valid_rows: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    return TileOperandsLegal_TPREFETCH(
               base_address, row_stride_elements, valid_columns,
               valid_rows, columns) &&
           TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
