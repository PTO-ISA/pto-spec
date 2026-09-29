<!-- GENERATED FROM: asl/tile/model/execution/reduction.asl -->
# Reduction

**Normative ASL source:** `asl/tile/model/execution/reduction.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-REDUCTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-reduction-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `ExecuteTileReduction`，即行归约与列归约共享的处理函数。TROWSUM、TROWPROD、TROWMIN、TROWMAX、TROWARGMIN 和 TROWARGMAX，以及对应的六个 TCOL 形式会到达它。

行归约为每个有效行产生一个值。列归约为每个有效列产生一个值。

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-concepts role=concepts-state -->
## 概念与可见状态

操作类型是指令束选择的 DataType；没有选中指令束操作时，是源 Tile 的 `data_type`。

外层索引遍历保留的轴，内层索引遍历被归约的轴。每个外层位置启动一个累加器：

- SUM 从全零编码开始，PRODUCT 从该类型的一编码开始。两者随后从内层索引 0 起折叠每个元素。
- MIN、MAX、ARGMIN 和 ARGMAX 从第一个元素开始，从内层索引 1 起折叠。

每一步用 ADD、MUL、MIN 或 MAX 调用 `TileProfileBinaryWithFlags`。标志从 bit 0 到 bit 4 依次为 NV、DZ、OF、UF 和 NX，在所有步骤上按位或合并。

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-rules role=rules-interactions -->
## 规则与交互

折叠严格按内层索引递增的顺序进行。浮点 SUM 和 PRODUCT 每一步都舍入，因此顺序是结果的一部分。

ARGMIN 和 ARGMAX 跟踪一个索引。只有当步骤结果等于新元素且不同于旧累加器时，才更新索引。后面出现的与累加器编码相同的元素不改变结果，因此位模式相同的极值保留第一个索引。浮点有符号零不算并列：例如，TROWARGMAX 在 -0 之后遇到 +0 时会移到 +0，因为 MAX 返回 +0。目标把该索引存为 U32 值。

行归约的目标是单列，列归约的目标是单行。循环结束后，处理函数把有效区域标记为已定义，应用指令束填充，记录按位或合并的标志，并发布目标。

设计要点：合法性拒绝命名源的目标。处理函数读取源的快照并私下构建结果，因此源元素在仍需使用时不会被覆盖。

设计要点：MIN 和 MAX 从第一个元素开始，因此每一步都比较两个源值，结果是其中之一，但两个 NaN 输入会得到规范静默 NaN。SUM 和 PRODUCT 从单位元开始，因此每个源元素恰好经过一次 ADD 或 MUL 步骤。

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-boundaries role=boundaries -->
## 架构边界

归约操作不在 `TileOperationExecutionMaskEligible` 中，因此不能为其绑定 ExecutionMask。处理函数读取每个有效源元素。

ARGMIN 和 ARGMAX 接受 S32、U32、FP32、S16、U16、FP16、BF16、S8 和 U8 源。其他归约接受 16 种算术类型，但浮点 ADD 和 MUL 经过 `ScalarFPBinaryProfile`，它接受 FP64、FP32、FP16 和 BF16。

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-example role=example-usage -->
## 非规范阅读示例

考虑在 S32 RowMajor 源上执行 TROWARGMAX，有效行为一行四列：

```text
TROWARGMAX <Row=32, Col=4, ValidRow=1, S32>, T#1, ->T<128B>
```

源行为 3、7、7、2。

1. 累加器从 3 开始，索引为 0。
2. 内层 1：3 与 7 的 MAX 为 7，它等于新元素且不同于 3，因此索引变为 1。
3. 内层 2：7 与 7 的 MAX 为 7，它等于旧累加器，因此索引保持 1。
4. 内层 3：7 与 2 的 MAX 为 7，因此索引保持 1。

目标元素为 U32 1。对同一行执行 TROWSUM 从 0 开始，得到 0 + 3 + 7 + 7 + 2 = 19。

<!-- PTO-READER-BLOCK: tile-model-execution-reduction-related role=related-owners-navigation -->
## 相关所有者

- [归约与扩展合法性](../legality/reduction-and-expansion.md)拥有形状和类型检查。
- [逐元素执行](elementwise.md)拥有二元步骤辅助函数。
- [扩展执行](expansion.md)拥有对应的广播操作。
- [谓词载体](predicate-carriers.md)拥有 ExecutionMask 资格列表。
- [数值状态](../../../arch/state/numeric-status.md)拥有粘滞标志。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/reduction.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REDUCTION","surface":"tile","classification":["model","execution","reduction"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE"]}
// PTO-REQ-TEPL-REDUCE-001: exact row, column, and index reductions.

pure func TileReductionOneEncoding(
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x3ff0000000000000;
        when TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} + 0x38;
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0x3c;
        when TileDataType_S64, TileDataType_S32,
             TileDataType_S16, TileDataType_S8,
             TileDataType_U64, TileDataType_U32,
             TileDataType_U16, TileDataType_U8 =>
            return Zeros{PTO_XLEN} + 1;
        otherwise =>
            unreachable;
    end;
end;

pure func TileReductionInitialValue(
    operation: TileReductionOperation,
    data_type: TileDataType,
    first: Word) => Word
begin
    case operation of
        when TileReduction_SUM =>
            return Zeros{PTO_XLEN};
        when TileReduction_PRODUCT =>
            return TileReductionOneEncoding(data_type);
        when TileReduction_MIN, TileReduction_MAX,
             TileReduction_ARGMIN, TileReduction_ARGMAX =>
            return first;
    end;
end;

func TileProfileReductionInitial(
    operation: TileReductionOperation,
    data_type: TileDataType,
    first: Word) => Word
begin
    return TileReductionInitialValue(
        operation,
        data_type,
        first);
end;

func TileReductionStepWithFlags(
    operation: TileReductionOperation,
    data_type: TileDataType,
    accumulator: Word,
    value: Word) => (Word, boolean, bits(5))
begin
    var binary_operation: TileBinaryOperation;
    case operation of
        when TileReduction_SUM =>
            binary_operation = TileBinary_ADD;
        when TileReduction_PRODUCT =>
            binary_operation = TileBinary_MUL;
        when TileReduction_MIN, TileReduction_ARGMIN =>
            binary_operation = TileBinary_MIN;
        when TileReduction_MAX, TileReduction_ARGMAX =>
            binary_operation = TileBinary_MAX;
    end;

    let (result, flags) = TileProfileBinaryWithFlags(
        binary_operation,
        data_type,
        accumulator,
        value);
    let selected =
        result == value && result != accumulator;
    return (result, selected, flags);
end;

func TileProfileReductionStep(
    operation: TileReductionOperation,
    data_type: TileDataType,
    accumulator: Word, value: Word) => (Word, boolean)
begin
    let (result, selected, -) = TileReductionStepWithFlags(
        operation,
        data_type,
        accumulator,
        value);
    return (result, selected);
end;

func ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveTileSelectedOperationType(source_tile.data_type);
    assert operation_type_valid;
    assert TileOperandsLegal_ExecuteTileReduction(
        operation,
        axis,
        destination,
        source);

    var result_tile = _Tiles[[destination]];
    var accumulated_flags = Zeros{5};
    let outer_count =
        if axis == TileAxis_Row then
            source_tile.valid_rows
        else
            source_tile.valid_columns;
    let inner_count =
        if axis == TileAxis_Row then
            source_tile.valid_columns
        else
            source_tile.valid_rows;

    for outer = 0 to outer_count - 1 looplimit 65536 do
        let first_row =
            if axis == TileAxis_Row then outer else 0;
        let first_column =
            if axis == TileAxis_Row then 0 else outer;
        let first_element = TileLogicalLinearIndex(
            source_tile,
            first_row as integer {0..65535},
            first_column as integer {0..65535});
        var accumulator = TileProfileReductionInitial(
            operation,
            operation_type,
            TileReadLogicalElement(source_tile, first_element));
        var selected_index: integer {0..65535} = 0;
        let identity_reduction =
            operation == TileReduction_SUM ||
            operation == TileReduction_PRODUCT;
        let first_inner =
            if identity_reduction then 0 else 1;

        if first_inner < inner_count then
            for inner = first_inner to inner_count - 1
                looplimit 65536 do
                let row =
                    if axis == TileAxis_Row then outer else inner;
                let column =
                    if axis == TileAxis_Row then inner else outer;
                let element = TileLogicalLinearIndex(
                    source_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let (next, selected, element_flags) =
                    TileReductionStepWithFlags(
                        operation,
                        operation_type,
                        accumulator,
                        TileReadLogicalElement(source_tile, element));
                accumulator = next;
                accumulated_flags =
                    accumulated_flags OR element_flags;
                if selected &&
                   (operation == TileReduction_ARGMIN ||
                    operation == TileReduction_ARGMAX) then
                    selected_index =
                        inner as integer {0..65535};
                end;
            end;
        end;

        let destination_row =
            if axis == TileAxis_Row then outer else 0;
        let destination_column =
            if axis == TileAxis_Row then 0 else outer;
        let destination_element = TileLogicalLinearIndex(
            result_tile,
            destination_row as integer {0..65535},
            destination_column as integer {0..65535});
        if operation == TileReduction_ARGMIN ||
           operation == TileReduction_ARGMAX then
            result_tile = TileInfoWithLogicalElement(result_tile,
                destination_element, NaturalToWord(
                    selected_index as integer {0..262144}));
        else
            result_tile = TileInfoWithLogicalElement(result_tile,
                destination_element, accumulator);
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
