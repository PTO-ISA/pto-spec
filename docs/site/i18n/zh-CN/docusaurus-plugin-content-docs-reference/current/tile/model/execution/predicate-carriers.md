<!-- GENERATED FROM: asl/tile/model/execution/predicate-carriers.asl -->
# Predicate Carriers

**Normative ASL source:** `asl/tile/model/execution/predicate-carriers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-predicate-carriers-purpose role=purpose-scope -->
## 用途与范围

本单元包含通用寄存器（GPR）所承载的 CUBE 谓词的执行辅助函数、TGPR2T 转置器，以及可接受显式 ExecutionMask 的操作列表。

块分派从 `ExecuteBundleComparisonGPRCarrier` 到达这些 GPR 辅助函数：

- 带 GPR 目标的 TCMPS 调用 `TileCompareCUBEScalarToGPRAs`。
- 带 ExecutionMask 的 TCMP 和 TCMPS 让其结果字经过 `TileExecutionMaskPredicateGPRResult`。
- 带 GPR 掩码的 TSEL 调用 `ExecuteTileSelectCUBEGPRAs`，TSELS 调用 `ExecuteTileSelectScalarCUBEGPRAs`。

`TGPR2T` 是 TGPR2T 指令的处理函数。

<!-- PTO-READER-BLOCK: tile-model-execution-predicate-carriers-concepts role=concepts-state -->
## 概念与可见状态

GPR 谓词在索引 `row + field x rows` 处为每个坐标打包一位。CUBE_M32 的 rows 为 32，CUBE_M16 为 16。一个字段就是一列。CUBE_M32 每字有 2 个字段，CUBE_M16 对 32 位类型有 2 个，其他情况有 4 个。对于 8 位类型，`high` 选择子从第 2 列（M32）或第 4 列（M16）开始。

`TileOperationExecutionMaskEligible` 是指令束分派在接受 ExecutionMask 载体之前查询的列表。它列出 92 个操作名，包括 MGATHER 和 MSCATTER 形式、逐元素和 Tile-标量操作、扩展、TCMP、TSEL、TCVT、TPACK、TSHUF、TLOAD、TSTORE 和 TGPR2T，也包括 TGATHER、TSCATTER 和 TTRI，而 ExecutionMask 源 schema 的 NDF 规定这三者没有适用的 ExecutionMask 形式。它不列出任何归约或矩阵操作。

<!-- PTO-READER-BLOCK: tile-model-execution-predicate-carriers-rules role=rules-interactions -->
## 规则与交互

`TileCompareCUBEScalarToGPRAs` 从 `TilePredicateGPRPaddingValue` 开始，因此有效形状之外坐标的位保持填充模式。对每个有效的活动坐标，它规格化标量、比较并写入该位。它一次性记录累积标志并返回该字。

`TileExecutionMaskPredicateGPRResult` 随后重新访问每个有效的非活动坐标。在 ZERO 下它清除该位。在 MERGE 下它从目标 GPR 的旧值复制该位，分派在写入之前读取该旧值。

GPR 掩码选择辅助函数对活动坐标用 `TileCubePredicateGPRBit` 读取掩码位，对非活动坐标使用 `BundleExecutionMaskDestinationValue`。随后它们把有效区域标为已定义并施加指令束 PadValue。

`TGPR2T` 读取四个 GPR，并在有效区域之外施加有效填充值。存在 B.DATR 时该填充为 B.DATR PadValue，否则为 Zero。每个活动的有效元素被设为填充值，每个非活动元素被设为其 ExecutionMask 值。随后 B.DATR RMode 第 1 到 0 位中的字节偏移选择接收打包字节的列。对于 CUBE_M32，该列每行得到一个字节，第 b 位取自平面 b。对于 CUBE_M16，两相邻列得到平面 0 到 7 和 8 到 15。每个打包字节只在坐标活动处写入。

设计要点：有效形状之外的位从填充模式开始且从不被覆写。读取整个 GPR 的消费者看到的是由 PadValue 选择的值，而不是残留值。

设计要点：TGPR2T 产生普通数值 U8 Tile，而不是 PredicateCell。其字节是打包的平面位，因此不限于 `0x00` 或 `0x01`。

<!-- PTO-READER-BLOCK: tile-model-execution-predicate-carriers-boundaries role=boundaries -->
## 架构边界

TGPR2T 要求 U8 CUBE 目标，有效形状为 32 乘 4（CUBE_M32）或 16 乘 8（CUBE_M16），RMode 第 2 位清零，有效填充为 Zero 或 Max。它不记录数值状态，也不写任何 GPR。

需求注释称合格集合为“the exact 91-op applicability set”，而函数列出了 92 个名字。

`TileTGPR2TEncodingLegal` 在当前 ASL 中没有调用者。

<!-- PTO-READER-BLOCK: tile-model-execution-predicate-carriers-example role=example-usage -->
## 非规范阅读示例

在 CUBE_M32 目标上执行 TGPR2T，B.DATR PadValue 为 Zero，RMode 为 0，且没有 ExecutionMask。第一个 GPR 为 `0x0000000100000001`，其余三个为零。

1. 填充和有效区域循环共同在每个元素写入 `0x00` 并标为已定义。
2. 偏移为 0，因此第 0 列接收打包字节。
3. 对于第 0 行，第 b 位来自平面 b。平面 0 是 GPR 0 的第 0 位，为 1。平面 1 是 GPR 0 的第 32 位，为 1。平面 2 到 7 为 0。
4. 第 0 行第 0 列变为 `0x03`。第 0 列的第 1 到 31 行为 `0x00`，第 1 到 3 列保持 `0x00`。

若 PadValue 为 Max，第 1 到 3 列将改为 `0xff`。

<!-- PTO-READER-BLOCK: tile-model-execution-predicate-carriers-related role=related-owners-navigation -->
## 相关所有者

- [比较](comparison.md)拥有 `TileCompareCUBEToGPRAs`、`TileCompareElement` 和 GPR 填充值。
- [ExecutionMask 状态](execution-mask-state.md)拥有 `TileCubePredicateGPRBit` 和非活动值选择。
- [谓词载体合法性](../legality/predicate-carriers.md)拥有字段数和 GPR 形状规则。
- [TGPR2T schema](../../../block/model/dispatch/tgpr2t-schema.md)在此处理函数运行之前检查 TGPR2T 指令束。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/predicate-carriers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","surface":"tile","classification":["model","execution","predicate-carriers"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-MASK","PTO-TILE-MODEL-STATE-ALLOCATION","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
// PTO-REQ-TEPL-PREDICATE-CARRIER-001: CUBE predicate carriers and explicit ExecutionMask.
// Eligible Local CUBE_M16/CUBE_M32 TileOps use an explicit ExecutionMask
// operand represented either by the existing one/two-word GPR mapping or by a
// canonical U8 TileStorage_PredicateCell with 0x00/0x01 values. PredicateCell
// consumer compatibility uses logical layout and valid rows and columns;
// generic ExecutionMask consumption MUST NOT require the producer's
// predicate_basis_type to equal the consumer operation type. Generic GPR
// binding schemas use TileOperationExecutionMaskEligible as the exact 91-op
// applicability set, excluding reductions, contractions, GMOV, and TPREFETCH.
// The carrier is
// snapshotted before an overlapping predicate destination is allocated or
// published. Effective activity is PE_MASK[pe] AND (mask_bit XOR PredInv),
// with PredInv and inactive ZERO/MERGE selected by B.DATR. Inactive effects
// MUST not read element-only source payloads, contribute numeric status, probe
// or fault on memory, or modify a destination except to preserve its old value
// (MERGE) or write zero (ZERO). No implicit mask state, packed-i1 storage,
// P0..P7 consumption, or mask stack is introduced.

readonly func TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
    source: TileIndex, scalar: Word, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    if !TileCubePredicateGPRDataTypeSupported(operation_type) ||
       !TileCubePredicateGPRShapeLegalAs(source, operation_type) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    return TileCubeNumericSourceLegalAs(source, operation_type) &&
           TileNumericEncodingValid(
               operation_type, TileRawElementValue(scalar, operation_type));
end;
readonly func TileOperandsLegal_ExecuteTileCompareCUBEScalarGPR(
    source: TileIndex, scalar: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
               source, scalar, operation_type);
end;

readonly func TileOperandsLegal_ExecuteTileSelectCUBEGPRAs(
    destination: TileIndex, source_true: TileIndex, source_false: TileIndex,
    operation_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, operation_type) &&
           TileCubeNumericShapeMatch(source_true, source_false) &&
           TileCubeNumericContentsDefined(source_true) &&
           TileCubeNumericContentsDefined(source_false) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_true]].data_type, operation_type) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_false]].data_type, operation_type) &&
           TileCubeDescriptorLegal(_Tiles[[destination]]) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].data_type == operation_type &&
           TileCubeNumericShapeMatch(destination, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileSelectCUBEGPR(
    destination: TileIndex, source_true: TileIndex, source_false: TileIndex)
    => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileSelectCUBEGPRAs(
               destination, source_true, source_false, operation_type);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAs(
    destination: TileIndex, source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, operation_type) &&
           TileCubeNumericContentsDefined(source_true) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_true]].data_type, operation_type) &&
           TileCubeDescriptorLegal(_Tiles[[destination]]) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].data_type == operation_type &&
           TileCubeNumericShapeMatch(destination, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalarCUBEGPR(
    destination: TileIndex, source_true: TileIndex, scalar_false: Word)
    => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAs(
               destination, source_true, scalar_false, operation_type);
end;

func TileCompareCUBEScalarToGPRAs(source: TileIndex, scalar: Word,
                                  comparison: TileComparison,
                                  high: boolean,
                                  operation_type: TileDataType) => Word
begin
    assert TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
        source, scalar, operation_type);
    let tile = _Tiles[[source]];
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    let rows = TileCubePredicateRowBits(tile.layout);
    let fields = TileCubePredicateFieldCount(operation_type, tile.layout);
    let base = TileCubePredicateColumnBase(operation_type, tile.layout, high);
    var result = TilePredicateGPRPaddingValue();
    var flags = Zeros{5};
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < tile.valid_columns then
            for row = 0 to rows - 1 looplimit 32 do
                if row < tile.valid_rows &&
                   BundleExecutionMaskActiveAt(
                       tile.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let (predicate, element_flags) = TileCompareElement(
                        comparison, operation_type,
                        TileReadLogicalElement(tile, element),
                        normalized_scalar);
                    flags = flags OR element_flags;
                    result[row + field * rows] = if predicate then '1' else '0';
                end;
            end;
        end;
    end;
    RecordNumericStatusFlags(flags);
    return result;
end;
func TileCompareCUBEScalarToGPR(source: TileIndex, scalar: Word,
                                comparison: TileComparison,
                                high: boolean) => Word
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    assert operation_type_valid;
    return TileCompareCUBEScalarToGPRAs(
        source, scalar, comparison, high, operation_type);
end;

func TileExecutionMaskPredicateGPRResult(
    result: Word, old_value: Word, data_type: TileDataType,
    layout: TileLayout, valid_rows: integer {1..65535},
    valid_columns: integer {1..65535}, high: boolean) => Word
begin
    if !_BundleExecutionMask.valid then return result; end;
    var masked = result;
    let rows = TileCubePredicateRowBits(layout);
    let fields = TileCubePredicateFieldCount(data_type, layout);
    let base = TileCubePredicateColumnBase(data_type, layout, high);
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < valid_columns then
            for row = 0 to rows - 1 looplimit 32 do
                if row < valid_rows &&
                   !BundleExecutionMaskActiveAt(
                       layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let bit_index = (row + field * rows)
                        as integer {0..63};
                    masked[bit_index] = if _BundleExecutionMask.zero_inactive
                        then '0' else old_value[bit_index];
                end;
            end;
        end;
    end;
    return masked;
end;

func ExecuteTileSelectCUBEGPRAs(destination: TileIndex, mask_low: Word,
                                mask_high: Word, source_true: TileIndex,
                                source_false: TileIndex,
                                operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileSelectCUBEGPRAs(
        destination, source_true, source_false, operation_type);
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    var result = _Tiles[[destination]];
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   true_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let selected = TileCubePredicateGPRBit(
                    mask_low, mask_high, true_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
                value = if selected then
                    TileReadLogicalElement(true_tile, element)
                    else TileReadLogicalElement(false_tile, element);
            else
                value = BundleExecutionMaskDestinationValue(
                    true_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(result, element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelectCUBEGPR(destination: TileIndex, mask_low: Word,
                              mask_high: Word, source_true: TileIndex,
                              source_false: TileIndex)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    assert operation_type_valid;
    ExecuteTileSelectCUBEGPRAs(
        destination, mask_low, mask_high, source_true, source_false,
        operation_type);
end;

func ExecuteTileSelectScalarCUBEGPRAs(
    destination: TileIndex, mask_low: Word, mask_high: Word,
    source_true: TileIndex, scalar_false: Word,
    operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileSelectScalarCUBEGPRAs(
        destination, source_true, scalar_false, operation_type);
    let true_tile = _Tiles[[source_true]];
    let normalized_scalar = TileRawElementValue(scalar_false,
        operation_type);
    var result = _Tiles[[destination]];
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   true_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let selected = TileCubePredicateGPRBit(
                    mask_low, mask_high, true_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
                value = if selected then
                    TileReadLogicalElement(true_tile, element)
                    else normalized_scalar;
            else
                value = BundleExecutionMaskDestinationValue(
                    true_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(result, element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelectScalarCUBEGPR(destination: TileIndex, mask_low: Word,
                                    mask_high: Word, source_true: TileIndex,
                                    scalar_false: Word)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    assert operation_type_valid;
    ExecuteTileSelectScalarCUBEGPRAs(
        destination, mask_low, mask_high, source_true, scalar_false,
        operation_type);
end;

pure func TileTGPR2TEncodingLegal(mask: integer, match: integer) => boolean
begin
    return mask == 0x000fffff && match == 0x07e19181;
end;

pure func TileTGPR2TRModeLegal(raw_rmode: bits(3)) => boolean
begin
    return raw_rmode[2] == '0';
end;

pure func TileTGPR2TByteOffset(raw_rmode: bits(3)) => integer {0..3}
begin
    assert TileTGPR2TRModeLegal(raw_rmode);
    return UInt(raw_rmode[1:0]) as integer {0..3};
end;

readonly func TileTGPR2TEffectivePadValue() => TilePadValue
begin
    return if _BundleDataAttributesPresent then CurrentBundlePadValue()
        else TilePad_Zero;
end;

readonly func TileTGPR2TPadLegal() => boolean
begin
    let pad = TileTGPR2TEffectivePadValue();
    return pad == TilePad_Zero || pad == TilePad_Max;
end;

pure func TileTGPR2TPredicateBit(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    plane: integer {0..15}, row: integer {0..31}) => bit
begin
    // M32 packs two 32-bit predicate planes per complete 64-bit GPR.
    assert row < 32;
    let word = plane DIVRM 2;
    let half = plane MOD 2;
    let within = half * 32 + row;
    if word == 0 then return gpr0[within]; end;
    if word == 1 then return gpr1[within]; end;
    if word == 2 then return gpr2[within]; end;
    return gpr3[within];
end;

pure func TileTGPR2TPredicateBitM16(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    plane: integer {0..15}, row: integer {0..15}) => bit
begin
    // M16 packs four 16-bit predicate planes per complete 64-bit GPR.
    let word = plane DIVRM 4;
    let quarter = plane MOD 4;
    let within = quarter * 16 + row;
    if word == 0 then return gpr0[within]; end;
    if word == 1 then return gpr1[within]; end;
    if word == 2 then return gpr2[within]; end;
    return gpr3[within];
end;

pure func TileTGPR2TPackedRowByte(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    row: integer {0..31}) => bits(8)
begin
    var result = Zeros{8};
    for bit_index = 0 to 7 looplimit 8 do
        result[bit_index] = TileTGPR2TPredicateBit(
            gpr0, gpr1, gpr2, gpr3, bit_index as integer {0..15}, row);
    end;
    return result;
end;

pure func TileTGPR2TPackedRowHalf(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    row: integer {0..15}, high: boolean) => bits(8)
begin
    var result = Zeros{8};
    let plane_base = if high then 8 else 0;
    for bit_index = 0 to 7 looplimit 8 do
        let plane = (plane_base + bit_index) as integer {0..15};
        result[bit_index] = TileTGPR2TPredicateBitM16(
            gpr0, gpr1, gpr2, gpr3, plane, row);
    end;
    return result;
end;

readonly func TileOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    if source0 >= PTO_ABSOLUTE_GPR_COUNT ||
       source1 >= PTO_ABSOLUTE_GPR_COUNT ||
       source2 >= PTO_ABSOLUTE_GPR_COUNT ||
       source3 >= PTO_ABSOLUTE_GPR_COUNT ||
       !TileCubeDescriptorLegal(_Tiles[[destination]]) ||
       _Tiles[[destination]].storage_kind != TileStorage_Numeric ||
       _Tiles[[destination]].data_type != TileDataType_U8 ||
       !TileLayoutIsCube(_Tiles[[destination]].layout) ||
       !TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) ||
       !TileTGPR2TPadLegal() then
        return FALSE;
    end;
    let tile = _Tiles[[destination]];
    return (tile.layout == TileLayout_CUBE_M32 &&
            tile.valid_rows == 32 && tile.valid_columns == 4) ||
           (tile.layout == TileLayout_CUBE_M16 &&
            tile.valid_rows == 16 && tile.valid_columns == 8);
end;

func TGPR2T(destination: TileIndex, source0: TileIndex, source1: TileIndex,
            source2: TileIndex, source3: TileIndex)
begin
    assert TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    let gpr0 = ReadGPR(source0 as GPRIndex);
    let gpr1 = ReadGPR(source1 as GPRIndex);
    let gpr2 = ReadGPR(source2 as GPRIndex);
    let gpr3 = ReadGPR(source3 as GPRIndex);
    let selected_pad = TileTGPR2TEffectivePadValue();
    var result = TileWithPadding(_Tiles[[destination]], selected_pad);
    let pad = TilePadValueForDataType(selected_pad,
        result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 32 do
        for column = 0 to result.valid_columns - 1 looplimit 8 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let value = if BundleExecutionMaskActiveAt(
                result.layout, row as integer {0..65535},
                column as integer {0..65535}) then pad else
                BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            result = TileInfoWithLogicalElementAndDefined(
                result, index, value, TRUE);
        end;
    end;
    let offset = TileTGPR2TByteOffset(
        _BundleDataAttributes.rounding_mode);
    if result.layout == TileLayout_CUBE_M32 then
        for row = 0 to 31 looplimit 32 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, offset);
            var value = Zeros{PTO_XLEN};
            value[7:0] = TileTGPR2TPackedRowByte(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..31});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535}, offset) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, index, value, TRUE);
            end;
        end;
    else
        for row = 0 to 15 looplimit 16 do
            let pair_start = (offset * 2) as integer {0..6};
            let low = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start);
            let high = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start + 1);
            var low_value = Zeros{PTO_XLEN};
            low_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, FALSE);
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   pair_start) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, low, low_value, TRUE);
            end;
            var high_value = Zeros{PTO_XLEN};
            high_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, TRUE);
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   pair_start + 1) then
                result = TileInfoWithLogicalElementAndDefined(
                    result, high, high_value, TRUE);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    _Tiles[[destination]] = result;
end;

pure func TileOperationExecutionMaskEligible(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return            decoded == TileOperation_MGATHER || decoded == TileOperation_MGATHER_ADD || decoded == TileOperation_MGATHER_AND || decoded == TileOperation_MGATHER_CAS || decoded == TileOperation_MGATHER_DEC ||
           decoded == TileOperation_MGATHER_EXCH || decoded == TileOperation_MGATHER_INC || decoded == TileOperation_MGATHER_MASK || decoded == TileOperation_MGATHER_MAX || decoded == TileOperation_MGATHER_MIN ||
           decoded == TileOperation_MGATHER_OR || decoded == TileOperation_MGATHER_XOR || decoded == TileOperation_MSCATTER || decoded == TileOperation_MSCATTER_ADD || decoded == TileOperation_MSCATTER_AND ||
           decoded == TileOperation_MSCATTER_DEC || decoded == TileOperation_MSCATTER_INC || decoded == TileOperation_MSCATTER_MASK || decoded == TileOperation_MSCATTER_MAX || decoded == TileOperation_MSCATTER_MIN ||
           decoded == TileOperation_MSCATTER_OR || decoded == TileOperation_MSCATTER_POPC || decoded == TileOperation_MSCATTER_XOR || decoded == TileOperation_TABS || decoded == TileOperation_TADD ||
           decoded == TileOperation_TADDS || decoded == TileOperation_TAND || decoded == TileOperation_TANDS || decoded == TileOperation_TCI || decoded == TileOperation_TCMP ||
           decoded == TileOperation_TCMPS || decoded == TileOperation_TCOLEXPAND || decoded == TileOperation_TCOLEXPANDADD || decoded == TileOperation_TCOLEXPANDDIV || decoded == TileOperation_TCOLEXPANDEXPDIF ||
           decoded == TileOperation_TCOLEXPANDMAX || decoded == TileOperation_TCOLEXPANDMIN || decoded == TileOperation_TCOLEXPANDMUL || decoded == TileOperation_TCOLEXPANDSUB || decoded == TileOperation_TCVT || decoded == TileOperation_TEXPDIF ||
           decoded == TileOperation_TDIV || decoded == TileOperation_TDIVS || decoded == TileOperation_TEXP || decoded == TileOperation_TEXPANDS || decoded == TileOperation_TFMA ||
           decoded == TileOperation_TGATHER || decoded == TileOperation_TGPR2T || decoded == TileOperation_TLOAD || decoded == TileOperation_TLOG || decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMAXS || decoded == TileOperation_TMIN || decoded == TileOperation_TMINS || decoded == TileOperation_TMOV || decoded == TileOperation_TMUL ||
           decoded == TileOperation_TMULS || decoded == TileOperation_TNEG || decoded == TileOperation_TNOT || decoded == TileOperation_TOR || decoded == TileOperation_TORS ||
           decoded == TileOperation_TPACK || decoded == TileOperation_TPERMUTE || decoded == TileOperation_TRECIP || decoded == TileOperation_TRELU || decoded == TileOperation_TREM ||
           decoded == TileOperation_TREMS || decoded == TileOperation_TROWEXPAND || decoded == TileOperation_TROWEXPANDADD || decoded == TileOperation_TROWEXPANDDIV || decoded == TileOperation_TROWEXPANDEXPDIF ||
           decoded == TileOperation_TROWEXPANDMAX || decoded == TileOperation_TROWEXPANDMIN || decoded == TileOperation_TROWEXPANDMUL || decoded == TileOperation_TROWEXPANDSUB || decoded == TileOperation_TRSQRT ||
           decoded == TileOperation_TSCATTER || decoded == TileOperation_TSEL || decoded == TileOperation_TSELS || decoded == TileOperation_TSHL || decoded == TileOperation_TSHLS ||
           decoded == TileOperation_TSHR || decoded == TileOperation_TSHRS || decoded == TileOperation_TSHUF || decoded == TileOperation_TSQRT || decoded == TileOperation_TSTORE ||
           decoded == TileOperation_TSUB || decoded == TileOperation_TSUBS || decoded == TileOperation_TTRI || decoded == TileOperation_TUNPACK || decoded == TileOperation_TXOR ||
           decoded == TileOperation_TXORS;
end;
```
<!-- GENERATED-ASL-END: unit -->
