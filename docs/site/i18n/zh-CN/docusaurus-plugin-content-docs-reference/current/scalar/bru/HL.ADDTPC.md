<!-- GENERATED FROM: asl/scalar/bru/HL.ADDTPC.asl -->
# HL.ADDTPC

**Normative ASL source:** `asl/scalar/bru/HL.ADDTPC.asl`

HL.ADDTPC - Add a signed 4 KiB page displacement to the current TPC.

## Normative identity {#PTO-INST-SCALAR-HL-ADDTPC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-addtpc-purpose role=purpose -->
## HL.ADDTPC 的作用

`HL.ADDTPC` 把一个有符号 `32` 位页位移加到当前指令的 `TPC` 上，并把和作为数据通过目的选择子发布。它不转移控制流：写入之后，执行继续走向后续指令。

设计要点：结果是算出的地址，而不是跳转目标。因此程序可以在不改变执行去向的前提下生成页相对基址或表地址，而 `48` 位形式的 `6` 字节顺序前进依然发生。同一 `48` 位骨架下的姊妹形式 `HL.SETRET` 则改为记录返回目标。

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-mechanism role=mechanism -->
## 页地址的形成方式

`32` 位 `imm32` 先符号扩展到 `PTO_XLEN`（`64` 位），再左移 `12` 位，然后与当前 `TPC` 相加。加法在 `64` 位宽度内进行，因此在 `2^64` 处回绕，从第 `63` 位进出的进位被丢弃。

设计要点：左移 `12` 位使立即数以 `4096` 字节的页为单位，因此该编码字段以 `4` KiB 页为步长。编码零不是特殊标记：它贡献零页位移，写入的值就是未改变的 `TPC`。

被读取的 `TPC` 就是 `HL.ADDTPC` 自身的地址，因为此前没有任何步骤推进它。目的写入与 `6` 字节顺序前进是两个独立步骤，顺序为先写后进。

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-inputs-outputs role=inputs-outputs -->
## 操作数与目的编码

- `imm32` 提供有符号页位移。它由两个指令片段拼装而成，宽度分别为 `20` 位和 `12` 位。

- `RegDst` 按普通 `Reg5` 规则选择目的：编码 `0` 到 `23` 指定绝对 GPR，编码 `24` 到 `29` 不写入任何位置，编码 `30` 压入 U 队列，编码 `31` 压入 T 队列。

- 没有源寄存器操作数。计算的基址就是该指令的 `TPC`。

设计要点：`RegDst` 的编码值 `10` 被保留，因为同一 `48` 位编码空间中该目的槽位由窄形式 `hl.setret` 占用。`RegDst` 为 `10` 的编码选中的是 `HL.SETRET`，而不是 `HL.ADDTPC`。

设计要点：编码 `24` 到 `29` 是非写入目的，因此使用其中之一编码的 `HL.ADDTPC` 只会让 `TPC` 前进 `6` 字节，所有寄存器与队列项都保持不变。

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-effects role=effects -->
## 效果与顺序

回绕后的和通过所选目的写入。`AddToPC` 不修改 `TPC`，因此写入之后由分派边界让 `TPC` 前进 `6` 字节，即该 `48` 位形式的编码长度。

`HL.ADDTPC` 不修改提交状态、任何 `BARG` 字段、任何内存位置或保留状态，并且 `AddToPC` 自身不引发故障。

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-constraints role=constraints -->
## 合法性与故障顺序

该形式的固定位必须匹配，否则该编码不会译码为本指令，并引发 `Fault_IllegalInstruction`。`RegDst` 的取值 `10` 是本形式唯一的保留字段值；`imm32` 的全部 `32` 位都已分配。

设计要点：合法性检查发生在读取 `TPC` 与写入目的之前，因此被拒绝的编码不发布任何值，并让 `TPC` 停在该指令处，以便恢复后完整重新执行。

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `TPC` 为 `0x1000` 时，`hl.addtpc 1, ->a1` 把 `0x2000` 写入 `a1`，下一条指令从 `0x1006` 取指。`hl.addtpc -1, ->a2` 写入 `0x0000`，`hl.addtpc 0, ->a3` 写入未改变的 `0x1000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.addtpc imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | HL48 | 48 | 0x00000007000e / 0x0000007f000f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | 0–9, 11–31 | none | 10 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | 0–4294967295 | none | none | signed 32-bit 4 KiB page displacement | Encoded zero contributes a zero page displacement and produces the current instruction TPC. |

- `hl_addtpc_48_2e8e692eea09.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| imm32 | signed 32-bit 4 KiB page displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_HL_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractImmediateWidth_HL_ADDTPC()
    => integer {32}
begin
    return 32;
end;

pure func InstructionContractImmediateIsSigned_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPageShift_HL_ADDTPC()
    => integer {12}
begin
    return 12;
end;

pure func InstructionContractWritesTPC_HL_ADDTPC()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractTarget_HL_ADDTPC(
    base: Word,
    page_offset: Word)
    => Word
begin
    return base + LSL(page_offset, 12);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The imm32 field is sign-extended and scaled by 4096 bytes; encoded zero contributes a zero page displacement and produces the current instruction TPC.
- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- hl_addtpc_48_2e8e692eea09.RegDst excludes 10; the excluded encoding is reserved.

## State effects

- HL.ADDTPC writes TPC + (SignExtend(imm32) << 12), wrapping at XLEN, through the selected Reg5 destination.
- The instruction does not install a control-flow target and does not directly modify TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read the current instruction TPC before computing the wrapping XLEN result.
- After the destination effect, the scalar dispatch boundary advances TPC by six bytes.

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.addtpc imm, ->{t, u, Rd}
