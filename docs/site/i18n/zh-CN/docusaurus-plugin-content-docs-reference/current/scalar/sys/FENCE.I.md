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

`FENCE.I` 建立指令可见性，同时使本地保留失效。

<!-- PTO-READER-BLOCK: scalar-fence-i-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_FenceInstruction`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-fence-i-inputs-outputs role=inputs-outputs -->
## 输入与输出

该编码没有显式操作数字段；操作完全由固定指令位选择。

<!-- PTO-READER-BLOCK: scalar-fence-i-effects role=effects -->
## 架构效果

完成时，本地保留失效，指令缓存纪元恰好递增一次，随后 `TPC` 前进。

`FENCE.I` 不发出数据内存事件；其效果是建立指令可见性并使保留失效。

<!-- PTO-READER-BLOCK: scalar-fence-i-constraints role=constraints -->
## 位置与拒绝边界

该指令没有操作数字段；位置与固定指令位合法性检查先于所有效果。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-fence-i-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `fence.i` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
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
