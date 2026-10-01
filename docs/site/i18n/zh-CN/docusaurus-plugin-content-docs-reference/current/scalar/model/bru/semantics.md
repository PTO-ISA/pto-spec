<!-- GENERATED FROM: asl/scalar/model/bru/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/bru/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-BRU-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-purpose role=purpose-scope -->
## 用途与范围

本单元定义标量分支单元（BRU）的取值与控制规则：条件求值、写入 0 或 1 的比较、提交条件设置指令（`SETC.*`）、跳转，以及 PC 相对地址形成。

[BRU 分派](../dispatch/bru.md)读取操作数并调用这些辅助函数；[ALU 分派](../dispatch/alu.md)也为 `C.SETRET` 调用 `SetReturnAddress`。其中 `BranchRelative` 和 `ReadBranchPredicate` 两个辅助函数在 ASL 树中没有调用者。

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-concepts role=concepts-state -->
## 概念与可见状态

`ConditionHolds` 在两个完整的 64 位字上求值一个 `ScalarCondition`：

| 条件 | 为真的情形 |
| --- | --- |
| `EQ`、`NE` | 位模式相等或不同 |
| `LT`、`GE` | 有符号比较 |
| `LTU`、`GEU` | 无符号比较 |
| `Z`、`NZ` | 左字为零或非零 |

规范布尔字在为真时为 1，为假时为 0。本单元中的每个比较和提交条件都产生这样的字。

提交参数 `_CommitArgument` 保存最近一次设置指令写入的规范布尔字；`SetBundleArgument` 和 `SetBundleArgumentKind` 也会写它。提交决策本身读取 `_BARG.taken`。`_BundleConditionSet` 记录当前指令束中已有设置指令执行过。

`ReadPC` 和 `ReadTPC` 返回同一个 `_PC` 寄存器。TPC 是当前指令地址。

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-rules role=rules-interactions -->
## 规则与交互

`ExecuteCompare` 和 `ExecuteCompareLogical` 通过 `WriteScalarDestination` 写入规范布尔字。逻辑变体用 AND 或 OR 组合两个字，并测试结果是否非零。

`ExecuteSetCommit` 和 `ExecuteSetCommitLogical` 不写寄存器。它们把规范布尔字存入 `_CommitArgument`，在指令束活动时把它复制到 `_BARG.taken`，并设置 `_BundleConditionSet`。

设计要点：`SETC.*` 的结果进入指令束状态而不是 GPR，因为指令束提交读取 `_BARG.taken` 来在目标 `BPCN` 与顺序后继之间选择。分支在指令束边界处决定，而不是在设置指令处。

`JumpRelative` 写入 `TPC + (offset << 1)`。偏移以半字计数，与 16 位指令粒度一致。

`JumpRegister` 检查目标的位 0。奇数目标引发 `Fault_InstructionPC`，以目标作为故障地址，并且不安装该目标。偶数目标直接写入。

设计要点：奇数目标检查是 `JR` 上唯一的目标检查。指令按半字对齐，因此奇数地址不可能是指令起点。故障在安装任何目标之前引发。`SetFault` 用当前 TPC 保存陷阱上下文，该 TPC 就是 `JR` 自身的地址。

`SetReturnAddress` 计算 `TPC + (offset << 1)`，并把它同时写入 GPR 10（返回地址寄存器 Ra）和 `_ReturnAddress`。

`AddToPC` 计算 `TPC + (page_offset << 12)`，并按 Reg5 目标规则写入。移位 12 使立即数以 4 KiB 页为单位计数。

所有算术按 2^64 取模回绕。

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-boundaries role=boundaries -->
## 架构边界

除没有调用者的 `BranchRelative`（条件为假时写入 TPC + 4）外，这些辅助函数不推进 TPC。标量顶层分派在成功后推进 TPC，但自行安装目标的处理函数除外，例如 `JumpRelative` 和 `JumpRegister`。

`SETC.*` 能否执行由更早的 `ScalarOperationApplicable` 决定。它要求存在活动的条件指令束体，且尚未设置条件。

`ReadBranchPredicate` 中的注释说明，P0 到 P7 是独立的寄存器文件，没有已接受的 PTO 指令使用者；指令束谓词由 `SETC.*` 提供。

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-example role=example-usage -->
## 非规范阅读示例

假设 TPC 为 0x200。

- 偏移为 -4 的 `JumpRelative` 写入 0x200 + (-8) = 0x1F8。
- 偏移为 6 的 `SetReturnAddress` 把 0x20C 写入 GPR 10 和 `_ReturnAddress`。
- 页偏移为 1 的 `AddToPC` 把 0x1200 写入其目标。
- 目标为 0x301 的 `JumpRegister` 在 0x301 引发 `Fault_InstructionPC`；保存的陷阱上下文记录 TPC 0x200。

`ExecuteSetCommit(ScalarCondition_LTU, 1, 0xFFFFFFFFFFFFFFFF)` 把 `_CommitArgument` 设为 1，因为 1 小于无符号最大值。

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-related role=related-owners-navigation -->
## 相关所有者

- [BRU 分派](../dispatch/bru.md)把 BRU 形式和立即数映射到这些辅助函数。
- [运算类型](../types/operations.md)定义 `ScalarCondition`。
- [BARG 状态](../../../block/model/state/barg.md)拥有读取 `_BARG.taken` 的提交目标选择（`BARGSelectsBPCN`、`BARGCommitPC`）；[控制状态](../../../block/model/state/control-state.md)声明 `_BARG`。
- [程序计数器](../../../arch/state/program-counter.md)拥有 `ReadPC`、`ReadTPC` 和 `WritePC`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/bru/semantics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-BRU-SEMANTICS","surface":"scalar","classification":["model","bru","semantics"],"depends_on":["PTO-SCALAR-MODEL-ALU-SEMANTICS"]}
// PTO-REQ-SCALAR-CONTROL-001: direct scalar comparison and control transfer.

pure func ConditionHolds(condition: ScalarCondition, left: Word, right: Word) => boolean
begin
    case condition of
        when ScalarCondition_EQ  => return left == right;
        when ScalarCondition_NE  => return left != right;
        when ScalarCondition_LT  => return SInt(left) < SInt(right);
        when ScalarCondition_GE  => return SInt(left) >= SInt(right);
        when ScalarCondition_LTU => return UInt(left) < UInt(right);
        when ScalarCondition_GEU => return UInt(left) >= UInt(right);
        when ScalarCondition_Z   => return IsZero(left);
        when ScalarCondition_NZ  => return !IsZero(left);
    end;
end;

readonly func ReadBranchPredicate() => Word
begin
    // SETC.* supplies the coupled-bundle predicate. P0..P7 are a distinct
    // register file and have no accepted PTO instruction consumer.
    return _CommitArgument;
end;

func BranchRelative(condition: ScalarCondition, left: Word, right: Word,
                    halfword_offset: Word)
begin
    let current_pc = ReadPC();
    if ConditionHolds(condition, left, right) then
        WritePC(current_pc + LSL(halfword_offset, 1));
    else
        WritePC(current_pc + 4);
    end;
end;

func JumpRegister(target: Word)
begin
    if target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    else
        WritePC(target);
    end;
end;

func ExecuteCompare(destination: Reg5Selector, condition: ScalarCondition,
                    left: Word, right: Word)
begin
    let result = if ConditionHolds(condition, left, right) then
        Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
    WriteScalarDestination(destination, result);
end;

func ExecuteCompareLogical(destination: Reg5Selector, left: Word,
                           right: Word, combine_or: boolean)
begin
    let logical_result = if combine_or then left OR right else left AND right;
    WriteScalarDestination(destination,
        if IsZero(logical_result) then Zeros{PTO_XLEN}
        else Zeros{PTO_XLEN} + 1);
end;

func ExecuteSetCommit(condition: ScalarCondition, left: Word, right: Word)
begin
    _CommitArgument = if ConditionHolds(condition, left, right) then
        Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
    if _BundleActive then _BARG.taken = !IsZero(_CommitArgument); end;
    _BundleConditionSet = TRUE;
end;

func ExecuteSetCommitLogical(left: Word, right: Word, combine_or: boolean)
begin
    let logical_result = if combine_or then left OR right else left AND right;
    _CommitArgument = if IsZero(logical_result) then Zeros{PTO_XLEN}
                      else Zeros{PTO_XLEN} + 1;
    if _BundleActive then _BARG.taken = !IsZero(_CommitArgument); end;
    _BundleConditionSet = TRUE;
end;

func SetReturnAddress(halfword_offset: Word)
begin
    let target = ReadTPC() + LSL(halfword_offset, 1);
    // SETRET's assembly destination is Ra (R10). The bundle-local return
    // address mirrors the same target for BSTART.RET and frame recovery.
    WriteGPR(10, target);
    _ReturnAddress = target;
end;

func JumpRelative(halfword_offset: Word)
begin
    WritePC(ReadPC() + LSL(halfword_offset, 1));
end;

func AddToPC(destination: Reg5Selector, page_offset: Word)
begin
    WriteScalarDestination(destination, ReadTPC() + LSL(page_offset, 12));
end;
```
<!-- GENERATED-ASL-END: unit -->
