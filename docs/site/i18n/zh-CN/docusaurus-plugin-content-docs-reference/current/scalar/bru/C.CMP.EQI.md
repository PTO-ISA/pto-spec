<!-- GENERATED FROM: asl/scalar/bru/C.CMP.EQI.asl -->
# C.CMP.EQI

**Normative ASL source:** `asl/scalar/bru/C.CMP.EQI.asl`

C.CMP.EQI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-C-CMP-EQI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-cmp-eqi-purpose role=purpose -->
## C.CMP.EQI 的作用

`C.CMP.EQI` 把 `T#1` 中的值与符号扩展后的 `5` 位立即数 `simm5` 比较，并把布尔相等结果压入 `T`。

它是紧凑比较指令：源和目的都由编码隐含，唯一被编码的操作数是立即数。

<!-- PTO-READER-BLOCK: scalar-c-cmp-eqi-mechanism role=mechanism -->
## 机制

契约返回 `ScalarHandler_ExecuteCompare`，其条件为 `ScalarCondition_EQ`。模型求值 `left == right`，并把答案转换为规范 XLEN 值：条件成立时为 `1`，不成立时为 `0`。

两个操作数都在队列写入之前被读取。左操作数由处理程序固定，而不是由编码字段给出：模型把寄存器编码 `24` 读作 `T#1`，即临时队列索引零，且不消耗它。右操作数是 `simm5`，从 `5` 位符号扩展到 XLEN。

目的也是固定的：寄存器编码 `31`，目的模型把它映射为向 `T` 队列的一次压入。模型读取隐含的 `T#1` 源时并不查询其队列有效标志，因此对读取空 `T` 队列并未定义任何故障：该要求是软件必须满足的架构前置条件，而不是可执行模型执行的检查。

设计要点：先读后压的顺序，正是同一个队列既能作源又能作结果载体的原因。压入把已有条目推向更老的索引，因此原本的 `T#1` 变成 `T#2`，新结果成为 `T#1`，而被比较的值早已被快照。

<!-- PTO-READER-BLOCK: scalar-c-cmp-eqi-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `simm5` 提供有符号的 `5` 位立即数，并符号扩展到 XLEN，因此 `-1` 以全一模式参与比较，而不是以 `31` 参与比较。
- 隐含的 `T#1` 提供左操作数；它被读取，但不被消耗。
- 结果作为新的 `T#1` 压入 `T`。

没有其他编码字段。特别地，既没有目的字段，也没有右源修饰位字段，因此 `C.CMP.EQI` 的操作数不能像寄存器形式比较的操作数那样做符号或零扩展。

`simm5` 编码为零时提供数值零，因此该指令可以拿源与零比较。

<!-- PTO-READER-BLOCK: scalar-c-cmp-eqi-effects role=effects -->
## 效果与排序

成功时该指令只写入一个队列条目，并让 `TPC` 前进 `2` 字节，即 `16` 位形式的编码长度。

它不读写内存，不改变保留状态，不更新指令束提交条件，也不记录数值状态标志。`C.CMP.EQI` 不是条件设置指令，因此它可以出现在任何接受普通标量指令的块位置中。

设计要点：结果是数据值，而不是提交决策。想要根据比较采取行动的程序，仍必须让它经过分支或某个提交条件设置指令。

<!-- PTO-READER-BLOCK: scalar-c-cmp-eqi-constraints role=constraints -->
## 合法性与故障顺序

`simm5` 的全部 `32` 个取值都已分配；没有保留立即数，因此保留编码检查没有可拒绝的对象。

检查顺序是先解码，再操作数合法性，最后是标量源可用性。操作数合法性只覆盖已编码字段，而该形式没有编码任何源选择子：寄存器编码 `24` 是写进处理程序的，不是写进指令的。因此没有可失败的源可用性检查，空 `T` 队列也不会以 `Fault_IllegalInstruction` 被拒绝。

因固定位不匹配而被拒绝的指令保持 `T` 队列内容及其压入顺序不变，陷入入口保存原始 `TPC`。

<!-- PTO-READER-BLOCK: scalar-c-cmp-eqi-example role=example -->
## 非规范示例

先用一条前置指令把 `7` 压入 `T`，于是 `T#1` 存放 `7`，并令 `C.CMP.EQI` 位于 `TPC = 4096`。

`c.cmp.eqi t#1, 7, ->t` 把 `7` 与 `7` 比较，发现条件成立，并把 `1` 压入 `T`。

随后的指令取自 `4096 + 2 = 4098`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.cmp.eqi t#1, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_cmp_eqi_16_e34367883ba1 | C16 | 16 | 0x002c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_cmp_eqi_16_e34367883ba1 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_cmp_eqi_16_e34367883ba1 | simm5 | 5 | 0–31 | none | none | 5-bit signed immediate | Encoded zero supplies numeric zero for the 5-bit signed immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm5 | 5-bit signed immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.EQI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_EQI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.EQI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_C_CMP_EQI()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCompareResult_C_CMP_EQI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_CMP_EQI(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- C.CMP.EQI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- c.cmp.eqi t#1, simm, ->t
