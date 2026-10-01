<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.LTUI.asl -->
# HL.CMP.LTUI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.LTUI.asl`

HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-LTUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-purpose role=purpose -->
## HL.CMP.LTUI 的作用

`HL.CMP.LTUI` 用无符号小于比较一个标量寄存器与 `24` 位无符号立即数，并把结果写为 `1` 或 `0`。有符号对应形式是 `HL.CMP.LTI`。

设计要点：两侧都按无符号值读取，任何操作数都不会被当作负数，而无符号最大值就是最大的值。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-mechanism role=mechanism -->
## 无符号小于判定的执行方式

读取 `SrcL`，并把 `uimm24` 零扩展到 `PTO_XLEN`，因此该字段总是提供 `0` 到 `16777215` 的非负值。处理程序判定无符号小于，成立时产生 `1`，不成立时产生 `0`。

设计要点：无符号值永远不会小于 `0`，因此 `hl.cmp.ltui a0, 0` 对任何 `a0` 都写入 `0`。同一编码若属于 `HL.CMP.LTI` 则是在判断是否为负值。

设计要点：写入的字始终是 `1` 或 `0`，绝不是全 `1` 掩码，因此使用者可以直接把它加到计数器上、移位或判断，无需再做掩码。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-inputs-outputs role=inputs-outputs -->
## 操作数与目的编码

- `SrcL` 按 `Reg5` 源规则提供左操作数：编码 `0` 到 `23` 读取绝对 GPR，编码 `24` 到 `27` 读取 T 队列，编码 `28` 到 `31` 读取 U 队列。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `uimm24` 提供 `24` 位无符号边界，编码在两个 `12` 位片段中。

- `RegDst` 按普通 `Reg5` 规则选择目的：编码 `0` 到 `23` 指定绝对 GPR，编码 `24` 到 `29` 不写入任何位置，编码 `30` 压入 U 队列，编码 `31` 压入 T 队列。

设计要点：本形式没有右源修饰字段，因此没有 `.sw`、`.uw` 或 `.not` 写法。左操作数按读取值原样使用，唯一的变换是立即数的扩展。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-effects role=effects -->
## 效果与顺序

规范化的 `1` 或 `0` 通过所选目的写入，除此之外不写任何位置。由于处理程序不写 `TPC`，随后由分派边界让 `TPC` 前进 `6` 字节，即该 `48` 位形式的编码长度。

`HL.CMP.LTUI` 不是条件设置操作，因此不接触 `_CommitArgument`、`BARG.TAKEN` 或指令束条件标记，对它也没有条件指令束的放置要求。具有同一条件的关系型提交姊妹形式是 `HL.SETC.LTUI`。

处理程序不访问内存、不获取保留状态、不记录数值状态，因此一次被接受的执行所造成的架构差异只有目的字与前进后的 `TPC`。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-constraints role=constraints -->
## 合法性与故障顺序

该形式的固定位必须匹配，否则该编码不会译码为本指令，并引发 `Fault_IllegalInstruction`。没有保留字段值：全部 `32` 个 `RegDst` 编码以及 `24` 位立即数字段的所有取值都已分配。所选的 `SrcL` 编码也必须可用，因此指向无效项的 T 或 U 队列编码会引发同一故障。

设计要点：译码、源与目的检查都在读取操作数之前、写入目的之前完成，因此被拒绝的编码既不改变目的，也不改变 `TPC`。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `a0` 为 `0` 时，`hl.cmp.ltui a0, 1, ->a1` 写入 `1`。当 `a0` 持有 `0xFFFFFFFFFFFFFFFF` 时，同一编码写入 `0`，因为该字是无符号最大值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | HL48 | 48 | 0x00006055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_ltui_48_d12167277d58 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_ltui_48_d12167277d58 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_ltui_48_d12167277d58 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_ltui_48_d12167277d58 | uimm24 | 24 | 0–16777215 | none | none | 24-bit unsigned immediate | Encoded zero supplies numeric zero for the 24-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| uimm24 | 24-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.LTUI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.LTUI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_HL_CMP_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCompareResult_HL_CMP_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_CMP_LTUI(),
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

- HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}
