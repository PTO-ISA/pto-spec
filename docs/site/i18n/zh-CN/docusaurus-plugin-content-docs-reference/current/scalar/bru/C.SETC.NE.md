<!-- GENERATED FROM: asl/scalar/bru/C.SETC.NE.asl -->
# C.SETC.NE

**Normative ASL source:** `asl/scalar/bru/C.SETC.NE.asl`

C.SETC.NE - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-C-SETC-NE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setc-ne-purpose role=purpose -->
## C.SETC.NE 的作用

`C.SETC.NE` 比较两个标量源的不等，并把答案用作当前正在执行的 Conditional 块的提交条件。

它不产生寄存器值。它的结果是决策：指令束提交参数，以及块参数的 taken 位。

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-mechanism role=mechanism -->
## 机制

契约返回 `ScalarHandler_ExecuteSetCommit`，其条件为 `ScalarCondition_NE`。模型快照两个源，求值 `left != right`，把答案规范化为 XLEN `1` 或 `0`，并把这个值写入提交参数。

适用性检查早于任何源读取。`C.SETC.NE` 是提交条件设置指令，因此它只在以下情况运行：块处于活动状态、其块体处于活动状态、块的转移类型为 `Conditional`，且本块中此前没有其他设置指令成功过。

检查通过后，模型还会把规范答案复制到块参数的 taken 位，并把块条件标记为已设置。块参数的其他字段保持不变。

设计要点：设置指令标记是整个设置指令家族共享的单个块私有出现标志，因此一个 Conditional 块只能表达一个提交条件，无法让它依次依赖两次比较。

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 提供左侧标量源，`SrcR` 提供右侧标量源。两者都是完整的 `32` 路 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。

任一源编码为零时指向架构零 GPR，因此该指令可以把寄存器与零比较。

两个源都不会被消耗，因为它们都是按值读取，而不是按队列弹出读取。

没有目的字段。结果的唯一观察者是块的提交条件，以及之后读取块参数的任何东西。

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-effects role=effects -->
## 效果与排序

成功时一次更新同时覆盖提交参数、块参数的 taken 位和出现标记，随后 `TPC` 前进 `2` 字节，即 `16` 位形式的编码长度。

状态契约保留块的 `BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 字段。没有内存效果、没有保留效果、没有描述符效果、没有数值状态标志，也没有目的寄存器效果。

设计要点：提交参数本身承载的就是规范 XLEN `1` 或 `0`，与比较写入寄存器的形状相同。这正是后续消费者能用同一种测试方式读取指令束谓词和寄存器结果的原因。

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-constraints role=constraints -->
## 合法性与精确故障

块位置错误会在当前 `TPC` 处抛出 `Fault_BundleControl`：没有活动块、块体不活动、转移类型不是 `Conditional`，或者同一块中已有另一个设置指令成功之后又出现 `C.SETC.NE`。

该位置检查早于标量源就绪检查和任何源读取，因此位置错误的设置指令既不改动提交参数，也不改动出现标记。

固定位不匹配或被选中但不可用的 `T` 或 `U` 源会在提交状态、队列或 `TPC` 改变之前抛出 `Fault_IllegalInstruction`。失败的首次尝试不会消耗共享标记，因此该指令可以重新执行并仍然设置该条件。

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-example role=example -->
## 非规范示例

在一个 Conditional 块内，把 GPR1 设为 `5`，把 GPR2 设为 `5`。

`c.setc.ne 1, 2` 发现条件成立，因此提交参数变为 `0`，块的 taken 位变为`0`。

同一块中的第二条 `C.SETC.NE` 会以 `Fault_BundleControl` 被拒绝，而不是覆盖该决策。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setc.ne srcL, srcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_ne_16_e9092e487e98 | C16 | 16 | 0x0036 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_ne_16_e9092e487e98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_setc_ne_16_e9092e487e98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_ne_16_e9092e487e98 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| c_setc_ne_16_e9092e487e98 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.SETC.NE.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_NE() => ScalarOperation
begin
    return ScalarOperation_C_SETC_NE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.SETC.NE.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_C_SETC_NE()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCommitResult_C_SETC_NE(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_SETC_NE(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute C.SETC.NE's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
- Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.
- No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.
- Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker.

## Exceptions

- Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.
- A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects.

## Examples

- c.setc.ne srcL, srcR
