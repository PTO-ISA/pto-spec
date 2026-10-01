<!-- GENERATED FROM: asl/scalar/sys/IC.IVA.asl -->
# IC.IVA

**Normative ASL source:** `asl/scalar/sys/IC.IVA.asl`

IC.IVA completes the instruction-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-IC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ic-iva-purpose role=purpose -->
## IC.IVA 的作用

`IC.IVA` 执行指令缓存虚拟地址作用域令牌维护操作并同步完成。作用域令牌来自唯一的源操作数 `SrcL`，该指令对它做捕获并记录（`asl/scalar/sys/IC.IVA.asl:29`）。

<!-- PTO-READER-BLOCK: scalar-ic-iva-mechanism role=mechanism -->
## 系统机制

该指令绑定到 `ScalarHandler_ExecuteMaintenance`（`asl/scalar/sys/IC.IVA.asl:11`），也绑定到令牌 `Maintenance_IC_IVA`（`asl/scalar/sys/IC.IVA.asl:23`）。在 `ExecuteMaintenance` 内部，该令牌选中指令缓存分支，它恰好推进一次 `_InstructionCacheEpoch`（`asl/scalar/model/sys/semantics.asl:138`）。

位置由适用性强制：bundle 必须活动且块体为 System 块，否则该次尝试会在操作数合法性之前停止（`asl/scalar/model/sys/semantics.asl:321`）。

<!-- PTO-READER-BLOCK: scalar-ic-iva-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 接受 Reg5 源编码 R0..R23、T#1..T#4 和 U#1..U#4，并提供请求的地址令牌。该指令没有目的地操作数，因此不向寄存器或队列发布结果。

编码零选择架构零 GPR。它是已分配的值，零令牌与其他令牌一样会被记录。

<!-- PTO-READER-BLOCK: scalar-ic-iva-effects role=effects -->
## 架构效果

在成功的尝试之后，指令缓存纪元增加一，维护记录显示 `Maintenance_IC_IVA` 与已快照的操作数（`asl/scalar/model/sys/semantics.asl:156`）。随后 `TPC` 按指令长度前进。

设计要点：令牌被记录而不是被做范围检查。可移植模型只暴露一个纪元与一条记录用于指令缓存维护，因此保留调用方作用域信息的正是被记录的操作数。

`IC.IVA` 不执行普通标量内存访问，自身也不使任何指令字节变得可见；纪元就是可观测点。不写任何寄存器、队列或系统寄存器。

<!-- PTO-READER-BLOCK: scalar-ic-iva-constraints role=constraints -->
## 位置与拒绝边界

效果之前有两道门。在活动 SYS 块体之外的尝试引发 `Fault_BundleControl` 并不触碰执行器就返回。在块体内部，固定位与 `SrcL` 选择器在处理程序运行之前完成校验。

指令缓存维护既没有环门，也没有规范地址要求。只有 `TLB.IV` 与 `TLB.IAV` 测试规范形式，也只有 TLB 操作需要 ring 0（`asl/scalar/model/sys/semantics.asl:115`）。

<!-- PTO-READER-BLOCK: scalar-ic-iva-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在源寄存器持有 0x1234 时，SYS 块体内部的 `ic.iva SrcL` 会快照 0x1234，把指令缓存纪元递增一，并以操作数 0x1234 记录 `Maintenance_IC_IVA`。同一条指令在任何访问环上执行行为相同，因为指令缓存维护不受环限制。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ic.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iva_32_11b9a61dd8b5 | L32 | 32 | 0x0000502b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ic_iva_32_11b9a61dd8b5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ic_iva_32_11b9a61dd8b5 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractOperation_IC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_IC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
IC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractHandler_IC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_IC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_IC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_IC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_IC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_IC_IVA()
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
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_IC_IVA and its exact operand token.
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

- ic.iva SrcL
