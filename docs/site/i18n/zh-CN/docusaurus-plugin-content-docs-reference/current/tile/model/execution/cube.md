<!-- GENERATED FROM: asl/tile/model/execution/cube.asl -->
# CUBE

**Normative ASL source:** `asl/tile/model/execution/cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-CUBE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-cube-purpose role=purpose-scope -->
## 用途与范围

本单元为 TMATMUL 和 TGEMV 族计算 CUBE 矩阵乘积。它构建原始累加结果，加上可选的偏置，然后把结果交给提交辅助函数。

完整指令束路径 `ExecuteBundleTMATMULOperation` 对普通形式调用 `TMATMULShared`，对 MX 形式调用 `TMATMULMXSharedWithOptionalScales`。本单元还为每个助记符定义一个直接函数，从 `TMATMUL` 到 `TGEMV_MX_ACC`，以及 `TMATMULMXShared`。未找到这些函数的 ASL 调用者。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-concepts role=concepts-state -->
## 概念与可见状态

- A 是左源，有 M 行 K 列。B 是右源，有 K 行 N 列。
- C 是 ACC 形式的显式累加器输入。D 是目标。
- 累加器类型来自 `TileMatrixAccumulatorDataType`：有符号输入为 S32，无符号输入为 U32，其他情况为 FP32。
- D 必须具有累加器类型；当所选 PreQuantMode 非零时，D 必须具有该模式的 `BundleFPATROutputType`。
- MX 形式增加按组缩放。一组覆盖 32 个内维元素，HiF4X2 为 64 个。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-rules role=rules-interactions -->
## 规则与交互

对每个结果行和列，和从 `MatrixInitialAccumulatorValue` 开始。不累加时该值为零，累加时为 C 元素，启用 CScale 时为缩放后的 C 元素。

随后内维索引按递增顺序从 0 运行到 K-1。普通形式每一步调用 `TileProfileMatrixAccumulate`，MX 形式每一步调用 `TileProfileMatrixScaledAccumulate`。

当累加器类型为 FP32、两个输入都是 FP32、TF32、HF32、FP16 或 BF16、三个载体都是有限值，并且对于 MX 形式两个缩放都不存在时，使用 FP32 参考路径。它先把乘积舍入到 FP32，再把和舍入到 FP32；普通形式使用 B.DATR 的 RMode 和 Sat，MX 形式使用默认控制。其他所有情况，包括整数类型以及无穷或 NaN 操作数，普通辅助函数都对原始元素载体返回 `accumulator + MultiplyWord(left, right)`，MX 辅助函数在缩放存在时先把每个输入乘以其缩放。

`MatrixBiasResult` 在乘积之后为每列加上一个偏置行元素。当值和偏置都是有限的 FP32 时，它用默认控制对二者之和进行舍入；否则直接相加载体。

CCTRL 位 0 置位时，`CommitMatrixRawPartial` 发布原始累加器类型结果，跳过后处理和辅助输出。否则由后处理单元中的 `CommitMatrixResult` 发布 D。

设计要点：A、B 和 C 在任何目标写入之前被读入私有副本，结果在私有 `TileInfo` 中构建。头部注释说明了其后果：当 D 指向 C 时，操作读取旧的 C 并写入新的 D。

设计要点：FP32 路径在每个内维步骤中舍入两次，并以固定顺序遍历 K，因此结果不是融合乘加，模型对每组输入给出唯一确定的结果。

设计要点：`MarkLocalTileValidRegionDefined` 清除所有已定义位，然后只标记有效区域。不应用 PadValue，因此 D 的填充保持未定义。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-boundaries role=boundaries -->
## 架构边界

这些辅助函数断言其形状和类型规则。`ExecuteBundleTMATMULOperation` 中的指令束预检在任何源快照之前检查这些规则，因此合法程序不会触发失败的断言。

在指令束路径上，当 TGEMV 形式的 M 不为 1 时，`ExecuteBundleTMATMULOperation` 产生 Fault_TileLegality；直接的 TGEMV 函数断言 1 个有效行。CScale 仅对 TMATMUL_ACC 和 TMATMUL_MX_ACC 合法；其 schema 是一个 M 行 1 列的 U8 CUBE_M32 Tile，合法性还要求 FP32 累加器。

累加和偏置丢弃数值状态标志。只有 CScale 和后处理记录标志。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-example role=example-usage -->
## 非规范阅读示例

考虑一个 M=1、N=1、K=2 的 FP32 TMATMUL_ACC：

```text
TMATMUL_ACC <M=1, N=1, K=2, FP32>, AccTile, SrcTile0, SrcTile1, ->DstTile<Size>
```

1. 左源行为 1.0 和 2.0。右源列为 3.0 和 4.0。累加器元素为 10.0。
2. 和从 10.0 开始。第 0 步加上 1.0 x 3.0 = 3.0，得到 13.0。
3. 第 1 步加上 2.0 x 4.0 = 8.0，得到 21.0。每个值都是精确的，因此不发生舍入。
4. 启用 CScale 且指数为 1 时，起始值为 10.0 / 2 = 5.0，结果为 16.0。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-related role=related-owners-navigation -->
## 相关所有者

- [矩阵缩放](matrix-scale.md)拥有初始累加值、CScale 和累加辅助函数。
- [后处理](postprocess.md)拥有 `CommitMatrixResult` 和辅助输出。
- [内部累加器](internal-accumulator.md)拥有非约束性的 CCTRL 缓存提示。
- [CUBE TMATMUL 分派](../../../block/model/dispatch/cube-tmatmul.md)执行预检并选择共享入口。
- [矩阵操作数](../legality/matrix-operands.md)拥有累加器、偏置和 CScale 的合法性。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-CUBE","surface":"tile","classification":["model","execution","cube"],"depends_on":["PTO-TILE-MODEL-MEMORY-RESTART","PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}
// PTO-REQ-CUBE-001: profile-defined matrix arithmetic with portable integer
// defaults. CUBE operations name their Local destination D explicitly. ACC
// forms also name their Local accumulator input C explicitly;
// C is snapshotted before D is written so D == C has read-old/write-new
// behavior.
func MarkLocalTileValidRegionDefined(tile: TileInfo) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    var result = tile;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.packed_defined_elements = zero_packed_tile_elements;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result.defined_elements[element] = '1';
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
func MatrixProductResultFromTiles(destination: TileIndex,
                                  destination_tile: TileInfo,
                                  accumulator: TileIndex,
                                  left_tile: TileInfo,
                                  right_tile: TileInfo,
                                  accumulate: boolean,
                                  c_scale: TileIndex,
                                  c_scale_present: boolean) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == left_tile.valid_rows;
    assert destination_tile.valid_columns == right_tile.valid_columns;
    assert destination_tile.data_type == expected_destination_type;
    if accumulate then
        assert accumulator_tile.allocated && accumulator_tile.contents_defined;
        assert accumulator_tile.valid_rows == left_tile.valid_rows;
        assert accumulator_tile.valid_columns == right_tile.valid_columns;
        assert accumulator_tile.data_type == accumulator_data_type;
        assert accumulator_tile.layout == destination_tile.layout;
        assert output_converted ||
               accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;
    if c_scale_present then
        assert accumulate &&
               TileMatrixLocalCScaleSchemaLegal(
                   c_scale,
                   left_tile.valid_rows as integer {1..65535});
    end;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var result: TileInfo = destination_tile;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    var result_payload: TilePayload = destination_tile.payload;
    let control = NumericExecutionControl {
        rounding_mode = DecodeBundleRoundingSelection(
            _BundleDataAttributes.rounding_mode).rounding_mode,
        saturating = _BundleDataAttributes.saturating
    };
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum = MatrixInitialAccumulatorValue(
                accumulator_tile, accumulate,
                row as integer {0..65535}, column as integer {0..65535},
                c_scale, c_scale_present);
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileStorageIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileStorageIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                sum = TileProfileMatrixAccumulate(sum,
                    left_payload[[left_element]], right_payload[[right_element]],
                    accumulator_data_type, left_tile.data_type,
                    right_tile.data_type, control);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.payload = result_payload;
    return MarkLocalTileValidRegionDefined(result);
end;
func MatrixProductResult(destination: TileIndex, accumulator: TileIndex,
                         left: TileIndex, right: TileIndex,
                         accumulate: boolean) => TileInfo
begin
    return MatrixProductResultFromTiles(destination, _Tiles[[destination]],
        accumulator, _Tiles[[left]], _Tiles[[right]], accumulate,
        0, FALSE);
end;
func MatrixBiasResult(input: TileInfo, bias: TileIndex,
                      intermediate_type: TileDataType) => TileInfo
begin
    let bias_tile = _Tiles[[bias]];
    let bias_payload = bias_tile.payload;
    assert bias_tile.allocated && bias_tile.contents_defined;
    assert TileCubeDescriptorLegal(bias_tile);
    assert bias_tile.valid_rows == 1;
    assert bias_tile.valid_columns == input.valid_columns;
    assert bias_tile.layout == TileLayout_CUBE_N8;
    assert bias_tile.data_type == intermediate_type;
    var result = input;
    var result_payload = input.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let result_element = TileLogicalLinearIndex(input,
                row as integer {0..65535}, column as integer {0..65535});
            let bias_element = TileLogicalLinearIndex(bias_tile,
                0, column as integer {0..65535});
            result_payload[[result_element]] = TileProfileMatrixBias(
                input.payload[[result_element]], bias_payload[[bias_element]],
                intermediate_type, bias_tile.data_type);
        end;
    end;
    result.payload = result_payload;
    return result;
end;
func MatrixMXProductResultFromTiles(destination: TileIndex,
                                    destination_tile: TileInfo,
                                    accumulator: TileIndex,
                                    left_tile: TileInfo,
                                    left_scale_tile: TileInfo,
                                    left_scale_present: boolean,
                                    right_tile: TileInfo,
                                    right_scale_tile: TileInfo,
                                    right_scale_present: boolean,
                                    accumulate: boolean,
                                    c_scale: TileIndex,
                                    c_scale_present: boolean) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert !left_scale_present ||
           (left_scale_tile.allocated && left_scale_tile.contents_defined);
    assert !right_scale_present ||
           (right_scale_tile.allocated && right_scale_tile.contents_defined);
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == left_tile.valid_rows;
    assert destination_tile.valid_columns == right_tile.valid_columns;
    assert destination_tile.data_type == expected_destination_type;
    if accumulate then
        assert accumulator_tile.allocated && accumulator_tile.contents_defined;
        assert accumulator_tile.valid_rows == left_tile.valid_rows;
        assert accumulator_tile.valid_columns == right_tile.valid_columns;
        assert accumulator_tile.data_type == accumulator_data_type;
        assert accumulator_tile.layout == destination_tile.layout;
        assert output_converted ||
               accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;
    if c_scale_present then
        assert accumulate &&
               TileMatrixLocalCScaleSchemaLegal(
                   c_scale,
                   left_tile.valid_rows as integer {1..65535});
    end;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let left_scale_payload = left_scale_tile.payload;
    let right_scale_payload = right_scale_tile.payload;
    var result: TileInfo = destination_tile;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    var result_payload = destination_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum = MatrixInitialAccumulatorValue(
                accumulator_tile, accumulate,
                row as integer {0..65535}, column as integer {0..65535},
                c_scale, c_scale_present);
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileStorageIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileStorageIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                let left_scale_element = if left_scale_present then
                    MatrixLeftScaleElement(
                        left_scale_tile, left_tile.data_type,
                        row as integer {0..65535},
                        inner as integer {0..65535})
                else
                    0;
                let right_scale_element = if right_scale_present then
                    MatrixRightScaleElement(
                        right_scale_tile, right_tile.data_type,
                        column as integer {0..65535},
                        inner as integer {0..65535})
                else
                    0;
                let left_scale_value = if left_scale_present then
                    left_scale_payload[[left_scale_element]]
                else
                    Zeros{PTO_XLEN};
                let right_scale_value = if right_scale_present then
                    right_scale_payload[[right_scale_element]]
                else
                    Zeros{PTO_XLEN};
                sum = TileProfileMatrixScaledAccumulate(
                    sum, left_payload[[left_element]],
                    right_payload[[right_element]],
                    left_scale_value, right_scale_value,
                    left_scale_present, right_scale_present,
                    accumulator_data_type, left_tile.data_type,
                    right_tile.data_type, left_scale_tile.data_type,
                    right_scale_tile.data_type);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.payload = result_payload;
    return MarkLocalTileValidRegionDefined(result);
end;
func MatrixMXProductResult(destination: TileIndex, accumulator: TileIndex,
                           left: TileIndex, left_scale: TileIndex,
                           right: TileIndex, right_scale: TileIndex,
                           accumulate: boolean) => TileInfo
begin
    let left_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[left]].data_type);
    let right_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[right]].data_type);
    return MatrixMXProductResultFromTiles(
        destination, _Tiles[[destination]], accumulator,
        _Tiles[[left]], _Tiles[[left_scale]], left_scale_present,
        _Tiles[[right]], _Tiles[[right_scale]], right_scale_present,
        accumulate, 0, FALSE);
end;
func MatrixMXProductResultWithOptionalScales(
    destination: TileIndex, destination_tile: TileInfo, accumulator: TileIndex,
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean,
    accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean) => TileInfo
begin
    return MatrixMXProductResultFromTiles(destination, destination_tile,
        accumulator, left, left_scale, left_scale_present, right, right_scale,
        right_scale_present, accumulate, c_scale, c_scale_present);
end;
func CommitMatrixRawPartial(destination: TileIndex, result: TileInfo,
                              accumulator_type: TileDataType)
begin
    // Spill uses the destination object reserved by complete preflight.  This
    // publishes only the raw accumulator result and deliberately bypasses
    // MatrixPostProcessResult and all auxiliary output publication.
    assert result.allocated && result.contents_defined;
    assert result.data_type == accumulator_type;
    _Tiles[[destination]] = result;
end;
func TMATMULShared(destination: TileIndex, destination_tile: TileInfo,
                   accumulator: TileIndex,
                   left: TileInfo, right: TileInfo,
                   bias: TileIndex, use_bias: boolean,
                   accumulate: boolean,
                   c_scale: TileIndex, c_scale_present: boolean,
                   partial_output: boolean)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        left.data_type, right.data_type);
    let product = MatrixProductResultFromTiles(destination, destination_tile,
        accumulator, left, right, accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    if partial_output then
        CommitMatrixRawPartial(destination, result, intermediate_type);
    else CommitMatrixResult(destination, result, intermediate_type); end;
end;
func TMATMULMXShared(destination: TileIndex, accumulator: TileIndex,
                     left: TileInfo, left_scale: TileInfo,
                     right: TileInfo, right_scale: TileInfo,
                     bias: TileIndex, use_bias: boolean,
                     accumulate: boolean)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultFromTiles(
        destination, _Tiles[[destination]], accumulator,
        left, left_scale, TRUE, right, right_scale, TRUE,
        accumulate, 0, FALSE);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    CommitMatrixResult(destination, result, intermediate_type);
end;
func TMATMULMXSharedWithOptionalScales(
    destination: TileIndex, destination_tile: TileInfo, accumulator: TileIndex,
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean,
    bias: TileIndex, use_bias: boolean, accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean,
    partial_output: boolean)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultWithOptionalScales(
        destination, destination_tile, accumulator,
        left, left_scale, left_scale_present,
        right, right_scale, right_scale_present,
        accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    if partial_output then
        CommitMatrixRawPartial(destination, result, intermediate_type);
    else CommitMatrixResult(destination, result, intermediate_type); end;
end;
func TMATMUL(destination: TileIndex, left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, destination,
        left, right, FALSE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left]].data_type, _Tiles[[right]].data_type));
end;
func TMATMUL_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex,
                  bias: TileIndex)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left]].data_type, _Tiles[[right]].data_type);
    let product = MatrixProductResult(destination, destination,
        left, right, FALSE);
    let result = MatrixBiasResult(product, bias, intermediate_type);
    CommitMatrixResult(destination, result, intermediate_type);
end;
func TMATMUL_ACC(destination: TileIndex, accumulator: TileIndex,
                 left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, accumulator,
        left, right, TRUE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left]].data_type, _Tiles[[right]].data_type));
end;
func TMATMUL_MX(destination: TileIndex, left: TileIndex,
                left_scale: TileIndex, right: TileIndex,
                right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
func TMATMUL_MX_BIAS(destination: TileIndex, left: TileIndex,
                     left_scale: TileIndex, right: TileIndex,
                     right_scale: TileIndex,
                     bias: TileIndex)
begin
    let product = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias, TileDataType_FP32);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
func TMATMUL_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                    left: TileIndex, left_scale: TileIndex,
                    right: TileIndex, right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, accumulator,
        left, left_scale, right, right_scale, TRUE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
func TGEMV(destination: TileIndex, left_vector: TileIndex,
           right_matrix: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixProductResult(destination, destination,
        left_vector, right_matrix, FALSE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left_vector]].data_type,
            _Tiles[[right_matrix]].data_type));
end;
func TGEMV_BIAS(destination: TileIndex, left_vector: TileIndex,
                right_matrix: TileIndex, bias: TileIndex)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left_vector]].data_type,
        _Tiles[[right_matrix]].data_type);
    assert _Tiles[[left_vector]].valid_rows == 1;
    let product = MatrixProductResult(destination, destination,
        left_vector, right_matrix, FALSE);
    let result = MatrixBiasResult(product, bias, intermediate_type);
    CommitMatrixResult(destination, result, intermediate_type);
end;
func TGEMV_ACC(destination: TileIndex, accumulator: TileIndex,
               left_vector: TileIndex, right_matrix: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixProductResult(destination, accumulator,
        left_vector, right_matrix, TRUE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left_vector]].data_type,
            _Tiles[[right_matrix]].data_type));
end;
func TGEMV_MX(destination: TileIndex, left_vector: TileIndex,
              left_scale: TileIndex, right_matrix: TileIndex,
              right_scale: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixMXProductResult(destination, destination,
        left_vector, left_scale, right_matrix, right_scale, FALSE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV_MX_BIAS(destination: TileIndex, left_vector: TileIndex,
                   left_scale: TileIndex, right_matrix: TileIndex,
                   right_scale: TileIndex,
                   bias: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let product = MatrixMXProductResult(destination, destination,
        left_vector, left_scale, right_matrix, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias, TileDataType_FP32);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                  left_vector: TileIndex, left_scale: TileIndex,
                  right_matrix: TileIndex, right_scale: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixMXProductResult(destination, accumulator,
        left_vector, left_scale, right_matrix, right_scale, TRUE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
```
<!-- GENERATED-ASL-END: unit -->
