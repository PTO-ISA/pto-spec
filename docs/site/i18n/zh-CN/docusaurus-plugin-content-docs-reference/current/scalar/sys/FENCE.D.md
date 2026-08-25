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

`FENCE.D` 把前驱与后继访问类别掩码记录为一个数据屏障事件，使本地保留状态失效，并作为活动 SYS 指令束中的一条标量操作完成退役。

<!-- PTO-READER-BLOCK: scalar-fence-d-mechanism role=mechanism -->
## 屏障机制

`PRED_IMM` 和 `SUCC_IMM` 是两个独立的 4 位掩码。指令会把两个精确值都记录到架构屏障状态和发出的屏障事件中。

若任一掩码含有指令可见性位，`FENCE.D` 还会推进指令缓存纪元。

<!-- PTO-READER-BLOCK: scalar-fence-d-inputs role=inputs-outputs -->
## 输入与结果形态

两个掩码都接受 `0` 至 `15` 的全部 `16` 个编码值。编码零是已分配的全零掩码，并不表示省略操作数。

`FENCE.D` 没有 Reg5 源和标量目的位置；它的可见结果是排序事件与系统状态更新。

<!-- PTO-READER-BLOCK: scalar-fence-d-effects role=effects -->
## 效果与顺序

成功执行会使本地保留状态失效，记录两个掩码，为当前内存主体发出一个 acquire-release 屏障事件，并推进 `TPC`。

指令本身不加载或存储数据内存；它的排序效果由所发出屏障事件中的精确掩码表示。

<!-- PTO-READER-BLOCK: scalar-fence-d-constraints role=constraints -->
## 放置规则与故障边界

`FENCE.D` 仅在活动 SYS 指令束的指令束体（body）中合法。非法放置会在编码字段检查或效果之前引发非法指令束异常（Illegal Block Exception）。

固定编码位不匹配会在保留状态、屏障状态、事件、缓存纪元或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-fence-d-example role=example -->
## 非规范掩码示例

下面的示例只说明已分配的掩码值，并不替代规范屏障关系。

当两个掩码都为 `0` 时，`FENCE.D` 仍会使保留状态失效并发出一个屏障事件，但不会推进指令缓存纪元。当两个掩码都为 `15` 时，它会记录全一掩码，并因为指令可见性位存在而推进该纪元。
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
