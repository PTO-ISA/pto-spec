// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARALUBOUNDARYMATRIX-BOUNDARY-001","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for TestScalarALUBoundaryMatrix","pass_condition":"TestScalarALUBoundaryMatrix completes without assertion failure","related_sources":[]}
func TestScalarALUBoundaryMatrix()
begin
    let zero: Word = Zeros{PTO_XLEN};
    let one: Word = Zeros{PTO_XLEN} + 1;
    let ones: Word = Ones{PTO_XLEN};
    let signed_min: Word = Zeros{PTO_XLEN} + 0x8000000000000000;
    let signed_max: Word = Zeros{PTO_XLEN} + 0x7fffffffffffffff;

    // Fixed-width arithmetic, logic, extrema, and shift-count reduction.
    assert ScalarBinary(ScalarBinary_ADD, zero, zero) == zero;
    assert ScalarBinary(ScalarBinary_ADD, ones, one) == zero;
    assert ScalarBinary(ScalarBinary_SUB, zero, one) == ones;
    assert ScalarBinary(ScalarBinary_AND, ones, zero) == zero;
    assert ScalarBinary(ScalarBinary_OR, zero, ones) == ones;
    assert ScalarBinary(ScalarBinary_XOR, ones, ones) == zero;
    assert ScalarBinary(ScalarBinary_SLL, one, zero) == one;
    assert ScalarBinary(ScalarBinary_SLL, one, Zeros{PTO_XLEN} + 63) == signed_min;
    assert ScalarBinary(ScalarBinary_SLL, one, Zeros{PTO_XLEN} + 64) == one;
    assert ScalarBinary(ScalarBinary_SRL, signed_min, Zeros{PTO_XLEN} + 63) == one;
    assert ScalarBinary(ScalarBinary_SRA, signed_min, Zeros{PTO_XLEN} + 63) == ones;
    assert ScalarBinary(ScalarBinary_MIN, signed_min, signed_max) == signed_min;
    assert ScalarBinary(ScalarBinary_MAX, signed_min, signed_max) == signed_max;
    assert ScalarBinary(ScalarBinary_MINU, zero, ones) == zero;
    assert ScalarBinary(ScalarBinary_MAXU, zero, ones) == ones;

    assert ScalarBinaryW(ScalarBinary_ADD, Zeros{PTO_XLEN} + 0x7fffffff, one) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ScalarBinaryW(ScalarBinary_SUB, zero, one) == ones;
    assert ScalarBinaryW(ScalarBinary_AND, Ones{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x80000000) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ScalarBinaryW(ScalarBinary_SLL, one, Zeros{PTO_XLEN} + 31) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ScalarBinaryW(ScalarBinary_SLL, one, Zeros{PTO_XLEN} + 32) == one;
    assert ScalarBinaryW(ScalarBinary_SRA, Zeros{PTO_XLEN} + 0x80000000,
        Zeros{PTO_XLEN} + 31) == ones;

    // Multiply, divide, remainder, and multiply-add corners at both widths.
    assert MultiplyWord(zero, ones) == zero;
    assert MultiplyWord(ones, ones) == one;
    assert ScalarMultiplyW(Zeros{PTO_XLEN} + 0x80000000, one) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    let unsigned_square = MultiplyWideUnsigned(ones, ones);
    assert unsigned_square[63:0] == one;
    assert unsigned_square[127:64] == Ones{PTO_XLEN} - 1;
    let signed_overflow = MultiplyWideSigned(signed_min, ones);
    assert signed_overflow[63:0] == signed_min;
    assert signed_overflow[127:64] == zero;

    assert ScalarDivideUnsigned(ones, zero) == zero;
    assert ScalarRemainderUnsigned(ones, zero) == ones;
    assert ScalarDivideUnsigned(ones, one) == ones;
    assert ScalarRemainderUnsigned(ones, one) == zero;
    assert ScalarDivideSigned(signed_min, ones) == signed_min;
    assert ScalarRemainderSigned(signed_min, ones) == zero;
    assert ScalarDivideSignedW(Zeros{PTO_XLEN} + 0x80000000, ones) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ScalarRemainderSignedW(Zeros{PTO_XLEN} + 0x80000000, ones) == zero;
    assert ScalarDivideUnsignedW(Ones{PTO_XLEN}, zero) == zero;
    assert ScalarRemainderUnsignedW(Ones{PTO_XLEN}, zero) == ones;
    assert ScalarMultiplyAdd(ones, one, one) == zero;
    assert ScalarMultiplyAddW(Zeros{PTO_XLEN} + 0x7fffffff, one, one) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ScalarMultiplyImmediateAdd(zero, ones, Ones{19}, FALSE) ==
        zero - ZeroExtend{PTO_XLEN}(Ones{19});
    assert ScalarMultiplyImmediateAdd(zero, ones, Ones{19}, TRUE) ==
        ZeroExtend{PTO_XLEN}(Ones{19});

    ExecuteScalarMultiplyPair(4, 5, ones, ones, FALSE);
    assert ReadGPR(4) == one;
    assert ReadGPR(5) == Ones{PTO_XLEN} - 1;
    ExecuteScalarDividePair(4, 5, ones, zero, FALSE);
    assert ReadGPR(4) == zero;
    assert ReadGPR(5) == ones;
    ExecuteScalarDividePairW(4, 5, Zeros{PTO_XLEN} + 0x80000000,
        ones, TRUE);
    assert ReadGPR(4) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert ReadGPR(5) == zero;
    ExecuteScalarMultiplyAddPair(4, 5, ones, one, one, FALSE);
    assert ReadGPR(4) == zero;
    assert ReadGPR(5) == zero;

    // Concatenation owns each encoded shift boundary, including the range in
    // which the word form returns zero.
    ExecuteConcatenatePair(4, 5, signed_min + one, Zeros{PTO_XLEN} + 2, 0);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 2;
    assert ReadGPR(5) == signed_min + one;
    ExecuteConcatenatePair(4, 5, signed_min + one, Zeros{PTO_XLEN} + 2, 63);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 2;
    assert ReadGPR(5) == one;
    ExecuteConcatenatePair(4, 5, signed_min + one, Zeros{PTO_XLEN} + 2, 64);
    assert ReadGPR(4) == signed_min + one;
    assert ReadGPR(5) == zero;
    ExecuteConcatenatePair(4, 5, signed_min + one, Zeros{PTO_XLEN} + 2, 127);
    assert ReadGPR(4) == one;
    assert ReadGPR(5) == zero;

    ExecuteConcatenatePairW(4, 5, Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 2, 0);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 2;
    assert ReadGPR(5) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000001);
    ExecuteConcatenatePairW(4, 5, Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 2, 31);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 2;
    assert ReadGPR(5) == one;
    ExecuteConcatenatePairW(4, 5, Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 2, 32);
    assert ReadGPR(4) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000001);
    assert ReadGPR(5) == zero;
    ExecuteConcatenatePairW(4, 5, Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 2, 63);
    assert ReadGPR(4) == one;
    assert ReadGPR(5) == zero;
    ExecuteConcatenatePairW(4, 5, Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 2, 64);
    assert ReadGPR(4) == zero;
    assert ReadGPR(5) == zero;
    ExecuteConcatenatePairW(4, 5, Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 2, 127);
    assert ReadGPR(4) == zero;
    assert ReadGPR(5) == zero;

    // Bitfield minimum, maximum, wrap, signedness, count, and replacement.
    assert ExtractBitfield(one, 1, 0, FALSE) == one;
    assert ExtractBitfield(one, 64, 1, FALSE) == signed_min;
    assert ExtractBitfield(one, 1, 0, TRUE) == ones;
    assert ExtractBitfield(signed_min + one, 2, 63, FALSE) == Zeros{PTO_XLEN} + 3;
    assert CountBitfield(zero, 64, 0, TRUE, FALSE) == Zeros{PTO_XLEN} + 64;
    assert CountBitfield(zero, 64, 0, FALSE, FALSE) == Zeros{PTO_XLEN} + 64;
    assert CountBitfield(ones, 64, 0, FALSE, TRUE) == Zeros{PTO_XLEN} + 64;
    assert CountBitfield(ones, 64, 0, TRUE, FALSE) == zero;
    assert ModifyBitfield(ones, 64, 0, FALSE) == zero;
    assert ModifyBitfield(zero, 64, 0, TRUE) == ones;
    assert ReverseBitfieldBytes(Zeros{PTO_XLEN} + 0x1122, 16, 0) ==
        Zeros{PTO_XLEN} + 0x2211;
    assert ReverseBitfieldBytes(ones, 1, 63) == zero;
    assert InsertBitfield(ones, zero, 0, 63) == zero;
    assert InsertBitfield(zero, Zeros{PTO_XLEN} + 3, 63, 0) == signed_min + one;

    // Materialization, extension, selection, and the catalogued control effects.
    assert MaterializeLUI(Zeros{20}) == zero;
    assert MaterializeLUI(Ones{20}) == Zeros{PTO_XLEN} + 0xfffffffffffff000;
    assert MaterializeLongSigned(Zeros{32} + 0x7fffffff) ==
        Zeros{PTO_XLEN} + 0x7fffffff;
    assert MaterializeLongSigned(Zeros{32} + 0x80000000) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);
    assert MaterializeLongUnsigned(Ones{32}) == Zeros{PTO_XLEN} + 0xffffffff;
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0x80, 8, TRUE) ==
        Zeros{PTO_XLEN} + 0xffffffffffffff80;
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0xff, 8, FALSE) ==
        Zeros{PTO_XLEN} + 0xff;
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0x8000, 16, TRUE) ==
        Zeros{PTO_XLEN} + 0xffffffffffff8000;
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0xffff, 16, FALSE) ==
        Zeros{PTO_XLEN} + 0xffff;
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0x80000000, 32, TRUE) ==
        Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert ExtendScalarValue(Zeros{PTO_XLEN} + 0xffffffff, 32, FALSE) ==
        Zeros{PTO_XLEN} + 0xffffffff;
    assert ScalarConditionalSelect(zero, one, Zeros{PTO_XLEN} + 2) ==
        Zeros{PTO_XLEN} + 2;
    assert ScalarConditionalSelect(one, one, Zeros{PTO_XLEN} + 2) == one;
    assert ScalarConditionalSelect(ones, one, Zeros{PTO_XLEN} + 2) == one;
    assert ApplySelectModifier(one, ScalarRight_NegateOrNot) == ones;

    SetCommitTarget(zero);
    assert _CommitArgument == zero;
    SetCommitTarget(ones);
    assert _CommitArgument == ones;
    WriteTPC(ones);
    SetReturnAddress(one);
    assert ReadGPR(10) == one;
    assert _ReturnAddress == one;
    WriteTPC(zero);
    SetReturnAddress(Zeros{PTO_XLEN} + 31);
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 62;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 62;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUBoundaryMatrix();
    return 0;
end;
