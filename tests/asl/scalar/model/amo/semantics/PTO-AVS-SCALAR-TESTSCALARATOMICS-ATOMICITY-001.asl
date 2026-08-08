// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARATOMICS-ATOMICITY-001","source":"asl/scalar/model/amo/semantics.asl","requirements":[],"kind":"atomicity","summary":"migrated independent behavior point for TestScalarAtomics","pass_condition":"TestScalarAtomics completes without assertion failure","related_sources":[]}
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

    for index = 0 to 63 do
        Store(Zeros{PTO_XLEN} + 256 + NaturalToWord(index as integer {0..262144}),
              1, Zeros{PTO_XLEN} + index);
        Store(Zeros{PTO_XLEN} + 320 + NaturalToWord(index as integer {0..262144}),
              1, Zeros{PTO_XLEN} + 0xaa);
    end;
    ClearFault();
    ExecuteScalarDMACopy64(Zeros{PTO_XLEN} + 256, Zeros{PTO_XLEN} + 320);
    assert _LastFault == Fault_None;
    for index = 0 to 63 do
        let copied_byte = LoadUnsigned(
            Zeros{PTO_XLEN} + 320 + NaturalToWord(index as integer {0..262144}),
            1);
        assert copied_byte == Zeros{PTO_XLEN} + index;
    end;

    WriteGPR(2, Zeros{PTO_XLEN} + 320);
    WriteGPR(3, Zeros{PTO_XLEN} + 384);
    var dma_instruction: bits(48) = Zeros{48} + 0x0000700b;
    dma_instruction[19:15] = Zeros{5} + 2;
    dma_instruction[24:20] = Zeros{5} + 3;
    ClearFault();
    let dma_status = ExecuteScalarInstruction(dma_instruction, 32);
    assert dma_status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    for index = 0 to 63 do
        let decoded_copied_byte = LoadUnsigned(
            Zeros{PTO_XLEN} + 384 + NaturalToWord(index as integer {0..262144}),
            1);
        assert decoded_copied_byte == Zeros{PTO_XLEN} + index;
    end;

    Store(Zeros{PTO_XLEN} + 480, 1, Zeros{PTO_XLEN} + 0x55);
    ClearFault();
    ExecuteScalarDMACopy64(Zeros{PTO_XLEN} + 320, Zeros{PTO_XLEN} + 4080);
    assert _LastFault == Fault_DataPage;
    let preserved_byte = LoadUnsigned(Zeros{PTO_XLEN} + 480, 1);
    assert preserved_byte == Zeros{PTO_XLEN} + 0x55;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarAtomics();
    return 0;
end;
