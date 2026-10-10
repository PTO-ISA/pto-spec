<!-- GENERATED FROM: asl/tile/model/execution/generation.asl -->
# Generation

**Normative ASL source:** `asl/tile/model/execution/generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-generation-purpose role=purpose-scope -->
## 用途与范围

本单元定义不读取源 Tile 而直接生成数值的 Tile 操作。`TCI` 把整数索引序列写入单行 RowMajor Tile。`TCICube` 把二维索引图样写入 CUBE_M16 或 CUBE_M32 Tile。`TTRI` 写入由类型化的一和零构成的三角掩码。

它还拥有这些操作的类型集合：`TileTCIDataTypeSupported` 接受 S32、S16、U32 和 U16，`TileTTRIDataTypeSupported` 在此基础上增加 FP32 和 FP16。

<!-- PTO-READER-BLOCK: tile-model-execution-generation-concepts role=concepts-state -->
## 概念与可见状态

这些辅助函数只修改目标 `TileInfo`：其载荷、逐元素已定义性、`defined_valid_elements` 以及 `contents_defined`。每个辅助函数都在局部副本中构建结果，并在末尾对 `_Tiles` 赋值一次。

起始值来自标量寄存器。`TileRawElementValue` 只保留适合元素宽度的低位，每个生成值也以同样方式归一化。因此整数序列按元素宽度取模回绕。

`TTRI` 把每一列 `c` 与 `r + diagonal` 比较，其中 `r` 是行号。下三角方向选择 `c <= r + diagonal`；上三角方向选择 `c >= r + diagonal`。被选中的元素得到 `TileTTRIOneEncoding` 给出的类型化一，例如 FP32 的 `0x3f800000`；其他有效元素得到零。

<!-- PTO-READER-BLOCK: tile-model-execution-generation-rules role=rules-interactions -->
## 规则与交互

`TCI` 断言 `valid_rows == 1`，并把第 `k` 列写为 `start + k`，降序时写为 `start - k`。

`TCICube` 接收一个打包的 Step2D 字。位 63 到 32 给出行步长，位 31 到 0 给出列步长，每个步长必须是 -1、0 或 1。元素 (row, column) 得到 `start + row x row_step + column x column_step`，并按元素宽度归一化。

`TCICube` 是本单元中唯一查询 ExecutionMask 的辅助函数。活动坐标得到生成值。非活动坐标得到 `BundleExecutionMaskDestinationValue`：在 ZERO 下为零，在 MERGE 下为合并基准的旧值。

三个辅助函数都先调用 `TileWithValidRegionDefined`，再以 `TilePad_Null` 调用 `TileWithPadding`。它们不使用指令束的 PadValue。

设计要点：生成操作总是以 Null 填充。TCI 和 TTRI 的 B.DATR 契约要求填充字段为零，因此这些指令不携带 PadValue。Null 在有效区域之外写入零载体，但这些元素保持未定义，因此之后的已定义性检查不会把它们当作生成数据。

设计要点：运算是原始载体运算后再截断。U16 升序序列越过 65535 后从 0 继续，不会故障也不会饱和。

<!-- PTO-READER-BLOCK: tile-model-execution-generation-boundaries role=boundaries -->
## 架构边界

[Tile 执行](../../../block/model/dispatch/tile-execution.md)中的指令束分派在操作为 TCI 且当前指令束布局为 CUBE_M16 或 CUBE_M32 时选择 `TCICube`。它先检查 `TileOperandsLegal_TCICube`，检查失败时引发 `Fault_TileLegality`，不调用该辅助函数。其他 TCI 形式通过生成的指令处理器到达 `TCI`。

`TTRI` 不调用 `BundleExecutionMaskActiveAt`。[ExecutionMask 源 schema](../legality/execution-mask-source-schema.md)规定 TTRI 仅支持 RowMajor，没有适用的 ExecutionMask 形式，因此 TTRI 上的掩码载体必须在产生效果之前被拒绝。但可执行列表 `TileOperationExecutionMaskEligible` 仍然列出 TTRI。

`TCI` 和 `TTRI` 以断言表达其前置条件。把错误请求变为故障的合法性谓词在这些辅助函数运行之前求值：`TileOperandsLegal_TCICube` 定义在本单元中并由指令束分派调用，`TileOperandsLegal_TCI` 和 `TileOperandsLegal_TTRI` 定义在[操作数 schema 合法性](../legality/operand-schema.md)中。

<!-- PTO-READER-BLOCK: tile-model-execution-generation-example role=example-usage -->
## 非规范阅读示例

一个 U16 `TCI` 目标有一行、4 个有效列。起始寄存器为 `0x1fffe`，方向为升序。

1. `TileRawElementValue` 保留低 16 位，因此起始值为 65534。
2. 第 0 到 3 列得到 65534、65535、0 和 1。第三个值是 65536 截断到 16 位的结果。
3. 这 4 个有效元素变为已定义。有效区域之外的物理元素保存零，但由于填充为 Null 而保持未定义。

一个 FP32 `TTRI` 目标有 3 个有效行、4 个有效列，下三角方向，diagonal 为 0，其值如下，其中 1 表示 `0x3f800000`：

```text
row 0: 1 0 0 0
row 1: 1 1 0 0
row 2: 1 1 1 0
```

<!-- PTO-READER-BLOCK: tile-model-execution-generation-related role=related-owners-navigation -->
## 相关所有者

- [TCI](../../irregular-and-complex/initialization/TCI.md)和[TTRI](../../irregular-and-complex/initialization/TTRI.md)拥有指令契约。
- [不规则与复杂操作分派](../dispatch/irregular-and-complex.md)命名包含 TCI 和 TTRI 的指令类别；它没有可执行 ASL。
- [ExecutionMask 状态](execution-mask-state.md)定义 `BundleExecutionMaskActiveAt` 和非活动值规则。
- [元素已定义性](../definedness/elements.md)定义 `TileWithValidRegionDefined` 和 `TileWithPadding`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/generation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-GENERATION","surface":"tile","classification":["model","execution","generation"],"depends_on":["PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}
// PTO-REQ-TEPL-GENERATE-001: generated sequences, masks, and padding.

pure func TileTCIDataTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S64 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U64 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16;
end;

pure func TileTTRIDataTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U64 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16;
end;

pure func TileTTRIOneEncoding(data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x3ff0000000000000;
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        otherwise =>
            return Zeros{PTO_XLEN} + 1;
    end;
end;

func TCI(destination: TileIndex, start: Word, descending: boolean)
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert result.valid_rows == 1;
    assert TileTCIDataTypeSupported(result.data_type);
    let normalized_start = TileRawElementValue(
        start,
        result.data_type);
    for column = 0 to result.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            result,
            0,
            column as integer {0..65535});
        let offset = NaturalToWord(column as integer {0..65535});
        let value = if descending then
            normalized_start - offset
        else
            normalized_start + offset;
        result = TileInfoWithLogicalElement(result, element,
            TileRawElementValue(
            value,
            result.data_type));
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

readonly func TileOperandsLegal_TCICube(destination: TileIndex, start: Word, step2d: Word) => boolean
begin
    let tile = _Tiles[[destination]];
    let row_step = SInt(step2d[63:32]); let column_step = SInt(step2d[31:0]);
    return TileCubeDescriptorLegal(tile) && TileTCIDataTypeSupported(tile.data_type) &&
           tile.storage_kind == TileStorage_Numeric &&
           (tile.layout == TileLayout_CUBE_M16 || tile.layout == TileLayout_CUBE_M32) &&
           tile.valid_rows >= 1 && tile.valid_columns >= 1 &&
           (row_step == -1 || row_step == 0 || row_step == 1) &&
           (column_step == -1 || column_step == 0 || column_step == 1);
end;
func TCICube(destination: TileIndex, start: Word, step2d: Word)
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert (result.layout == TileLayout_CUBE_M16 ||
            result.layout == TileLayout_CUBE_M32);
    assert result.valid_rows >= 1 && result.valid_columns >= 1;
    assert TileTCIDataTypeSupported(result.data_type);
    let row_step = SInt(step2d[63:32]);
    let column_step = SInt(step2d[31:0]);
    assert (row_step == -1 || row_step == 0 || row_step == 1) &&
           (column_step == -1 || column_step == 0 || column_step == 1);
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let row_offset = if row_step == -1 then
                    Zeros{PTO_XLEN} - NaturalToWord(
                        row as integer {0..65535})
                else if row_step == 1 then
                    NaturalToWord(row as integer {0..65535})
                else
                    Zeros{PTO_XLEN};
                let column_offset = if column_step == -1 then
                    Zeros{PTO_XLEN} - NaturalToWord(
                        column as integer {0..65535})
                else if column_step == 1 then
                    NaturalToWord(column as integer {0..65535})
                else
                    Zeros{PTO_XLEN};
                result = TileInfoWithLogicalElement(result, element,
                    TileRawElementValue(
                        start + row_offset + column_offset,
                        result.data_type));
            else
                result = TileInfoWithLogicalElement(result, element,
                    BundleExecutionMaskDestinationValue(
                        result.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TTRI(destination: TileIndex, upper: boolean,
          diagonal: integer {-65535..65535})
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert result.valid_rows >= 1;
    assert result.valid_columns >= 1;
    assert TileTTRIDataTypeSupported(result.data_type);
    let one = TileTTRIOneEncoding(result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let boundary: integer = row + diagonal;
            let selected = if upper then
                column >= boundary
            else
                column <= boundary;
            let element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                if selected then
                one
            else
                Zeros{PTO_XLEN});
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
