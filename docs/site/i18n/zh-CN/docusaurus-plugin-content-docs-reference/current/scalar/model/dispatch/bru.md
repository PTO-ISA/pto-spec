<!-- GENERATED FROM: asl/scalar/model/dispatch/bru.asl -->
# BRU

**Normative ASL source:** `asl/scalar/model/dispatch/bru.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-BRU}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-purpose role=purpose-scope -->
## 用途与范围

本单元执行每个已译码的标量分支单元形式：比较（`CMP.*`、`C.CMP.*`）、提交条件设置指令（`SETC.*`、`C.SETC.*`）、跳转（`J`、`JR`），以及 PC 相对辅助形式（`ADDTPC`、`SETRET` 及其 `HL` 形式）。

`ExecuteDecodedBRUForm` 按运算分支，选取立即数字段，并调用[BRU 语义](../bru/semantics.md)中的辅助函数。`ScalarConditionForOperation` 把每个关系比较或设置指令助记符映射为一个 `ScalarCondition`：EQ、NE、LT、GE、LTU 或 GEU。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-concepts role=concepts-state -->
## 概念与可见状态

对于比较和设置指令形式，立即数字段由助记符决定：

| 形式 | 字段 |
| --- | --- |
| 有符号 32 位形式，例如 `CMP.LTI`、`SETC.EQI`、`CMP.ANDI` | `simm12` |
| 无符号 32 位形式 `CMP.LTUI`、`CMP.GEUI`、`SETC.LTUI`、`SETC.GEUI` | `uimm12` |
| 有符号 48 位 `HL` 形式 | `simm24` |
| 无符号 48 位 `HL` 形式 | `uimm24` |
| `C.CMP.EQI`、`C.CMP.NEI` | `simm5` |

有符号字段符号扩展、无符号字段零扩展到 64 位。

寄存器比较的右操作数可以带 `SrcRType` 修饰符。关系比较和设置指令使用 `ApplyRestrictedCompareModifier`，因此原始 `11` 表示不变。逻辑形式 `CMP.AND`、`CMP.OR`、`SETC.AND` 和 `SETC.OR` 使用 `logical_family` 为 TRUE 的完整修饰符，因此原始 `11` 执行按位 NOT。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-rules role=rules-interactions -->
## 规则与交互

比较形式按 Reg5 目标规则写入字 0 或 1。设置指令形式写入 `_CommitArgument`，并在指令束内写入 `_BARG.taken`。

立即数 `SETC.*` 形式在比较之前把扩展后的立即数左移已译码的 `shamt` 位。立即数 `CMP.*` 形式不移位。

设计要点：只有设置指令会移位其立即数。因此同样的 12 位或 24 位字段在 `SETC.*` 形式中能表示的常数范围比对应的 `CMP.*` 形式更宽。移位是普通的 64 位运算；移出的位会丢失。

`C.CMP.EQI` 和 `C.CMP.NEI` 以 T#1 作为左操作数，并把结果压入 T（选择子 31）。原 T#1 变为 T#2。

`J` 把 `simm22` 中的半字偏移加到 TPC 上。`JR` 读取 `SrcL`，加上左移 1 位的 `simm12`，并在目标为奇数时产生故障。

`ADDTPC` 和 `HL.ADDTPC` 对 `imm20` 或 `imm32` 做符号扩展，左移 12 位后加到 TPC 上。`SETRET` 和 `HL.SETRET` 对 `imm20` 或 `imm32` 做零扩展，把 TPC 加上该值左移 1 位的结果写入 GPR 10 和 `_ReturnAddress`。

设计要点：`SETRET` 写成具有固定目标的独立形式。更宽的 `ADDTPC` 和 `HL.ADDTPC` 编码排除 `RegDst == 10`，顶层分派列出的三处经审查的重叠中有两处把该位置交给 `SETRET` 和 `HL.SETRET`；第三处把 `C.MOVI` 的位置交给由 ALU 分派执行的 `C.SETRET`。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-boundaries role=boundaries -->
## 架构边界

设置指令能否在当前指令束中执行，由顶层分派中的 `ScalarOperationApplicable` 更早检查。它要求存在活动的条件指令束体且其条件尚未设置；否则指令在设置指令执行之前引发 `Fault_BundleControl`；只保留顶层分派所做的指令束体进入转换。

此处只有 `J` 和 `JR` 安装 TPC；其他 BRU 形式在成功后由顶层分派推进 TPC。

`ScalarImplicitSourceOperandsLegal` 为 `C.SDI`、`C.SLLI`、`C.SRLI` 和 `C.SWI` 检查 T#1 的可用性。它没有列出 `C.CMP.EQI` 或 `C.CMP.NEI`。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-example role=example-usage -->
## 非规范阅读示例

取 32 位字 0xFFF1C275。它匹配 `SETC.LTI`（掩码 0x707F，匹配值 0x4075）。

| 字段 | 位 | 原始值 | 值 |
| --- | --- | --- | --- |
| `shamt` | 11:7 | 4 | 移位 4 |
| `SrcL` | 19:15 | 3 | GPR 3 |
| `simm12` | 31:20 | 0xFFF | -1 |

右操作数为 -1 左移 4 位，即 -16。若 GPR 3 持有 -20，有符号测试 `-20 < -16` 为真。`_CommitArgument` 变为 1，`_BARG.taken` 变为 TRUE，`_BundleConditionSet` 变为 TRUE。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-related role=related-owners-navigation -->
## 相关所有者

- [BRU 语义](../bru/semantics.md)拥有条件、设置指令、跳转和 PC 相对辅助函数。
- [标量译码辅助函数](decode.md)拥有比较修饰符表。
- [SYS 语义](../sys/semantics.md)拥有 `ScalarOperationApplicable`。
- [标量顶层分派](top-level.md)拥有 TPC 推进和经审查的编码重叠。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/bru.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-BRU","surface":"scalar","classification":["model","dispatch","bru"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-BRU-SEMANTICS","PTO-SCALAR-ADDTPC","PTO-SCALAR-C-CMP-EQI","PTO-SCALAR-C-CMP-NEI","PTO-SCALAR-C-SETC-EQ","PTO-SCALAR-C-SETC-NE","PTO-SCALAR-CMP-AND","PTO-SCALAR-CMP-ANDI","PTO-SCALAR-CMP-EQ","PTO-SCALAR-CMP-EQI","PTO-SCALAR-CMP-GE","PTO-SCALAR-CMP-GEI","PTO-SCALAR-CMP-GEU","PTO-SCALAR-CMP-GEUI","PTO-SCALAR-CMP-LT","PTO-SCALAR-CMP-LTI","PTO-SCALAR-CMP-LTU","PTO-SCALAR-CMP-LTUI","PTO-SCALAR-CMP-NE","PTO-SCALAR-CMP-NEI","PTO-SCALAR-CMP-OR","PTO-SCALAR-CMP-ORI","PTO-SCALAR-HL-ADDTPC","PTO-SCALAR-HL-CMP-ANDI","PTO-SCALAR-HL-CMP-EQI","PTO-SCALAR-HL-CMP-GEI","PTO-SCALAR-HL-CMP-GEUI","PTO-SCALAR-HL-CMP-LTI","PTO-SCALAR-HL-CMP-LTUI","PTO-SCALAR-HL-CMP-NEI","PTO-SCALAR-HL-CMP-ORI","PTO-SCALAR-HL-SETC-ANDI","PTO-SCALAR-HL-SETC-EQI","PTO-SCALAR-HL-SETC-GEI","PTO-SCALAR-HL-SETC-GEUI","PTO-SCALAR-HL-SETC-LTI","PTO-SCALAR-HL-SETC-LTUI","PTO-SCALAR-HL-SETC-NEI","PTO-SCALAR-HL-SETC-ORI","PTO-SCALAR-HL-SETRET","PTO-SCALAR-J","PTO-SCALAR-JR","PTO-SCALAR-SETC-AND","PTO-SCALAR-SETC-ANDI","PTO-SCALAR-SETC-EQ","PTO-SCALAR-SETC-EQI","PTO-SCALAR-SETC-GE","PTO-SCALAR-SETC-GEI","PTO-SCALAR-SETC-GEU","PTO-SCALAR-SETC-GEUI","PTO-SCALAR-SETC-LT","PTO-SCALAR-SETC-LTI","PTO-SCALAR-SETC-LTU","PTO-SCALAR-SETC-LTUI","PTO-SCALAR-SETC-NE","PTO-SCALAR-SETC-NEI","PTO-SCALAR-SETC-OR","PTO-SCALAR-SETC-ORI","PTO-SCALAR-SETRET"]}
pure func ScalarConditionForOperation(operation: ScalarOperation) => ScalarCondition
begin
    case operation of
        when ScalarOperation_C_CMP_EQI,
             ScalarOperation_C_SETC_EQ, ScalarOperation_CMP_EQ,
             ScalarOperation_CMP_EQI, ScalarOperation_HL_CMP_EQI,
             ScalarOperation_HL_SETC_EQI, ScalarOperation_SETC_EQ,
             ScalarOperation_SETC_EQI => return ScalarCondition_EQ;
        when ScalarOperation_C_CMP_NEI,
             ScalarOperation_C_SETC_NE, ScalarOperation_CMP_NE,
             ScalarOperation_CMP_NEI, ScalarOperation_HL_CMP_NEI,
             ScalarOperation_HL_SETC_NEI, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_NEI => return ScalarCondition_NE;
        when ScalarOperation_CMP_LT,
             ScalarOperation_CMP_LTI, ScalarOperation_HL_CMP_LTI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_SETC_LT,
             ScalarOperation_SETC_LTI => return ScalarCondition_LT;
        when ScalarOperation_CMP_GE,
             ScalarOperation_CMP_GEI, ScalarOperation_HL_CMP_GEI,
             ScalarOperation_HL_SETC_GEI, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_GEI => return ScalarCondition_GE;
        when ScalarOperation_CMP_LTU,
             ScalarOperation_CMP_LTUI, ScalarOperation_HL_CMP_LTUI,
             ScalarOperation_HL_SETC_LTUI, ScalarOperation_SETC_LTU,
             ScalarOperation_SETC_LTUI => return ScalarCondition_LTU;
        when ScalarOperation_CMP_GEU,
             ScalarOperation_CMP_GEUI, ScalarOperation_HL_CMP_GEUI,
             ScalarOperation_HL_SETC_GEUI, ScalarOperation_SETC_GEU,
             ScalarOperation_SETC_GEUI => return ScalarCondition_GEU;
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedCompareRegister(instruction: bits(48),
                                   form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                   operation: ScalarOperation)
begin
    let right = ApplyRestrictedCompareModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form));
    ExecuteCompare(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), right);
end;

func ExecuteDecodedCompareImmediate(instruction: bits(48),
                                    form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                    operation: ScalarOperation,
                                    immediate_field: ScalarOperandField)
begin
    ExecuteCompare(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedWord(instruction, form, immediate_field));
end;

func ExecuteDecodedCompareLogicalRegister(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    combine_or: boolean)
begin
    let right = ApplyScalarRightModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form), TRUE);
    ExecuteCompareLogical(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        right, combine_or);
end;

func ExecuteDecodedCompareLogicalImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    immediate_field: ScalarOperandField, combine_or: boolean)
begin
    ExecuteCompareLogical(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedWord(instruction, form, immediate_field), combine_or);
end;

func ExecuteDecodedSetCommitRegister(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                     operation: ScalarOperation)
begin
    let right = ApplyRestrictedCompareModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form));
    ExecuteSetCommit(ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), right);
end;

func ExecuteDecodedSetCommitImmediate(instruction: bits(48),
                                      form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                      operation: ScalarOperation,
                                      immediate_field: ScalarOperandField)
begin
    let shifted_immediate = LSL(
        ScalarDecodedWord(instruction, form, immediate_field),
        ScalarDecodedUInt6(instruction, form, ScalarField_shamt));
    ExecuteSetCommit(ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        shifted_immediate);
end;

func ExecuteDecodedSetCommitLogicalRegister(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    combine_or: boolean)
begin
    let right = ApplyScalarRightModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form), TRUE);
    ExecuteSetCommitLogical(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        right, combine_or);
end;

func ExecuteDecodedSetCommitLogicalImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    immediate_field: ScalarOperandField, combine_or: boolean)
begin
    let shifted_immediate = LSL(
        ScalarDecodedWord(instruction, form, immediate_field),
        ScalarDecodedUInt6(instruction, form, ScalarField_shamt));
    ExecuteSetCommitLogical(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        shifted_immediate, combine_or);
end;

func ExecuteDecodedBRUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_CMP_EQ, ScalarOperation_CMP_NE,
             ScalarOperation_CMP_LT, ScalarOperation_CMP_GE,
             ScalarOperation_CMP_LTU, ScalarOperation_CMP_GEU =>
            ExecuteDecodedCompareRegister(instruction, form, operation);
        when ScalarOperation_CMP_EQI, ScalarOperation_CMP_NEI,
             ScalarOperation_CMP_LTI, ScalarOperation_CMP_GEI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_simm12);
        when ScalarOperation_CMP_LTUI, ScalarOperation_CMP_GEUI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_uimm12);
        when ScalarOperation_HL_CMP_EQI, ScalarOperation_HL_CMP_NEI,
             ScalarOperation_HL_CMP_LTI, ScalarOperation_HL_CMP_GEI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_simm24);
        when ScalarOperation_HL_CMP_LTUI, ScalarOperation_HL_CMP_GEUI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_uimm24);
        when ScalarOperation_CMP_AND =>
            ExecuteDecodedCompareLogicalRegister(instruction, form, FALSE);
        when ScalarOperation_CMP_OR =>
            ExecuteDecodedCompareLogicalRegister(instruction, form, TRUE);
        when ScalarOperation_CMP_ANDI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm12, FALSE);
        when ScalarOperation_CMP_ORI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm12, TRUE);
        when ScalarOperation_HL_CMP_ANDI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_CMP_ORI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm24, TRUE);

        when ScalarOperation_C_CMP_EQI, ScalarOperation_C_CMP_NEI =>
            ExecuteCompare(31, ScalarConditionForOperation(operation),
                ReadScalarRegisterOperand(24),
                ScalarDecodedWord(instruction, form, ScalarField_simm5));

        when ScalarOperation_SETC_EQ, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_LT, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_LTU, ScalarOperation_SETC_GEU =>
            ExecuteDecodedSetCommitRegister(instruction, form, operation);
        when ScalarOperation_SETC_EQI, ScalarOperation_SETC_NEI,
             ScalarOperation_SETC_LTI, ScalarOperation_SETC_GEI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_simm12);
        when ScalarOperation_SETC_LTUI, ScalarOperation_SETC_GEUI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_uimm12);
        when ScalarOperation_HL_SETC_EQI, ScalarOperation_HL_SETC_NEI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_HL_SETC_GEI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_simm24);
        when ScalarOperation_HL_SETC_LTUI, ScalarOperation_HL_SETC_GEUI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_uimm24);
        when ScalarOperation_SETC_AND =>
            ExecuteDecodedSetCommitLogicalRegister(instruction, form, FALSE);
        when ScalarOperation_SETC_OR =>
            ExecuteDecodedSetCommitLogicalRegister(instruction, form, TRUE);
        when ScalarOperation_SETC_ANDI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm12, FALSE);
        when ScalarOperation_SETC_ORI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm12, TRUE);
        when ScalarOperation_HL_SETC_ANDI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_SETC_ORI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm24, TRUE);
        when ScalarOperation_C_SETC_EQ, ScalarOperation_C_SETC_NE =>
            ExecuteSetCommit(ScalarConditionForOperation(operation),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR));

        when ScalarOperation_J =>
            JumpRelative(ScalarDecodedWord(instruction, form, ScalarField_simm22));
        when ScalarOperation_JR =>
            JumpRegister(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL) +
                LSL(ScalarDecodedWord(instruction, form, ScalarField_simm12), 1));

        when ScalarOperation_ADDTPC =>
            AddToPC(ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                SignExtend{PTO_XLEN}(
                    ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_ADDTPC =>
            AddToPC(ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                SignExtend{PTO_XLEN}(
                    ScalarDecodedBits32(instruction, form, ScalarField_imm32)));
        when ScalarOperation_SETRET =>
            SetReturnAddress(ZeroExtend{PTO_XLEN}(
                ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_SETRET =>
            SetReturnAddress(ZeroExtend{PTO_XLEN}(
                ScalarDecodedBits32(instruction, form, ScalarField_imm32)));
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
