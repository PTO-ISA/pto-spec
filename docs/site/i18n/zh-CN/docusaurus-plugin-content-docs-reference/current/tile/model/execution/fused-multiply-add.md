<!-- GENERATED FROM: asl/tile/model/execution/fused-multiply-add.asl -->
# Fused Multiply Add

**Normative ASL source:** `asl/tile/model/execution/fused-multiply-add.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `TFMA`，即 TFMA 指令的处理函数。它对每个活动的有效坐标计算左乘右再加加数，三个源和目标使用同一数据类型。

它还拥有逐元素辅助函数 `TileFixedFusedMultiplyAddValue`，TFMA 指令页把它指定为其值契约。

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-concepts role=concepts-state -->
## 概念与可见状态

该处理函数有四个 Tile 操作数：目标、左源、右源和加数。`TileOperandsLegal_TFMA` 要求四者形状、布局和数据类型相同。布局必须是 RowMajor、CUBE_M16 或 CUBE_M32。

元素结果是一个值加五个状态标志，从 bit 0 到 bit 4 依次为 NV、DZ、OF、UF 和 NX。处理函数把活动元素的标志按位或起来。

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-rules role=rules-interactions -->
## 规则与交互

对整数类型，每个源都按元素宽度读作无符号元素。结果是乘积加加数后的低位，不产生标志。因此有符号和无符号类型产生相同的位模式。

对浮点类型，先处理三种无效情况：

- 任一源为信号 NaN。
- 零乘无穷，顺序不限。
- 无穷乘积加上符号相反的无穷加数。

每种情况都返回规范静默 NaN 并设置 NV。其他输入交给 `ScalarFPFusedProfile`，舍入为 RNE。

设计要点：三个源都在任何写入之前被快照。处理函数在循环前复制目标和三个源的 `TileInfo` 记录，并私下构建结果。因此目标即使命名某个源，读取的仍是旧值。

设计要点：发布只发生一次。有效载荷、有效区域已定义性和填充都在私有副本上计算，并一起变为可见。标志在发布之后用 `ScalarFPRecordFlags` 记录。

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-boundaries role=boundaries -->
## 架构边界

操作数合法性在处理函数运行之前检查，处理函数本身不产生故障。对浮点类型，合法性还要求每个有效源元素的编码合法；存在 ExecutionMask 时只检查活动元素。

在 ExecutionMask 下，非活动坐标不读取任何源，并取 ZERO 或 MERGE 值。它不贡献标志。

`TileFusedMultiplyAddDataTypeSupported` 允许 16 种算术类型。`ScalarFPFusedProfile` 断言类型为 FP64、FP32 或 FP16。对合法性允许的其他浮点类型，只有这三种无效情况产生结果，即规范静默 NaN；其他所有输入都会到达 `ScalarFPFusedProfile`，而其断言只允许 FP64、FP32 和 FP16。

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-example role=example-usage -->
## 非规范阅读示例

考虑在 32 乘 4 元素、有效行为一行的 U8 Tile 上执行 TFMA，没有 ExecutionMask：

```text
TFMA <Row=32, Col=4, ValidRow=1, U8>, T#1, T#2, T#3, ->T<128B>
```

第一个有效列中，左源为 20，右源为 13，加数为 7。

1. 乘积为 20 x 13 = 260。
2. 加上加数得到 267。
3. U8 元素保留低八位：267 - 256 = 11。

目标元素为 11，不记录任何标志。在 S8 Tile 中，相同的位模式会产生相同的结果位。

TFMA 生成的合法性列表只列出 FP16、FP32 和 BF16，因此这个 U8 情况说明的是可执行 ASL 的值辅助函数，而不是该列表允许的形式。

<!-- PTO-READER-BLOCK: tile-model-execution-fused-multiply-add-related role=related-owners-navigation -->
## 相关所有者

- [TFMA](../../elementwise-tile-tile/arithmetic/TFMA.md) 是到达该处理函数的指令。
- [索引布局合法性](../legality/indexed-layout.md)拥有 `TileOperandsLegal_TFMA`。
- [标量浮点](../../../scalar/model/fsu/scalar-fp.md)拥有 `ScalarFPFusedProfile`。
- [逐元素执行](elementwise.md)拥有共享的元素规范化辅助函数。
- [执行掩码状态](execution-mask-state.md)拥有非活动坐标的处理。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/fused-multiply-add.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD","surface":"tile","classification":["model","execution","fused-multiply-add"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-SCALAR-MODEL-FSU-SCALAR-FP"]}
func TileProfileFusedMultiplyAdd(
    data_type: TileDataType,
    addend: Word,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    return ScalarFPFusedProfile(
        FloatingFused_MADD,
        DefaultNumericExecutionControl().rounding_mode,
        TileDataTypeToEncoding(data_type),
        addend,
        left,
        right);
end;

func TileProfileFusedInvalidResult(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    let (available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    assert available;
    return (quiet_nan, Zeros{5} + 1);
end;

pure func TileNumericClassIsNegative(
    value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_NegativeZero ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeInfinity;
end;

func TileFixedFusedMultiplyAddValue(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    assert TileFusedMultiplyAddDataTypeSupported(data_type);
    if TileDataTypeIsInteger(data_type) then
        let left_element = TileUnsignedElementValue(left, data_type);
        let right_element = TileUnsignedElementValue(right, data_type);
        let addend_element = TileUnsignedElementValue(addend, data_type);
        return (
            TileUnsignedElementValue(
                MultiplyWord(left_element, right_element) + addend_element,
                data_type),
            Zeros{5});
    end;

    assert TileNumericEncodingValid(data_type, left);
    assert TileNumericEncodingValid(data_type, right);
    assert TileNumericEncodingValid(data_type, addend);
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let addend_class = TileNumericValueClass(data_type, addend);
    let signaling_nan =
        left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN ||
        addend_class == NumericValue_SignalingNaN;
    let zero_times_infinity =
        (NumericValueClassIsZero(left_class) &&
         NumericValueClassIsInfinity(right_class)) ||
        (NumericValueClassIsInfinity(left_class) &&
         NumericValueClassIsZero(right_class));
    let product_is_infinite =
        NumericValueClassIsInfinity(left_class) ||
        NumericValueClassIsInfinity(right_class);
    let product_is_negative =
        TileNumericClassIsNegative(left_class) !=
        TileNumericClassIsNegative(right_class);
    let opposite_infinities =
        product_is_infinite &&
        NumericValueClassIsInfinity(addend_class) &&
        product_is_negative != TileNumericClassIsNegative(addend_class);
    if signaling_nan || zero_times_infinity || opposite_infinities then
        return TileProfileFusedInvalidResult(
            data_type,
            left,
            right,
            addend);
    end;
    return TileProfileFusedMultiplyAdd(
        data_type,
        addend,
        left,
        right);
end;

// PTO-REQ-TFMA-001: complete preflight precedes three source snapshots. The
// valid payload, padding definedness, descriptor, and accumulated flags are
// computed privately and become visible only through the final publication.
func TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex)
begin
    assert TileOperandsLegal_TFMA(
        destination,
        source_left,
        source_right,
        addend);
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let addend_tile = _Tiles[[addend]];
    var result_tile = destination_tile;
    var flags = Zeros{5};
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                destination_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            var result = Zeros{PTO_XLEN};
            var element_flags = Zeros{5};
            if BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let (active_result, active_flags) =
                    TileFixedFusedMultiplyAddValue(
                        destination_tile.data_type,
                        TileReadLogicalElement(left_tile, element),
                        TileReadLogicalElement(right_tile, element),
                        TileReadLogicalElement(addend_tile, element));
                result = active_result;
                element_flags = active_flags;
            else
                result = BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result_tile = TileInfoWithLogicalElement(result_tile, element,
                result);
            flags = flags OR element_flags;
        end;
    end;
    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    _Tiles[[destination]] = result_tile;
    ScalarFPRecordFlags(flags);
end;
```
<!-- GENERATED-ASL-END: unit -->
