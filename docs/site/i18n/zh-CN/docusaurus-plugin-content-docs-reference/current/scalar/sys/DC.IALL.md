<!-- GENERATED FROM: asl/scalar/sys/DC.IALL.asl -->
# DC.IALL

**Normative ASL source:** `asl/scalar/sys/DC.IALL.asl`

DC.IALL completes the data-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-iall-purpose role=purpose -->
## DC.IALL 的作用

`DC.IALL` 是数据缓存所有条目的作用域维护操作。它完全消除了操作数问题：其编码是单一的固定 32 位形式，根本没有任何字段（`asl/scalar/sys/DC.IALL.asl:1`），因此语义操作数是全零的 XLEN 值。

<!-- PTO-READER-BLOCK: scalar-dc-iall-mechanism role=mechanism -->
## 系统机制

该指令选择共用的维护处理程序（`asl/scalar/sys/DC.IALL.asl:11`）与操作令牌 `Maintenance_DC_IALL`（`asl/scalar/sys/DC.IALL.asl:23`）。由于 `InstructionContractMaintenanceUsesOperand_DC_IALL` 返回 `FALSE`（`asl/scalar/sys/DC.IALL.asl:29`），派发器传入 `Zeros{PTO_XLEN}`，而不读取寄存器（`asl/scalar/model/dispatch/sys.asl:23`）。

这一行派发代码就是它与 `DC.IVA` 及其同类指令的实际差别：完全不读取标量寄存器，因此某个恰好为空的临时队列不会让这条指令变得非法。

该指令仍然需要活动 SYS 块体才适用（`asl/scalar/model/sys/semantics.asl:322`）。

<!-- PTO-READER-BLOCK: scalar-dc-iall-inputs-outputs role=inputs-outputs -->
## 输入与输出

没有编码操作数。单条目录记录的掩码 `0xffffffff` 没有留下任何可变位，因此每一个匹配该形式的 32 位字只表示一种含义。

被记录的操作数为零，该指令不写任何目的地寄存器，也不写任何临时队列项。

<!-- PTO-READER-BLOCK: scalar-dc-iall-effects role=effects -->
## 架构效果

成功的尝试把数据缓存纪元递增一（`asl/scalar/model/sys/semantics.asl:137`），并把 `Maintenance_DC_IALL` 连同零操作数存入维护记录（`asl/scalar/model/sys/semantics.asl:159`）。随后 `TPC` 前进 4 字节，即该 32 位形式的长度（`asl/scalar/model/dispatch/top-level.asl:56`）。

设计要点：所有条目的请求没有作用域令牌需要保存，但记录仍会被写入。因此该记录始终描述最近一次成功的维护操作，无论该操作是否有值得指名的操作数。

不发生普通标量内存访问，也不会向建模缓存装入数据或从其中移除数据。

<!-- PTO-READER-BLOCK: scalar-dc-iall-constraints role=constraints -->
## 位置与拒绝边界

唯一能到达该指令的拒绝路径是位置。在活动 SYS 块体之外，派发器引发 `Fault_BundleControl` 且从不调用执行器，因此记录与纪元保持先前值。

没有保留编码需要拒绝，因为每一位都是固定的。也没有环限制：`MaintenanceAccessPermitted` 在每个 ACR 都对数据缓存操作返回 `TRUE`（`asl/scalar/model/sys/semantics.asl:123`）。

<!-- PTO-READER-BLOCK: scalar-dc-iall-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内执行 `dc.iall`。该次尝试检查固定位，把数据缓存纪元递增一，以操作数零记录 `Maintenance_DC_IALL`，并把 `TPC` 推进 4 字节。在任何其他块种类中执行它，例如在 Standard 块体内，则会引发 `Fault_BundleControl`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iall_32_3d61563dd077 | L32 | 32 | 0x0010602b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractOperation_DC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_DC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractHandler_DC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_DC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_IALL()
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

- Success records Maintenance_DC_IALL and its exact operand token.
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

- dc.iall
