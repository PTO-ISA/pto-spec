<!-- GENERATED FROM: asl/scalar/sys/DC.IVA.asl -->
# DC.IVA

**Normative ASL source:** `asl/scalar/sys/DC.IVA.asl`

DC.IVA completes the data-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-iva-purpose role=purpose -->
## DC.IVA 的作用

`DC.IVA` 是按虚拟地址清洗并使数据缓存失效的操作。地址位于唯一的 Reg5 源 `SrcL` 中，该指令在完成时记录操作令牌与该操作数（`asl/scalar/sys/DC.IVA.asl:23`）。

<!-- PTO-READER-BLOCK: scalar-dc-iva-mechanism role=mechanism -->
## 系统机制

DOC 区域把该指令绑定到 `ScalarHandler_ExecuteMaintenance`（`asl/scalar/sys/DC.IVA.asl:11`），操作令牌 `Maintenance_DC_IVA` 在执行器内选中数据缓存分支（`asl/scalar/model/sys/semantics.asl:134`）。派发器为该形式读取源寄存器，因为 `InstructionContractMaintenanceUsesOperand_DC_IVA` 为 `TRUE`（`asl/scalar/sys/DC.IVA.asl:29`）。

块位置是适用性规则的一部分：在操作数合法性被考虑之前，bundle 必须活动，且其块体必须是 System 块（`asl/scalar/model/sys/semantics.asl:321`）。

<!-- PTO-READER-BLOCK: scalar-dc-iva-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 接受 Reg5 源编码 R0..R23、T#1..T#4 和 U#1..U#4，并提供请求的虚拟地址。该指令没有目的地字段。

唯一的输出是维护记录项。`SrcL` 中的编码零命名架构零 GPR，因此零地址是通过指名该寄存器来表达的，而不是通过省略操作数。

<!-- PTO-READER-BLOCK: scalar-dc-iva-effects role=effects -->
## 架构效果

该次尝试推进一次数据缓存纪元，随后在未引发故障的前提下把 `Maintenance_DC_IVA` 与已快照的操作数写入维护记录（`asl/scalar/model/sys/semantics.asl:156`）。`TPC` 在该次尝试报告成功后前进（`asl/scalar/model/dispatch/top-level.asl:56`）。

地址被记录而不是被使用：`DC.IVA` 不执行普通标量内存访问，因此随后对同一虚拟地址的加载或存储看到的是未变的内存。不写任何寄存器、临时队列或系统寄存器。

<!-- PTO-READER-BLOCK: scalar-dc-iva-constraints role=constraints -->
## 位置与拒绝边界

在活动 SYS 块体之外的尝试会在处理程序之前引发 `Fault_BundleControl`，因此纪元和记录都不被修改。在块体内部，固定位与 `SrcL` 选择器在执行器运行之前完成校验。

`DC.IVA` 不施加环门，也不施加地址形状门。数据缓存操作在每个 ACR 都允许，而规范地址测试只属于 TLB 操作（`asl/scalar/model/sys/semantics.asl:115`）。即使操作数带高位，也会被记录而不是被拒绝。

设计要点：同一个处理程序同时服务基于地址和基于令牌的数据缓存请求。把调用方的操作数原样保留在记录里，正是事后能够区分这两类请求的原因。

<!-- PTO-READER-BLOCK: scalar-dc-iva-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 GPR 持有 0x1234 时，SYS 块体内部的 `dc.iva SrcL` 会快照 0x1234，把数据缓存纪元递增一，并以操作数 0x1234 记录 `Maintenance_DC_IVA`。像 0xffff000000001234 这样的操作数会被同一路径接受并原样记录，因为只有 TLB 操作会测试地址规范性。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iva_32_0131d0cf364f | L32 | 32 | 0x0000602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_iva_32_0131d0cf364f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_iva_32_0131d0cf364f | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IVA.asl -->
```asl
readonly func InstructionContractOperation_DC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IVA.asl -->
```asl
readonly func InstructionContractHandler_DC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_IVA()
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

- Success records Maintenance_DC_IVA and its exact operand token.
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

- dc.iva SrcL
