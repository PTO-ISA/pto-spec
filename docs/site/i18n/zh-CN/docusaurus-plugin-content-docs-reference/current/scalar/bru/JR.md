<!-- GENERATED FROM: asl/scalar/bru/JR.asl -->
# JR

**Normative ASL source:** `asl/scalar/bru/JR.asl`

JR - Jump to the scalar-register target.

## Normative identity {#PTO-INST-SCALAR-JR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-jr-purpose role=purpose -->
## JR 的作用

`JR` 把控制流转移到一个由标量寄存器加有符号半字位移形成的地址。寄存器值是基址，因此目标是绝对的，不依赖当前 `PC`。

设计要点：`jr Ra, 0` 是经由 `Ra` 的间接跳转，因为位移加在寄存器值上，而不是加在 `PC` 上。与 `J` 不同，目标并不锚定在指令地址上。

<!-- PTO-READER-BLOCK: scalar-jr-mechanism role=mechanism -->
## 目标计算与偶数目标规则

`SrcL` 按普通 `Reg5` 源规则读取，`simm12` 先符号扩展到 `PTO_XLEN` 再左移 `1` 位。二者在 `64` 位宽度内相加，并在 `2^64` 处回绕，所得和即候选目标。

只有当候选目标的最低位为 `0` 时才把它安装为新的 `PC`。当最低位为 `1` 时，`JumpRegister` 以该候选目标作为故障参数引发 `Fault_InstructionPC`，并且不写 `PC`。

设计要点：移位后的位移一定是偶数，因此只有寄存器值会使和为奇数。检查这个和就用一次判断覆盖了两个输入，而且发生故障时不会安装任何目标，也不会替换成对齐后的地址。

<!-- PTO-READER-BLOCK: scalar-jr-inputs-outputs role=inputs-outputs -->
## 操作数、别名字段与结果

- `SrcL` 按 `Reg5` 源规则提供基址：编码 `0` 到 `23` 读取绝对 GPR，编码 `24` 到 `27` 读取 T 队列，编码 `28` 到 `31` 读取 U 队列。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `simm12` 提供有符号半字位移，编码在两个片段中，宽度分别为 `7` 位和 `5` 位。

- `SrcZero` 会被译码但从不被读取：操作中没有任何路径使用它，因此这 `5` 位的取值既不能改变目标，也不能改变故障判定。

设计要点：`SrcZero` 是被忽略的别名字段，而不是操作数。规范汇编 `jr SrcL, label` 中没有它的位置，该字段的全部 `32` 个取值都译码为同一操作。

<!-- PTO-READER-BLOCK: scalar-jr-effects role=effects -->
## 效果、故障与顺序

`WritePC` 安装这个偶数目标。`JumpRegister` 属于会写 `TPC` 的处理程序，因此分派边界不会再叠加该 `32` 位形式的 `4` 字节长度。

在故障路径上不会安装任何 `PC` 值，`TPC` 也不前进，`Fault_InstructionPC` 报告该候选目标。两条路径都不写寄存器、队列项、内存位置或 `BARG` 字段。

<!-- PTO-READER-BLOCK: scalar-jr-constraints role=constraints -->
## 合法性与故障顺序

该形式的固定位必须匹配，且所选的 `SrcL` 源必须可用，否则会在计算任何目标之前引发 `Fault_IllegalInstruction`。包括 `SrcZero` 在内，没有任何保留字段值。

设计要点：只有在译码与操作数检查之后才读取源并计算目标，因此被拒绝的 `JR` 不会改动 `PC` 与源寄存器，恢复后可以重新执行该指令。

<!-- PTO-READER-BLOCK: scalar-jr-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `a0` 持有 `0x8000` 且 `PC` 为 `0x4000` 时，`jr a0, 4` 安装 `0x8008`。`jr a0, 0` 安装 `0x8000`；若 `a0` 持有的是 `0x8001`，同一编码会以 `0x8001` 作为参数引发 `Fault_InstructionPC`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
jr SrcL, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | L32 | 32 | 0x00006027 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| jr_32_c4128e843b05 | SrcZero | 5 | 0–31 | none | none | explicit zero-valued source selector | Encoded zero selects value zero of the explicit zero-valued source selector. |
| jr_32_c4128e843b05 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcZero | explicit zero-valued source selector |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractOperation_JR() => ScalarOperation
begin
    return ScalarOperation_JR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractHandler_JR() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRegister;
end;

pure func InstructionContractRequiresEvenTarget_JR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_JR(
    register_value: Word,
    halfword_offset: Word)
    => Word
begin
    return register_value + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- JR - Jump to the scalar-register target.
- After decode and legality checks, execute the normative JumpRegister ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- jr SrcL, label
