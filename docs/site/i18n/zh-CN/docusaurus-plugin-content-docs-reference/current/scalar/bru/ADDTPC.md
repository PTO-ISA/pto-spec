<!-- GENERATED FROM: asl/scalar/bru/ADDTPC.asl -->
# ADDTPC

**Normative ASL source:** `asl/scalar/bru/ADDTPC.asl`

ADDTPC - Add a signed 4 KiB page displacement to the current TPC.

## Normative identity {#PTO-INST-SCALAR-ADDTPC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addtpc-purpose role=purpose -->
## ADDTPC 的作用

`ADDTPC` 给当前指令 `TPC` 加上一个有符号的 `4` KiB 页位移，并把得到的地址写入目的寄存器。

它是物化指令而非分支：算出的地址成为数据，执行继续到下一条指令。

<!-- PTO-READER-BLOCK: scalar-addtpc-mechanism role=mechanism -->
## 机制

契约返回 `ScalarHandler_AddToPC`，其中 `InstructionContractUsesTPC_ADDTPC` 为真、`InstructionContractImmediateIsSigned_ADDTPC` 为真、`InstructionContractImmediateWidth_ADDTPC` 为 `20`、`InstructionContractPageShift_ADDTPC` 为 `12`。

模型把左移 `12` 位后的 `SignExtend(imm20)` 加到 `TPC` 上，并把该和通过目的选择子写出。加法在 XLEN 处回绕。`TPC` 在加法之前只读取一次，因此该和相对于 `ADDTPC` 自身的地址，而绝不相对于下一条指令。

设计要点：编码立即数为零时贡献零位移，因此该指令无需其他准备就能把当前 `TPC` 复制进寄存器。这为软件提供了获取自相对基地址的途径，而不必额外载入一个常量。

<!-- PTO-READER-BLOCK: scalar-addtpc-inputs-outputs role=inputs-outputs -->
## 输入与输出

`imm20` 提供范围为 `-524288` 到 `524287` 页的有符号 `20` 位页位移。按 `4096` 字节缩放后，字节位移范围是 `-2147483648` 到 `2147479552`（`-2 GiB` 到 `2 GiB - 4 KiB`）。

`RegDst` 命名目的。编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃结果，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。

`RegDst` 编码为零时指向架构零 GPR，因此写入该处没有架构效果。

设计要点：`RegDst` 排除编码 `10`，因为这个五位值是 `SETRET` 隐式返回地址目的的编码，而更窄的 `SETRET` 形式恰好占据 `ADDTPC` 操作码中的那个空洞。因此 `RegDst` 为 `10` 会被拒绝，而不是被重新解释。

<!-- PTO-READER-BLOCK: scalar-addtpc-effects role=effects -->
## 效果与排序

`ADDTPC` 只写一个目的值，别的什么都不做。`InstructionContractWritesTPC_ADDTPC` 返回假，状态契约也声明该指令既不安装控制流目标，也不直接修改 `TPC`。

在目的效果之后，标量派发让 `TPC` 前进 `4` 字节，即该形式的编码长度，因为 `ScalarHandlerWritesTPC` 对 `AddToPC` 为假。

没有内存效果，没有保留效果，也没有数值状态标志。

设计要点：地址运算与程序计数器前进是两个分离的步骤。因此后续的分支或间接转移可以从寄存器中取用算出的地址，而在此之前只读的 `TPC` 寄存器一直保持它通常的顺序含义。

<!-- PTO-READER-BLOCK: scalar-addtpc-constraints role=constraints -->
## 合法性与故障顺序

先执行解码。固定位不匹配会在指令地址处抛出 `Fault_IllegalInstruction`，且在任何效果之前。

唯一受约束的字段是 `RegDst`，其取值 `10` 是保留的，也会在任何效果之前抛出 `Fault_IllegalInstruction`。`imm20` 没有保留取值：包括符号位在内，全部 `20` 位模式都已分配。

<!-- PTO-READER-BLOCK: scalar-addtpc-example role=example -->
## 非规范示例

设 `a0 = 8192`，并设 `ADDTPC` 指令本身位于 `TPC = 53248`。

当 `imm20 = 1` 时位移为 `1 << 12 = 4096`，因此 `addtpc simm, ->{t, u, Rd}` 把 `53248 + 4096 = 57344` 写入 `a0`。

下一条指令取自 `53248 + 4 = 53252`，而不是 `57344`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addtpc simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addtpc_32_e5aa0f0abca3 | L32 | 32 | 0x00000007 / 0x0000007f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addtpc_32_e5aa0f0abca3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addtpc_32_e5aa0f0abca3 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addtpc_32_e5aa0f0abca3 | RegDst | 5 | 0–9, 11–31 | none | 10 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| addtpc_32_e5aa0f0abca3 | imm20 | 20 | 0–1048575 | none | none | signed 20-bit 4 KiB page displacement | Encoded zero contributes a zero page displacement and produces the current instruction TPC. |

- `addtpc_32_e5aa0f0abca3.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| imm20 | signed 20-bit 4 KiB page displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractImmediateWidth_ADDTPC()
    => integer {20}
begin
    return 20;
end;

pure func InstructionContractImmediateIsSigned_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPageShift_ADDTPC()
    => integer {12}
begin
    return 12;
end;

pure func InstructionContractWritesTPC_ADDTPC()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractTarget_ADDTPC(
    base: Word,
    page_offset: Word)
    => Word
begin
    return base + LSL(page_offset, 12);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The imm20 field is sign-extended and scaled by 4096 bytes; encoded zero contributes a zero page displacement and produces the current instruction TPC.
- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- addtpc_32_e5aa0f0abca3.RegDst excludes 10; the excluded encoding is reserved.

## State effects

- ADDTPC writes TPC + (SignExtend(imm20) << 12), wrapping at XLEN, through the selected Reg5 destination.
- The instruction does not install a control-flow target and does not directly modify TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read the current instruction TPC before computing the wrapping XLEN result.
- After the destination effect, the scalar dispatch boundary advances TPC by four bytes.

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- addtpc simm, ->{t, u, Rd}
