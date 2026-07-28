func TestScalarDispatchEffects()
begin
    WriteGPR(2, Zeros{PTO_XLEN} + 10);
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    var add_instruction: bits(48) = Zeros{48} + 0x00000005;
    add_instruction[11:7] = Zeros{5} + 5;
    add_instruction[19:15] = Zeros{5} + 2;
    add_instruction[24:20] = Zeros{5} + 3;
    add_instruction[26:25] = '11';
    add_instruction[31:27] = Zeros{5} + 1;
    let add_status = ExecuteScalarInstruction(add_instruction, 32);
    assert add_status == ScalarExecution_Executed;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 4;

    var addi_instruction: bits(48) = Zeros{48} + 0x00000015;
    addi_instruction[11:7] = Zeros{5} + 6;
    addi_instruction[19:15] = Zeros{5} + 2;
    addi_instruction[31:20] = Zeros{12} + 7;
    let addi_status = ExecuteScalarInstruction(addi_instruction, 32);
    assert addi_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 17;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x7fffffff);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    WriteGPR(4, Zeros{PTO_XLEN} + 1);
    var maddw_instruction: bits(48) = Zeros{48} + 0x00007047;
    maddw_instruction[11:7] = Zeros{5} + 7;
    maddw_instruction[19:15] = Zeros{5} + 3;
    maddw_instruction[24:20] = Zeros{5} + 4;
    maddw_instruction[31:27] = Zeros{5} + 2;
    let maddw_status = ExecuteScalarInstruction(maddw_instruction, 32);
    assert maddw_status == ScalarExecution_Executed;
    assert ReadGPR(7) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000000);

    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    WriteGPR(3, Zeros{PTO_XLEN} + 9);
    var compressed_add: bits(48) = Zeros{48} + 0x0008;
    compressed_add[10:6] = Zeros{5} + 2;
    compressed_add[15:11] = Zeros{5} + 3;
    let compressed_status = ExecuteScalarInstruction(compressed_add, 16);
    assert compressed_status == ScalarExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 17;

    ClearFault();
    WritePC(Zeros{PTO_XLEN} + 100);
    var specific_alias: bits(48) = Zeros{48} + 0x0016;
    specific_alias[15:11] = Zeros{5} + 10;
    let alias_status = ExecuteScalarInstruction(specific_alias, 16);
    assert alias_status == ScalarExecution_Executed;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 100;
    assert _LastFault == Fault_None;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x0f);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xf0);
    var compare_and: bits(48) = Zeros{48} + 0x00002045;
    compare_and[11:7] = Zeros{5} + 8;
    compare_and[19:15] = Zeros{5} + 2;
    compare_and[24:20] = Zeros{5} + 3;
    let compare_and_zero_status = ExecuteScalarInstruction(compare_and, 32);
    assert compare_and_zero_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN};
    compare_and[26:25] = '11';
    let compare_and_nonzero_status = ExecuteScalarInstruction(compare_and, 32);
    assert compare_and_nonzero_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 1;

    WriteGPR(2, Zeros{PTO_XLEN} + 8);
    var set_commit_immediate: bits(48) = Zeros{48} + 0x00000075;
    set_commit_immediate[11:7] = Zeros{5} + 3;
    set_commit_immediate[19:15] = Zeros{5} + 2;
    set_commit_immediate[31:20] = Zeros{12} + 1;
    let set_commit_status = ExecuteScalarInstruction(set_commit_immediate, 32);
    assert set_commit_status == ScalarExecution_Executed;
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;

    WritePredicateMask(Zeros{PTO_XLEN});
    WritePC(Zeros{PTO_XLEN} + 100);
    var branch_zero: bits(48) = Zeros{48} + 0x00001037;
    branch_zero[31:15] = Zeros{17} + 3;
    let branch_taken_status = ExecuteScalarInstruction(branch_zero, 32);
    assert branch_taken_status == ScalarExecution_Executed;
    assert ReadPC() == Zeros{PTO_XLEN} + 106;
    WritePredicateMask(Zeros{PTO_XLEN} + 1);
    WritePC(Zeros{PTO_XLEN} + 100);
    let branch_fallthrough_status = ExecuteScalarInstruction(branch_zero, 32);
    assert branch_fallthrough_status == ScalarExecution_Executed;
    assert ReadPC() == Zeros{PTO_XLEN} + 104;

    WriteGPR(2, Zeros{PTO_XLEN} + 200);
    var jump_register: bits(48) = Zeros{48} + 0x00006027;
    jump_register[19:15] = Zeros{5} + 2;
    jump_register[31:25] = Zeros{7} + 2;
    let jump_register_status = ExecuteScalarInstruction(jump_register, 32);
    assert jump_register_status == ScalarExecution_Executed;
    assert ReadPC() == Zeros{PTO_XLEN} + 204;
end;

func TestScalarSystemDispatchEffects()
begin
    ClearFault();
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    var ssrset_instruction: bits(48) = Zeros{48} + 0x0000103b;
    ssrset_instruction[19:15] = Zeros{5} + 5;
    let ssrset_status = ExecuteScalarInstruction(ssrset_instruction, 32);
    assert ssrset_status == ScalarExecution_Executed;
    let tp_after_set = ReadSystemRegister(SystemRegister_TP);
    assert tp_after_set == Zeros{PTO_XLEN} + 0x55;

    var ssrget_instruction: bits(48) = Zeros{48} + 0x0000003b;
    ssrget_instruction[11:7] = Zeros{5} + 6;
    let ssrget_status = ExecuteScalarInstruction(ssrget_instruction, 32);
    assert ssrget_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x55;

    WriteGPR(7, Zeros{PTO_XLEN} + 0x66);
    var ssrswap_instruction: bits(48) = Zeros{48} + 0x0000203b;
    ssrswap_instruction[11:7] = Zeros{5} + 8;
    ssrswap_instruction[19:15] = Zeros{5} + 7;
    let ssrswap_status = ExecuteScalarInstruction(ssrswap_instruction, 32);
    assert ssrswap_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 0x55;
    let tp_after_swap = ReadSystemRegister(SystemRegister_TP);
    assert tp_after_swap == Zeros{PTO_XLEN} + 0x66;

    var compressed_get: bits(48) = Zeros{48} + 0x802c;
    let compressed_get_status = ExecuteScalarInstruction(compressed_get, 16);
    assert compressed_get_status == ScalarExecution_Executed;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x66;

    WriteGPR(5, Zeros{PTO_XLEN} + 0x1234);
    var long_set: bits(48) = Zeros{48} + 0x0000103b000e;
    long_set[47:36] = Zeros{12} + 0xf10;
    long_set[15:4] = Zeros{12} + 1;
    long_set[35:31] = Zeros{5} + 5;
    let long_set_status = ExecuteScalarInstruction(long_set, 48);
    assert long_set_status == ScalarExecution_Executed;
    let long_system_value = ReadSystemRegisterAddress(Zeros{24} + 0x1f10);
    assert long_system_value == Zeros{PTO_XLEN} + 0x1234;

    let before_data_cache = _DataCacheEpoch;
    var maintenance: bits(48) = Zeros{48} + 0x0030602b;
    maintenance[19:15] = Zeros{5} + 5;
    let maintenance_status = ExecuteScalarInstruction(maintenance, 32);
    assert maintenance_status == ScalarExecution_Executed;
    assert _DataCacheEpoch == before_data_cache + 1;

    WriteGPR(5, Zeros{PTO_XLEN} + 17);
    var wait_event: bits(48) = Zeros{48} + 0x0010002b;
    wait_event[19:15] = Zeros{5} + 5;
    let wait_event_status = ExecuteScalarInstruction(wait_event, 32);
    assert wait_event_status == ScalarExecution_Executed;
    assert _LastControlRequest == ExecutionControl_WaitEvent;
    assert _ControlRequestOperand == Zeros{PTO_XLEN} + 17;

    let before_release = _MemoryReleaseEpoch;
    let before_acquire = _MemoryAcquireEpoch;
    let before_instruction = _InstructionCacheEpoch;
    var fence_data: bits(48) = Zeros{48} + 0x0000202b;
    fence_data[27:24] = '1010';
    fence_data[23:20] = '0101';
    let fence_status = ExecuteScalarInstruction(fence_data, 32);
    assert fence_status == ScalarExecution_Executed;
    assert _LastFencePredecessor == '1010';
    assert _LastFenceSuccessor == '0101';
    assert _MemoryReleaseEpoch == before_release + 1;
    assert _MemoryAcquireEpoch == before_acquire + 1;
    assert _InstructionCacheEpoch == before_instruction + 1;

    WriteGPR(5, Zeros{PTO_XLEN} + 0x800);
    var set_target: bits(48) = Zeros{48} + 0x0000403b;
    set_target[19:15] = Zeros{5} + 5;
    let set_target_status = ExecuteScalarInstruction(set_target, 32);
    assert set_target_status == ScalarExecution_Executed;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x800;

    let before_request = _ArchitectureRequestEpoch;
    var close_request: bits(48) = Zeros{48} + 0x0000302b;
    close_request[23:20] = '0111';
    let close_status = ExecuteScalarInstruction(close_request, 32);
    assert close_status == ScalarExecution_Executed;
    assert _ArchitectureRequestEpoch == before_request + 1;
    assert _SystemRegisters.cstate[3:0] == '0111';

    ClearFault();
    var enter_request: bits(48) = Zeros{48} + 0x0100302b;
    enter_request[23:20] = '0010';
    let enter_status = ExecuteScalarInstruction(enter_request, 32);
    assert enter_status == ScalarExecution_Executed;
    assert _LastFault == Fault_IllegalInstruction;

    ClearFault();
    WritePC(Zeros{PTO_XLEN} + 0x400);
    var breakpoint: bits(48) = Zeros{48} + 0x0010102b;
    breakpoint[27:24] = '1001';
    let breakpoint_status = ExecuteScalarInstruction(breakpoint, 32);
    assert breakpoint_status == ScalarExecution_Executed;
    assert _LastFault == Fault_SoftwareBreakpoint;
    assert _BreakpointTag == '01001';
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x400;

    ClearFault();
    var assertion: bits(48) = Zeros{48} + 0x0000102b;
    let assertion_status = ExecuteScalarInstruction(assertion, 32);
    assert assertion_status == ScalarExecution_Executed;
    assert _LastFault == Fault_Assert;
end;

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

    WritePC(Zeros{PTO_XLEN} + 100);
    ExecuteCompare(10, ScalarCondition_LT, max_word, Zeros{PTO_XLEN});
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 1;
    ExecuteSetCommit(ScalarCondition_EQ, Zeros{PTO_XLEN} + 7, Zeros{PTO_XLEN} + 7);
    assert _CommitArgument == Zeros{PTO_XLEN} + 1;
    SetReturnAddress(Zeros{PTO_XLEN} + 3);
    assert _ReturnAddress == Zeros{PTO_XLEN} + 106;
    AddToPC(11, Zeros{PTO_XLEN} + 4);
    assert ReadGPR(11) == Zeros{PTO_XLEN} + 108;

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

func TestScalarMemory()
begin
    ClearFault();
    Store(Zeros{PTO_XLEN} + 16, 4, Zeros{PTO_XLEN} + 0x44332211);
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 16) == '00010001';
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 19) == '01000100';
    let loaded = LoadUnsigned(Zeros{PTO_XLEN} + 16, 4);
    assert loaded == Zeros{PTO_XLEN} + 0x44332211;

    ClearFault();
    ScalarPrefetch(Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 8, 8);
    assert _LastFault == Fault_None;

    ClearFault();
    - = LoadUnsigned(Zeros{PTO_XLEN} + 17, 4);
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == Zeros{PTO_XLEN} + 17;

    ClearFault();
    WriteGPR(2, Zeros{PTO_XLEN} + 64);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x1122);
    ExecuteScalarStore(3, 2, Zeros{PTO_XLEN} + 8, 2, AddressUpdate_PreIndex);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 72;
    ExecuteScalarLoad(4, 2, Zeros{PTO_XLEN} + 2, 2, FALSE, AddressUpdate_PostIndex);
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 74;

    WriteGPR(5, Zeros{PTO_XLEN} + 0x3344);
    ExecuteScalarStorePair(3, 5, 2, Zeros{PTO_XLEN} + 6, 2, AddressUpdate_None);
    ExecuteScalarLoadPair(6, 7, 2, Zeros{PTO_XLEN} + 6, 2, FALSE, AddressUpdate_None);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x3344;
end;

func TestScalarAtomics()
begin
    ClearFault();
    Store(Zeros{PTO_XLEN} + 128, 8, Zeros{PTO_XLEN} + 10);
    let reserved = LoadReserved(Zeros{PTO_XLEN} + 128, 8, MemoryOrder_Acquire);
    assert reserved == Zeros{PTO_XLEN} + 10;
    let sc_success = StoreConditional(Zeros{PTO_XLEN} + 128, 8,
        Zeros{PTO_XLEN} + 11, MemoryOrder_Release);
    assert sc_success == Zeros{PTO_XLEN};
    let after_sc = LoadUnsigned(Zeros{PTO_XLEN} + 128, 8);
    assert after_sc == Zeros{PTO_XLEN} + 11;

    let sc_failure = StoreConditional(Zeros{PTO_XLEN} + 128, 8,
        Zeros{PTO_XLEN} + 12, MemoryOrder_Relaxed);
    assert sc_failure == Zeros{PTO_XLEN} + 1;

    let old_add = AtomicReadModifyWrite(Zeros{PTO_XLEN} + 128, 8,
        Atomic_ADD, Zeros{PTO_XLEN} + 9, MemoryOrder_AcquireRelease);
    assert old_add == Zeros{PTO_XLEN} + 11;
    let after_add = LoadUnsigned(Zeros{PTO_XLEN} + 128, 8);
    assert after_add == Zeros{PTO_XLEN} + 20;

    let old_cas = CompareAndSwap(Zeros{PTO_XLEN} + 128, 8,
        Zeros{PTO_XLEN} + 20, Zeros{PTO_XLEN} + 99,
        MemoryOrder_AcquireRelease);
    assert old_cas == Zeros{PTO_XLEN} + 20;
    let after_cas = LoadUnsigned(Zeros{PTO_XLEN} + 128, 8);
    assert after_cas == Zeros{PTO_XLEN} + 99;

    Store(Zeros{PTO_XLEN} + 200, 1, Zeros{PTO_XLEN} + 0xff);
    let old_signed_min = AtomicReadModifyWrite(Zeros{PTO_XLEN} + 200, 1,
        Atomic_SMIN, Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed);
    let after_signed_min = LoadUnsigned(Zeros{PTO_XLEN} + 200, 1);
    assert old_signed_min == Zeros{PTO_XLEN} + 0xff;
    assert after_signed_min == Zeros{PTO_XLEN} + 0xff;

    for byte_index = 0 to 63 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(Zeros{PTO_XLEN} + 256 + offset,
            (Zeros{8} + byte_index) as Byte);
    end;
    DMA64(Zeros{PTO_XLEN} + 256, Zeros{PTO_XLEN} + 384);
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 384) == Zeros{8};
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 447) == Zeros{8} + 63;
end;

func TestScalarSystem()
begin
    ClearFault();
    WriteSystemRegister(SystemRegister_TP, Zeros{PTO_XLEN} + 123);
    let tp = ReadSystemRegister(SystemRegister_TP);
    assert tp == Zeros{PTO_XLEN} + 123;

    WriteSystemRegister(SystemRegister_VENDOR, Ones{PTO_XLEN});
    assert _LastFault == Fault_IllegalInstruction;

    let before_acquire = _MemoryAcquireEpoch;
    let before_release = _MemoryReleaseEpoch;
    FenceData('0010', '0001');
    assert _MemoryAcquireEpoch == before_acquire + 1;
    assert _MemoryReleaseEpoch == before_release + 1;
    assert _LastFencePredecessor == '0010';
    assert _LastFenceSuccessor == '0001';

    ClearFault();
    let old_tp = SwapSystemRegister(SystemRegister_TP, Zeros{PTO_XLEN} + 456);
    assert old_tp == Zeros{PTO_XLEN} + 123;
    let new_tp = ReadSystemRegister(SystemRegister_TP);
    assert new_tp == Zeros{PTO_XLEN} + 456;
    let before_tlb = _TLBEpoch;
    ExecuteMaintenance(Maintenance_TLB_IV, Zeros{PTO_XLEN} + 0x1000);
    assert _TLBEpoch == before_tlb + 1;
    ExecuteMaintenance(Maintenance_TLB_IV, Zeros{PTO_XLEN} + 0x0001000000000000);
    assert _LastFault == Fault_DataPage;
    ClearFault();
    ArchitectureAssert(Zeros{PTO_XLEN});
    assert _LastFault == Fault_Assert;
    ClearFault();
    let before_request = _ArchitectureRequestEpoch;
    ArchitectureEnterRequest('0001');
    assert _ArchitectureRequestEpoch == before_request + 1;
    ExecuteControlRequest(ExecutionControl_WaitEvent, Zeros{PTO_XLEN} + 17);
    assert _LastControlRequest == ExecutionControl_WaitEvent;
    assert _ControlRequestOperand == Zeros{PTO_XLEN} + 17;
    SetCommitTarget(Zeros{PTO_XLEN} + 0x800);
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x800;

    ClearFault();
    let translation_base = Zeros{24} + 0x1f10;
    WriteSystemRegisterAddress(translation_base, Zeros{PTO_XLEN} + 0x1234);
    let translation_base_value = ReadSystemRegisterAddress(translation_base);
    assert translation_base_value == Zeros{PTO_XLEN} + 0x1234;

    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x4000);
    let trap_status = ReadSystemRegisterAddress(Zeros{24} + 0x0f02);
    assert trap_status[62] == '1';
    assert trap_status[5:0] == Zeros{6} + 35;
    let trap_argument = ReadSystemRegisterAddress(Zeros{24} + 0x0f03);
    assert trap_argument == Zeros{PTO_XLEN} + 0x4000;

    ClearFault();
    WriteSystemRegisterAddress(Zeros{24} + 0x0010, Ones{PTO_XLEN});
    assert _LastFault == Fault_IllegalInstruction;
    ClearFault();
    let unknown_value = ReadSystemRegisterAddress(Zeros{24} + 0x100000);
    assert unknown_value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;

    ClearFault();
    RaiseInterrupt(Zeros{PTO_XLEN} + 7, Zeros{24} + 9);
    assert PackTrapStatus()[63] == '1';
    assert PackTrapStatus()[5:0] == Zeros{6} + 44;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a, Zeros{PTO_XLEN} + 7);
    assert PackTrapStatus()[63] == '0';

    ClearFault();
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    ExecuteSystemRegisterSet(5, Zeros{24} + 0x0000);
    ExecuteSystemRegisterGet(6, Zeros{24} + 0x0000);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x55;

    ClearFault();
    WriteGPR(5, Zeros{PTO_XLEN} + 0x66);
    ExecuteSystemRegisterSwap(6, 5, Zeros{24} + 0x0000);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x55;
    let swapped_tp = ReadSystemRegister(SystemRegister_TP);
    assert swapped_tp == Zeros{PTO_XLEN} + 0x66;

    WriteSystemRegister(SystemRegister_TP, Zeros{PTO_XLEN} + 0x77);
    ExecuteCompressedSystemRegisterGet(Zeros{24} + 0x0000);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x77;

    let before_instruction_fence = _MemoryReleaseEpoch;
    FenceInstruction();
    assert _MemoryReleaseEpoch == before_instruction_fence + 1;

    let before_close = _ArchitectureRequestEpoch;
    ArchitectureCloseRequest('0011');
    assert _ArchitectureRequestEpoch == before_close + 1;
    assert _SystemRegisters.cstate[3:0] == '0011';

    WritePC(Zeros{PTO_XLEN} + 0x400);
    ClearFault();
    SoftwareBreakpoint('01001');
    assert _LastFault == Fault_SoftwareBreakpoint;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x400;
    assert _BreakpointTag == '01001';
end;

func TestScalarFloating()
begin
    assert FloatingBinary(FloatingBinary_ADD, 1.5, 2.25) == 3.75;
    assert FloatingBinary(FloatingBinary_MUL, -2.0, 4.0) == -8.0;
    assert FloatingCompare(FloatingCompare_LT, -1.0, 0.0);
    assert FloatingCompare(FloatingCompare_GE, 5.0, 5.0);
    assert FloatingFused(FloatingFused_MADD, 1.0, 2.0, 3.0) == 7.0;
    let square_root = FloatingUnary(FloatingUnary_SQRT, 9.0);
    assert square_root == 3.0;
    let rounded_down = FloatingToInteger(3.75, FloatingRound_Down);
    let rounded_zero = FloatingToInteger(-3.75, FloatingRound_TowardsZero);
    assert rounded_down == 3;
    assert rounded_zero == -3;
    let converted_encoding = ConvertFloatingEncoding(Zeros{PTO_XLEN} + 0x1234,
        Zeros{5}, Zeros{5} + 1, Zeros{3});
    assert converted_encoding == Zeros{PTO_XLEN} + 0x1234;
end;
