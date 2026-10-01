<!-- GENERATED FROM: asl/scalar/sys/IC.IALL.asl -->
# IC.IALL

**Normative ASL source:** `asl/scalar/sys/IC.IALL.asl`

IC.IALL completes the instruction-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-IC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ic-iall-purpose role=purpose -->
## IC.IALL 的作用

`IC.IALL` 是指令缓存所有条目的作用域维护操作。它的编码没有操作数字段（`asl/scalar/sys/IC.IALL.asl:1`），契约规定其语义操作数是全零的 XLEN 值，而不是某个寄存器。

<!-- PTO-READER-BLOCK: scalar-ic-iall-mechanism role=mechanism -->
## 系统机制

该指令选择共用的维护处理程序（`asl/scalar/sys/IC.IALL.asl:11`）与令牌 `Maintenance_IC_IALL`（`asl/scalar/sys/IC.IALL.asl:23`）。`Maintenance_IC_IALL` 是执行器中两个指令缓存分支之一，因此它推进 `_InstructionCacheEpoch`，而不是数据缓存纪元（`asl/scalar/model/sys/semantics.asl:138`）。

由于 `InstructionContractMaintenanceUsesOperand_IC_IALL` 为 `FALSE`（`asl/scalar/sys/IC.IALL.asl:29`），派发器直接提供 `Zeros{PTO_XLEN}`，不读取任何标量寄存器（`asl/scalar/model/dispatch/sys.asl:46`）。

`IC.IALL` 只在活动 SYS 块体中适用（`asl/scalar/model/sys/semantics.asl:322`）。

<!-- PTO-READER-BLOCK: scalar-ic-iall-inputs-outputs role=inputs-outputs -->
## 输入与输出

没有编码操作数，也没有目的地。单条目录记录固定了该 32 位形式的每一位，因此该指令无法选择作用域、set 或 way。

被记录的操作数为零。不向寄存器、临时队列或系统寄存器写入任何内容。

<!-- PTO-READER-BLOCK: scalar-ic-iall-effects role=effects -->
## 架构效果

成功的尝试把指令缓存纪元递增一，并把 `Maintenance_IC_IALL` 与零操作数存入维护记录（`asl/scalar/model/sys/semantics.asl:159`）。随后 `TPC` 前进 4 字节，即该 32 位形式的长度（`asl/scalar/model/dispatch/top-level.asl:56`）。

设计要点：指令缓存纪元同时也是 `fence.i` 与 `FENCE.D` 可以推进的可见性点。把纪元与已记录的操作令牌配对，使记录的读者能够把所有条目的请求与按地址限定范围的请求区分开，即使两者移动的是同一个计数器。

数据内存、寄存器或队列状态都不改变。

<!-- PTO-READER-BLOCK: scalar-ic-iall-constraints role=constraints -->
## 位置与拒绝边界

只有位置能拒绝 `IC.IALL`：在活动 SYS 块体之外，派发器引发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:28`），执行器从不运行，因此纪元与记录保持先前值。所有位都是固定的，所以没有保留编码可拒绝。

指令缓存维护没有环限制：`MaintenanceAccessPermitted` 只把四个 TLB 操作限制在 ring 0（`asl/scalar/model/sys/semantics.asl:121`）。

<!-- PTO-READER-BLOCK: scalar-ic-iall-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内执行 `ic.iall`。该次尝试检查固定位，把指令缓存纪元递增一，以操作数零记录 `Maintenance_IC_IALL`，并给 `TPC` 加上 4 字节。数据缓存纪元与 TLB 纪元不受影响。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ic.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iall_32_854f0d4d906a | L32 | 32 | 0x0010502b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractOperation_IC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
IC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractHandler_IC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_IC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_IC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_IC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_IC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_IC_IALL()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- This form has no operand; the semantic operand is the all-zero XLEN value.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_IC_IALL and its exact operand token.
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

- ic.iall
