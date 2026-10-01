<!-- GENERATED FROM: asl/scalar/sys/SSRGET.asl -->
# SSRGET

**Normative ASL source:** `asl/scalar/sys/SSRGET.asl`

SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ssrget-purpose role=purpose -->
## SSRGET 的作用

`SSRGET` 读取一个系统寄存器。它从 `SSR_ID` 取得 12 位寄存器地址、从 `RegDst` 取得 5 位目的地选择器，读取被寻址的寄存器，并把完整值发布到该目的地。该地址空间是规范的，因此基寄存器与上下文寄存器由同一条指令到达。

<!-- PTO-READER-BLOCK: scalar-ssrget-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_SSRGET` 选择 `ScalarHandler_ExecuteSystemRegisterGet`（`asl/scalar/sys/SSRGET.asl:18`），`InstructionContractSystemAddressWidth_SSRGET` 把地址宽度固定为 12（`asl/scalar/sys/SSRGET.asl:36`）。派发器把 `RegDst` 解码为 Reg5 选择器、把 `SSR_ID` 解码为系统寄存器地址，然后按该顺序调用读取辅助函数（`asl/scalar/model/dispatch/sys.asl:106`）。

该辅助函数先读后写：`ExecuteSystemRegisterGet` 先读取被寻址的寄存器，只有在未引发故障时才写目的地（`asl/scalar/model/sys/registers.asl:144`）。

<!-- PTO-READER-BLOCK: scalar-ssrget-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SSR_ID` 是 12 位系统寄存器标识符，`RegDst` 是目的地选择器 `discard, R1..R23, push U, or push T`（`asl/scalar/sys/SSRGET.asl:1`）。`ReadSystemRegisterAddress` 路径把地址分类为基寄存器、扩展寄存器或未分配，并在读取之前检查其访问类别（`asl/scalar/model/sys/registers.asl:60`）。

L32 形式长 32 位，因此 `SSR_ID` 可寻址 4096 个寄存器位置。`SSR_ID` 中的编码零是地址 0 处的基寄存器，`RegDst` 中的编码零命名架构零 GPR，即丢弃该值。

<!-- PTO-READER-BLOCK: scalar-ssrget-effects role=effects -->
## 架构效果

成功的读取通过 Reg5 目的地映射发布完整的寄存器值，该映射会写 GPR 或压入 U 队列或 T 队列（`asl/scalar/model/types/operands.asl:65`）。随后 `TPC` 前进 4 字节。

设计要点：目的地写入以读取成功为前提。因此被拒绝的读取会让目的地寄存器、临时队列和系统寄存器都保持不变，失败的 `SSRGET` 无法破坏后续代码所依赖的值。

`SSRGET` 不修改系统寄存器堆，也不执行普通标量内存访问。

<!-- PTO-READER-BLOCK: scalar-ssrget-constraints role=constraints -->
## 位置与拒绝边界

第一道门是位置必须在活动 SYS 块体内；在其他位置，该次尝试在地址被检查之前引发 `Fault_BundleControl`。第二道门是地址检查：当环缺少权限，或地址类别为 `SystemRegisterAccess_Unknown` 或 `SystemRegisterAccess_WriteOnly` 时，读取以 `Fault_IllegalInstruction` 被拒绝（`asl/scalar/model/sys/registers.asl:66`）。

设计要点：访问环权限由地址而不是由指令决定。低于 0x0F00 的地址在每个环都可到达，而上下文、地址转换和调试系列需要 ACR0，因此同一条 `SSRGET` 编码会因执行它的环而成功或失败。

<!-- PTO-READER-BLOCK: scalar-ssrget-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

`ssrget SSR_ID, ->{t, u, Rd}` 在 `SSR_ID` 为 0x0010 且目的地为 R1 时读取 `TIME`，即架构时间寄存器，并把该值发布到 R1。把同一指令的 `SSR_ID` 改为 0x0F04 则被拒绝，因为该地址没有已分配的访问类别，读取在任何目的地写入之前引发 `Fault_IllegalInstruction`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | L32 | 32 | 0x0000003b / 0x000ff07f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractOperation_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractHandler_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_SSRGET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRGET()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Read the complete XLEN system-register value and publish it through the common Reg5 destination mapping.
- A rejected read preserves the destination and queue state except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ssrget SSR_ID, ->{t, u, Rd}
