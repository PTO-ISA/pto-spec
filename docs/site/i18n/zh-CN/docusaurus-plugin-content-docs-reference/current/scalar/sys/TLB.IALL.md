<!-- GENERATED FROM: asl/scalar/sys/TLB.IALL.asl -->
# TLB.IALL

**Normative ASL source:** `asl/scalar/sys/TLB.IALL.asl`

TLB.IALL completes the all translation entries maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iall-purpose role=purpose -->
## TLB.IALL 的作用

`TLB.IALL` 同步完成所有地址转换条目的维护操作。作为最宽的 TLB 请求，它不需要操作数：其编码没有字段（`asl/scalar/sys/TLB.IALL.asl:1`），语义操作数是全零的 XLEN 值。

<!-- PTO-READER-BLOCK: scalar-tlb-iall-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_TLB_IALL` 选择共用的维护处理程序（`asl/scalar/sys/TLB.IALL.asl:18`），而令牌 `Maintenance_TLB_IALL` 位于执行器的最后一个分支，推进 TLB 纪元且完全没有操作数测试（`asl/scalar/model/sys/semantics.asl:154`）。

`InstructionContractMaintenanceUsesOperand_TLB_IALL` 为 `FALSE`（`asl/scalar/sys/TLB.IALL.asl:36`），因此派发器传入 `Zeros{PTO_XLEN}`，不读取任何标量寄存器（`asl/scalar/model/dispatch/sys.asl:59`）。

环特权仍然适用：`InstructionContractMaintenanceRequiresRootRing_TLB_IALL` 返回 `TRUE`（`asl/scalar/sys/TLB.IALL.asl:42`）。

<!-- PTO-READER-BLOCK: scalar-tlb-iall-inputs-outputs role=inputs-outputs -->
## 输入与输出

没有编码操作数，也没有目的地。该 32 位形式的每一位都由单条目录记录固定，因此该指令无法被收窄到某个作用域、某个标识符或某个地址。

被记录的操作数为零，不向寄存器、临时队列或系统寄存器写入任何内容。

<!-- PTO-READER-BLOCK: scalar-tlb-iall-effects role=effects -->
## 架构效果

成功时 TLB 纪元递增一，`Maintenance_TLB_IALL` 与操作数零被写入维护记录（`asl/scalar/model/sys/semantics.asl:155`）。随后 `TPC` 前进 4 字节，即该 32 位形式的长度。

设计要点：所有条目的请求没有操作数需要校验，但特权检查仍然先运行。这使地址转换维护统一保持仅限管理者，因此非特权尝试甚至无法到达纪元推进那一步。

该指令不执行普通标量内存访问，也不定义地址转换表的内容。

<!-- PTO-READER-BLOCK: scalar-tlb-iall-constraints role=constraints -->
## 位置与拒绝边界

在活动 SYS 块体之外，该次尝试在处理程序之前引发 `Fault_BundleControl`。在块体内部，当前环不是 ACR0 会引发 `Fault_IllegalInstruction`，并且 TLB 纪元保持先前值，因为执行器在纪元推进之前就返回了（`asl/scalar/model/sys/semantics.asl:130`）。

没有保留编码，也没有操作数形状的拒绝，因为所有位都是固定的且不读取操作数。

<!-- PTO-READER-BLOCK: scalar-tlb-iall-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 ACR0，SYS 块体内部的 `tlb.iall` 把 TLB 纪元递增一，以操作数零记录 `Maintenance_TLB_IALL`，并把 `TPC` 推进 4 字节。同一条指令在 ACR1 会引发 `Fault_IllegalInstruction`，而另外三个纪元计数器在两种情况下都不受影响。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iall_32_0fb421b85c88 | L32 | 32 | 0x0030702b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractOperation_TLB_IALL()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractHandler_TLB_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IALL()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- This form has no operand; the semantic operand is the all-zero XLEN value.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.

## State effects

- Success records Maintenance_TLB_IALL and its exact operand token.
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

- tlb.iall
