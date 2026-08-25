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

`ADDTPC` 根据当前 `TPC` 形成页相对地址，但不执行控制转移。

<!-- PTO-READER-BLOCK: scalar-addtpc-mechanism role=mechanism -->
## 执行机制

有符号 `20` 位立即数先扩展并左移 `12` 位，再与快照的当前 `TPC` 按 `2^PTO_XLEN` 取模相加。

计算出的地址通过编码目的位置发布，不会被安装为下一条 `TPC`。

<!-- PTO-READER-BLOCK: scalar-addtpc-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择编码指定的目的位置或丢弃行为。

- `imm20` 提供编码立即数或位移。

<!-- PTO-READER-BLOCK: scalar-addtpc-effects role=effects -->
## 效果与顺序

结果先通过编码目的位置发布，成功分派随后让 `TPC` 前进 `4` 字节。

该指令不分支，也不访问内存或保留状态。

<!-- PTO-READER-BLOCK: scalar-addtpc-constraints role=constraints -->
## 合法性与故障顺序

编码、保留字段值和源可用性都会在目的、控制或 `TPC` 效果前检查。

<!-- PTO-READER-BLOCK: scalar-addtpc-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`addtpc simm, ->{t, u, Rd}` 把页相对地址作为数据发布，随后继续顺序执行。
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
