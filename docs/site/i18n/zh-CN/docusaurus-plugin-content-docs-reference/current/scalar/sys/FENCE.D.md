<!-- GENERATED FROM: asl/scalar/sys/FENCE.D.asl -->
# FENCE.D

**Normative ASL source:** `asl/scalar/sys/FENCE.D.asl`

FENCE.D records predecessor/successor ordering masks and invalidates the local reservation.

## Normative identity {#PTO-INST-SCALAR-FENCE-D}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fence-d-purpose role=purpose -->
## FENCE.D 的作用

`FENCE.D` 是带显式前驱与后继访问类别掩码的数据排序屏障。两个掩码都是编码中的 4 位立即数而不是寄存器，因此该屏障描述哪些类别的访问必须被排序，而不从标量寄存器堆读取任何操作数。

<!-- PTO-READER-BLOCK: scalar-fence-d-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_FENCE_D` 选择 `ScalarHandler_FenceData`（`asl/scalar/sys/FENCE.D.asl:18`），而 `InstructionContractFenceInvalidatesReservation_FENCE_D` 返回 `TRUE`（`asl/scalar/sys/FENCE.D.asl:36`）。派发器把 `PRED_IMM` 与 `SUCC_IMM` 解码为两个 4 位字段，并按该顺序传给 `FenceData`（`asl/scalar/model/dispatch/sys.asl:81`）。

`FenceData` 依次执行四步：清除本地保留，存入前驱掩码，存入后继掩码，然后测试两个掩码的第 3 位（`asl/scalar/model/sys/semantics.asl:72`）。

<!-- PTO-READER-BLOCK: scalar-fence-d-inputs role=inputs-outputs -->
## 输入与输出

`PRED_IMM` 是 4 位前驱访问类别掩码，`SUCC_IMM` 是 4 位后继掩码（`asl/scalar/sys/FENCE.D.asl:1`）。每个字段的全部十六个值都已分配，因此没有掩码值被保留，也没有字段是可选的。

`FENCE.D` 没有目的地操作数。它不读取任何寄存器，因此不从寄存器堆快照任何内容；编码零是已分配的掩码值，而不是省略的操作数。

<!-- PTO-READER-BLOCK: scalar-fence-d-effects role=effects -->
## 架构效果

该屏障清除本地保留，并把两个掩码记录为一个数据屏障事件。如果任一掩码的第 3 位被置位，指令缓存纪元也会递增一（`asl/scalar/model/sys/semantics.asl:77`）。随后 `TPC` 按指令长度前进，因为该处理程序不写自己的 `TPC`。

设计要点：纪元推进取决于编码中可见的那一位。因此任一位置掩码为 8 的屏障具有指令可见性副作用，而掩码为 1 与 1 的屏障没有；同一条编码指令的行为始终一致。

该指令没有内存效果：`memory_effects` 为 `none`，且 `FenceData` 不触碰内存。它也不写任何寄存器或临时队列。

<!-- PTO-READER-BLOCK: scalar-fence-d-constraints role=constraints -->
## 位置与拒绝边界

`FENCE.D` 在活动 SYS 块体中执行。在其他位置的尝试会在掩码被读取之前引发 `Fault_BundleControl`，因此保留、已记录的掩码以及指令缓存纪元都保持先前值。

由于每个 4 位掩码值都已分配，这些字段不存在保留编码的拒绝。该 32 位形式的固定位仍在处理程序运行之前完成校验，且该操作不受访问环限制。

<!-- PTO-READER-BLOCK: scalar-fence-d-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内运行 `fence.d 8, 1`。保留被清除，前驱掩码 8 与后继掩码 1 被记录为一个屏障事件；由于前驱掩码的第 3 位被置位，指令缓存纪元递增一。运行 `fence.d 1, 1` 会清除保留并记录掩码，且不改变纪元。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fence.d pred_imm, succ_imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fence_d_32_f4783f17d84d | L32 | 32 | 0x0000202b / 0xf00fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fence_d_32_f4783f17d84d | PRED_IMM | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |
| fence_d_32_f4783f17d84d | SUCC_IMM | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fence_d_32_f4783f17d84d | PRED_IMM | 4 | 0–15 | none | none | fence predecessor access-class mask | Encoded zero selects value zero of the fence predecessor access-class mask. |
| fence_d_32_f4783f17d84d | SUCC_IMM | 4 | 0–15 | none | none | fence successor access-class mask | Encoded zero selects value zero of the fence successor access-class mask. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| PRED_IMM | fence predecessor access-class mask |
| SUCC_IMM | fence successor access-class mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractOperation_FENCE_D()
    => ScalarOperation
begin
    return ScalarOperation_FENCE_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
FENCE.D executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.D.asl -->
```asl
readonly func InstructionContractHandler_FENCE_D()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FenceData;
end;

pure func InstructionContractRequiresSystemBlock_FENCE_D()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFenceMaskWidth_FENCE_D()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractFenceInvalidatesReservation_FENCE_D()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- All sixteen values of each four-bit predecessor and successor mask are assigned.

## State effects

- Invalidate the local reservation, record both masks, emit the fence event, and advance TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Record the exact predecessor and successor masks as one data-fence event.
- If either mask carries the instruction-visibility bit, advance the instruction-cache epoch.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- fence.d pred_imm, succ_imm
