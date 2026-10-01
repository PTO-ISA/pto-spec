<!-- GENERATED FROM: asl/tile/model/execution/postprocess.asl -->
# Postprocess

**Normative ASL source:** `asl/tile/model/execution/postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-POSTPROCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-purpose role=purpose-scope -->
## 用途与范围

本单元完成一次 CUBE 矩阵操作。它路由 B.FPATR 后处理操作数，在存在 B.FPATR 时转换每个有效 D 元素，计算可选的 RowMax 和 GroupMax 输出，并一起发布所有输出。

其入口是 `CommitMatrixResult`。对每个未选择原始部分输出的形式，CUBE 执行单元都会调用它。

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-concepts role=concepts-state -->
## 概念与可见状态

- B.FPATR 是矩阵后处理命令。其字段包括 PreQuantMode、ReluMode、GroupNCode、RowMaxEn、GroupMaxEn、RowMaxInit 和 MaxAbsEn。
- 有效类型是转换后的 D 类型。PreQuantMode 为 0 时，`BundleFPATREffectiveDataType` 保留累加器类型。
- RowMaxOut 每行保存一个最大值。GroupMaxOut 每组 GroupN 列保存一个最大值。

额外源按以下顺序跟在数学源之后：RowMaxEn 和 RowMaxInit 都置位时为 RowMaxIn，然后是向量量化 Tile，然后是向量 ReLU Tile。D 是目标 0，RowMaxOut 是目标 1，GroupMaxOut 是下一个目标。

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-rules role=rules-interactions -->
## 规则与交互

没有 B.FPATR 时，`MatrixPostProcessResult` 原样返回输入。否则它访问每个有效元素并调用 `TileProfileMatrixPostProcessWithFlags`。

量化参数根据 PreQuantMode 取自向量 Tile 的第 `column` 列、取自标量操作数，或为常数 1。ReluMode 为 3 时，ReLU 参数取自向量 Tile，否则取自标量操作数。

`MatrixRowMaxResult` 以第 0 列开始每一行，并按递增顺序折叠第 1 到 N-1 列。启用 RowMaxInit 时，它随后折叠该行的 RowMaxIn。`MatrixGroupMaxResult` 以同样方式折叠每组 GroupN 列，按递增列顺序并在最后一个有效列处停止；它没有要折叠的输入 Tile。

每个折叠步骤使用 `TileProfileMatrixReductionStepWithFlags`。启用 MaxAbsEn 时，它先对两个操作数取绝对值，再应用普通 MAX 步骤。

`CommitMatrixResult` 从提交前的状态计算 D、RowMaxOut 和 GroupMaxOut。然后它写入所有启用的输出，并记录所有输出标志的 OR。

设计要点：归约消耗的是最终编码的 D 值，而不是原始累加器。因此 RowMax 等于程序从已发布 D 计算出的值。

设计要点：每个输出都在任何输出写入之前从提交前的状态准备好。RowMaxIn 和输出 Tile 在 D 发布之前被读取，随后 D、启用的归约输出和标志作为一次提交一起改变。

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-boundaries role=boundaries -->
## 架构边界

合法性把 RowMax 和 GroupMax 限制为有效类型 FP32、FP16 或 BF16。对这些类型，MAX 遵循浮点 min/max 规则，只有信号 NaN 会引发 NV。

归约输出只在其有效区域内被标记为已定义。`MatrixPostProcessResult` 修改其记录中的 D 类型，并保留乘积所设置的已定义性。

`TileProfileMatrixPostProcess` 和 `TileProfileMatrixReductionStep` 包装函数丢弃标志；在 ASL 中未找到二者的调用者。

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-example role=example-usage -->
## 非规范阅读示例

一个 FP32 TMATMUL 的 PreQuantMode 为 0，ReluMode 为 0，RowMaxEn 为 1，RowMaxInit 为 1。D 的第 0 行为 3.0、-7.0、5.0，RowMaxIn 第 0 行为 6.0。

1. 后处理保持 D 不变，因为两种模式都为 0。
2. 不启用 MaxAbsEn 时，行折叠给出 max(3.0, -7.0) = 3.0，然后 max(3.0, 5.0) = 5.0。
3. 折叠 RowMaxIn 给出 max(6.0, 5.0) = 6.0，因此 RowMaxOut 第 0 行为 6.0。
4. 启用 MaxAbsEn 时，折叠使用 3.0、7.0 和 5.0，在 RowMaxIn 之前达到 7.0，并发布 7.0。

<!-- PTO-READER-BLOCK: tile-model-execution-postprocess-related role=related-owners-navigation -->
## 相关所有者

- [矩阵后处理](matrix-postprocess.md)拥有逐元素转换和激活。
- [CUBE 执行](cube.md)产生本单元提交的结果。
- [矩阵后处理合法性](../legality/matrix-postprocess.md)检查操作数数量和有效类型。
- [B.FPATR](../../../block/attributes/B.FPATR.md)定义模式字段。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-POSTPROCESS","surface":"tile","classification":["model","execution","postprocess"],"depends_on":["PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}
// Complete-bundle B.FPATR post-processing.  Numeric conversion and activation
// remain behind the named profile hooks while this unit owns operand routing,
// reductions, and atomic auxiliary-output publication.

func TileProfileMatrixPostProcess(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => Word
begin
    let (result, -) = TileProfileMatrixPostProcessWithFlags(
        value, pre_quant_mode, relu_mode, group_n_code,
        output_type, quant_param, relu_param, control);
    return result;
end;

func TileProfileMatrixPostProcessWithFlags(
    value: Word, pre_quant_mode: bits(6), relu_mode: bits(3),
    group_n_code: bits(4), output_type: TileDataType,
    quant_param: Word, relu_param: Word,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let effective_control = MatrixFPATREffectiveControl(
        pre_quant_mode, control);
    return MatrixPostQuantBaseWithFlags(
        value, pre_quant_mode, output_type, relu_mode,
        quant_param, relu_param, effective_control);
end;

func TileProfileMatrixReductionStep(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => Word
begin
    let (result, -) = TileProfileMatrixReductionStepWithFlags(
        current, candidate, max_abs, data_type);
    return result;
end;

func TileProfileMatrixReductionStepWithFlags(
    current: Word, candidate: Word, max_abs: boolean,
    data_type: TileDataType) => (Word, bits(5))
begin
    let (lhs_abs, lhs_flags) = if max_abs then
        MatrixReductionAbsoluteWithFlags(current, data_type)
    else
        (current, Zeros{5});
    let (rhs_abs, rhs_flags) = if max_abs then
        MatrixReductionAbsoluteWithFlags(candidate, data_type)
    else
        (candidate, Zeros{5});
    let lhs = if max_abs then lhs_abs else current;
    let rhs = if max_abs then rhs_abs else candidate;
    let (selected, -, flags) = TileReductionStepWithFlags(
        TileReduction_MAX, data_type, lhs, rhs);
    return (selected, flags OR lhs_flags OR rhs_flags);
end;

readonly func BundleMatrixLocalMathematicalSourceCount() => integer {0..6}
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    let base = TileMatrixLocalMathematicalSourceCount(
        function, left_type, right_type, BundleSharedBindingCount());
    return (base +
        (if _BundleFixedPointAttributes.c_scale_en then 1 else 0))
        as integer {0..6};
end;

readonly func BundleMatrixOperationIndex() => integer {0..PTO_TILE_OPERATION_COUNT-1}
begin
    let decoded = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    return decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
end;

func MatrixRowMaxResult(input: TileInfo, destination: TileIndex,
                        rowmax_input: TileIndex, has_input: boolean,
                        intermediate_type: TileDataType)
                        => (TileInfo, bits(5))
begin
    var output = _Tiles[[destination]];
    var payload = output.payload;
    var flags = Zeros{5};
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        let first = TileStorageIndex(input, row as integer {0..65535}, 0);
        var value = input.payload[[first]];
        if _BundleFixedPointAttributes.max_abs_en then
            let (initial, initial_flags) =
                TileProfileMatrixReductionStepWithFlags(
                    value, value, TRUE, intermediate_type);
            value = initial;
            flags = flags OR initial_flags;
        end;
        for column = 1 to input.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(input, row as integer {0..65535}, column as integer {0..65535});
            let (next, step_flags) = TileProfileMatrixReductionStepWithFlags(
                value, input.payload[[element]],
                _BundleFixedPointAttributes.max_abs_en, intermediate_type);
            value = next;
            flags = flags OR step_flags;
        end;
        if has_input then
            let input_element = TileStorageIndex(_Tiles[[rowmax_input]], row as integer {0..65535}, 0);
            let (next, step_flags) = TileProfileMatrixReductionStepWithFlags(
                _Tiles[[rowmax_input]].payload[[input_element]], value,
                _BundleFixedPointAttributes.max_abs_en, intermediate_type);
            value = next;
            flags = flags OR step_flags;
        end;
        let output_element = TileStorageIndex(output, row as integer {0..65535}, 0);
        payload[[output_element]] = value;
    end;
    output.payload = payload;
    return (MarkLocalTileValidRegionDefined(output), flags);
end;

func MatrixGroupMaxResult(input: TileInfo, destination: TileIndex,
                          intermediate_type: TileDataType)
    => (TileInfo, bits(5))
begin
    var output = _Tiles[[destination]];
    var payload = output.payload;
    var flags = Zeros{5};
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for group = 0 to output.valid_columns - 1 looplimit 65536 do
            let first_column = group * group_n;
            let first = TileStorageIndex(input, row as integer {0..65535}, first_column as integer {0..65535});
            var value = input.payload[[first]];
            if _BundleFixedPointAttributes.max_abs_en then
                let (initial, initial_flags) =
                    TileProfileMatrixReductionStepWithFlags(
                        value, value, TRUE, intermediate_type);
                value = initial;
                flags = flags OR initial_flags;
            end;
            for offset = 1 to group_n - 1 looplimit 128 do
                let column = first_column + offset;
                if column < input.valid_columns then
                    let element = TileStorageIndex(input, row as integer {0..65535}, column as integer {0..65535});
                    let (next, step_flags) =
                        TileProfileMatrixReductionStepWithFlags(
                            value, input.payload[[element]],
                            _BundleFixedPointAttributes.max_abs_en,
                            intermediate_type);
                    value = next;
                    flags = flags OR step_flags;
                end;
            end;
            let output_element = TileStorageIndex(output, row as integer {0..65535}, group as integer {0..65535});
            payload[[output_element]] = value;
        end;
    end;
    output.payload = payload;
    return (MarkLocalTileValidRegionDefined(output), flags);
end;

func MatrixPostProcessResult(input: TileInfo,
                             intermediate_type: TileDataType)
    => (TileInfo, bits(5))
begin
    if !_BundleFixedPointAttributes.valid then
        return (input, Zeros{5});
    end;
    var result = input;
    var payload = input.payload;
    var flags = Zeros{5};
    let output_type = BundleFPATREffectiveDataType(
        _BundleFixedPointAttributes.pre_quant_mode, intermediate_type);
    let operation = BundleMatrixOperationIndex();
    let operands = BundleTileInstructionOperands(operation);
    let numeric_control = ResolveTileNumericExecutionControl(operation, operands);
    let mathematical_sources = BundleMatrixLocalMathematicalSourceCount();
    let quant_source_ordinal = mathematical_sources +
        (if _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init then 1 else 0);
    let relu_source_ordinal = quant_source_ordinal +
        (if BundleFPATRModeUsesVectorParameter(
            _BundleFixedPointAttributes.pre_quant_mode) then 1 else 0);
    let quant_tile = BundleMatrixSourceAt(quant_source_ordinal as integer {0..8});
    let relu_tile = BundleMatrixSourceAt(relu_source_ordinal as integer {0..8});
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(input, row as integer {0..65535},
                column as integer {0..65535});
            let quant_param = if BundleFPATRModeUsesVectorParameter(
                _BundleFixedPointAttributes.pre_quant_mode) then
                _Tiles[[quant_tile]].payload[[TileStorageIndex(
                    _Tiles[[quant_tile]], 0,
                    column as integer {0..65535})]]
            else if BundleFPATRModeUsesScalarParameter(
                _BundleFixedPointAttributes.pre_quant_mode) then
                operands.post_quant_param
            else
                Zeros{PTO_XLEN} + 1;
            let relu_param = if BundleFPATRReluModeUsesVectorParameter(
                _BundleFixedPointAttributes.relu_mode) then
                _Tiles[[relu_tile]].payload[[TileStorageIndex(
                    _Tiles[[relu_tile]], 0,
                    column as integer {0..65535})]]
            else
                operands.post_lrelu_param;
            let (processed, element_flags) =
                TileProfileMatrixPostProcessWithFlags(
                payload[[element]],
                _BundleFixedPointAttributes.pre_quant_mode,
                _BundleFixedPointAttributes.relu_mode,
                _BundleFixedPointAttributes.group_n_code,
                output_type, quant_param, relu_param, numeric_control);
            payload[[element]] = processed;
            flags = flags OR element_flags;
        end;
    end;
    result.data_type = output_type;
    result.predicate_basis_type = output_type;
    result.payload = payload;
    return (result, flags);
end;

func CommitMatrixResult(destination: TileIndex, result: TileInfo,
                        intermediate_type: TileDataType)
begin
    let mathematical_sources = BundleMatrixLocalMathematicalSourceCount();
    let rowmax_input = BundleMatrixSourceAt(
        mathematical_sources as integer {0..8});
    let (processed, process_flags) = MatrixPostProcessResult(
        result, intermediate_type);
    let rowmax_destination = BundleMatrixDestinationAt(1);
    let group_destination = if _BundleFixedPointAttributes.row_max_en then BundleMatrixDestinationAt(2)
        else BundleMatrixDestinationAt(1);
    let (row_result, row_flags) = if _BundleFixedPointAttributes.row_max_en then
        MatrixRowMaxResult(
            processed, rowmax_destination, rowmax_input,
            _BundleFixedPointAttributes.row_max_init,
            processed.data_type)
        else (_Tiles[[0]], Zeros{5});
    let (group_result, group_flags) = if _BundleFixedPointAttributes.group_max_en then
        MatrixGroupMaxResult(
            processed, group_destination, processed.data_type)
        else (_Tiles[[0]], Zeros{5});
    // Prepare every output from pre-commit state, then publish as one group.
    _Tiles[[destination]] = processed;
    if _BundleFixedPointAttributes.row_max_en then _Tiles[[rowmax_destination]] = row_result; end;
    if _BundleFixedPointAttributes.group_max_en then _Tiles[[group_destination]] = group_result; end;
    RecordNumericStatusFlags(process_flags OR row_flags OR group_flags);
end;

func CommitMatrixResult(destination: TileIndex, result: TileInfo)
begin
    CommitMatrixResult(destination, result, result.data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
