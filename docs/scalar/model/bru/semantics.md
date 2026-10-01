<!-- GENERATED FROM: asl/scalar/model/bru/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/bru/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-BRU-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the value and control rules of the scalar branch unit (BRU): condition evaluation, comparisons that write 0 or 1, commit-condition setters (`SETC.*`), jumps, and PC-relative address formation.

[BRU dispatch](../dispatch/bru.md) reads the operands and calls these helpers; [ALU dispatch](../dispatch/alu.md) also calls `SetReturnAddress` for `C.SETRET`. Two helpers, `BranchRelative` and `ReadBranchPredicate`, have no caller in the ASL tree.

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-concepts role=concepts-state -->
## Concepts and visible state

`ConditionHolds` evaluates one `ScalarCondition` on two full 64-bit words:

| Condition | True when |
| --- | --- |
| `EQ`, `NE` | the bit patterns are equal or different |
| `LT`, `GE` | signed comparison |
| `LTU`, `GEU` | unsigned comparison |
| `Z`, `NZ` | the left word is zero or nonzero |

A canonical boolean word is 1 for true and 0 for false. Every comparison and commit condition in this unit produces one.

The commit argument `_CommitArgument` holds the canonical boolean written by the latest setter; `SetBundleArgument` and `SetBundleArgumentKind` also write it. The commit decision itself reads `_BARG.taken`. `_BundleConditionSet` records that a setter has run in the current bundle.

`ReadPC` and `ReadTPC` both return the same `_PC` register. TPC is the current instruction address.

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-rules role=rules-interactions -->
## Rules and interactions

`ExecuteCompare` and `ExecuteCompareLogical` write a canonical boolean through `WriteScalarDestination`. The logical variant combines the two words with AND or OR and tests the result for nonzero.

`ExecuteSetCommit` and `ExecuteSetCommitLogical` do not write a register. They store the canonical boolean in `_CommitArgument`, copy it to `_BARG.taken` when a bundle is active, and set `_BundleConditionSet`.

Design point: a `SETC.*` result goes to bundle state instead of a GPR, because the bundle commit reads `_BARG.taken` to choose between the target `BPCN` and the sequential continuation. The branch is resolved at the bundle boundary, not at the setter.

`JumpRelative` writes `TPC + (offset << 1)`. The offset counts halfwords, which matches the 16-bit instruction granule.

`JumpRegister` checks bit 0 of the target. An odd target raises `Fault_InstructionPC` with the target as the fault address and does not install the target. An even target is written directly.

Design point: the odd-target check is the only target check on `JR`. Instructions are halfword aligned, so an odd address can never start one. The fault is raised before any target is installed. `SetFault` saves the trap context with the current TPC, which is the address of the `JR` itself.

`SetReturnAddress` computes `TPC + (offset << 1)` and writes it to both GPR 10 (the return-address register Ra) and `_ReturnAddress`.

`AddToPC` computes `TPC + (page_offset << 12)` and writes it through the Reg5 destination rules. The shift of 12 makes the immediate count 4 KiB pages.

All arithmetic wraps modulo 2^64.

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-boundaries role=boundaries -->
## Architectural boundaries

Apart from the uncalled `BranchRelative`, which writes TPC + 4 when its condition is false, these helpers do not advance TPC. Scalar top-level dispatch advances TPC after success, except for the handlers that install a target themselves, such as `JumpRelative` and `JumpRegister`.

Whether a `SETC.*` may execute at all is decided earlier, by `ScalarOperationApplicable`. It requires an active conditional bundle body with no condition set yet.

The comment in `ReadBranchPredicate` states that P0 through P7 are a separate register file with no accepted PTO instruction consumer; `SETC.*` supplies the bundle predicate.

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-example role=example-usage -->
## Non-normative reading example

Assume TPC is 0x200.

- `JumpRelative` with offset -4 writes 0x200 + (-8) = 0x1F8.
- `SetReturnAddress` with offset 6 writes 0x20C to GPR 10 and to `_ReturnAddress`.
- `AddToPC` with page offset 1 writes 0x1200 to its destination.
- `JumpRegister` with target 0x301 raises `Fault_InstructionPC` at 0x301; the saved trap context records TPC 0x200.

`ExecuteSetCommit(ScalarCondition_LTU, 1, 0xFFFFFFFFFFFFFFFF)` sets `_CommitArgument` to 1, since 1 is below the unsigned maximum.

<!-- PTO-READER-BLOCK: scalar-model-bru-semantics-related role=related-owners-navigation -->
## Related owners

- [BRU dispatch](../dispatch/bru.md) maps BRU forms and immediates to these helpers.
- [Operation types](../types/operations.md) defines `ScalarCondition`.
- [BARG state](../../../block/model/state/barg.md) owns the commit-target selection (`BARGSelectsBPCN`, `BARGCommitPC`) that reads `_BARG.taken`; [control state](../../../block/model/state/control-state.md) declares `_BARG`.
- [Program counter](../../../arch/state/program-counter.md) owns `ReadPC`, `ReadTPC`, and `WritePC`.
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
