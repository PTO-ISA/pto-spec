<!-- GENERATED FROM: asl/scalar/sys/HL.SSRGET.asl -->
# HL.SSRGET

**Normative ASL source:** `asl/scalar/sys/HL.SSRGET.asl`

HL.SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-HL-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ssrget-purpose role=purpose -->
## HL.SSRGET 的作用

`HL.SSRGET` 是系统寄存器读取的宽地址形式。它的行为与 `SSRGET` 相同，但地址字段是 24 位而不是 12 位，因此同一条指令覆盖的寄存器空间大得多。

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_HL_SSRGET` 选择 `ScalarHandler_ExecuteSystemRegisterGet`（`asl/scalar/sys/HL.SSRGET.asl:18`），即 32 位形式所用的同一个辅助函数。变化的是地址：`InstructionContractSystemAddressWidth_HL_SSRGET` 把宽度固定为 24（`asl/scalar/sys/HL.SSRGET.asl:36`），汇编形式为 48 位（`asl/scalar/sys/HL.SSRGET.asl:1`）。

派发器在调用读取辅助函数之前，用两个 12 位片段拼出该 24 位地址（`asl/scalar/model/dispatch/sys.asl:91`）。

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SSR_ID` 是 24 位系统寄存器地址，`RegDst` 是目的地选择器 `discard, R1..R23, push U, or push T`（`asl/scalar/sys/HL.SSRGET.asl:1`）。`InstructionContractPushesTemporaryT_HL_SSRGET` 返回 `FALSE`（`asl/scalar/sys/HL.SSRGET.asl:42`），由目的地选择器单独决定该值是落入 GPR 还是进入临时队列。

`SSR_ID` 中的编码零是地址 0 处的基寄存器，`RegDst` 中的编码零命名架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-effects role=effects -->
## 架构效果

成功时完整的寄存器值通过 Reg5 目的地映射发布，`TPC` 按指令长度前进。只有在读取未报告故障时才写目的地（`asl/scalar/model/sys/registers.asl:148`），因此被拒绝的宽读取会让目的地与临时队列都不被触碰。

设计要点：读取路径对存入扩展寄存器堆的地址只接受第 23:16 位为零者，`SystemRegisterFileIndexOf` 对该条件做断言（`asl/scalar/model/sys/registers.asl:56`）。因此该空间这一部分的地址在索引形成之前就由访问类别表决定接受或拒绝。

该指令不修改系统寄存器堆，也不执行普通标量内存访问。

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-constraints role=constraints -->
## 位置与拒绝边界

先检查位置是否在活动 SYS 块体内，在其他位置的尝试引发 `Fault_BundleControl`。随后读取路径在当前环对该地址缺少权限，或访问类别为未知或只写时以 `Fault_IllegalInstruction` 拒绝（`asl/scalar/model/sys/registers.asl:66`）。

设计要点：更宽的地址字段并不放宽权限规则。低 12 位低于 0x0F00 的地址在每个环都可到达，而上下文、地址转换和调试系列需要 ACR0，与 12 位形式完全一致。

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

`hl.ssrget SSR_ID, ->{t, u, Rd}` 在 `SSR_ID` 为 0x1F02 且目的地为 R2 时，于 ACR0 读取 ring 1 的陷阱状态寄存器并把其打包值发布到 R2；该字在第 5:0 位携带陷阱号，并同时携带陷阱原因与状态标志。用同一目的地读取 `SSR_ID` 0x0F04 会被 `Fault_IllegalInstruction` 拒绝，因为该地址没有已分配的访问类别，而 R2 保持先前值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | HL48 | 48 | 0x0000003b000e / 0x000ff07f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ssrget_48_fde37e58a3c4 | SSR_ID | 24 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| hl_ssrget_48_fde37e58a3c4 | SSR_ID | 24 | 0–16777215 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_HL_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
HL.SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_HL_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_HL_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_HL_SSRGET()
    => integer {5,12,24}
begin
    return 24;
end;

pure func InstructionContractPushesTemporaryT_HL_SSRGET()
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

- hl.ssrget SSR_ID, ->{t, u, Rd}
