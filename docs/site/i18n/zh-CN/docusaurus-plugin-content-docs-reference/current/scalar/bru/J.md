<!-- GENERATED FROM: asl/scalar/bru/J.asl -->
# J

**Normative ASL source:** `asl/scalar/bru/J.asl`

J - Jump to the PC-relative target.

## Normative identity {#PTO-INST-SCALAR-J}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-j-purpose role=purpose -->
## J 的作用

`J` 把控制流转移到 PC 相对目标。它的位移是有符号的、以半字为单位，并且作用在 `J` 指令自身的地址上。

设计要点：`J` 直接写入 `TPC`，分派边界之后不再叠加顺序前进，因此该跳转是替换后续执行位置，而不是在其上叠加位移。

<!-- PTO-READER-BLOCK: scalar-j-mechanism role=mechanism -->
## 目标地址的计算

`simm22` 先符号扩展到 `PTO_XLEN`，再左移 `1` 位，与当前 `PC` 相加的结果成为新的 `PC`。加法在 `64` 位宽度内进行，并在 `2^64` 处回绕。

设计要点：位移以 `J` 自身的地址为基准，而不是以下一条指令为基准，因此编码值 `0` 会产生自循环，重复执行同一条跳转。

设计要点：`JumpRelative` 不对算出的目标做任何检查，因此被接受的 `J` 总会安装其目标；目标奇偶检查属于寄存器跳转 `JR`，而不属于 `J`。

<!-- PTO-READER-BLOCK: scalar-j-inputs-outputs role=inputs-outputs -->
## 操作数与结果

- `simm22` 提供有符号半字位移。它编码在两个指令片段中，宽度分别为 `17` 位和 `5` 位。

- 计算的基址是处理过程中读取的当前 `PC`。`J` 没有寄存器操作数，也没有立即数基址操作数。

- 唯一的输出是新的 `PC`。不写任何寄存器、队列项或内存位置。

<!-- PTO-READER-BLOCK: scalar-j-effects role=effects -->
## 控制流效果

`WritePC` 用算出的目标替换程序计数器，因此下一条指令从该目标取指。由于 `JumpRelative` 属于会写 `TPC` 的处理程序，分派边界不会再叠加该 `32` 位形式的 `4` 字节长度。

`J` 不写寄存器、队列项、内存位置、提交参数或任何 `BARG` 字段。它不需要条件指令束的放置要求，因为它不是条件设置操作。

<!-- PTO-READER-BLOCK: scalar-j-constraints role=constraints -->
## 合法性与故障顺序

与该形式固定位不匹配的编码会引发 `Fault_IllegalInstruction`，并让 `TPC` 保持不变。没有保留字段值：包括 `0` 在内，`simm22` 的每个取值都已分配。

设计要点：位移从指令中读出，目标的计算与安装在同一步内完成，因此被拒绝的译码不会留下只完成一半的控制转移。

<!-- PTO-READER-BLOCK: scalar-j-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

对于位于 `0x4000` 的 `J`，`j 8` 把 `0x4010` 安装为新的 `PC`，而顺序继续本应是 `0x4004`。`j -3` 安装 `0x3FFA`，`j 0` 安装 `0x4000`，即重新执行同一条跳转。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
j label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| j_32_a303cf05af42 | L32 | 32 | 0x00000037 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| j_32_a303cf05af42 | simm22 | 22 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| j_32_a303cf05af42 | simm22 | 22 | 0–4194303 | none | none | 22-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 22-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm22 | 22-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractOperation_J() => ScalarOperation
begin
    return ScalarOperation_J;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractHandler_J() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRelative;
end;

pure func InstructionContractUsesCurrentPC_J()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_J(
    current_pc: Word,
    halfword_offset: Word)
    => Word
begin
    return current_pc + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- J - Jump to the PC-relative target.
- After decode and legality checks, execute the normative JumpRelative ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- j label
