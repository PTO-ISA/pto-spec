// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-MULTI-ALIAS-EXEC-003","source":"asl/scalar/model/alu/semantics.asl","requirements":[],"kind":"execution","summary":"ternary, bitfield, and select operations snapshot overlapping operands","pass_condition":"ternary, bitfield, and select alias assertions hold","related_sources":[]}
func TestScalarALUMultiOperandAliases()
begin
    // Ternary arithmetic snapshots every source before an overlapping write.
    var madd: bits(48) = Zeros{48} + 0x00006047;
    madd[31:27] = Zeros{5} + 2;
    madd[19:15] = Zeros{5} + 3;
    madd[24:20] = Zeros{5} + 4;
    // ALU-ALIAS-DECODED: ternary-destination-overlaps-addend
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    WriteGPR(4, Zeros{PTO_XLEN} + 7);
    madd[11:7] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(madd, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 47;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 6;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 7;
    // ALU-ALIAS-DECODED: ternary-destination-overlaps-left
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    WriteGPR(4, Zeros{PTO_XLEN} + 7);
    madd[11:7] = Zeros{5} + 3;
    - = ExecuteScalarInstruction(madd, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 47;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 7;
    // ALU-ALIAS-DECODED: ternary-destination-overlaps-right
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 6);
    WriteGPR(4, Zeros{PTO_XLEN} + 7);
    madd[11:7] = Zeros{5} + 4;
    - = ExecuteScalarInstruction(madd, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 5;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 6;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 47;

    // Bitfield insertion snapshots both the preserved base and inserted value.
    var bitfield_insert: bits(48) = Zeros{48} + 0x0000204d000e;
    bitfield_insert[35:31] = Zeros{5} + 2;
    bitfield_insert[40:36] = Zeros{5} + 3;
    bitfield_insert[9:4] = Zeros{6} + 63;
    bitfield_insert[15:10] = Zeros{6};
    // ALU-ALIAS-DECODED: bitfield-destination-overlaps-base
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    bitfield_insert[27:23] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(bitfield_insert, 48);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x8000000000000001;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;
    // ALU-ALIAS-DECODED: bitfield-destination-overlaps-insert
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    bitfield_insert[27:23] = Zeros{5} + 3;
    - = ExecuteScalarInstruction(bitfield_insert, 48);
    assert ReadGPR(2) == Zeros{PTO_XLEN};
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x8000000000000001;

    // Select snapshots the true, false, and predicate operands independently.
    var select: bits(48) = Zeros{48} + 0x00000077;
    select[19:15] = Zeros{5} + 2;
    select[24:20] = Zeros{5} + 3;
    select[31:27] = Zeros{5} + 4;
    select[26:25] = Zeros{2};
    // ALU-ALIAS-DECODED: select-destination-overlaps-true
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    select[11:7] = Zeros{5} + 2;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 10;
    // ALU-ALIAS-DECODED: select-destination-overlaps-false
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    WriteGPR(4, Zeros{PTO_XLEN});
    select[26:25] = Zeros{2} + 3;
    select[11:7] = Zeros{5} + 3;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xffffffffffffffec;
    // ALU-ALIAS-DECODED: select-destination-overlaps-predicate
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 20);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    select[26:25] = Zeros{2};
    select[11:7] = Zeros{5} + 4;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 10;

    // ALU-ALIAS-DECODED: select-queue-sources-and-push
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 5);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 7);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 1);
    select[19:15] = Zeros{5} + 24;
    select[24:20] = Zeros{5} + 29;
    select[31:27] = Zeros{5} + 28;
    select[11:7] = Zeros{5} + 31;
    - = ExecuteScalarInstruction(select, 32);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 5;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarALUMultiOperandAliases();
    return 0;
end;
