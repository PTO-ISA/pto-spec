<!-- GENERATED FROM: asl/scalar/sys/DC.ISW.asl -->
# DC.ISW

**Normative ASL source:** `asl/scalar/sys/DC.ISW.asl`

DC.ISW completes the data-cache set/way scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-ISW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-isw-purpose role=purpose -->
## DC.ISW 的作用

`DC.ISW` 执行数据缓存 set/way 作用域令牌维护操作并同步完成。令牌来自唯一的源操作数 `SrcL`（`asl/scalar/sys/DC.ISW.asl:29`），该指令对它做快照并记录。

<!-- PTO-READER-BLOCK: scalar-dc-isw-mechanism role=mechanism -->
## 系统机制

该指令绑定到维护处理程序（`asl/scalar/sys/DC.ISW.asl:11`），也绑定到 `Maintenance_DC_ISW`（`asl/scalar/sys/DC.ISW.asl:23`）。执行器的特权表把该令牌视为缓存操作，其操作表把它归入推进 `_DataCacheEpoch` 的数据缓存组（`asl/scalar/model/sys/semantics.asl:134`）。

`DC.ISW` 是活动 SYS 块体中的一个标量操作。强制这一点的适用性规则读取的是活动 bundle 及其块种类，而不是解码后的操作数（`asl/scalar/model/sys/semantics.asl:321`）。

<!-- PTO-READER-BLOCK: scalar-dc-isw-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。解码后的值在效果之前被捕获，并作为操作数传给执行器（`asl/scalar/model/dispatch/sys.asl:27`）。

没有目的地操作数，因此操作数值只发布到维护记录中。编码零选择架构零 GPR，它是可用的令牌值而不是省略。

<!-- PTO-READER-BLOCK: scalar-dc-isw-effects role=effects -->
## 架构效果

成功时 `_DataCacheEpoch` 递增一，维护记录被设为 `Maintenance_DC_ISW` 加上已捕获的操作数（`asl/scalar/model/sys/semantics.asl:137`）。随后 `TPC` 按指令长度前进，这一步来自派发器的成功尾部（`asl/scalar/model/dispatch/top-level.asl:56`）。

设计要点：纪元与记录是两个彼此独立的可观测项。纪元表示一次数据缓存维护步骤已完成；记录表示是哪个操作、由哪个令牌引起。只读纪元无法把 `DC.ISW` 与 `DC.CVA` 区分开。

该操作不伴随任何标量内存访问、寄存器写入或队列压入。

<!-- PTO-READER-BLOCK: scalar-dc-isw-constraints role=constraints -->
## 位置与拒绝边界

位置与编码在执行器被进入之前完成检查。在活动 SYS 块体之外的尝试会在活动块的 `TPC` 值处引发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:28`），记录与纪元保持不动。

环权限不约束 `DC.ISW`，因为只有 TLB 维护操作会拒绝非根环（`asl/scalar/model/sys/semantics.asl:121`）。被记录的令牌从不针对建模的 set 或 way 数量做边界检查。

<!-- PTO-READER-BLOCK: scalar-dc-isw-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内运行 `dc.isw SrcL`，源持有 0x21。该次尝试通过位置与编码检查，快照 0x21，把数据缓存纪元递增一，并使记录保持为 `Maintenance_DC_ISW` 与操作数 0x21。在任何访问环上运行同一序列都得到相同结果，因为该操作不受环限制。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.isw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_isw_32_7940273560b2 | L32 | 32 | 0x0040602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_isw_32_7940273560b2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_isw_32_7940273560b2 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.ISW.asl -->
```asl
readonly func InstructionContractOperation_DC_ISW()
    => ScalarOperation
begin
    return ScalarOperation_DC_ISW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.ISW executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.ISW.asl -->
```asl
readonly func InstructionContractHandler_DC_ISW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_ISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_ISW()
    => MaintenanceOperation
begin
    return Maintenance_DC_ISW;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_ISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_ISW()
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

- Success records Maintenance_DC_ISW and its exact operand token.
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

- dc.isw SrcL
