<!-- GENERATED FROM: asl/scalar/sys/TLB.IV.asl -->
# TLB.IV

**Normative ASL source:** `asl/scalar/sys/TLB.IV.asl`

TLB.IV completes the canonical 48-bit virtual address maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iv-purpose role=purpose -->
## TLB.IV 的作用

`TLB.IV` 同步完成规范 48 位虚拟地址的地址转换维护操作。它是纯地址形式：要失效的地址来自 `SrcL`，只有当该值是规范 48 位虚拟地址且当前环为 ACR0 时该次尝试才被接受。

<!-- PTO-READER-BLOCK: scalar-tlb-iv-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_TLB_IV` 选择共用的维护处理程序（`asl/scalar/sys/TLB.IV.asl:18`），而 `InstructionContractMaintenanceRequiresRootRing_TLB_IV` 返回 `TRUE`（`asl/scalar/sys/TLB.IV.asl:42`），正是这一点把该操作放进执行器的环受限组（`asl/scalar/model/sys/semantics.asl:121`）。派发器为该形式读取 `SrcL`，因为 `InstructionContractMaintenanceUsesOperand_TLB_IV` 为 `TRUE`（`asl/scalar/model/dispatch/sys.asl:50`）。

执行器内部的顺序是先特权、后操作数：环检查在规范地址测试之前运行，两种失败各有自己的故障类别（`asl/scalar/model/sys/semantics.asl:129`）。

<!-- PTO-READER-BLOCK: scalar-tlb-iv-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。它的值是虚拟地址操作数，由 `IsCanonicalAddress48` 测试，该函数要求当第 47 位为 0 时第 63:48 位全为 0，当第 47 位为 1 时全为 1（`asl/scalar/model/sys/semantics.asl:108`）。

没有目的地操作数。成功时该操作数只发布到维护记录中，编码零命名架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-tlb-iv-effects role=effects -->
## 架构效果

成功的尝试恰好把 TLB 纪元递增一，并以该地址操作数记录 `Maintenance_TLB_IV`（`asl/scalar/model/sys/semantics.asl:146`）。随后 `TPC` 按指令长度前进，因为无故障的尝试会向派发器报告成功。

设计要点：被拒绝的操作数不会改变 TLB 纪元，而且只有在该次尝试无故障时才写入记录（`asl/scalar/model/sys/semantics.asl:156`）。因此对纪元或记录的读者来说，非规范请求不可能看起来像一次已完成的失效。

该指令不执行普通标量内存访问，因此不触碰页表或数据内存。

<!-- PTO-READER-BLOCK: scalar-tlb-iv-constraints role=constraints -->
## 位置与拒绝边界

位置先由派发器检查：在活动 SYS 块体之外，该次尝试引发 `Fault_BundleControl`，执行器从不运行。在块体内部，固定位与 `SrcL` 选择器在调用之前完成校验。

随后执行器施加自己的两种拒绝。当前环不是 ACR0 会引发 `Fault_IllegalInstruction`。ring 0 下操作数不是规范地址会引发 `Fault_DataPage`，并以该操作数作为陷阱参数，同时纪要不改变（`asl/scalar/model/sys/semantics.asl:143`）。

设计要点：地址转换维护属于管理者状态，因此被限制在根环；而地址形状的操作数保留自己的页故障类别。区分这两种拒绝，使处理程序能分辨特权失败与地址格式错误。

<!-- PTO-READER-BLOCK: scalar-tlb-iv-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 ACR0，GPR 持有 0x1234 时，`tlb.iv SrcL` 快照 0x1234，因第 63:48 位为零而通过规范测试，把 TLB 纪元递增一，并以操作数 0x1234 记录 `Maintenance_TLB_IV`。同一条指令在 ACR1 环上引发 `Fault_IllegalInstruction`，且不读取操作数的规范形式。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iv SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | L32 | 32 | 0x0010702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IV.asl -->
```asl
readonly func InstructionContractOperation_TLB_IV()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IV executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IV.asl -->
```asl
readonly func InstructionContractHandler_TLB_IV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IV()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IV;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IV()
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
- The operand must be a canonical 48-bit virtual address.

## State effects

- Success records Maintenance_TLB_IV and its exact operand token.
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

- tlb.iv SrcL
