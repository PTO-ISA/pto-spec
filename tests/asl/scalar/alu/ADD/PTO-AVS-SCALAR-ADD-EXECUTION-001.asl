// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADD-EXECUTION-001","source":"asl/scalar/alu/ADD.asl","requirements":["PTO-INST-SCALAR-ADD"],"kind":"execution","summary":"migrated independent behavior point for TestScalarInteger","pass_condition":"TestScalarInteger completes without assertion failure","related_sources":[]}
func TestScalarInteger()
begin
    let max_word: Word = Ones{PTO_XLEN};
    assert ScalarBinary(ScalarBinary_ADD, max_word, Zeros{PTO_XLEN} + 1) ==
        Zeros{PTO_XLEN};
    assert ScalarBinary(ScalarBinary_SUB, Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1) ==
        max_word;
    assert ScalarBinary(ScalarBinary_SLL, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 65) == Zeros{PTO_XLEN} + 2;
    assert ScalarBinaryW(ScalarBinary_ADD, Zeros{PTO_XLEN} + 0x7fffffff,
        Zeros{PTO_XLEN} + 1) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);

    assert ConditionHolds(ScalarCondition_EQ, max_word, max_word);
    assert ConditionHolds(ScalarCondition_LT, max_word, Zeros{PTO_XLEN});
    assert ConditionHolds(ScalarCondition_LTU, Zeros{PTO_XLEN}, max_word);

    assert ScalarDivideUnsigned(Zeros{PTO_XLEN} + 10, Zeros{PTO_XLEN} + 3) ==
        Zeros{PTO_XLEN} + 3;
    assert ScalarRemainderUnsigned(Zeros{PTO_XLEN} + 10, Zeros{PTO_XLEN} + 3) ==
        Zeros{PTO_XLEN} + 1;
    let minus_ten = Zeros{PTO_XLEN} - 10;
    assert ScalarDivideSigned(minus_ten, Zeros{PTO_XLEN} + 3) ==
        Zeros{PTO_XLEN} - 3;
    assert ScalarRemainderSigned(minus_ten, Zeros{PTO_XLEN} + 3) ==
        Zeros{PTO_XLEN} - 1;

    ExecuteScalarMultiplyPair(8, 9, max_word, Zeros{PTO_XLEN} + 2, FALSE);
    assert ReadGPR(8) == Zeros{PTO_XLEN} - 2;
    assert ReadGPR(9) == Zeros{PTO_XLEN} + 1;
    ExecuteScalarDividePair(8, 9, Zeros{PTO_XLEN} + 23,
        Zeros{PTO_XLEN} + 5, FALSE);
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 4;
    assert ReadGPR(9) == Zeros{PTO_XLEN} + 3;

    assert ScalarDivideSignedW(Zeros{PTO_XLEN} + 0xfffffff6,
        Zeros{PTO_XLEN} + 3) == Ones{PTO_XLEN} - 2;
    assert ScalarRemainderUnsignedW(Zeros{PTO_XLEN} + 0xffffffff,
        Zeros{PTO_XLEN} + 16) == Zeros{PTO_XLEN} + 15;
    assert ScalarMultiplyW(Zeros{PTO_XLEN} + 0x80000000,
        Zeros{PTO_XLEN} + 1) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);

    assert ApplyScalarRightModifier(Zeros{PTO_XLEN} + 0xffffffff,
        ScalarRight_SignedWord, FALSE) == Ones{PTO_XLEN};
    assert ApplyScalarRightModifier(Zeros{PTO_XLEN} + 3,
        ScalarRight_NegateOrNot, TRUE) == NOT(Zeros{PTO_XLEN} + 3);
    assert ApplyRestrictedCompareModifier(Zeros{PTO_XLEN} + 7,
        ScalarRight_NegateOrNot) == Zeros{PTO_XLEN} + 7;
    assert ApplySelectModifier(Zeros{PTO_XLEN} + 7,
        ScalarRight_NegateOrNot) == Zeros{PTO_XLEN} - 7;
    assert MaterializeLUI('10000000000000000000') ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert MaterializeLongUnsigned(Ones{32}) == Zeros{PTO_XLEN} + 0xffffffff;
    assert MoveScalarValue(Zeros{PTO_XLEN} + 0x1234) ==
        Zeros{PTO_XLEN} + 0x1234;
    assert ScalarMultiplyImmediateAdd(Zeros{PTO_XLEN} + 100,
        Zeros{PTO_XLEN} + 7, Zeros{19} + 3, FALSE) == Zeros{PTO_XLEN} + 121;
    assert ScalarMultiplyImmediateAdd(Zeros{PTO_XLEN} + 100,
        Zeros{PTO_XLEN} + 7, Zeros{19} + 3, TRUE) == Zeros{PTO_XLEN} + 79;
    assert InsertBitfield(Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0xf, 62, 1) ==
        (Zeros{PTO_XLEN} + 0xc000000000000003);

    ExecuteConcatenatePair(6, 7, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x22, 4);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x1000000000000002;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 1;
    ExecuteConcatenatePairW(6, 7, Zeros{PTO_XLEN} + 0x80000000,
        Zeros{PTO_XLEN} + 1, 0);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 1;
    assert ReadGPR(7) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0x80, 8, TRUE) ==
        SignExtend{PTO_XLEN}(Zeros{8} + 0x80);
    ExecuteScalarMultiplyAddPair(6, 7, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3, FALSE);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 7;
    assert ReadGPR(7) == Zeros{PTO_XLEN};

    assert ExtractBitfield(Zeros{PTO_XLEN} + 0x00f0, 8, 4, FALSE) ==
        Zeros{PTO_XLEN} + 0x0f;
    assert CountBitfield(Zeros{PTO_XLEN} + 0x00f0, 8, 4, FALSE, TRUE) ==
        Zeros{PTO_XLEN} + 4;
    assert CountBitfield(Zeros{PTO_XLEN} + 0x00f0, 8, 4, TRUE, FALSE) ==
        Zeros{PTO_XLEN} + 4;
    assert ModifyBitfield(Zeros{PTO_XLEN}, 3, 4, TRUE) == Zeros{PTO_XLEN} + 0x70;
    assert ReverseBitfieldBytes(Zeros{PTO_XLEN} + 0x11223344, 32, 0) ==
        Zeros{PTO_XLEN} + 0x44332211;
    assert ReverseBitfieldBytes(Ones{PTO_XLEN}, 7, 0) == Zeros{PTO_XLEN};

    WriteTPC(Zeros{PTO_XLEN} + 100);
    ExecuteCompare(10, ScalarCondition_LT, max_word, Zeros{PTO_XLEN});
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 1;
    ExecuteSetCommit(ScalarCondition_EQ, Zeros{PTO_XLEN} + 7, Zeros{PTO_XLEN} + 7);
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;
    SetReturnAddress(Zeros{PTO_XLEN} + 3);
    assert _ReturnAddress == Zeros{PTO_XLEN} + 106;
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 106;
    AddToPC(11, Zeros{PTO_XLEN} + 4);
    assert ReadGPR(11) == Zeros{PTO_XLEN} + 0x4064;

    assert MaterializeLongSigned(Zeros{32} + 0x80000000) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert MultiplyWord(Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 4) ==
        Zeros{PTO_XLEN} + 12;
    assert ScalarConditionalSelect(Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2) == Zeros{PTO_XLEN} + 2;
    assert ScalarDivideUnsignedW(Zeros{PTO_XLEN} + 0xffffffff,
        Zeros{PTO_XLEN} + 16) == Zeros{PTO_XLEN} + 0x0fffffff;
    assert ScalarRemainderSignedW(Zeros{PTO_XLEN} + 0xfffffff6,
        Zeros{PTO_XLEN} + 3) == Ones{PTO_XLEN};
    assert ScalarMultiplyAdd(Zeros{PTO_XLEN} + 5, Zeros{PTO_XLEN} + 3,
        Zeros{PTO_XLEN} + 4) == Zeros{PTO_XLEN} + 17;
    assert ScalarMultiplyAddW(Zeros{PTO_XLEN} + 5,
        Zeros{PTO_XLEN} + 0xffffffff, Zeros{PTO_XLEN} + 3) ==
        Zeros{PTO_XLEN} + 2;

    // Division is non-trapping. A zero divisor returns a zero quotient and
    // preserves the dividend as the remainder. Signed minimum divided by -1
    // wraps to the signed minimum with zero remainder, at both widths.
    assert ScalarDivideUnsigned(Zeros{PTO_XLEN} + 0x1234,
        Zeros{PTO_XLEN}) == Zeros{PTO_XLEN};
    assert ScalarRemainderUnsigned(Zeros{PTO_XLEN} + 0x1234,
        Zeros{PTO_XLEN}) == Zeros{PTO_XLEN} + 0x1234;
    assert ScalarDivideSigned(Zeros{PTO_XLEN} + 0x8000000000000000,
        Ones{PTO_XLEN}) == Zeros{PTO_XLEN} + 0x8000000000000000;
    assert ScalarRemainderSigned(Zeros{PTO_XLEN} + 0x8000000000000000,
        Ones{PTO_XLEN}) == Zeros{PTO_XLEN};
    assert ScalarDivideSignedW(Zeros{PTO_XLEN} + 0x80000000,
        Ones{PTO_XLEN}) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ScalarRemainderSignedW(Zeros{PTO_XLEN} + 0x80000000,
        Ones{PTO_XLEN}) == Zeros{PTO_XLEN};

    ExecuteScalarDividePairW(8, 9, Zeros{PTO_XLEN} + 23,
        Zeros{PTO_XLEN} + 5, FALSE);
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 4;
    assert ReadGPR(9) == Zeros{PTO_XLEN} + 3;

    ExecuteCompareLogical(10, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 1;
    ExecuteCompareLogical(10, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, FALSE);
    assert ReadGPR(10) == Zeros{PTO_XLEN};
    ExecuteSetCommitLogical(Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, TRUE);
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;
    ExecuteSetCommitLogical(Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, FALSE);
    assert _CommitArgument == Zeros{PTO_XLEN};

    WritePC(Zeros{PTO_XLEN} + 100);
    BranchRelative(ScalarCondition_EQ, Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 7, Zeros{PTO_XLEN} + 3);
    assert ReadPC() == Zeros{PTO_XLEN} + 106;
    WritePC(Zeros{PTO_XLEN} + 100);
    BranchRelative(ScalarCondition_NE, Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 7, Zeros{PTO_XLEN} + 3);
    assert ReadPC() == Zeros{PTO_XLEN} + 104;
    WritePC(Zeros{PTO_XLEN} + 100);
    JumpRelative(Zeros{PTO_XLEN} + 4);
    assert ReadPC() == Zeros{PTO_XLEN} + 108;
    JumpRegister(Zeros{PTO_XLEN} + 200);
    assert ReadPC() == Zeros{PTO_XLEN} + 200;
    ClearFault();
    JumpRegister(Zeros{PTO_XLEN} + 201);
    assert _LastFault == Fault_InstructionPC;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarInteger();
    return 0;
end;
