<!-- GENERATED FROM: asl/scalar/model/bru/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/bru/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-BRU-SEMANTICS}

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
end;

func ExecuteSetCommitLogical(left: Word, right: Word, combine_or: boolean)
begin
    let logical_result = if combine_or then left OR right else left AND right;
    _CommitArgument = if IsZero(logical_result) then Zeros{PTO_XLEN}
                      else Zeros{PTO_XLEN} + 1;
    if _BundleActive then _BARG.taken = !IsZero(_CommitArgument); end;
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

func AddToPC(destination: Reg5Selector, halfword_offset: Word)
begin
    WriteScalarDestination(destination, ReadTPC() + LSL(halfword_offset, 1));
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
