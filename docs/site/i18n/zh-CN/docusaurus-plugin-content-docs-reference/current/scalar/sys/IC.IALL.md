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

`IC.IALL` 同步完成所分配的缓存或地址翻译维护请求，并记录精确操作令牌。

<!-- PTO-READER-BLOCK: scalar-ic-iall-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ExecuteMaintenance`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-ic-iall-inputs-outputs role=inputs-outputs -->
## 输入与输出

该编码没有显式操作数字段；操作完全由固定指令位选择。

<!-- PTO-READER-BLOCK: scalar-ic-iall-effects role=effects -->
## 架构效果

成功时，维护记录接收 `Maintenance_IC_IALL` 和精确捕获的操作数令牌。

选中的缓存或 TLB 纪元恰好递增一次，然后 `TPC` 前进；该操作是同步完成的本地提示。

<!-- PTO-READER-BLOCK: scalar-ic-iall-constraints role=constraints -->
## 位置与拒绝边界

缓存维护在每个 ACR 都是同步本地提示，并不定义额外的实现缓存内容。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-ic-iall-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `ic.iall` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
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
