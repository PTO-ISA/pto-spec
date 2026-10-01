<!-- GENERATED FROM: asl/scalar/sys/BC.IALL.asl -->
# BC.IALL

**Normative ASL source:** `asl/scalar/sys/BC.IALL.asl`

BC.IALL completes the bundle-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-BC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bc-iall-purpose role=purpose -->
## BC.IALL 的作用

`BC.IALL` 是全部表项范围的指令束缓存维护操作。它作为 SYS 块的一个标量操作同步完成，并推进指令束缓存纪元。

它不携带地址：全部表项范围意味着每一个表项，因此没有任何东西需要编码。

<!-- PTO-READER-BLOCK: scalar-bc-iall-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

处理程序以全零操作数运行 `Maintenance_BC_IALL` 操作的共享维护规则。该规则首先询问当前环是否允许该操作。

全部表项缓存范围属于本地提示，在每个环上都被允许，因此对该操作而言权限测试不可能是失败的那一步。规则随后推进指令束缓存纪元。只有在没有引发故障时，它才把该操作及其操作数令牌记录为最近一次维护效果。

设计要点：纪元就是完成效果，而被记录的操作与操作数使该效果可审计。`CORE_STATE` 式模型状态的读者既能看出指令束缓存维护确实发生了，也能看出究竟是哪一个操作和操作数产生了它。

<!-- PTO-READER-BLOCK: scalar-bc-iall-inputs-outputs role=inputs-outputs -->
## 输入与输出

- 本形式没有操作数字段。语义操作数是全零 XLEN 值，并且它会被记录为最近一次维护操作数。
- 没有目的字段，因此该指令绝不写 GPR，也绝不压入 `T` 或 `U`。
- 不读取任何标量寄存器或队列表项。

<!-- PTO-READER-BLOCK: scalar-bc-iall-effects role=effects -->
## 架构效果

成功时恰好有一个纪元前进，对本操作而言是指令束缓存纪元。模型中存在一个数据缓存纪元、一个指令缓存纪元、一个指令束缓存纪元和一个 TLB 纪元，完成执行的维护操作恰好推进其中之一。

该指令不进行普通标量内存访问：它不加载、不存储、也不探测地址，并且不引发数据访问故障。成功时 `TPC` 前进 `4` 字节。不获取也不丢弃保留状态。

<!-- PTO-READER-BLOCK: scalar-bc-iall-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

由于全部表项缓存范围在每个环上都是本地提示完成，该操作绝不会被维护权限规则拒绝。因此本形式可达的 `Fault_IllegalInstruction` 路径是放置检查与编码合法性检查，而不是环限制。

该操作不携带地址，因此不适用任何地址规范性或地址范围检查。

<!-- PTO-READER-BLOCK: scalar-bc-iall-example role=example -->
## 非规范示例

`bc.iall` 把指令束缓存纪元推进一，把 `Maintenance_BC_IALL` 与零操作数令牌一起记录，并让 `TPC` 前进 `4` 字节。它不产生内存流量，也不触碰任何标量寄存器。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bc.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bc_iall_32_fdceb48516a8 | L32 | 32 | 0x0010402b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BC.IALL.asl -->
```asl
readonly func InstructionContractOperation_BC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_BC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BC.IALL.asl -->
```asl
readonly func InstructionContractHandler_BC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_BC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_BC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_BC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_BC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_BC_IALL()
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

- Success records Maintenance_BC_IALL and its exact operand token.
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

- bc.iall
