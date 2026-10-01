<!-- GENERATED FROM: asl/scalar/sys/BC.IVA.asl -->
# BC.IVA

**Normative ASL source:** `asl/scalar/sys/BC.IVA.asl`

BC.IVA completes the bundle-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-BC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bc-iva-purpose role=purpose -->
## BC.IVA 的作用

`BC.IVA` 是虚拟地址范围的指令束缓存维护操作。它作为 SYS 块的一个标量操作同步完成，并推进指令束缓存纪元。

它携带的地址就是范围令牌：它选择该维护作用于哪些表项。

<!-- PTO-READER-BLOCK: scalar-bc-iva-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

处理程序读取 `SrcL`，并以该值作为操作数运行 `Maintenance_BC_IVA` 操作的共享维护规则。该规则首先询问当前环是否允许该操作。

全部表项缓存范围属于本地提示，在每个环上都被允许；虚拟地址缓存范围属于同一类，因为只有翻译范围受到限制。因此规则推进指令束缓存纪元，并在成功时把该操作与它收到的操作数令牌一起记录。

设计要点：操作数被保留为记录下来的维护操作数，而不是被纪元更新消费掉。这使带地址的提示事后仍可检查：纪元说明指令束缓存维护已完成，而记录下来的令牌说明它指名的是哪个地址范围。

<!-- PTO-READER-BLOCK: scalar-bc-iva-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是提供范围令牌的源选择器。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，而该零是合法的范围令牌：操作不会因为令牌为零而被拒绝。
- 没有目的字段，因此该指令绝不写 GPR，也绝不压入 `T` 或 `U`。

<!-- PTO-READER-BLOCK: scalar-bc-iva-effects role=effects -->
## 架构效果

成功时恰好有一个纪元前进，对本操作而言是指令束缓存纪元。模型中存在一个数据缓存纪元、一个指令缓存纪元、一个指令束缓存纪元和一个 TLB 纪元，完成执行的维护操作恰好推进其中之一。

该指令不进行普通标量内存访问：它不加载、不存储、也不探测它携带的地址，因此指名未映射内存的令牌不会引发数据访问故障。成功时 `TPC` 前进 `4` 字节。不获取也不丢弃保留状态。

<!-- PTO-READER-BLOCK: scalar-bc-iva-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

虚拟地址缓存范围属于本地提示完成，因此维护权限规则在每个环上都接受它；环限制只适用于翻译维护。因此本形式可达的 `Fault_IllegalInstruction` 路径是放置检查与编码合法性检查，而不是环限制。

指名不可用 `T` 或 `U` 槽的源选择器会在维护规则运行之前被拒绝，因此这样的选择器绝不会推进任何纪元。

<!-- PTO-READER-BLOCK: scalar-bc-iva-example role=example -->
## 非规范示例

`bc.iva a0` 从 `a0` 读取范围令牌，把指令束缓存纪元推进一，把 `Maintenance_BC_IVA` 与该令牌一起记录，并让 `TPC` 前进 `4` 字节。如果源选择器不可用，则不推进任何纪元，指令改为被拒绝。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | L32 | 32 | 0x0000402b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractOperation_BC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_BC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractHandler_BC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_BC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_BC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_BC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_BC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_BC_IVA()
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

- Success records Maintenance_BC_IVA and its exact operand token.
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

- bc.iva SrcL
