<!-- GENERATED FROM: asl/scalar/sys/TLB.IA.asl -->
# TLB.IA

**Normative ASL source:** `asl/scalar/sys/TLB.IA.asl`

TLB.IA completes the 16-bit ASID token in bits 15:0 maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-ia-purpose role=purpose -->
## TLB.IA 的作用

`TLB.IA` 同步完成 16 位 ASID 的地址转换维护操作。它的操作数不是地址而是地址空间标识符：`SrcL` 的第 15:0 位携带该令牌，且第 63:16 位必须为零，该次尝试才被接受。

<!-- PTO-READER-BLOCK: scalar-tlb-ia-mechanism role=mechanism -->
## 系统机制

该指令选择共用的维护处理程序（`asl/scalar/sys/TLB.IA.asl:18`）与令牌 `Maintenance_TLB_IA`（`asl/scalar/sys/TLB.IA.asl:30`）。该令牌在执行器中拥有自己的分支，与两个地址分支分开，因为它的操作数测试是位范围测试而不是规范性测试（`asl/scalar/model/sys/semantics.asl:148`）。

`InstructionContractMaintenanceRequiresRootRing_TLB_IA` 返回 `TRUE`（`asl/scalar/sys/TLB.IA.asl:42`），这使该操作进入 `MaintenanceAccessPermitted` 中仅限 ACR0 的那一组。

<!-- PTO-READER-BLOCK: scalar-tlb-ia-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。该指令把它解释为打包令牌，因此任何在第 15 位以上有非零位的值都不是该形式的有效操作数。

没有目的地操作数，也没有第二个字段。成功时该令牌被记录在维护记录中；任何被拒绝的情况下都不发布任何内容。

<!-- PTO-READER-BLOCK: scalar-tlb-ia-effects role=effects -->
## 架构效果

成功的尝试把 TLB 纪元递增一，并把 `Maintenance_TLB_IA` 与操作数存入维护记录（`asl/scalar/model/sys/semantics.asl:148`）。一旦该次尝试报告成功，`TPC` 按指令长度前进。

设计要点：操作数检查是范围测试而不是掩码，因此带有多余高位的操作数会被拒绝，而不是被静默截断为低 16 位。把标识符打包进寄存器的软件因此必须把高位清零。

该指令不执行普通标量内存访问，也不写任何寄存器、队列或系统寄存器。

<!-- PTO-READER-BLOCK: scalar-tlb-ia-constraints role=constraints -->
## 位置与拒绝边界

维护路径上有三种拒绝，顺序如下。在活动 SYS 块体之外，派发器在执行器之前引发 `Fault_BundleControl`。ACR0 之外的环引发 `Fault_IllegalInstruction`。在 ACR0，第 63:16 位不全为零的操作数引发 `Fault_IllegalInstruction`，TLB 纪元保持不变（`asl/scalar/model/sys/semantics.asl:149`）。还有一次拒绝发生在位置检查与执行器之间：共用的操作数合法性检查会拒绝指名不可用临时队列项的 `SrcL` 选择器（`asl/scalar/model/types/operands.asl:6`）。

设计要点：特权测试在操作数测试之前运行。因此非根环的尝试即使操作数同样格式错误，也走特权拒绝，并且永远到不了纪元推进那一步。

<!-- PTO-READER-BLOCK: scalar-tlb-ia-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 ACR0 且源寄存器持有 3 时，`tlb.ia SrcL` 通过 ASID 位测试，把 TLB 纪元递增一，并以操作数 3 记录 `Maintenance_TLB_IA`。如果某个高位被置位，例如 0x10000，同一条指令在 ACR0 会引发 `Fault_IllegalInstruction`，TLB 纪元不动。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.ia SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_ia_32_e794d6bf347e | L32 | 32 | 0x0000702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_ia_32_e794d6bf347e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_ia_32_e794d6bf347e | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IA.asl -->
```asl
readonly func InstructionContractOperation_TLB_IA()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IA.asl -->
```asl
readonly func InstructionContractHandler_TLB_IA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IA()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IA;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.
- Operand bits 63:16 must be zero; bits 15:0 are the ASID token.

## State effects

- Success records Maintenance_TLB_IA and its exact operand token.
- Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC.

## Memory effects and ordering

### Memory effects

- No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch.

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- tlb.ia SrcL
