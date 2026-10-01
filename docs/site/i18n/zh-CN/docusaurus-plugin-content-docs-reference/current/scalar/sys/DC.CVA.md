<!-- GENERATED FROM: asl/scalar/sys/DC.CVA.asl -->
# DC.CVA

**Normative ASL source:** `asl/scalar/sys/DC.CVA.asl`

DC.CVA completes the data-cache clean-by-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-cva-purpose role=purpose -->
## DC.CVA 的作用

`DC.CVA` 是按地址清洗数据缓存的操作。它从 `SrcL` 取得要清洗的地址并同步完成请求，同时记录操作与确切的操作数令牌（`asl/scalar/sys/DC.CVA.asl:23`）。

<!-- PTO-READER-BLOCK: scalar-dc-cva-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_DC_CVA` 选择 `ScalarHandler_ExecuteMaintenance`，即整个缓存与地址转换维护组共用的那一个处理程序（`asl/scalar/sys/DC.CVA.asl:11`）。使这条指令与众不同的是它的操作令牌：`Maintenance_DC_CVA` 选中 `ExecuteMaintenance` 的数据缓存分支，该分支把 `_DataCacheEpoch` 递增一（`asl/scalar/model/sys/semantics.asl:135`）。

位置是机制的一部分，而不是事后补充。该指令只在活动 SYS 块体中适用，派发器会在流程到达处理程序之前拒绝其他一切情况（`asl/scalar/model/sys/semantics.asl:321`）。

<!-- PTO-READER-BLOCK: scalar-dc-cva-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 承载 Reg5 源，即 R0..R23、T#1..T#4 或 U#1..U#4 之一。由于 `DC.CVA` 是按地址清洗，该寄存器提供请求所用的地址。

该指令没有目的地操作数。它的输出是维护记录项，其中存入的是纪元推进之前捕获的操作数值。

<!-- PTO-READER-BLOCK: scalar-dc-cva-effects role=effects -->
## 架构效果

执行器递增数据缓存纪元，随后仅在未引发故障时把 `Maintenance_DC_CVA` 与操作数存入维护记录（`asl/scalar/model/sys/semantics.asl:156`）。派发器的公共尾部随后按指令长度推进 `TPC`（`asl/scalar/model/dispatch/top-level.asl:56`）。

该指令不执行普通标量内存访问。对同一地址的加载或存储不受影响，也不写任何目的地寄存器或临时队列。

设计要点：基于地址的维护请求被记录，而不是针对建模缓存执行，因此可观测的契约是纪元推进与已记录的令牌，而不是某个具体缓存行的状态。

<!-- PTO-READER-BLOCK: scalar-dc-cva-constraints role=constraints -->
## 位置与拒绝边界

位置优先：在活动 SYS 块体之外，该次尝试引发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:28`），不触碰任何执行器状态。编码合法性随后进行，覆盖固定位与 `SrcL` 选择器。

环权限在这里不构成约束。`MaintenanceAccessPermitted` 在每个 ACR 都允许数据缓存操作，并把 ring 0 保留给 TLB 操作（`asl/scalar/model/sys/semantics.asl:120`）。`SrcL` 中的地址同样不做范围检查，因为该操作不属于规范地址路径。

<!-- PTO-READER-BLOCK: scalar-dc-cva-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 GPR 持有 0x1234 时，SYS 块体内部的 `dc.cva SrcL` 会快照 0x1234，推进数据缓存纪元一次，并使维护记录保持为 `Maintenance_DC_CVA` 与操作数 0x1234。没有任何机制按地址规则校验 0x1234，也没有任何机制把该指令限制在特定环上。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.cva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_cva_32_166d5a076f0e | L32 | 32 | 0x0020602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_cva_32_166d5a076f0e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_cva_32_166d5a076f0e | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_CVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_CVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CVA()
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

- Success records Maintenance_DC_CVA and its exact operand token.
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

- dc.cva SrcL
