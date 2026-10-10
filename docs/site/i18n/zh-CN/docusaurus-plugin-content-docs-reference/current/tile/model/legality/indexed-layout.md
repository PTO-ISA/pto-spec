<!-- GENERATED FROM: asl/tile/model/legality/indexed-layout.asl -->
# Indexed Layout

**Normative ASL source:** `asl/tile/model/legality/indexed-layout.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-purpose role=purpose-scope -->
## 用途与范围

本单元负责索引 TLSU 操作的布局、类型与形状检查，以及 `TFMA` 和 `GMOV` 的操作数检查。索引 TLSU 操作是 Tile 访存单元中按索引 Tile 提供的逐元素地址读写全局内存的操作，例如 MGATHER 与 MSCATTER。

- `IndexedTLSULayoutSupported`、`IndexedTLSUNumericDescriptorLegal` 与 `IndexedTLSUNumericContentsDefined` 检查数据 Tile 的布局与描述符。
- `IndexedTLSUMemoryIndexDataTypeLegal` 与 `IndexedTLSUOrdinaryTransferDataTypeLegal` 检查类型。
- `IndexedTLSUDataShapeMatchesIndex` 与 `IndexedTLSUPhysicalShapeLegal` 检查形状。
- `TileOperandsLegal_TFMA` 与 `TileOperandsLegal_GMOV` 是完整的操作数谓词。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-concepts role=concepts-state -->
## 概念与可见状态

所有谓词都是只读的，自身不引发故障。索引 Tile 为每个数据元素保存一个地址或偏移；数据 Tile 保存被搬运的值。

支持的索引布局为 RowMajor、CUBE_M16 与 CUBE_M32。内存索引 Tile 必须是 S32、U32、S64 或 U64。

打包四位类型（例如 E2M1X2 或 U4X2）每字节存放两个逻辑元素。在形状匹配中，一个索引元素对应一个打包对。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-rules role=rules-interactions -->
## 规则与交互

`IndexedTLSUNumericDescriptorLegal` 要求数值存储和受支持的布局。CUBE 布局必须通过 `TileCubeDescriptorLegal`；RowMajor 必须通过 `TileDescriptorLegal`。

`IndexedTLSUDataShapeMatchesIndex` 要求有效行数相等。对四位数据类型，数据有效列数必须为偶数，且等于索引有效列数的两倍；否则有效列数必须相等。

设计要点：索引地址是字节位移，而指令束 schema没有选择字节低半或高半的字段。因此四位转移以完整的打包对为单位搬运，这就是一个索引覆盖两个数据列、且奇数数据列数被拒绝的原因。

`IndexedTLSUOrdinaryTransferDataTypeLegal` 对每种数据类型都返回 TRUE：它等于 `IndexedTLSUTransferDataTypeLegal`（非四位）或四位。真正约束四位转移的是上面的成对规则。

`IndexedTLSUPhysicalShapeLegal` 检查指令束的布局与维度。对 RowMajor，物理列数必须是 2 的幂且不小于 ValidCol。对 CUBE 布局，CUBE 存储行数与所需字节数必须非零，并通过 `TileCubeDescriptorShapeAndPhysicalLegal`。

`TileOperandsLegal_TFMA` 要求目标与三个源（左、右、加数）具有相同的形状、布局、存储种类与数据类型；布局必须是 RowMajor、CUBE_M16 或 CUBE_M32；源在每个有效坐标（存在 ExecutionMask 时为每个活动坐标）上必须已定义，对浮点类型还必须编码有效。

`TileOperandsLegal_TFMA` 使用 `TileFusedMultiplyAddDataTypeSupported`，恰好接受 `FP64`、`S64`、`U64`、`FP16`、`FP32` 与 `BF16`。定宽整数形式以及 `FP64`、`FP32`、`FP16` 融合浮点路径可执行。`ScalarFPFusedProfile` 不接受 BF16，因此既有已接受 BF16 的有限 FMA 缺口保持不变。其他向量算术类型不会进入 TFMA 执行。

`TileOperandsLegal_GMOV` 要求 `peer_tid` 小于 4、源已定义、形状匹配、类型与布局相同、布局为受支持的逐元素布局，且数据类型属于 `TileCarrierOrPackedBaselineDataTypeSupported`（最高 64 位的非打包类型，或既有打包基线）。

这些检查都在预检中运行，早于任何内存请求、快照或目标写入。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-boundaries role=boundaries -->
## 架构边界

调用者包括 `TileOperandsLegal_MGATHER` 等内存 schema合法性谓词，MGATHER、MSCATTER 及其 MASK 与 CAS 形式和 GM 原子归约的 TLSU 分派单元，以及 gather-scatter 等断言其中部分谓词的内存执行单元。`TFMA` 与融合乘加执行调用 `TileOperandsLegal_TFMA`；GMOV 分派调用 `TileOperandsLegal_GMOV`。

在 `asl/` 中 grep 找不到 `IndexedTLSUNumericContentsDefined` 的调用者。

本单元不检查索引值是否在内存范围内，也不检查 B.DATR 字段或 PE_MASK。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-example role=example-usage -->
## 非规范阅读示例

考虑一条 MGATHER，目标为 E2M1X2 RowMajor 数据 Tile，有效区域 4 乘 32，使用有效区域 4 乘 16 的 S32 索引 Tile。

- S32 是合法的内存索引类型。
- 有效行数都是 4。
- E2M1X2 是四位类型，因此 32 必须为偶数且等于 2 x 16，条件成立。
- `B.DIM` Col 为 32 时，RowMajor 要求 32 是 2 的幂且不小于 32，条件成立。

若索引 Tile 的有效区域为 4 乘 32，形状匹配会失败，因为 32 不等于 2 x 32。

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-related role=related-owners-navigation -->
## 相关所有者

- [内存 schema](memory-schema.md) 在这些检查之上构建索引 TLSU 操作数谓词。
- [Gather 与 scatter](../memory/gather-scatter.md) 执行转移。
- [融合乘加](../execution/fused-multiply-add.md) 执行 `TFMA`。
- [TLSU MGATHER 分派](../../../block/model/dispatch/tlsu-mgather.md) 应用物理形状检查。
- [CUBE 单元几何](../shape/cube-cell.md) 负责 CUBE 形状检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-layout.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
pure func IndexedTLSULayoutSupported(layout: TileLayout) => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

pure func IndexedTLSUMemoryIndexDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func IndexedTLSUOrdinaryTransferDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(data_type) ||
           TileDataTypeIsFourBit(data_type);
end;

readonly func IndexedTLSUNumericDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSULayoutSupported(tile.layout) ||
       tile.storage_kind != TileStorage_Numeric then
        return FALSE;
    end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile);
    end;
    return TileDescriptorLegal(index) && tile.layout == TileLayout_RowMajor;
end;

readonly func IndexedTLSUNumericContentsDefined(index: TileIndex) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(index) &&
           _Tiles[[index]].contents_defined;
end;

pure func IndexedTLSUDataShapeMatchesIndex(
    data_valid_rows: integer {0..65535},
    data_valid_columns: integer {0..65535},
    index_valid_rows: integer {0..65535},
    index_valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    if data_valid_rows != index_valid_rows then return FALSE; end;
    if TileDataTypeIsFourBit(data_type) then
        return data_valid_columns MOD 2 == 0 &&
               data_valid_columns == 2 * index_valid_columns;
    end;
    return data_valid_columns == index_valid_columns;
end;

readonly func IndexedTLSUPhysicalShapeLegal(
    layout: TileLayout, data_type: TileDataType,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535}) => boolean
begin
    if !IndexedTLSULayoutSupported(layout) then return FALSE; end;
    if layout == TileLayout_RowMajor then
        return valid_columns <= columns && IsNonzeroPowerOfTwo(columns);
    end;
    let physical_rows = TileCubeStorageRows(layout, valid_rows, data_type);
    let required_bytes = TileCubePhysicalRequiredBytes(
        layout, physical_rows, columns, data_type);
    return physical_rows != 0 && required_bytes != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(required_bytes,
               physical_rows, columns, valid_rows, valid_columns,
               data_type, layout);
end;

readonly func TileOperandsLegal_TFMA(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, addend: TileIndex) => boolean
begin
    return TileElementwiseDescriptorLegal(destination) &&
           TileElementwiseSourceContentsDefined(source_left) &&
           TileElementwiseSourceContentsDefined(source_right) &&
           TileElementwiseSourceContentsDefined(addend) &&
           TileFusedMultiplyAddDataTypeSupported(
               _Tiles[[destination]].data_type) &&
           TileElementwiseShapeAndTypeMatch(destination, source_left) &&
           TileElementwiseShapeAndTypeMatch(destination, source_right) &&
           TileElementwiseShapeAndTypeMatch(destination, addend) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[addend]].data_type &&
           TileElementwiseLayoutSupported(_Tiles[[destination]].layout) &&
           (!TileDataTypeIsFloating(_Tiles[[destination]].data_type) ||
            (TileElementwiseSourceEncodingsValid(source_left) &&
             TileElementwiseSourceEncodingsValid(source_right) &&
             TileElementwiseSourceEncodingsValid(addend)));
end;

readonly func TileOperandsLegal_GMOV(
    destination: TileIndex, source: TileIndex, peer_tid: Word) => boolean
begin
    return UInt(peer_tid) < 4 &&
           TileElementwiseDescriptorLegal(destination) &&
           TileElementwiseSourceContentsDefined(source) &&
           TileElementwiseShapeMatch(destination, source) &&
           TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
           TileElementwiseLayoutSupported(_Tiles[[destination]].layout) &&
           TileCarrierOrPackedBaselineDataTypeSupported(
               _Tiles[[source]].data_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout;
end;
```
<!-- GENERATED-ASL-END: unit -->
