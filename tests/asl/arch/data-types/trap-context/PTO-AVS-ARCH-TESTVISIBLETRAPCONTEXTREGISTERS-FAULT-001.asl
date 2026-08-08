// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTVISIBLETRAPCONTEXTREGISTERS-FAULT-001","source":"asl/arch/data-types/trap-context.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for TestVisibleTrapContextRegisters","pass_condition":"TestVisibleTrapContextRegisters completes without assertion failure","related_sources":[]}
func TestVisibleTrapContextRegisters()
begin
    ResetProfileState();
    SetCurrentACR(0);
    ClearFault();

    WriteSystemRegisterAddress(Zeros{24} + 0x0f40,
        Zeros{PTO_XLEN} + 0x40);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f45,
        Zeros{PTO_XLEN} + 0x145);
    WriteSystemRegisterAddress(Zeros{24} + 0xff51,
        Zeros{PTO_XLEN} + 0xf51);
    assert _LastFault == Fault_None;
    let ebarg0 = ReadSystemRegisterAddress(Zeros{24} + 0x0f40);
    let ebarg_tq0 = ReadSystemRegisterAddress(Zeros{24} + 0x1f45);
    let ebarg_tplflags = ReadSystemRegisterAddress(Zeros{24} + 0xff51);
    let other_bank_ebarg0 = ReadSystemRegisterAddress(Zeros{24} + 0x1f40);
    assert ebarg0 == Zeros{PTO_XLEN} + 0x40;
    assert ebarg_tq0 == Zeros{PTO_XLEN} + 0x145;
    assert ebarg_tplflags == Zeros{PTO_XLEN} + 0xf51;
    assert other_bank_ebarg0 == Zeros{PTO_XLEN};

    SetCurrentACR(1);
    ClearFault();
    WriteSystemRegisterAddress(Zeros{24} + 0x1f40,
        Ones{PTO_XLEN});
    assert _LastFault == Fault_IllegalInstruction;
    assert CurrentACR() == 1;

    ResetProfileState();
    assert _ExtendedSystemRegisters[[0x0f40]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0x1f45]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0xff51]] == Zeros{PTO_XLEN};

    // PTO-REQ-SCALAR-SSR-001: the EBARG tail is visible context storage,
    // not recovery-active state. Trap save clears LB/LC, preserves the three
    // extended words, and recovery consumes none of the five values.
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f4d,
        Zeros{PTO_XLEN} + 0x4d);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f4e,
        Zeros{PTO_XLEN} + 0x4e);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f4f,
        Zeros{PTO_XLEN} + 0x4f);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f50,
        Zeros{PTO_XLEN} + 0x50);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f51,
        Zeros{PTO_XLEN} + 0x51);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteBPC(Zeros{PTO_XLEN} + 0x100);
    SaveTrapContext(1, 2);
    let saved_lb = ReadSystemRegisterAddress(Zeros{24} + 0x1f4d);
    let saved_lc = ReadSystemRegisterAddress(Zeros{24} + 0x1f4e);
    let saved_extctx_ptr = ReadSystemRegisterAddress(Zeros{24} + 0x1f4f);
    let saved_extctx_meta = ReadSystemRegisterAddress(Zeros{24} + 0x1f50);
    let saved_tplflags = ReadSystemRegisterAddress(Zeros{24} + 0x1f51);
    // SYSREG-EFFECT-WITNESS saved-loop-context-storage/trap-save-clears-value
    assert saved_lb == Zeros{PTO_XLEN};
    assert saved_lc == Zeros{PTO_XLEN};
    // SYSREG-EFFECT-WITNESS extended-context-storage/trap-save-preserves-value
    assert saved_extctx_ptr == Zeros{PTO_XLEN} + 0x4f;
    assert saved_extctx_meta == Zeros{PTO_XLEN} + 0x50;
    assert saved_tplflags == Zeros{PTO_XLEN} + 0x51;

    WriteSystemRegisterAddress(Zeros{24} + 0x1f4d,
        Zeros{PTO_XLEN} + 0x14d);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f4e,
        Zeros{PTO_XLEN} + 0x14e);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f4f,
        Zeros{PTO_XLEN} + 0x14f);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f50,
        Zeros{PTO_XLEN} + 0x150);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f51,
        Zeros{PTO_XLEN} + 0x151);
    let recovered_tail_context = RecoverTrapContext(1);
    assert recovered_tail_context;
    assert CurrentACR() == 2;
    SetCurrentACR(0);
    let recovered_lb = ReadSystemRegisterAddress(Zeros{24} + 0x1f4d);
    let recovered_lc = ReadSystemRegisterAddress(Zeros{24} + 0x1f4e);
    let recovered_extctx_ptr =
        ReadSystemRegisterAddress(Zeros{24} + 0x1f4f);
    let recovered_extctx_meta =
        ReadSystemRegisterAddress(Zeros{24} + 0x1f50);
    let recovered_tplflags = ReadSystemRegisterAddress(Zeros{24} + 0x1f51);
    // SYSREG-EFFECT-WITNESS saved-loop-context-storage/pto-v0-recovery-does-not-consume-value
    assert recovered_lb == Zeros{PTO_XLEN} + 0x14d;
    assert recovered_lc == Zeros{PTO_XLEN} + 0x14e;
    // SYSREG-EFFECT-WITNESS extended-context-storage/pto-v0-recovery-does-not-consume-value
    assert recovered_extctx_ptr == Zeros{PTO_XLEN} + 0x14f;
    assert recovered_extctx_meta == Zeros{PTO_XLEN} + 0x150;
    assert recovered_tplflags == Zeros{PTO_XLEN} + 0x151;
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestVisibleTrapContextRegisters();
    return 0;
end;
