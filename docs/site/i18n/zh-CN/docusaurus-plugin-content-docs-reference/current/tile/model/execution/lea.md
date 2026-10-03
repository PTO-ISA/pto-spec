<!-- GENERATED FROM: asl/tile/model/execution/lea.asl -->
# Lea

**Normative ASL source:** `asl/tile/model/execution/lea.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-LEA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-lea-purpose role=purpose-scope -->
## 目的与范围

本单元负责 `TLEA` 的元素变换与发布顺序。`TileLEAExtendedIndex` 执行有符号或无符号扩展，`TileLEAByteScale` 把显式元素宽度从位换算为字节，`TileLEAByteOffset` 形成低 64 位乘积，`TLEA` 把该变换应用于一个 Local 源 Tile。

<!-- PTO-READER-BLOCK: tile-model-execution-lea-concepts role=concepts-state -->
## 概念与可见状态

handler 读取完整源 Tile 记录、预分配目标记录、当前 ExecutionMask 与当前 `PadValue`。它发布一个更新后的目标记录，并保持源不变。

源类型同时控制扩展与目标符号性。`S32` 符号扩展，`U32` 零扩展；`S64` 与 `U64` 已占满整个 `Word`。元素宽度 8、16、32、64 分别映射到字节缩放因子 1、2、4、8。

<!-- PTO-READER-BLOCK: tile-model-execution-lea-rules role=rules-interactions -->
## 规则与交互

`TileLEAByteOffset` 先扩展逻辑索引，再用字节缩放因子调用 `MultiplyWord`。word 乘法保留低 64 位，因此操作按模 2^64 定义，不使用宿主语言的有符号算术。

`TLEA` 在构造结果前把完整源记录与目标记录复制到局部值。对每个活动逻辑坐标，它读取旧源元素并计算字节偏移。对于非活动 CUBE ExecutionMask 坐标，它不读取源元素，而取既有 ZERO 或 MERGE 目标值。有效矩形完成后，handler 将其标记为已定义，对物理尾部应用所选填充，并一次性发布目标。

<!-- PTO-READER-BLOCK: tile-model-execution-lea-boundaries role=boundaries -->
## 架构边界

这些函数断言 `TileOperandsLegal_TLEA` 与元素宽度谓词已经成立。因此，schema、描述符、形状、已定义性与分配拒绝属于预检，而不属于元素循环。

本单元只生成字节偏移。它不读取基址 GPR，不进行地址转换或内存访问，不生成内存事件，也不更新数值状态。严格 `PE_MASK=0000` 处理发生在调用 handler 之前。

<!-- PTO-READER-BLOCK: tile-model-execution-lea-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL owner，不替代规范操作。

对于值为 -1 的 `S32` 源和 `element_bits=32`，`TileLEAExtendedIndex` 先产生 `0xFFFFFFFFFFFFFFFF`。`TileLEAByteScale` 返回 4，`MultiplyWord` 产生低 64 位模式 `0xFFFFFFFFFFFFFFFC`，表示 -4 字节位移。相同缩放下，`U32` 源行 `[0, 1, 2]` 则产生 `[0, 4, 8]`。

<!-- PTO-READER-BLOCK: tile-model-execution-lea-related role=related-owners-navigation -->
## 相关 owner

- [TLEA 操作数合法性](../legality/lea-operands.md)建立 handler 前置条件。
- [TLEA bundle schema](../../../block/model/dispatch/lea-schema.md)检查输入绑定与标量宽度。
- [ExecutionMask 状态](execution-mask-state.md)负责非活动 ZERO 与 MERGE 值。
- [TLEA](../../tile-scalar-and-immediate/arithmetic/TLEA.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/lea.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-LEA","surface":"tile","classification":["model","execution","lea"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS"]}

pure func TileLEAExtendedIndex(value: Word, data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S32 => return SignExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_U32 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_S64, TileDataType_U64 => return value;
        otherwise => unreachable;
    end;
end;

pure func TileLEAByteScale(element_bits: Word) => Word
begin
    assert TileLEAElementBitsLegal(element_bits);
    if element_bits == Zeros{PTO_XLEN} + 8 then
        return Zeros{PTO_XLEN} + 1;
    elsif element_bits == Zeros{PTO_XLEN} + 16 then
        return Zeros{PTO_XLEN} + 2;
    elsif element_bits == Zeros{PTO_XLEN} + 32 then
        return Zeros{PTO_XLEN} + 4;
    end;
    return Zeros{PTO_XLEN} + 8;
end;

pure func TileLEAByteOffset(
    value: Word, data_type: TileDataType, element_bits: Word) => Word
begin
    assert TileLEAIndexDataTypeLegal(data_type);
    assert TileLEAElementBitsLegal(element_bits);
    return MultiplyWord(
        TileLEAExtendedIndex(value, data_type),
        TileLEAByteScale(element_bits));
end;

func TLEA(destination: TileIndex, source: TileIndex, element_bits: Word)
begin
    assert TileOperandsLegal_TLEA(destination, source, element_bits);
    let source_tile = _Tiles[[source]];
    var result = _Tiles[[destination]];

    // Snapshot the complete source record before constructing the result.
    // This gives direct S64/U64 destination aliases read-old/write-new behavior.
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let source_element = TileLogicalLinearIndex(
                    source_tile, row as integer {0..65535},
                    column as integer {0..65535});
                value = TileLEAByteOffset(
                    TileReadLogicalElement(source_tile, source_element),
                    source_tile.data_type, element_bits);
            else
                value = BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(
                result, destination_element, value);
        end;
    end;

    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
