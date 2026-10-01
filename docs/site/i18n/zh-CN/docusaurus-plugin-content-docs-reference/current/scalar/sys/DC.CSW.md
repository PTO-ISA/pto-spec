<!-- GENERATED FROM: asl/scalar/sys/DC.CSW.asl -->
# DC.CSW

**Normative ASL source:** `asl/scalar/sys/DC.CSW.asl`

DC.CSW completes the data-cache clean-by-set/way scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CSW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-csw-purpose role=purpose -->
## DC.CSW 的作用

`DC.CSW` 执行数据缓存 clean-by-set/way 作用域令牌维护操作并同步完成，因此该指令退休时该次尝试已经结束。它唯一的操作数 `SrcL` 携带标识本次请求作用域的令牌（`asl/scalar/sys/DC.CSW.asl:29`）。

<!-- PTO-READER-BLOCK: scalar-dc-csw-mechanism role=mechanism -->
## 系统机制

该指令绑定到共用的维护处理程序（`asl/scalar/sys/DC.CSW.asl:11`），也绑定到操作令牌 `Maintenance_DC_CSW`（`asl/scalar/sys/DC.CSW.asl:23`）。`ExecuteMaintenance` 用该令牌对照特权表和操作表，而 `Maintenance_DC_CSW` 分支属于推进 `_DataCacheEpoch` 的八个数据缓存分支之一（`asl/scalar/model/sys/semantics.asl:134`）。

这是一条 SYS 块指令。它的适用性规则要求 bundle 处于活动状态，且其块体的块种类为 `BundleKind_System`（`asl/scalar/model/sys/semantics.asl:321`）。

<!-- PTO-READER-BLOCK: scalar-dc-csw-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。派发器捕获解码后的寄存器值，并把它作为操作数交给执行器（`asl/scalar/model/dispatch/sys.asl:39`）。

`DC.CSW` 不写目的地。它记录该操作数而不是返回它，并且编码零是已分配的值，不是省略的操作数。

<!-- PTO-READER-BLOCK: scalar-dc-csw-effects role=effects -->
## 架构效果

在无故障的尝试中，数据缓存纪元递增一，维护记录被 `Maintenance_DC_CSW` 与操作数值覆盖。该记录的更新受执行器内部故障检查保护，因此发生故障的尝试不会改动它（`asl/scalar/model/sys/semantics.asl:156`）。

设计要点：指令完成被建模为一次纪元推进加上一个已记录的令牌。这样软件获得了一个已定义、可观测的完成点，同时不约束具体实现实际清洗多少缓存行。

`TPC` 在尝试报告成功后前进；该增量是一个指令长度，而不是一个纪元（`asl/scalar/model/dispatch/top-level.asl:56`）。

<!-- PTO-READER-BLOCK: scalar-dc-csw-constraints role=constraints -->
## 位置与拒绝边界

处于活动 SYS 块体之外的 `DC.CSW` 会在操作数合法性被评估之前以 `Fault_BundleControl` 拒绝，因此纪元和记录都不变。在块体内部，固定位与 `SrcL` 编码在执行器运行之前完成校验。

数据缓存维护没有环限制：除四个 TLB 操作之外，`MaintenanceAccessPermitted` 对每个操作都返回 `TRUE`（`asl/scalar/model/sys/semantics.asl:123`）。因此 `DC.CSW` 中不存在因环、地址或访问类别而触发的 `Fault_IllegalInstruction` 路径。

<!-- PTO-READER-BLOCK: scalar-dc-csw-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

从 SYS 块体执行 `dc.csw SrcL`，源寄存器持有令牌 7。位置与编码检查通过，寄存器被快照，数据缓存纪元递增一，随后维护记录显示 `Maintenance_DC_CSW` 与操作数 7。重复同一条指令会再次推进纪元，并用同一令牌改写记录。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.csw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_csw_32_2719115a9246 | L32 | 32 | 0x0050602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_csw_32_2719115a9246 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_csw_32_2719115a9246 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CSW.asl -->
```asl
readonly func InstructionContractOperation_DC_CSW()
    => ScalarOperation
begin
    return ScalarOperation_DC_CSW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CSW executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CSW.asl -->
```asl
readonly func InstructionContractHandler_DC_CSW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CSW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CSW()
    => MaintenanceOperation
begin
    return Maintenance_DC_CSW;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CSW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CSW()
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

- Success records Maintenance_DC_CSW and its exact operand token.
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

- dc.csw SrcL
