<!-- GENERATED FROM: asl/scalar/bru/HL.SETRET.asl -->
# HL.SETRET

**Normative ASL source:** `asl/scalar/bru/HL.SETRET.asl`

HL.SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-HL-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setret-purpose role=purpose -->
## HL.SETRET 的作用

`HL.SETRET` 用当前指令的 `TPC` 加上一个无符号半字偏移算出返回地址，并把它记录在两个位置：汇编中名为 `Ra` 的通用寄存器 `R10`，以及指令束局部的返回地址。

设计要点：`HL.SETRET` 只准备返回，不执行返回。真正的转移发生在之后：当转移类型为返回的块起始读取已记录的返回地址时才发生，因此该指令本身让执行保持顺序前进。

<!-- PTO-READER-BLOCK: scalar-hl-setret-mechanism role=mechanism -->
## 返回地址的形成方式

`32` 位 `imm32` 先零扩展到 `PTO_XLEN`，再左移 `1` 位，然后与当前 `TPC` 相加。该 `2` 倍缩放使字段以半字为单位，和在 `2^64` 处回绕。

设计要点：`imm32` 采用零扩展而不是符号扩展，因此该字段覆盖 `0` 到 `4294967295` 个半字，且没有负位移。姊妹形式 `HL.ADDTPC` 则使用有符号立即数并以 `12` 位页位移缩放，因此两者不可互换。

两处写入使用同一个计算值，并在同一步处理中完成：`SetReturnAddress` 先写 GPR `10`，再写指令束局部的返回地址。

<!-- PTO-READER-BLOCK: scalar-hl-setret-inputs-outputs role=inputs-outputs -->
## 操作数与固定目的

- `imm32` 提供无符号半字偏移。它由两个指令片段拼装而成，宽度分别为 `20` 位和 `12` 位。

- 没有目的选择子字段：其他 `48` 位形式用作 `RegDst` 的那些位在本形式中固定为值 `10`，因此目标总是写入 `R10`。

- 没有源寄存器操作数。计算的基址就是该指令的 `TPC`。

设计要点：由于目的由编码本身固定，而不是由字段指定，`HL.SETRET` 无法编码出丢弃型或队列型目的。每一次成功执行都会同时更新 `R10` 与返回地址。

<!-- PTO-READER-BLOCK: scalar-hl-setret-effects role=effects -->
## 效果与顺序

`R10` 接收回绕后的目标，指令束局部返回地址接收同一个值。`SetReturnAddress` 不写 `TPC`，因此随后由分派边界让 `TPC` 前进 `6` 字节。

其他状态都不改变：不写内存位置、保留状态、提交参数或任何 `BARG` 字段。`SetReturnAddress` 路径自身不引发故障。

设计要点：同时写 `R10` 与指令束局部返回地址，使该值对普通标量代码可见，可以用常规寄存器操作读取、保存或替换；而块机制保留自己的副本，供返回类型的块起始与帧模板使用。

<!-- PTO-READER-BLOCK: scalar-hl-setret-constraints role=constraints -->
## 合法性与故障顺序

该形式的固定位必须匹配，否则该编码不会译码为本指令，并引发 `Fault_IllegalInstruction`。`imm32` 的每个取值都已分配，因此没有保留的立即数。

设计要点：译码发生在读取 `TPC` 与两处写入之前，因此被拒绝的编码不会改动 `R10`、指令束局部返回地址和 `TPC`。

<!-- PTO-READER-BLOCK: scalar-hl-setret-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `TPC` 为 `0x2000` 时，`hl.setret 4, ->Ra` 把 `0x2008` 写入 `R10` 并记录 `0x2008` 为返回地址，而执行继续走向 `0x2006`。`hl.setret 0, ->Ra` 记录 `0x2000`，即该指令自身的地址。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setret imm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | HL48 | 48 | 0x00000507000e / 0x00000fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | 0–4294967295 | none | none | 32-bit immediate value | Encoded zero supplies numeric zero for the 32-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm32 | 32-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_HL_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_HL_SETRET(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- HL.SETRET - Write the architectural return address.
- After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.setret imm, ->Ra
