<!-- GENERATED FROM: asl/block/attributes/B.FPATR.asl -->
# B.FPATR

**Normative ASL source:** `asl/block/attributes/B.FPATR.asl`

Latches complete-bundle matrix post-processing mode, reduction enables, and fixed-point descriptor controls.

## Normative identity {#PTO-INST-BLOCK-B-FPATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-fpatr-purpose role=purpose -->
## B.FPATR 的作用

`B.FPATR`（定点后处理属性）是用于 CUBE 矩阵 Block（例如 `TMATMUL` 和 `TGEMV`）的 32 位 header 命令。它锁存一个描述符，控制累加器结果在发布之前的处理：预量化、激活、行最大值与分组最大值、Shared 输入的逻辑转置，以及显式 FP32 累加器 `C` 的缩放。

每个 CUBE 矩阵 Block 必须恰好包含一条 `B.FPATR`。其他 Block 不得包含它。该描述符由 `SetBundleFixedPointAttributeState` 写入；见[属性 schema 模型](../model/schema/attributes.md)。

<!-- PTO-READER-BLOCK: block-b-fpatr-mechanism role=mechanism -->
## 放置与机制

只有当 Block 处于活动状态且位于 header 中、尚未锁存 `B.FPATR`、已选操作（若有）是矩阵操作，并且还不存在标量、Tile 或 Shared 绑定时，`BundleFixedPointAttributesCanBePlaced` 才接受该命令。否则该命令引发 `Fault_BundleControl`。

随后写入器检查下面的跨字段规则。若检查失败，它引发 `Fault_TileLegality` 且不写入任何内容。

设计要点：`B.FPATR` 必须位于绑定之前，因为它会改变操作数 schema。启用的 RowMax 输入、向量量化参数、向量 PReLU 参数和 `CScale` 会增加 Local 源，RowMax 与 GroupMax 会增加目标。之后的绑定按已经固定的 schema 检查。

<!-- PTO-READER-BLOCK: block-b-fpatr-inputs role=inputs-outputs -->
## 编码字段

固定位为 `W=1`（第 0 位）、`Opcode=1`（第 1 至 3 位）、`Opc1=2`（第 4 至 6 位）、`Reserved=0`（第 10 位）、`ElementWiseEn=0`（第 11 位）和 `Func=2`（第 12 至 14 位）。可变字段如下：

- `TransA`（第 7 位）与 `TransB`（第 8 位）：对 Shared A 或 B 主操作数做逻辑转置。
- `CScaleEn`，第 9 位：对显式 FP32 累加器 `C` 做逐行缩放。
- `MaxAbsEn`，第 15 位：按最大绝对值而不是有符号最大值归约。
- `RowMaxInit`，第 16 位；`GroupMaxEn`，第 17 位；`RowMaxEn`，第 18 位。
- `GroupNCode`，第 19 至 22 位：编码 0 至 9 选择 0、8、16、32、48、64、80、96、112 或 128 列的分组宽度。
- `ReluMode`，第 23 至 25 位：编码 0 至 3 依次选择无、ReLU、标量 LReLU/PReLU 和向量 PReLU。
- `PreQuantMode`，第 26 至 31 位：编码 0 至 5、12、13、16 至 20、23 至 28 以及 32 至 39。

不在这些编码集合中的值或固定位不匹配都无法译码，并引发 `Fault_IllegalInstruction`。

设计要点：`PreQuantMode` 是封闭的编码表。ASL 注释指出 `U8` 不是 `S8` 的同义词。每个非零编码同时固定所需的累加器类别（`S32` 或 `FP32`）和输出类型；编码 0 接受 `FP32`、`S32` 或 `U32` 并保持该类型。

<!-- PTO-READER-BLOCK: block-b-fpatr-effects role=effects -->
## 默认值、状态与输出

全零字段表示：无预量化、无激活、无分组最大值、无行最大值、无转置、无 `CScale`。此时有效输出类型 `EffectiveDType` 即累加器类型。

设计要点：省略 `B.FPATR` 与全零的 `B.FPATR` 不同。缺少它的矩阵 Block 会在完整预检时以 `Fault_BundleControl` 失败，因为矩阵操作数 schema 要求该描述符。全零命令才是请求普通输出的方式。

Block 提交时，`D`、`RowMaxOut` 与 `GroupMaxOut` 作为一个输出组一起发布。被拒绝的 Block 一个都不发布。RowMax 与 GroupMax 在 `EffectiveDType` 中对最终编码的 `D` 值做归约。

该描述符在 Block 提交时被清除，并在陷阱保存与恢复中随待处理 Block 一起保留。

<!-- PTO-READER-BLOCK: block-b-fpatr-constraints role=constraints -->
## 合法性与故障

由命令检查，失败时引发 `Fault_TileLegality`：

- `RowMaxInit` 要求 `RowMaxEn`。
- `GroupMaxEn` 与非零 `GroupNCode` 互为前提。
- `MaxAbsEn` 要求 `RowMaxEn` 或 `GroupMaxEn`。

由完整预检在任何效果之前检查，失败时引发 `Fault_TileLegality`：

- 累加器类型必须与 `PreQuantMode` 类别匹配。启用 `RowMaxEn` 或 `GroupMaxEn` 时，`EffectiveDType` 必须是 `FP32`、`FP16` 或 `BF16`。
- `TransA` 或 `TransB` 要求对应主操作数为 Shared。`CScaleEn` 只被 FP32 `TMATMUL.ACC` 与 `TMATMULMX.ACC` 接受。
- 矩阵 `B.DATR` 只提供转换控制：`PreQuantMode` 为 0 或移位模式（12、13）时，`RMode` 与 `Sat` 必须为零；固定舍入模式时，`RMode` 必须为零。
- 若 `B.DATR` 设置 `CCTRL[0]=1`（原始部分和输出），所有后处理与归约字段都必须为零；只保留合法的 `CScale`。

<!-- PTO-READER-BLOCK: block-b-fpatr-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0
```

该命令请求普通输出：累加器为 `FP32` 时，`D` 以 `FP32` 发布。同一 header 中的第二条 `B.FPATR` 引发 `Fault_BundleControl`。

再看 `PreQuantMode` 编码 16、`ReluMode` 1、`GroupNCode` 2、`RowMaxEn=1` 与 `GroupMaxEn=1`。编码 16 需要 `FP32` 累加器并输出 `BF16`，因此 `EffectiveDType` 为 `BF16`，两种归约都被允许；每个分组最大值覆盖 16 列。编码 16 使用固定舍入，因此矩阵 `B.DATR` 必须保持 `RMode` 为零。若改用 `PreQuantMode` 编码 2，输出类型为 `S8`，同样的归约使能会在预检时以 `Fault_TileLegality` 失败。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_fpatr_32_30c307e06d4a | L32 | 32 | 0x00002023 / 0x00007c7f | [{"field":"PreQuantMode","operator":"one-of","values":[0,1,2,3,4,5,12,13,16,17,18,19,20,23,24,25,26,27,28,32,33,34,35,36,37,38,39]},{"field":"ReluMode","operator":"one-of","values":[0,1,2,3]},{"field":"GroupNCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9]},{"field":"RowMaxEn","operator":"one-of","values":[0,1]},{"field":"GroupMaxEn","operator":"one-of","values":[0,1]},{"field":"RowMaxInit","operator":"one-of","values":[0,1]},{"field":"MaxAbsEn","operator":"one-of","values":[0,1]},{"field":"Func","operator":"one-of","values":[2]},{"field":"ElementWiseEn","operator":"one-of","values":[0]},{"field":"TransA","operator":"one-of","values":[0,1]},{"field":"TransB","operator":"one-of","values":[0,1]},{"field":"CScaleEn","operator":"one-of","values":[0,1]},{"field":"Reserved","operator":"one-of","values":[0]},{"field":"Opc1","operator":"one-of","values":[2]},{"field":"Opcode","operator":"one-of","values":[1]},{"field":"W","operator":"one-of","values":[1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_fpatr_32_30c307e06d4a | PreQuantMode | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_fpatr_32_30c307e06d4a | ReluMode | 3 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":3}] |
| b_fpatr_32_30c307e06d4a | GroupNCode | 4 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":4}] |
| b_fpatr_32_30c307e06d4a | RowMaxEn | 1 | encoding-defined | [{"instruction_lsb":18,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | GroupMaxEn | 1 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | RowMaxInit | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | MaxAbsEn | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | Func | 3 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":3}] |
| b_fpatr_32_30c307e06d4a | ElementWiseEn | 1 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | TransA | 1 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | TransB | 1 | encoding-defined | [{"instruction_lsb":8,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | CScaleEn | 1 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | Reserved | 1 | encoding-defined | [{"instruction_lsb":10,"value_lsb":0,"width":1}] |
| b_fpatr_32_30c307e06d4a | Opc1 | 3 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":3}] |
| b_fpatr_32_30c307e06d4a | Opcode | 3 | encoding-defined | [{"instruction_lsb":1,"value_lsb":0,"width":3}] |
| b_fpatr_32_30c307e06d4a | W | 1 | encoding-defined | [{"instruction_lsb":0,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_fpatr_32_30c307e06d4a | PreQuantMode | 6 | 0–5, 12–13, 16–20, 23–28, 32–39 | none | 6–11, 14–15, 21–22, 29–31, 40–63 | closed Matrix destination pre-quantization and output-type selector | No pre-quantization; D retains the FP32, S32, or U32 accumulator type. |
| b_fpatr_32_30c307e06d4a | ReluMode | 3 | 0–3 | none | 4–7 | pre-conversion activation multiplier selector | No activation. |
| b_fpatr_32_30c307e06d4a | GroupNCode | 4 | 0–9 | none | 10–15 | group maximum column-count selector | No group maximum; GroupMaxEn must also be zero. |
| b_fpatr_32_30c307e06d4a | RowMaxEn | 1 | 0–1 | none | none | row maximum input/output enable | No RowMax input or output. |
| b_fpatr_32_30c307e06d4a | GroupMaxEn | 1 | 0–1 | none | none | group maximum output enable | No GroupMax output. |
| b_fpatr_32_30c307e06d4a | RowMaxInit | 1 | 0–1 | none | none | row maximum initialization from RowMaxIn enable | Do not initialize RowMax from RowMaxIn. |
| b_fpatr_32_30c307e06d4a | MaxAbsEn | 1 | 0–1 | none | none | maximum-absolute-value reduction selector | Use signed maximum rather than maximum absolute value for enabled reductions. |
| b_fpatr_32_30c307e06d4a | Func | 3 | 2 | none | 0–1, 3–7 | fixed B.FPATR function discriminator equal to 2 | Encoded zero supplies numeric zero for the fixed B.FPATR function discriminator equal to 2. |
| b_fpatr_32_30c307e06d4a | ElementWiseEn | 1 | 0 | none | 1 | fixed complete-bundle selector equal to zero | Fixed zero selects complete-bundle Matrix post-processing. |
| b_fpatr_32_30c307e06d4a | TransA | 1 | 0–1 | none | none | logical transpose enable for a Shared A primary | Do not transpose Shared A. |
| b_fpatr_32_30c307e06d4a | TransB | 1 | 0–1 | none | none | logical transpose enable for a Shared B primary | Do not transpose Shared B. |
| b_fpatr_32_30c307e06d4a | CScaleEn | 1 | 0–1 | none | none | per-row FP32 accumulator C scaling enable | Do not scale the explicit FP32 accumulator C. |
| b_fpatr_32_30c307e06d4a | Reserved | 1 | 0 | none | 1 | fixed-zero reserved field | Bit 10 is fixed zero; every nonzero encoding is reserved. |
| b_fpatr_32_30c307e06d4a | Opc1 | 3 | 2 | none | 0–1, 3–7 | fixed command-class discriminator equal to 2 | Encoded zero supplies numeric zero for the fixed command-class discriminator equal to 2. |
| b_fpatr_32_30c307e06d4a | Opcode | 3 | 1 | none | 0, 2–7 | fixed block-attribute opcode discriminator equal to 1 | Encoded zero supplies numeric zero for the fixed block-attribute opcode discriminator equal to 1. |
| b_fpatr_32_30c307e06d4a | W | 1 | 1 | none | 0 | fixed 32-bit command-width discriminator equal to 1 | Encoded zero supplies numeric zero for the fixed 32-bit command-width discriminator equal to 1. |

- `b_fpatr_32_30c307e06d4a.PreQuantMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.ReluMode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.GroupNCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.Func` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.ElementWiseEn` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.Reserved` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.Opc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.Opcode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_fpatr_32_30c307e06d4a.W` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| PreQuantMode | closed Matrix destination pre-quantization and output-type selector |
| ReluMode | pre-conversion activation multiplier selector |
| GroupNCode | group maximum column-count selector |
| RowMaxEn | row maximum input/output enable |
| GroupMaxEn | group maximum output enable |
| RowMaxInit | row maximum initialization from RowMaxIn enable |
| MaxAbsEn | maximum-absolute-value reduction selector |
| Func | fixed B.FPATR function discriminator equal to 2 |
| ElementWiseEn | fixed complete-bundle selector equal to zero |
| TransA | logical transpose enable for a Shared A primary |
| TransB | logical transpose enable for a Shared B primary |
| CScaleEn | per-row FP32 accumulator C scaling enable |
| Reserved | fixed-zero reserved field |
| Opc1 | fixed command-class discriminator equal to 2 |
| Opcode | fixed block-attribute opcode discriminator equal to 1 |
| W | fixed 32-bit command-width discriminator equal to 1 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.FPATR.asl -->
```asl
readonly func InstructionContractMatches_B_FPATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_fpatr_32_30c307e06d4a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Required exactly once in a CUBE Matrix block after BSTART and before scalar or tile bindings and the first body instruction.
The complete block schema places mathematical Local sources first, then optional RowMaxIn, vector pre-quantization, and vector PReLU sources; Local destinations are D, optional RowMaxOut, then optional GroupMaxOut.
Scalar pre-quantization and LReLU/PReLU parameters use the dense B.IOR schema; LReLU-only consumes RegSrc0.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.FPATR.asl -->
```asl
// PreQuantMode is deliberately a closed code table.  In particular U8 is not
// a synonym for S8 and generic FP8 resolves to E4M3 in the PTO type namespace.
pure func BundleFPATRPreQuantModeLegal(code: bits(6)) => boolean
begin
    let value = UInt(code);
    return value == 0 || value == 1 || value == 2 || value == 3 ||
           value == 4 || value == 5 || value == 12 || value == 13 ||
           value == 16 || value == 17 || value == 18 || value == 19 ||
           value == 20 || value == 23 || value == 24 || value == 25 ||
           value == 26 || value == 27 || value == 28 || value == 32 ||
           value == 33 || value == 34 || value == 35 || value == 36 ||
           value == 37 || value == 38 || value == 39;
end;

pure func BundleFPATRReluModeLegal(code: bits(3)) => boolean
begin
    return UInt(code) <= 3;
end;

pure func BundleFPATRGroupNCodeLegal(code: bits(4)) => boolean
begin
    return UInt(code) <= 9;
end;

pure func BundleFPATRGroupN(code: bits(4)) => integer {0,8,16,32,48,64,80,96,112,128}
begin
    case UInt(code) of
        when 0 => return 0;
        when 1 => return 8;
        when 2 => return 16;
        when 3 => return 32;
        when 4 => return 48;
        when 5 => return 64;
        when 6 => return 80;
        when 7 => return 96;
        when 8 => return 112;
        when 9 => return 128;
        otherwise => unreachable;
    end;
end;

pure func BundleFPATRModeUsesVectorParameter(code: bits(6)) => boolean
begin
    return UInt(code) == 2 || UInt(code) == 4 || UInt(code) == 12 ||
           UInt(code) == 18 || UInt(code) == 20 || UInt(code) == 23 ||
           UInt(code) == 28 || UInt(code) == 33 || UInt(code) == 36 ||
           UInt(code) == 37 || UInt(code) == 38 || UInt(code) == 39;
end;

pure func BundleFPATRModeUsesScalarParameter(code: bits(6)) => boolean
begin
    return UInt(code) == 3 || UInt(code) == 5 || UInt(code) == 13 ||
           UInt(code) == 17 || UInt(code) == 19 || UInt(code) == 24 ||
           UInt(code) == 25 || UInt(code) == 26 || UInt(code) == 27 ||
           UInt(code) == 32 || UInt(code) == 34 || UInt(code) == 35;
end;

pure func BundleFPATRModeUsesS32Accumulator(code: bits(6)) => boolean
begin
    let value = UInt(code);
    return value == 2 || value == 3 || value == 4 || value == 5 ||
           value == 12 || value == 13 || value == 17 || value == 18 ||
           value == 19 || value == 20 || value == 35 || value == 39;
end;

pure func BundleFPATRModeUsesFP32Accumulator(code: bits(6)) => boolean
begin
    return BundleFPATRPreQuantModeLegal(code) &&
           UInt(code) != 0 &&
           !BundleFPATRModeUsesS32Accumulator(code);
end;

pure func BundleFPATRAccumulatorTypeLegal(
    code: bits(6), accumulator_type: TileDataType) => boolean
begin
    if UInt(code) == 0 then
        return accumulator_type == TileDataType_FP32 ||
               accumulator_type == TileDataType_S32 ||
               accumulator_type == TileDataType_U32;
    elsif BundleFPATRModeUsesS32Accumulator(code) then
        return accumulator_type == TileDataType_S32;
    elsif BundleFPATRModeUsesFP32Accumulator(code) then
        return accumulator_type == TileDataType_FP32;
    end;
    return FALSE;
end;

pure func BundleFPATRModeOffsetWidth(code: bits(6))
    => integer {0,5,9,17}
begin
    let value = UInt(code);
    if value == 17 || value == 18 then return 5;
    elsif value == 2 || value == 3 || value == 23 || value == 24 then
        return 9;
    elsif value == 19 || value == 20 then return 17;
    else return 0;
    end;
end;

pure func BundleFPATRModeIsShift(code: bits(6)) => boolean
begin
    return UInt(code) == 12 || UInt(code) == 13;
end;

pure func BundleFPATRModeFixedRounding(code: bits(6)) => boolean
begin
    let value = UInt(code);
    return value == 1 || value == 16 || value == 25 || value == 26 ||
           value == 28 || value == 32 || value == 33 || value == 34 ||
           value == 36 || value == 37;
end;

pure func BundleFPATRModeFinalSatProgrammable(code: bits(6)) => boolean
begin
    return UInt(code) != 0 && !BundleFPATRModeIsShift(code);
end;

pure func BundleFPATRReluModeUsesScalarParameter(code: bits(3)) => boolean
begin
    return UInt(code) == 2;
end;

pure func BundleFPATRReluModeUsesVectorParameter(code: bits(3)) => boolean
begin
    return UInt(code) == 3;
end;

// Quantization descriptors use one closed 64-bit carrier.  The selected
// mode alone determines which payload bits are meaningful; every other bit
// is reserved and must be zero before matrix operands are snapshotted.
pure func BundleFPATRQuantParameterWordLegal(code: bits(6),
                                             value: Word) => boolean
begin
    let mode = UInt(code);
    if mode == 12 || mode == 13 then
        return value[31:0] == Zeros{32} &&
               value[63:36] == Zeros{28};
    end;
    if mode == 17 || mode == 18 then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[36:32] == Zeros{5} &&
               value[63:42] == Zeros{22};
    end;
    if mode == 2 || mode == 3 || mode == 23 || mode == 24 then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[36:32] == Zeros{5} &&
               value[63:46] == Zeros{18};
    end;
    if mode == 19 || mode == 20 then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[36:32] == Zeros{5} &&
               value[63:54] == Zeros{10};
    end;
    if BundleFPATRModeUsesScalarParameter(code) ||
       BundleFPATRModeUsesVectorParameter(code) then
        return value[12:0] == Zeros{13} &&
               FP19ScaleLegal(value[31:13]) &&
               value[63:32] == Zeros{32};
    end;
    return FALSE;
end;

// Scalar LReLU and vector PReLU elements carry one FP19 value in the low
// nineteen bits.  FP19 arithmetic remains profile-owned, but its carrier is
// architectural and therefore rejects nonzero high bits.
pure func BundleFPATRReluParameterWordLegal(value: Word) => boolean
begin
    return value[63:19] == Zeros{45} &&
           FP19ActivationParameterLegal(value[18:0]);
end;

// Matrix B.DATR contributes only the destination conversion controls once
// B.FPATR is present.  None keeps the architectural default conversion
// (RMode=NONE and Sat=0). Fixed floating modes reject a non-default RMode;
// fixed shift modes additionally reject Sat. Other accepted modes retain the
// complete rounding selector and final saturation control.
pure func BundleFPATRDATRFieldsLegal(pre_quant: bits(6),
                                     rounding_mode: bits(3),
                                     saturating: boolean) => boolean
begin
    if !BundleFPATRPreQuantModeLegal(pre_quant) then return FALSE; end;
    if UInt(pre_quant) == 0 then
        return rounding_mode == Zeros{3} && !saturating;
    end;
    if BundleFPATRModeIsShift(pre_quant) then
        return rounding_mode == Zeros{3} && !saturating;
    end;
    if BundleFPATRModeFixedRounding(pre_quant) then
        return rounding_mode == Zeros{3};
    end;
    return TRUE;
end;

pure func BundleFPATROutputType(code: bits(6)) => TileDataType
begin
    case UInt(code) of
        when 0 => return TileDataType_FP32;
        when 1, 4, 5, 32, 33 => return TileDataType_FP16;
        when 2, 3, 23, 24 => return TileDataType_S8;
        when 12, 13, 19, 20 => return TileDataType_S16;
        when 16, 34, 35, 36, 39 => return TileDataType_BF16;
        when 17, 18 => return TileDataType_S4X2;
        when 25, 28 => return TileDataType_HiF8;
        when 26, 37 => return TileDataType_E4M3;
        when 27, 38 => return TileDataType_FP32;
        otherwise => unreachable;
    end;
end;

// PreQuantMode zero preserves the actual accumulator type, including S32 and
// U32. The mode table's code-zero FP32 entry is not an effective-type default.
pure func BundleFPATREffectiveDataType(
    pre_quant_mode: bits(6), accumulator_type: TileDataType)
    => TileDataType
begin
    if UInt(pre_quant_mode) == 0 then return accumulator_type; end;
    return BundleFPATROutputType(pre_quant_mode);
end;

pure func BundleFPATRReductionDataTypeLegal(
    effective_type: TileDataType) => boolean
begin
    return effective_type == TileDataType_FP32 ||
           effective_type == TileDataType_FP16 ||
           effective_type == TileDataType_BF16;
end;

pure func BundleFPATRFieldsLegal(pre_quant: bits(6), relu: bits(3),
                                 group_n: bits(4), row_max: boolean,
                                 group_max: boolean, row_init: boolean,
                                 max_abs: boolean) => boolean
begin
    if !BundleFPATRPreQuantModeLegal(pre_quant) ||
       !BundleFPATRReluModeLegal(relu) ||
       !BundleFPATRGroupNCodeLegal(group_n) then return FALSE; end;
    if !row_max && row_init then return FALSE; end;
    if !group_max && UInt(group_n) != 0 then return FALSE; end;
    if group_max && UInt(group_n) == 0 then return FALSE; end;
    if !row_max && !group_max && max_abs then return FALSE; end;
    return TRUE;
end;

readonly func InstructionContractHandler_B_FPATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleFixedPointAttributes;
end;

pure func InstructionContractHeaderOnly_B_FPATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_FPATR()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded PreQuantMode=0 and ReluMode=0 disable pre-quantization and activation. GroupNCode=0 selects no group maximum. All four reduction enable bits default to disabled. TransA=0 and TransB=0 select no logical transpose; CScaleEn=0 disables accumulator scaling.
- Omitting B.FPATR is not a default for a CUBE Matrix block: complete-bundle preflight rejects the missing command before allocation or effects.
- CCTRL[0]=0 selects the final-output path. CCTRL[0]=1 requires final-output post-processing and auxiliary-output controls to remain zero except for legal accumulator-input CScale.

## Legality

- PreQuantMode accepts exactly codes 0..5, 12..13, 16..20, 23..28, and 32..39; all other six-bit codes are reserved.
- Each nonzero PreQuantMode accepts exactly its assigned S32 or FP32 accumulator class; code zero accepts FP32, S32, or U32 and preserves that type.
- ReluMode codes 0..3 select None, ReLU, scalar LReLU/PReLU, and vector PReLU; codes 4..7 are reserved.
- GroupNCode codes 0..9 select 0, 8, 16, 32, 48, 64, 80, 96, 112, and 128 columns; codes 10..15 are reserved.
- RowMaxInit requires RowMaxEn. GroupMaxEn requires nonzero GroupNCode and nonzero GroupNCode requires GroupMaxEn. MaxAbsEn requires RowMaxEn or GroupMaxEn.
- TransA and TransB are independent one-bit controls accepted only when the corresponding A or B primary is Shared. CScaleEn is accepted only by FP32 TMATMUL.ACC and TMATMULMX.ACC.
- Func=2, ElementWiseEn=0, Reserved[10]=0, Opc1=2, Opcode=1, and W=1 are fixed encoding discriminators.
- Matrix B.DATR supplies only destination conversion controls when B.FPATR is present: None requires RMode=NONE and Sat=0; fixed floating modes require RMode=NONE; fixed shift modes require RMode=NONE and Sat=0; programmable integer modes retain the complete rounding selector and final clamp/wrap control.
- The derived scalar/vector parameter count, Local source count, and Local destination count must fit the complete-bundle schema without duplicate destinations or illegal source/destination aliases.
- When matrix CCTRL[0]=1, PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, and MaxAbsEn must all be zero; legal CScale remains an accumulator-input transform and D publishes the raw accumulator type.
- EffectiveDType is the accumulator type when PreQuantMode is zero and the assigned output type otherwise. If RowMaxEn or GroupMaxEn is enabled, EffectiveDType must be FP32, FP16, or BF16; RowMaxIn, RowMaxOut, and GroupMaxOut must all use that type.

## State effects

- Latch the accepted fixed-point post-processing descriptor once for the active block; bundle reset clears its presence and every field, including TransA, TransB, and CScaleEn.
- Trap save and recovery preserve the complete latched descriptor with the pending block.
- Successful execution selects any activation-dependent multiplier before destination conversion, encodes each final D value, reduces those final D values in EffectiveDType, and atomically commits all enabled outputs through the numeric-profile hook.
- CCTRL[0]=1 bypasses final-output post-processing and auxiliary publication while preserving legal CScale before raw accumulator-type D publication.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete field, B.DATR, operand-schema, alias, shape, and allocation preflight precedes every source consumption and destination effect.
- D, RowMaxOut, and GroupMaxOut are published as one atomic complete-block output group; rejection exposes none of them.
- Raw-partial CCTRL validation is part of complete preflight; transparent-cache hints cannot change B.FPATR legality, D publication, auxiliary-output suppression, faults, or numeric status.

## Exceptions

- Missing, duplicate, or non-CUBE-Matrix use raises Fault_BundleControl before operand consumption, allocation, payload, or destination effects.
- Decode-reserved field values do not decode and raise Fault_IllegalInstruction. Accepted encodings with inconsistent reduction enables, invalid B.DATR conversion controls, invalid parameters, malformed operand streams, illegal aliases, or invalid derived shapes raise Fault_TileLegality before effects.
- Fixed-bit mismatch does not decode as B.FPATR and is rejected by normal command decoding before this handler executes.

## Examples

- B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0
- B.FPATR S8Vector, LReLU, 2, 1, 1, 1, 1, 1, 1, 0
