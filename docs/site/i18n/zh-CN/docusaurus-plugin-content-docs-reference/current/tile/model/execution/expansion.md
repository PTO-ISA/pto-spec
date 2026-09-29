<!-- GENERATED FROM: asl/tile/model/execution/expansion.asl -->
# Expansion

**Normative ASL source:** `asl/tile/model/execution/expansion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-EXPANSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-expansion-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `ExecuteTileExpand`，即行广播与列广播操作共享的处理函数。八个 TROWEXPAND 形式（TROWEXPAND、TROWEXPANDADD、TROWEXPANDSUB、TROWEXPANDMUL、TROWEXPANDDIV、TROWEXPANDMAX、TROWEXPANDMIN、TROWEXPANDEXPDIF）以及对应的八个 TCOLEXPAND 形式会到达它。

它承载已接受的条款 `PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001`。

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-concepts role=concepts-state -->
## 概念与可见状态

每个操作有三个 Tile 操作数：目标、全尺寸源和广播源。轴选择与每个目标坐标配对的广播元素：

- 行轴：广播源同一行中位于广播槽列的元素。
- 列轴：广播源第 0 行中同一列的元素。

对 RowMajor，广播槽为第 0 列。对 CUBE_M16 或 CUBE_M32 的行形式，`TileExpansionBroadcastSlot` 用 B.DATR RMode 中的 BroadcastByteOffset 除以元素字节数。

操作种类选择元素函数。COPY 返回广播元素。ADD、SUB、MUL、DIV、MAX 和 MIN 对源元素和广播元素应用 `TileProfileBinaryWithFlags`。EXPDIF 使用 EXPDIF 元素辅助函数。

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-rules role=rules-interactions -->
## 规则与交互

处理函数遍历目标有效区域。对活动坐标，它读取广播元素，并在 COPY 以外的情况下读取同一坐标的源元素。它存储结果值，并把元素标志按位或起来，标志从 bit 0 到 bit 4 依次为 NV、DZ、OF、UF 和 NX。

循环结束后，它把有效区域标记为已定义，应用指令束填充，记录按位或合并的标志，并发布目标。

设计要点：三个操作数记录在循环之前被快照，结果在私有副本上构建。目标即使命名源，读取的仍是旧值。

设计要点：COPY 要求源操作数和广播操作数命名同一个 Tile。COPY 从不读取源元素，因此不涉及第二个全尺寸操作数。

设计要点：只有 EXPDIF 的目标类型可以与源操作类型不同。其他种类都要求两种类型相等，因此算术总是在目标类型中进行。

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-boundaries role=boundaries -->
## 架构边界

在 ExecutionMask 下，非活动坐标不读取任何源，不贡献标志，并取 ZERO 或 MERGE 值。因此只有当某个活动坐标使用广播元素时，它才会被读取。

对整数 DIV，合法性在处理函数运行前要求活动输出的除数非零。浮点算术遵循 `TileProfileBinaryWithFlags` 的类型限制：ADD、SUB、MUL 和 DIV 使用 `ScalarFPBinaryProfile`，它接受 FP64、FP32、FP16 和 BF16。

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-example role=example-usage -->
## 非规范阅读示例

考虑在 RowMajor S32 Tile 上执行 TROWEXPANDSUB，有效区域为 2 行乘 3 列，没有 ExecutionMask：

```text
TROWEXPANDSUB <Row=32, Col=4, ValidRow=2, ValidCol=3, S32>, T#1, T#2, ->T<512B>
```

源行为 10、20、30 和 5、6、7。广播源在第 0 列中，第 0 行为 1，第 1 行为 5。

1. 第 0 行减 1：9、19、29。
2. 第 1 行减 5：0、1、2。

整数路径不返回标志，因此粘滞状态不变。

<!-- PTO-READER-BLOCK: tile-model-execution-expansion-related role=related-owners-navigation -->
## 相关所有者

- [归约与扩展合法性](../legality/reduction-and-expansion.md)拥有操作数检查和广播槽。
- [逐元素执行](elementwise.md)拥有二元元素辅助函数。
- [EXPDIF 执行](expdif.md)拥有 EXPDIF 元素辅助函数。
- [归约执行](reduction.md)拥有对应的行归约与列归约。
- [执行掩码状态](execution-mask-state.md)拥有非活动坐标的处理。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/expansion.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Predicated expansion reads and validates source coordinates only when the mapped output coordinate is active. A selected row-broadcast element is read only if at least one active output consumes it; inactive outputs use the common MERGE/ZERO rule and contribute no numeric flags. Integer division-by-zero checks apply only to active outputs.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-EXPANSION","surface":"tile","classification":["model","execution","expansion"],"depends_on":["PTO-TILE-MODEL-EXECUTION-EXPDIF","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
// PTO-REQ-TEPL-EXPAND-001: exact typed row and column broadcast operations.

pure func TileExpandBinaryOperation(
    operation: TileExpandOperation) => TileBinaryOperation
begin
    case operation of
        when TileExpand_ADD =>
            return TileBinary_ADD;
        when TileExpand_SUB =>
            return TileBinary_SUB;
        when TileExpand_MUL =>
            return TileBinary_MUL;
        when TileExpand_DIV =>
            return TileBinary_DIV;
        when TileExpand_MAX =>
            return TileBinary_MAX;
        when TileExpand_MIN =>
            return TileBinary_MIN;
        otherwise =>
            unreachable;
    end;
end;

func TileExpandValueWithTypesAndFlags(
    operation: TileExpandOperation,
    source_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    if operation == TileExpand_COPY then
        return (broadcast, Zeros{5});
    end;

    if operation == TileExpand_EXPDIF then
        return TileExpdifValueWithTypesAndFlags(
            source_type, destination_type, left, broadcast);
    end;

    return TileProfileBinaryWithFlags(
        TileExpandBinaryOperation(operation),
        destination_type,
        left,
        broadcast);
end;

func TileProfileExpand(op: TileExpandOperation,
                                      data_type: TileDataType,
                                      left: Word, broadcast: Word) => Word
begin
    return TileExpandValue(
        op,
        data_type,
        left,
        broadcast);
end;

func TileExpandValueWithFlags(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    return TileExpandValueWithTypesAndFlags(
        operation,
        data_type,
        data_type,
        left,
        broadcast);
end;

func TileExpandValue(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => Word
begin
    let (result, -) = TileExpandValueWithFlags(
        operation,
        data_type,
        left,
        broadcast);
    return result;
end;

func ExecuteTileExpand(op: TileExpandOperation, axis: TileAxis,
                       destination: TileIndex, source: TileIndex,
                       broadcast_source: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileExpand(
        op,
        axis,
        destination,
        source,
        broadcast_source);

    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    var result_tile = _Tiles[[destination]];
    let expdif = op == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(result_tile.data_type);
    assert operation_type_valid;
    let source_operation_type = if expdif && !BundleTileOperationSelected() then
        source_tile.data_type else selected_type;
    let destination_operation_type = if expdif then
        result_tile.data_type else selected_type;
    let broadcast_slot = TileExpansionBroadcastSlot(
        axis, broadcast_tile.layout, source_operation_type);
    var accumulated_flags = Zeros{5};

    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let broadcast_row = if axis == TileAxis_Row then row else 0;
                let broadcast_column = if axis == TileAxis_Row then
                    broadcast_slot else column;
                let broadcast_element = TileLogicalLinearIndex(broadcast_tile,
                    broadcast_row as integer {0..65535},
                    broadcast_column as integer {0..65535});
                var left = TileReadLogicalElement(broadcast_tile,
                    broadcast_element);
                if op != TileExpand_COPY then
                    let source_element = TileLogicalLinearIndex(
                        source_tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    left = TileReadLogicalElement(source_tile, source_element);
                end;
                let (value, element_flags) = TileExpandValueWithTypesAndFlags(
                    op,
                    source_operation_type,
                    destination_operation_type,
                    left,
                    TileReadLogicalElement(broadcast_tile, broadcast_element));
                result_tile = TileInfoWithLogicalElement(result_tile,
                    destination_element, value);
                accumulated_flags = accumulated_flags OR element_flags;
            else
                let value = BundleExecutionMaskDestinationValue(
                    result_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
            end;
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
```
<!-- GENERATED-ASL-END: unit -->
