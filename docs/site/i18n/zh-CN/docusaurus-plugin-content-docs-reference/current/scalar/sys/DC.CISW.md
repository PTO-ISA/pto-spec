<!-- GENERATED FROM: asl/scalar/sys/DC.CISW.asl -->
# DC.CISW

**Normative ASL source:** `asl/scalar/sys/DC.CISW.asl`

DC.CISW completes the data-cache clean-and-invalidate set/way token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CISW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-cisw-purpose role=purpose -->
## DC.CISW 的作用

`DC.CISW` 同步完成数据缓存 clean-and-invalidate set/way 维护操作。该指令携带一个操作数 `SrcL`（`asl/scalar/sys/DC.CISW.asl:29`），由它提供维护记录所捕获的作用域令牌。

<!-- PTO-READER-BLOCK: scalar-dc-cisw-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_DC_CISW` 选择 `ScalarHandler_ExecuteMaintenance`（`asl/scalar/sys/DC.CISW.asl:11`），而 `InstructionContractMaintenanceOperation_DC_CISW` 把操作固定为 `Maintenance_DC_CISW`（`asl/scalar/sys/DC.CISW.asl:23`）。该处理程序与其他所有缓存、bundle 缓存和 TLB 维护指令共用，因此它们之间的差别只在于操作令牌和操作数规则。

该指令占用活动 SYS 块体中的一个标量操作位置（`asl/scalar/model/sys/semantics.asl:322`）。所有固定位和操作数约束都在合法性检查阶段完成，早于处理程序运行。

<!-- PTO-READER-BLOCK: scalar-dc-cisw-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。派发器通过 `ReadDecodedScalarRegister` 读取它，并把取到的值作为操作数传给执行器（`asl/scalar/model/dispatch/sys.asl:42`）。编码零命名架构零 GPR，因此它是已分配的值，从不表示省略操作数。

`DC.CISW` 不产生标量目的地。唯一的输出是维护记录。

<!-- PTO-READER-BLOCK: scalar-dc-cisw-effects role=effects -->
## 架构效果

成功时，维护记录接收 `Maintenance_DC_CISW` 和确切的操作数令牌（`asl/scalar/model/sys/semantics.asl:159`），同时数据缓存纪元递增一（`asl/scalar/model/sys/semantics.asl:137`）。随后 `TPC` 按指令长度前进，因为派发器只在执行报告成功之后才推进 `TPC`（`asl/scalar/model/dispatch/top-level.asl:55`）。

设计要点：操作数在纪元改变之前完成快照，因此被记录的令牌就是该指令读取时源所持有的值。之后对该源的写入无法改写日志中这条指令所请求的内容。

不执行普通标量内存访问，因此数据内存保持不变。

<!-- PTO-READER-BLOCK: scalar-dc-cisw-constraints role=constraints -->
## 位置与拒绝边界

先检查位置。如果 bundle 未活动，或其块体不是 System 块，该次尝试会在任何合法性检查之前引发 `Fault_BundleControl`，因此记录与数据缓存纪元保持原值。

缓存在每个 ACR 都允许维护；只有 TLB 操作被限制在 ring 0。因此 `DC.CISW` 没有特权门，具体实现的缓存内容也不由该指令定义。

设计要点：该操作发布的是操作令牌和纪元，而不是指名缓存行，因此 `SrcL` 中的作用域令牌被记录为证据，而不会被可移植模型解释为 set/way 索引。

<!-- PTO-READER-BLOCK: scalar-dc-cisw-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内运行 `dc.cisw SrcL`。如果源寄存器持有 10，该次尝试先通过位置与编码检查，再读取该寄存器作为操作数，然后推进数据缓存纪元，最后以操作数 10 记录 `Maintenance_DC_CISW`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.cisw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_cisw_32_166b7135e3c1 | L32 | 32 | 0x0060602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_cisw_32_166b7135e3c1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_cisw_32_166b7135e3c1 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CISW.asl -->
```asl
readonly func InstructionContractOperation_DC_CISW()
    => ScalarOperation
begin
    return ScalarOperation_DC_CISW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CISW executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CISW.asl -->
```asl
readonly func InstructionContractHandler_DC_CISW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CISW()
    => MaintenanceOperation
begin
    return Maintenance_DC_CISW;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CISW()
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

- Success records Maintenance_DC_CISW and its exact operand token.
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

- dc.cisw SrcL
