<!-- GENERATED FROM: asl/scalar/sys/DC.CIVA.asl -->
# DC.CIVA

**Normative ASL source:** `asl/scalar/sys/DC.CIVA.asl`

DC.CIVA completes the data-cache clean-and-invalidate scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CIVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-civa-purpose role=purpose -->
## DC.CIVA 的作用

`DC.CIVA` 同步完成数据缓存 clean-and-invalidate 作用域令牌维护操作。在数据缓存这一组中它并不常见：操作数是作用域令牌而不是地址，该指令读取 `SrcL` 并记录它，但可移植模型从不把它解释为内存位置。

<!-- PTO-READER-BLOCK: scalar-dc-civa-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_DC_CIVA` 返回 `ScalarHandler_ExecuteMaintenance`（`asl/scalar/sys/DC.CIVA.asl:11`），而 `InstructionContractMaintenanceOperation_DC_CIVA` 把成功尝试所记录的令牌固定为 `Maintenance_DC_CIVA`（`asl/scalar/sys/DC.CIVA.asl:23`）。执行器本身是共用的：`ExecuteMaintenance` 按操作令牌分派，而 `Maintenance_DC_CIVA` 属于推进 `_DataCacheEpoch` 的数据缓存组（`asl/scalar/model/sys/semantics.asl:134`）。

与共用该处理程序的其他十五条指令一样，`DC.CIVA` 只在活动 SYS 块体内适用（`asl/scalar/model/sys/semantics.asl:322`）。

<!-- PTO-READER-BLOCK: scalar-dc-civa-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是唯一的编码操作数，即可从 R0..R23、T#1..T#4 或 U#1..U#4 中选取的 Reg5 源。`DC.CIVA` 没有目的地字段，因此没有寄存器或队列接收结果。

`SrcL` 中的编码零选择架构零 GPR。它是真实的操作数值，而不是省略标记。

<!-- PTO-READER-BLOCK: scalar-dc-civa-effects role=effects -->
## 架构效果

成功的尝试会恰好推进一次数据缓存纪元，并把 `Maintenance_DC_CIVA` 与操作数令牌存入维护记录。随后 `TPC` 前进，因为公共派发尾部只对报告成功的尝试推进它（`asl/scalar/model/dispatch/top-level.asl:55`）。

设计要点：只有在尝试仍未出错时才写入记录，因此被拒绝的 `DC.CIVA` 会让记录中此前的操作和操作数继续可见。读取该记录的代码因此看到的始终是最后一次真正完成的尝试。

架构状态的其他部分都不变。`DC.CIVA` 不执行普通标量内存访问，不写任何寄存器或队列，也不定义缓存内容。

<!-- PTO-READER-BLOCK: scalar-dc-civa-constraints role=constraints -->
## 位置与拒绝边界

有两道检查保护该效果。第一道是位置：在活动 SYS 块体之外，该次尝试引发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:28`），并在合法性检查之前就停止。第二道是编码合法性：固定位和 Reg5 编码在执行器被调用之前完成校验。

包括 `DC.CIVA` 在内的全部八个数据缓存操作在每个访问环都允许（`asl/scalar/model/sys/semantics.asl:115`）。只有四个 TLB 维护操作需要 ring 0，因此 `DC.CIVA` 在非根环上不会引发特权故障。

<!-- PTO-READER-BLOCK: scalar-dc-civa-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内执行 `dc.civa SrcL`。该次尝试检查位置与编码，把 `SrcL` 读入操作数，使数据缓存纪元递增一，并以该操作数记录 `Maintenance_DC_CIVA`。操作数本身从不进入内存系统。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.civa SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | L32 | 32 | 0x0030602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CIVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_CIVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CIVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CIVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CIVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CIVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_CIVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CIVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CIVA()
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

- Success records Maintenance_DC_CIVA and its exact operand token.
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

- dc.civa SrcL
