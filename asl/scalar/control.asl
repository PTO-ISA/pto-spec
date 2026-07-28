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

func ExecuteCompare(destination: GPRIndex, condition: ScalarCondition,
                    left: Word, right: Word)
begin
    let result = if ConditionHolds(condition, left, right) then
        Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
    WriteGPR(destination, result);
end;

func ExecuteCompareLogical(destination: GPRIndex, condition: ScalarCondition,
                           left: Word, right: Word, combine_or: boolean)
begin
    let old_value = ReadGPR(destination);
    let comparison = ConditionHolds(condition, left, right);
    let old_predicate = !IsZero(old_value);
    let result = if combine_or then old_predicate || comparison
                 else old_predicate && comparison;
    WriteGPR(destination, if result then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
end;

func ExecuteSetCommit(condition: ScalarCondition, left: Word, right: Word)
begin
    _CommitArgument = if ConditionHolds(condition, left, right) then
        Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
end;

func ExecuteSetCommitLogical(condition: ScalarCondition, left: Word,
                             right: Word, combine_or: boolean)
begin
    let comparison = ConditionHolds(condition, left, right);
    let old_predicate = !IsZero(_CommitArgument);
    let result = if combine_or then old_predicate || comparison
                 else old_predicate && comparison;
    _CommitArgument = if result then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
end;

func SetReturnAddress(halfword_offset: Word)
begin
    _ReturnAddress = ReadPC() + LSL(halfword_offset, 1);
end;

func JumpRelative(halfword_offset: Word)
begin
    WritePC(ReadPC() + LSL(halfword_offset, 1));
end;

func AddToPC(destination: GPRIndex, halfword_offset: Word)
begin
    WriteGPR(destination, ReadPC() + LSL(halfword_offset, 1));
end;
