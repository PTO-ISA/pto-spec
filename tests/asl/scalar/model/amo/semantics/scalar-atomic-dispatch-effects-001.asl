// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARATOMICDISPATCHEFFECTS-ATOMICITY-001","source":"asl/scalar/model/amo/semantics.asl","requirements":[],"kind":"atomicity","summary":"Covers Scalar Atomic Dispatch Effects.","pass_condition":"TestScalarAtomicDispatchEffects completes without assertion failure","related_sources":[]}
func TestScalarAtomicDispatchEffects()
begin
    ClearFault();
    WriteGPR(2, Zeros{PTO_XLEN} + 128);
    Store(Zeros{PTO_XLEN} + 128, 4, Zeros{PTO_XLEN} + 0x80000001);
    var load_reserved: bits(48) = Zeros{48} + 0x2000000b;
    load_reserved[11:7] = Zeros{5} + 5;
    load_reserved[19:15] = Zeros{5} + 2;
    load_reserved[27] = '1';
    load_reserved[26] = '1';
    load_reserved[25] = '1';
    let load_reserved_form_index = DecodeScalarForm(load_reserved, 32);
    assert load_reserved_form_index != PTO_SCALAR_FORM_COUNT;
    let load_reserved_form = load_reserved_form_index as
        integer {0..PTO_SCALAR_FORM_COUNT-1};
    assert ScalarDecodedMemoryOrder(load_reserved, load_reserved_form) ==
        MemoryOrder_AcquireRelease;
    let load_reserved_status = ExecuteScalarInstruction(load_reserved, 32);
    assert load_reserved_status == ScalarExecution_Executed;
    assert ReadGPR(5) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000001);
    assert _ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN} + 128;
    assert _ReservationSize == 4;

    WriteGPR(3, Zeros{PTO_XLEN} + 0x11223344);
    var store_conditional: bits(48) = Zeros{48} + 0x2000100b;
    store_conditional[11:7] = Zeros{5} + 6;
    store_conditional[19:15] = Zeros{5} + 3;
    store_conditional[24:20] = Zeros{5} + 2;
    store_conditional[25] = '1';
    let store_conditional_status =
        ExecuteScalarInstruction(store_conditional, 32);
    assert store_conditional_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN};
    let stored_word = LoadUnsigned(Zeros{PTO_XLEN} + 128, 4);
    assert stored_word == Zeros{PTO_XLEN} + 0x11223344;

    WriteGPR(2, Zeros{PTO_XLEN} + 136);
    WriteGPR(3, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 136, 8, Zeros{PTO_XLEN} + 7);
    var atomic_add: bits(48) = Zeros{48} + 0x0000400b;
    atomic_add[11:7] = Zeros{5} + 7;
    atomic_add[19:15] = Zeros{5} + 2;
    atomic_add[24:20] = Zeros{5} + 3;
    let atomic_add_status = ExecuteScalarInstruction(atomic_add, 32);
    assert atomic_add_status == ScalarExecution_Executed;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 7;
    let atomic_add_value = LoadUnsigned(Zeros{PTO_XLEN} + 136, 8);
    assert atomic_add_value == Zeros{PTO_XLEN} + 12;

    WriteGPR(2, Zeros{PTO_XLEN} + 144);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xff00ff00);
    Store(Zeros{PTO_XLEN} + 144, 4, Zeros{PTO_XLEN} + 0xffff0000);
    var atomic_store_xor: bits(48) = Zeros{48} + 0x3000300b;
    atomic_store_xor[19:15] = Zeros{5} + 2;
    atomic_store_xor[24:20] = Zeros{5} + 3;
    atomic_store_xor[27] = '1';
    atomic_store_xor[25] = '1';
    let atomic_store_status =
        ExecuteScalarInstruction(atomic_store_xor, 32);
    assert atomic_store_status == ScalarExecution_Executed;
    let atomic_store_value = LoadUnsigned(Zeros{PTO_XLEN} + 144, 4);
    assert atomic_store_value == Zeros{PTO_XLEN} + 0x00ffff00;

    WriteGPR(2, Zeros{PTO_XLEN} + 152);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x80000001);
    WriteGPR(4, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 152, 4, Zeros{PTO_XLEN} + 0x80000001);
    var compare_swap: bits(48) = Zeros{48} + 0x0000201b;
    compare_swap[11:7] = Zeros{5} + 8;
    compare_swap[19:15] = Zeros{5} + 2;
    compare_swap[24:20] = Zeros{5} + 3;
    compare_swap[31:27] = Zeros{5} + 4;
    let compare_swap_status = ExecuteScalarInstruction(compare_swap, 32);
    assert compare_swap_status == ScalarExecution_Executed;
    assert ReadGPR(8) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000001);
    let compare_swap_value = LoadUnsigned(Zeros{PTO_XLEN} + 152, 4);
    assert compare_swap_value == Zeros{PTO_XLEN} + 9;

    ClearFault();
    WriteMemoryByte(Zeros{PTO_XLEN} + 256, Zeros{8} + 0x5a);
    WriteMemoryByte(Zeros{PTO_XLEN} + 319, Zeros{8} + 0xa5);
    WriteGPR(2, Zeros{PTO_XLEN} + 256);
    WriteGPR(3, Zeros{PTO_XLEN} + 448);
    var dma_instruction: bits(48) = Zeros{48} + 0x0000700b;
    dma_instruction[19:15] = Zeros{5} + 2;
    dma_instruction[24:20] = Zeros{5} + 3;
    let dma_status = ExecuteScalarInstruction(dma_instruction, 32);
    assert dma_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 448) == Zeros{8} + 0x5a;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 511) == Zeros{8} + 0xa5;

    // Destination failure is detected before any source read or destination
    // write becomes architecturally visible.
    WriteMemoryByte(Zeros{PTO_XLEN} + 4032, Zeros{8} + 0x77);
    WriteGPR(3, Zeros{PTO_XLEN} + 4064);
    ClearFault();
    let dma_fault_status = ExecuteScalarInstruction(dma_instruction, 32);
    assert dma_fault_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + 4064;
    assert ReadMemoryByte(Zeros{PTO_XLEN} + 4032) == Zeros{8} + 0x77;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarAtomicDispatchEffects();
    return 0;
end;
