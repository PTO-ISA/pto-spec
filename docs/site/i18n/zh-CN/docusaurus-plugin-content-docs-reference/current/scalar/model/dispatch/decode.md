<!-- GENERATED FROM: asl/scalar/model/dispatch/decode.asl -->
# Decode

**Normative ASL source:** `asl/scalar/model/dispatch/decode.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-DECODE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-purpose role=purpose-scope -->
## 用途与范围

本单元把原始指令位转换为标量分派所用的类型化操作数值。识别出标量形式之后，每个族分派器都用这些辅助函数读取寄存器选择子、立即数、内存序对或右操作数修饰符。

它还定义 `ScalarExecutionStatus`（`ScalarExecution_Executed` 或 `ScalarExecution_Rejected`）以及 `ScalarHandlerWritesTPC`；后者列出自行安装 TPC 的三个处理函数：`ScalarHandler_JumpRelative`、`ScalarHandler_JumpRegister` 和 `ScalarHandler_ArchitectureEnterRequest`。

本单元依赖由指令目录构建的 `generated:decoders`。该生成层提供 `DecodeScalarForm`、`DecodeScalarOperandRaw` 以及各形式的合法性函数。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-concepts role=concepts-state -->
## 概念与可见状态

形式是某个助记符的一个目录编码，具有固定长度（16、32 或 48 位）、掩码和匹配值。当 `word AND mask == match` 时，指令字属于该形式。

字段是形式中的具名操作数，例如 `RegDst`、`SrcL`、`simm12` 或 `SrcRType`。`DecodeScalarOperandRaw` 把字段的各个位片收集到一个 48 位值的低位中。一个字段可以分成多个位片。

这些辅助函数解释该原始值：

- `ScalarDecodedSelector` 保留 5 位作为 `Reg5Selector`。
- `ScalarDecodedWord` 对目录有符号性为 `Signed` 的字段做符号扩展，对其他所有字段做零扩展。
- `ScalarDecodedUInt6`、`ScalarDecodedUInt7` 以及 `ScalarDecodedBits*` 辅助函数保留固定的低位片。
- `ScalarDecodedBitfieldWidth` 对 6 位 `imml` 加 1，因此宽度为 1 到 64。
- `ScalarDecodedMemoryOrder` 把 `aq` 和 `rl` 位映射为宽松、获取、释放或获取-释放。

这些辅助函数是纯函数或只读函数。`ReadDecodedScalarRegister` 通过 `ReadScalarRegisterOperand` 读取 GPR 或 T/U 队列条目，`ScalarDecodedAtomicAddress` 通过 `ReadDecodedScalarRegister` 读取其地址寄存器；其他辅助函数不读取状态。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-rules role=rules-interactions -->
## 规则与交互

2 位 `SrcRType` 字段在各族中的译码不同：

| 原始值 | 二元 ALU | 比较 | 选择 | 地址 |
| --- | --- | --- | --- | --- |
| `00` | `.sw` | 无 | 无 | 无 |
| `01` | `.uw` | `.sw` | 无 | `.sw` |
| `10` | `.neg` 或 `.not` | `.uw` | 无 | `.uw` |
| `11` | 无 | NOT 或无 | `.neg` | 不可达 |

设计要点：二元 ALU 表把“无修饰符”放在 `11`。ADD 契约说明，省略的汇编后缀编码为 `11`，因此该字段的编码零选择 `.sw`，而不是“不变”。

NDF 条款 PTO-REQ-AGU-SRCRTYPE-001 规定寄存器偏移 AGU 形式的原始 `11` 为保留值，必须在读取任何源之前拒绝。译码器通过目录约束满足这一点：每个此类形式都把 `SrcRType` 限定为 0、1 或 2 之一，`ScalarFormOperandsLegal` 会在 AGU 处理函数运行之前拒绝该字。这就是 `DecodeScalarAddressRightModifier` 能把 `11` 标记为 `unreachable` 的原因。

设计要点：目录约束的保留值由合法性检查拒绝，而不是由取值辅助函数拒绝。因此取值辅助函数可以把这些值标记为 `unreachable`，这样的字会在任何族处理函数读取源或写入结果之前被拒绝。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-boundaries role=boundaries -->
## 架构边界

本单元不决定指令字属于哪个形式，也不检查合法性。这些步骤在[标量顶层分派](top-level.md)中通过生成的 `DecodeScalarForm`、`ScalarFormOperandsLegal` 和 `ScalarRegisterOperandsLegal` 运行。

`ScalarDecodedAtomicAddress` 用已译码的 `far` 位调用[AMO 语义](../amo/semantics.md)中的 `AtomicAddress`；在本模型中地址保持不变。

`ScalarDecodedWord` 接受有符号宽度 5、12、17、22、24、29 和 32。任何其他有符号宽度都是 `unreachable`。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-example role=example-usage -->
## 非规范阅读示例

取 32 位字 0x0F818F85。`ADD` 形式的掩码为 0x707F，匹配值为 0x0005。该字与掩码相与得 0x0005，因此它是 `ADD`。

| 字段 | 位 | 原始值 | 含义 |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 31 | 把结果压入 T |
| `SrcL` | 19:15 | 3 | GPR 3 |
| `SrcR` | 24:20 | 24 | T#1，即最新的 T 条目 |
| `SrcRType` | 26:25 | `11` | 无修饰符 |
| `shamt` | 31:27 | 1 | 右操作数左移 1 位 |

该指令把 GPR 3 与左移 1 位的 T#1 相加，并把和压入 T。读取 T#1 不会消耗它。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-related role=related-owners-navigation -->
## 相关所有者

- [标量顶层分派](top-level.md)在使用这些辅助函数之前运行形式译码和合法性检查。
- [标量操作数](../types/operands.md)拥有 Reg5 源和目标的含义。
- [ALU 语义](../alu/semantics.md)应用已译码的修饰符。
- [指令束编码 schema](../../../block/model/schema/bundle-encoding.md)是本单元声明的另一项依赖。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/decode.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-DECODE","surface":"scalar","classification":["model","dispatch","decode"],"depends_on":["generated:decoders","PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"]}
// PTO-REQ-SCALAR-DISPATCH-001, PTO-REQ-SCALAR-CONSTRAINT-001: decoded scalar
// execution with catalog-generated form and family legality.
//
// Every accepted scalar family has a form-to-effect binding. Unknown or
// operand-illegal encodings are rejected; there is no silent unsupported path.

// NDF-BEGIN: PTO-REQ-AGU-SRCRTYPE-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Every register-offset AGU form MUST decode SrcRType as 00=unchanged,
// 01=.sw, and 10=.uw before the encoded or fixed left shift. Raw 11 is
// reserved and MUST reject before source reads or architectural effects.
// NDF-END: PTO-REQ-AGU-SRCRTYPE-001

type ScalarExecutionStatus of enumeration {
    ScalarExecution_Executed,
    ScalarExecution_Rejected
};

pure func ScalarHandlerWritesTPC(handler: ScalarSemanticHandler) => boolean
begin
    return handler == ScalarHandler_JumpRelative ||
           handler == ScalarHandler_JumpRegister ||
           handler == ScalarHandler_ArchitectureEnterRequest;
end;

pure func ScalarDecodedSelector(instruction: bits(48),
                                form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                field: ScalarOperandField) => Reg5Selector
begin
    let raw = DecodeScalarOperandRaw(instruction, form, field);
    return UInt(raw[4:0]) as Reg5Selector;
end;

pure func ScalarDecodedWord(instruction: bits(48),
                            form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                            field: ScalarOperandField) => Word
begin
    let raw = DecodeScalarOperandRaw(instruction, form, field);
    if ScalarOperandSignedness(form, field) == ScalarField_Signed then
        case ScalarOperandWidth(form, field) of
            when 5  => return SignExtend{PTO_XLEN}(raw[4:0]);
            when 12 => return SignExtend{PTO_XLEN}(raw[11:0]);
            when 17 => return SignExtend{PTO_XLEN}(raw[16:0]);
            when 22 => return SignExtend{PTO_XLEN}(raw[21:0]);
            when 24 => return SignExtend{PTO_XLEN}(raw[23:0]);
            when 29 => return SignExtend{PTO_XLEN}(raw[28:0]);
            when 32 => return SignExtend{PTO_XLEN}(raw[31:0]);
            otherwise => unreachable;
        end;
    end;
    return ZeroExtend{PTO_XLEN}(raw);
end;

pure func ScalarDecodedBits19(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(19)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[18:0];
end;

pure func ScalarDecodedBits20(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(20)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[19:0];
end;

pure func ScalarDecodedBits4(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => bits(4)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[3:0];
end;

pure func ScalarDecodedBits5(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => bits(5)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[4:0];
end;

pure func ScalarDecodedSystemRegisterAddress(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    field: ScalarOperandField) => SystemRegisterAddress
begin
    return DecodeScalarOperandRaw(instruction, form, field)[23:0];
end;

pure func ScalarDecodedBoolean(instruction: bits(48),
                               form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                               field: ScalarOperandField) => boolean
begin
    return DecodeScalarOperandRaw(instruction, form, field)[0] == '1';
end;

pure func ScalarDecodedMemoryOrder(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => MemoryOrder
begin
    let acquire = ScalarDecodedBoolean(instruction, form, ScalarField_aq);
    let release = ScalarDecodedBoolean(instruction, form, ScalarField_rl);
    if acquire && release then return MemoryOrder_AcquireRelease;
    elsif acquire then return MemoryOrder_Acquire;
    elsif release then return MemoryOrder_Release;
    else return MemoryOrder_Relaxed;
    end;
end;

readonly func ScalarDecodedAtomicAddress(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    field: ScalarOperandField) => Word
begin
    let address = ReadDecodedScalarRegister(instruction, form, field);
    let far = ScalarDecodedBoolean(instruction, form, ScalarField_far);
    return AtomicAddress(address, far);
end;

pure func ScalarDecodedBits32(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(32)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[31:0];
end;

pure func ScalarDecodedUInt6(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => integer {0..63}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, field)[5:0]);
end;

pure func ScalarDecodedUInt7(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => integer {0..127}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, field)[6:0]);
end;

pure func ScalarDecodedBitfieldWidth(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1})
                                     => integer {1..64}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, ScalarField_imml)[5:0]) + 1;
end;

pure func DecodeScalarBinaryRightModifier(raw: bits(2))
                                           => ScalarRightModifier
begin
    case raw of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func DecodeScalarComparisonRightModifier(raw: bits(2))
                                               => ScalarRightModifier
begin
    case raw of
        when '00' => return ScalarRight_None;
        when '01' => return ScalarRight_SignedWord;
        when '10' => return ScalarRight_UnsignedWord;
        when '11' => return ScalarRight_NegateOrNot;
    end;
end;

pure func DecodeScalarSelectRightModifier(raw: bits(2))
                                          => ScalarRightModifier
begin
    if raw == '11' then
        return ScalarRight_NegateOrNot;
    else
        return ScalarRight_None;
    end;
end;

pure func DecodeScalarAddressRightModifier(raw: bits(2))
                                           => ScalarRightModifier
begin
    case raw of
        when '00' => return ScalarRight_None;
        when '01' => return ScalarRight_SignedWord;
        when '10' => return ScalarRight_UnsignedWord;
        when '11' => unreachable;
    end;
end;

pure func ScalarDecodedBinaryRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarBinaryRightModifier(raw);
end;

pure func ScalarDecodedComparisonRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarComparisonRightModifier(raw);
end;

pure func ScalarDecodedSelectRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarSelectRightModifier(raw);
end;

pure func ScalarDecodedAddressRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarAddressRightModifier(raw);
end;

readonly func ReadDecodedScalarRegister(instruction: bits(48),
                                        form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                        field: ScalarOperandField) => Word
begin
    return ReadScalarRegisterOperand(ScalarDecodedSelector(instruction, form, field));
end;
```
<!-- GENERATED-ASL-END: unit -->
