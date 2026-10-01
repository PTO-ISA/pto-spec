<!-- GENERATED FROM: asl/scalar/sys/FENCE.I.asl -->
# FENCE.I

**Normative ASL source:** `asl/scalar/sys/FENCE.I.asl`

FENCE.I establishes instruction visibility, invalidates the reservation, and advances the instruction-cache epoch.

## Normative identity {#PTO-INST-SCALAR-FENCE-I}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fence-i-purpose role=purpose -->
## FENCE.I 的作用

`FENCE.I` 是指令可见性屏障。它没有操作数、没有掩码、也没有目的地：整个 32 位形式都是固定的，该指令的全部职责就是让指令缓存纪元前进并清除本地保留。

<!-- PTO-READER-BLOCK: scalar-fence-i-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_FENCE_I` 选择 `ScalarHandler_FenceInstruction`（`asl/scalar/sys/FENCE.I.asl:18`），且 `InstructionContractFenceInvalidatesReservation_FENCE_I` 与 `InstructionContractAdvancesInstructionEpoch_FENCE_I` 都返回 `TRUE`（`asl/scalar/sys/FENCE.I.asl:30`）。`FenceInstruction` 恰好实现这两步，其 ASL 注释指出可执行字节数组模型本就具有一致的指令与数据存储，因此是指令缓存纪元把架构可见性点显式化（`asl/scalar/model/sys/semantics.asl:83`）。

与其他 SYS 块指令一样，该指令要求活动 SYS 块的块体。

<!-- PTO-READER-BLOCK: scalar-fence-i-inputs-outputs role=inputs-outputs -->
## 输入与输出

完全没有编码操作数。该形式的每一位都是固定的，因此无法改变任何选择器、掩码或立即数，该指令也无法用来指名比整个指令流更窄的作用域。

`FENCE.I` 不写目的地寄存器、临时队列项或系统寄存器。它唯一的输出是保留状态与指令缓存纪元。

<!-- PTO-READER-BLOCK: scalar-fence-i-effects role=effects -->
## 架构效果

该指令清除本地保留，即后续 `StoreConditional` 成功所需的 `_ReservationValid` 状态（`asl/scalar/model/amo/semantics.asl:93`），并恰好把指令缓存纪元递增一。随后它为该 32 位形式把 `TPC` 推进 4 字节。

设计要点：`FENCE.I` 不带掩码，因此它的效果是无条件的，而 `fence.d` 的效果是有条件的。不存在让指令缓存纪元保持不变的 `fence.i` 编码，也不存在总是推进它的 `fence.d` 编码。

该指令不发出数据内存事件，也不执行普通标量内存访问，因此不改变任何内存位置。针对数据访问的排序由 `FENCE.D` 负责。

<!-- PTO-READER-BLOCK: scalar-fence-i-constraints role=constraints -->
## 位置与拒绝边界

唯一可用的拒绝是位置。在活动 SYS 块体之外的尝试会引发 `Fault_BundleControl` 并在处理程序之前返回，因此保留仍然有效、纪元保持原值。没有保留编码可拒绝，因为所有位都是固定的，也没有操作数需要校验。

不需要任何访问环。维护路径中的环限制属于四个 TLB 操作，而 `FENCE.I` 根本不使用那条路径。

<!-- PTO-READER-BLOCK: scalar-fence-i-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内执行 `fence.i`。保留被清除，指令缓存纪元递增一，`TPC` 继续前进 4 字节。在 Standard 块体中的尝试则会引发 `Fault_BundleControl`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fence.i
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fence_i_32_a321a2a186b1 | L32 | 32 | 0x1000202b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractOperation_FENCE_I()
    => ScalarOperation
begin
    return ScalarOperation_FENCE_I;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
FENCE.I executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractHandler_FENCE_I()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FenceInstruction;
end;

pure func InstructionContractRequiresSystemBlock_FENCE_I()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFenceInvalidatesReservation_FENCE_I()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAdvancesInstructionEpoch_FENCE_I()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no operand or mask field.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.

## State effects

- Invalidate the local reservation, advance the instruction-cache epoch exactly once, and advance TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before architectural effects.
- Invalidate the local reservation and advance the instruction-cache epoch exactly once; FENCE.I emits no data-memory event.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- fence.i
