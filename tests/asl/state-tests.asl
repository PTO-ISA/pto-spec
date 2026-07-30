func TestScalarState()
begin
    WriteGPR(1, Zeros{PTO_XLEN} + 42);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 42;
    WriteGPR(0, Ones{PTO_XLEN});
    assert ReadGPR(0) == Zeros{PTO_XLEN};

    WritePC(Zeros{PTO_XLEN} + 16);
    assert ReadPC() == Zeros{PTO_XLEN} + 16;
    WritePredicateRegister(0, Zeros{PTO_XLEN} + 0xf0);
    WritePredicateRegister(7, Zeros{PTO_XLEN} + 0x7f);
    assert ReadPredicateRegister(0) == Zeros{PTO_XLEN} + 0xf0;
    assert ReadPredicateRegister(7) == Zeros{PTO_XLEN} + 0x7f;
    ClearFault();
    assert _LastFault == Fault_None;
end;

// PTO-REQ-PREDICATE-001: P0 is the bundle-body EXEC predicate. P1..P7 are
// resettable and trap-preserved visible state with no PTO v0 instruction
// consumer.
func TestPredicateStateContract()
begin
    ResetProfileState();
    for index = 0 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        assert ReadPredicateRegister(index as PredicateIndex) ==
            Zeros{PTO_XLEN};
    end;
    assert PredicateRegisterHasInstructionConsumer(0);
    for index = 1 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        assert !PredicateRegisterHasInstructionConsumer(index as PredicateIndex);
    end;

    WritePredicateRegister(1, Zeros{PTO_XLEN} + 0x11);
    WritePredicateRegister(7, Zeros{PTO_XLEN} + 0x77);
    WritePredicateRegister(0, Zeros{PTO_XLEN} + 0x55);
    BeginBundle(BundleKind_Standard, BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x80, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, FALSE);
    assert BundleIsActive();
    assert ReadPredicateRegister(0) == Zeros{PTO_XLEN} + 0x55;
    StopBundleAt(Zeros{PTO_XLEN} + 4);
    assert !BundleIsActive();
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    assert ReadPredicateRegister(0) == Ones{PTO_XLEN};
    assert ReadPredicateRegister(1) == Zeros{PTO_XLEN} + 0x11;
    assert ReadPredicateRegister(7) == Zeros{PTO_XLEN} + 0x77;

    // B.Z/B.NZ consume only P0 in a bundle body.
    WritePredicateRegister(0, Zeros{PTO_XLEN});
    WritePredicateRegister(1, Ones{PTO_XLEN});
    assert ReadBranchPredicate() == Zeros{PTO_XLEN};

    WritePredicateRegister(0, Zeros{PTO_XLEN} + 0xaa);
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_Assert, Zeros{PTO_XLEN} + 0x200);
    assert CurrentACR() == 1;
    WritePredicateRegister(0, Zeros{PTO_XLEN});
    WritePredicateRegister(1, Zeros{PTO_XLEN});
    WritePredicateRegister(7, Zeros{PTO_XLEN});
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert ReadPredicateRegister(0) == Zeros{PTO_XLEN} + 0xaa;
    assert ReadPredicateRegister(1) == Ones{PTO_XLEN};
    assert ReadPredicateRegister(7) == Zeros{PTO_XLEN} + 0x77;
    WritePredicateRegister(0, Zeros{PTO_XLEN} + 0xbb);
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_ExecutionStateCheck;
    assert ReadPredicateRegister(0) == Zeros{PTO_XLEN} + 0xbb;
    ResetProfileState();
end;

func TestTrapRoutingPolicy()
begin
    assert TrapTargetForFault(0) == 0;
    assert TrapTargetForFault(1) == 1;
    assert TrapTargetForFault(2) == 1;
    assert TrapTargetForFault(15) == 1;
    assert TrapTargetForInterrupt(0) == 0;
    assert TrapTargetForInterrupt(1) == 1;
    assert TrapTargetForInterrupt(2) == 1;
    assert TrapTargetForInterrupt(15) == 1;

    ResetProfileState();
    SetCurrentACR(1);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    SetFault(Fault_IllegalInstruction, Zeros{PTO_XLEN} + 0x100);
    assert CurrentACR() == 1;
    assert _TrapContexts[[1]].source_acr == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 4;

    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x300);
    assert CurrentACR() == 1;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x300;

    ResetProfileState();
end;

func CheckSynchronousTrapMapping(code: FaultCode, expected: TrapNumber)
begin
    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x1000);
    SetFault(code, Zeros{PTO_XLEN} + 0x2000);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == expected;
    assert _ACRTrapArgumentValid[[1]];
    assert !_ACRTrapAsynchronous[[1]];
    assert _ACRTrapCause[[1]] == Zeros{24};
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x2000;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x1000;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert CurrentACR() == 15;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x1000;
    assert !_TrapContexts[[1]].valid;
end;

// PTO-REQ-FAULT-001: every cataloged trap identity has an executable entry
// envelope. PTO v0 may leave its trigger inactive, but number, routing,
// argument, saved context, and restart snapshot remain fully defined.
func TestCompleteTrapEnvelope()
begin
    CheckSynchronousTrapMapping(Fault_ExecutionStateCheck, Zeros{6});
    CheckSynchronousTrapMapping(Fault_IllegalInstruction, Zeros{6} + 4);
    CheckSynchronousTrapMapping(Fault_BundleControl, Zeros{6} + 5);
    CheckSynchronousTrapMapping(Fault_TileLegality, Zeros{6} + 5);
    CheckSynchronousTrapMapping(Fault_ServiceRequest, Zeros{6} + 6);
    CheckSynchronousTrapMapping(Fault_InstructionPC, Zeros{6} + 32);
    CheckSynchronousTrapMapping(Fault_InstructionPage, Zeros{6} + 33);
    CheckSynchronousTrapMapping(Fault_DataAlignment, Zeros{6} + 34);
    CheckSynchronousTrapMapping(Fault_DataPage, Zeros{6} + 35);
    CheckSynchronousTrapMapping(Fault_HardwareBreakpoint, Zeros{6} + 49);
    CheckSynchronousTrapMapping(Fault_SoftwareBreakpoint, Zeros{6} + 50);
    CheckSynchronousTrapMapping(Fault_HardwareWatchpoint, Zeros{6} + 51);
    CheckSynchronousTrapMapping(Fault_Assert, Zeros{6} + 52);

    ResetProfileState();
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x3000);
    RaiseInterrupt(Zeros{PTO_XLEN} + 7, Zeros{24} + 0x55);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 44;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 7;
    assert _ACRTrapCause[[1]] == Zeros{24} + 0x55;
    assert _ACRTrapAsynchronous[[1]];
    assert _ACRTrapArgumentValid[[1]];
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x3000;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert CurrentACR() == 15;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x3000;
    ResetProfileState();
end;

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
    assert saved_lb == Zeros{PTO_XLEN};
    assert saved_lc == Zeros{PTO_XLEN};
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
    assert recovered_lb == Zeros{PTO_XLEN} + 0x14d;
    assert recovered_lc == Zeros{PTO_XLEN} + 0x14e;
    assert recovered_extctx_ptr == Zeros{PTO_XLEN} + 0x14f;
    assert recovered_extctx_meta == Zeros{PTO_XLEN} + 0x150;
    assert recovered_tplflags == Zeros{PTO_XLEN} + 0x151;
    ResetProfileState();
end;

func TestTileRegisterMapping()
begin
    assert TileHandOf(0) == TileHand_T;
    assert TileHandOf(15) == TileHand_T;
    assert TileHandOf(16) == TileHand_U;
    assert TileHandOf(32) == TileHand_M;
    assert TileHandOf(63) == TileHand_N;
    assert TileIndexWithinHand(0) == 1;
    assert TileIndexWithinHand(63) == 16;

    assert !TileCapacityIsLegal(0);
    assert TileCapacityIsLegal(256);
    assert TileCapacityIsLegal(262144);
    assert TileCapacityIsLegal(524288);
    assert !TileCapacityIsLegal(32);
    assert TileElementBits(TileDataType_F64) == 64;
    assert TileElementBits(TileDataType_S8) == 8;
    assert TileElementBits(TileDataType_U8) == 8;
    assert TileElementBits(TileDataType_S16) == 16;
    assert TileElementBits(TileDataType_U16) == 16;
    assert TileElementBits(TileDataType_S32) == 32;
    assert TileElementBits(TileDataType_U32) == 32;
    assert TileElementBits(TileDataType_S64) == 64;
    assert TileElementBits(TileDataType_U64) == 64;
    assert TileElementBits(TileDataType_F16) == 16;
    assert TileElementBits(TileDataType_BF16) == 16;
    assert TileElementBits(TileDataType_F32) == 32;
    assert TileElementBits(TileDataType_FP8) == 8;
    assert TileElementBits(TileDataType_FPL8) == 8;
    assert TileElementBits(TileDataType_FP4) == 4;
    assert TileElementBits(TileDataType_FPL4) == 4;
    assert TileElementBits(TileDataType_S4) == 4;
    assert TileElementBits(TileDataType_U4) == 4;
    assert TileElementBits(TileDataType_E8M0) == 8;

    for code = 0 to 63 do
        let encoded = Zeros{PTO_XLEN} + code;
        let expected = code == 0 || code == 1 || code == 2 || code == 3 ||
                       code == 6 || code == 7 || code == 11 || code == 12 ||
                       (16 <= code && code <= 20) ||
                       (24 <= code && code <= 28);
        assert TileDataTypeEncodingValid(encoded) == expected;
    end;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN}) == TileDataType_F64;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 1) == TileDataType_F32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 2) == TileDataType_F16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 3) == TileDataType_FP8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 6) == TileDataType_BF16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 7) == TileDataType_FPL8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 11) == TileDataType_FP4;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 12) == TileDataType_FPL4;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 16) == TileDataType_S64;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 17) == TileDataType_S32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 18) == TileDataType_S16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 19) == TileDataType_S8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 20) == TileDataType_S4;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 24) == TileDataType_U64;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 25) == TileDataType_U32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 26) == TileDataType_U16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 27) == TileDataType_U8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 28) == TileDataType_U4;
    assert !TileDataTypeEncodingValid(Zeros{PTO_XLEN} + 13);
    assert TileStorageBytes(1, 1, TileDataType_U4) == 1;
    assert TileStorageBytes(1, 2, TileDataType_U4) == 1;
    assert TileStorageBytes(1, 3, TileDataType_U4) == 2;
    assert TileStorageBytes(2, 2, TileDataType_U64) == 32;
    assert TileStorageFitsCapacity(32, 8, TileDataType_U8, 256);
    assert !TileStorageFitsCapacity(33, 1, TileDataType_U64, 256);
end;

func TestScalarTemporaryQueues()
begin
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 10);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 20);
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 20;
    assert ReadScalarRegisterOperand(25) == Zeros{PTO_XLEN} + 10;

    WriteScalarDestination(30, Zeros{PTO_XLEN} + 300);
    WriteScalarDestination(30, Zeros{PTO_XLEN} + 301);
    WriteScalarDestination(31, Zeros{PTO_XLEN} + 310);
    assert ReadScalarRegisterOperand(28) == Zeros{PTO_XLEN} + 301;
    assert ReadScalarRegisterOperand(29) == Zeros{PTO_XLEN} + 300;
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 310;

    WriteGPR(5, Zeros{PTO_XLEN} + 5);
    WriteScalarDestination(24, Ones{PTO_XLEN});
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 5;
end;

func TestTileAllocationState()
begin
    ConfigureTile(5, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_ImplementationDefined, TileLocation_Any);
    assert _Tiles[[5]].allocated;
    assert !_Tiles[[5]].contents_defined;
    assert TileDescriptorConfigured(5);
    assert !TileGenericIndexingPermitted(_Tiles[[5]]);
    assert !TileDescriptorLegal(5);

    ConfigureTile(5, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert !_Tiles[[5]].contents_defined;
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 9);
    assert _Tiles[[5]].contents_defined;
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 9;
end;

// PTO-REQ-INTERRUPT-001: pending, priority, acknowledgement, enable, and timer
// comparison state are coherent across the visible ACR register family.
func TestInterruptRegisterState()
begin
    ResetProfileState();
    assert _ExtendedSystemRegisters[[0x0f07]] == Zeros{PTO_XLEN} + 3;
    assert _ExtendedSystemRegisters[[0xff07]] == Zeros{PTO_XLEN} + 3;
    let reset_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    assert reset_pending == Zeros{PTO_XLEN};

    SetInterruptPending(0, 7);
    SetInterruptPending(0, 2);
    let pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    let top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert pending[7] == '1' && pending[2] == '1';
    assert top == Zeros{PTO_XLEN} + 2;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 2);
    let remaining_top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert remaining_top == Zeros{PTO_XLEN} + 7;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 7);
    let acknowledged_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    assert acknowledged_pending == Zeros{PTO_XLEN};

    // A disabled external interrupt becomes pending without taking a trap.
    WriteSystemRegisterAddress(Zeros{24} + 0x0f07, Zeros{PTO_XLEN} + 2);
    RaiseInterrupt(Zeros{PTO_XLEN} + 7, Zeros{24} + 0x55);
    assert _ACRTrapNumber[[0]] == Zeros{6};
    let disabled_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    assert disabled_pending[7] == '1';
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 7);

    // Ring-one timer interrupt ID 3 follows the compare value. Acknowledge can
    // clear it transiently, but it reasserts until software clears comparison.
    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 9;
    WriteSystemRegisterAddress(Zeros{24} + 0x1f21,
        Zeros{PTO_XLEN} + 10);
    let timer_before = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    assert timer_before[3] == '0';
    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 10;
    let timer_at_compare = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    let timer_top = ReadSystemRegisterAddress(Zeros{24} + 0x1f09);
    assert timer_at_compare[3] == '1';
    assert timer_top == Zeros{PTO_XLEN} + 3;
    WriteSystemRegisterAddress(Zeros{24} + 0x1f0a,
        Zeros{PTO_XLEN} + 3);
    let timer_reasserted = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    assert timer_reasserted[3] == '1';
    WriteSystemRegisterAddress(Zeros{24} + 0x1f21,
        Zeros{PTO_XLEN});
    let timer_disabled = ReadSystemRegisterAddress(Zeros{24} + 0x1f08);
    assert timer_disabled[3] == '0';
    ResetProfileState();
end;
