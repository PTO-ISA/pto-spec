func TestScalarState()
begin
    WriteGPR(1, Zeros{PTO_XLEN} + 42);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 42;
    WriteGPR(0, Ones{PTO_XLEN});
    assert ReadGPR(0) == Zeros{PTO_XLEN};

    WritePC(Zeros{PTO_XLEN} + 16);
    assert ReadPC() == Zeros{PTO_XLEN} + 16;
    WritePredicateRegister(0, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH} + 0x7f);
    // P0 is the hardwired always-active warp predicate. A write cannot
    // suppress it.
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x7f;
    ClearFault();
    assert _LastFault == Fault_None;
end;

// PTO-REQ-PREDICATE-001: the eight 32-bit per-warp predicate registers are
// distinct from the 64-bit kernel EXEC mask. P0 is hardwired all-ones;
// P1..P7 are writable and trap-preserved.
func TestPredicateStateContract()
begin
    ResetProfileState();
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    for index = 1 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        assert ReadPredicateRegister(index as PredicateIndex) ==
            Zeros{PTO_PREDICATE_WIDTH};
    end;
    for index = 0 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        assert !PredicateRegisterHasInstructionConsumer(index as PredicateIndex);
    end;

    WritePredicateRegister(0, Zeros{PTO_PREDICATE_WIDTH});
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    WritePredicateRegister(1, Zeros{PTO_PREDICATE_WIDTH} + 0x11);
    WritePredicateRegister(7,
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001);
    assert !BundleKindUsesExecutionMask(BundleKind_Standard);
    assert !BundleKindUsesExecutionMask(BundleKind_Floating);
    assert !BundleKindUsesExecutionMask(BundleKind_System);
    assert BundleKindUsesExecutionMask(BundleKind_MachineParallel);
    assert BundleKindUsesExecutionMask(BundleKind_MachineSequential);
    assert !BundleKindUsesExecutionMask(BundleKind_TileElement);
    assert !BundleKindUsesExecutionMask(BundleKind_TileMemory);
    assert !BundleKindUsesExecutionMask(BundleKind_TileMatrix);
    assert !BundleKindUsesExecutionMask(BundleKind_FrameTemplate);

    WriteExecutionMask(Zeros{PTO_XLEN} + 0x55);
    _CommitArgument = Zeros{PTO_XLEN} + 0xcc;
    BeginBundle(BundleKind_Standard, BundleTransfer_Conditional,
        Zeros{PTO_XLEN} + 0x80, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, FALSE);
    assert BundleIsActive();
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadExecutionMask() == Zeros{PTO_XLEN} + 0x55;
    EnterBundleBody();
    assert !ExecutionMaskIsActive();
    assert ReadBranchPredicate() == Zeros{PTO_XLEN} + 0xcc;
    StopBundleAt(Zeros{PTO_XLEN} + 4);
    assert !BundleIsActive();
    BeginBundle(BundleKind_MachineParallel, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    assert ExecutionMaskIsActive();
    assert ReadExecutionMask() == Ones{PTO_XLEN};
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(1) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x11;
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;

    StopBundle();
    WriteExecutionMask(Zeros{PTO_XLEN} + 0x55);
    BeginBundle(BundleKind_MachineSequential, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x180, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    assert ExecutionMaskIsActive();
    assert ReadExecutionMask() == Ones{PTO_XLEN};

    // B.Z/B.NZ consume the independent EXEC mask in a bundle body.
    WriteExecutionMask(Zeros{PTO_XLEN});
    WritePredicateRegister(1, Ones{PTO_PREDICATE_WIDTH});
    assert ReadBranchPredicate() == Zeros{PTO_XLEN};

    WriteExecutionMask(Zeros{PTO_XLEN} + 0xaa);
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    SetFault(Fault_Assert, Zeros{PTO_XLEN} + 0x200);
    assert CurrentACR() == 1;
    WriteExecutionMask(Zeros{PTO_XLEN});
    WritePredicateRegister(1, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH});
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert ReadExecutionMask() == Zeros{PTO_XLEN} + 0xaa;
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(1) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(7) ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x80000001;
    WriteExecutionMask(Zeros{PTO_XLEN} + 0xbb);
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_ExecutionStateCheck;
    assert ReadExecutionMask() == Zeros{PTO_XLEN} + 0xbb;
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
    CheckSynchronousTrapMapping(Fault_TileAllocation, Zeros{6} + 5);
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
    RaiseInterrupt(63, Zeros{24} + 0x55);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 44;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 63;
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

// PTO-REQ-FAULT-001, PTO-REQ-SCALAR-SSR-001: all TrapContext leaves have
// direct nonzero save/preserve/recover/invalidate evidence. ECSTATE and the
// recovery-active EBARG words form the portable first-layer context snapshot;
// EBSTATE-only leaves are bounded PTO v0 retention, not portable
// serialization.
func TestTrapContextAllLeafRecoveryEvidence()
begin
    ResetProfileState();
    SetCurrentACR(15);
    _SystemRegisters.core_state = Zeros{PTO_XLEN} + 0xabc0;
    SetCurrentACR(15);
    WriteTPC(Zeros{PTO_XLEN} + 0x1200);
    WriteBPC(Zeros{PTO_XLEN} + 0x2200);
    _BundleArgument = Zeros{PTO_XLEN} + 0x3300;
    _CommitArgument = Zeros{PTO_XLEN} + 0x4400;
    _BundleActive = TRUE;
    _BundleBodyActive = TRUE;
    _BundleKind = BundleKind_TileMatrix;
    _BundleTransfer = BundleTransfer_Conditional;
    _BundleCondition = FALSE;
    _BundleTarget = Zeros{PTO_XLEN} + 0x5500;
    _BundleFallthrough = Zeros{PTO_XLEN} + 0x6600;
    _BundleReturnTarget = Zeros{PTO_XLEN} + 0x7700;
    _ReturnAddress = Zeros{PTO_XLEN} + 0x8800;
    _BundleArgumentKind = Zeros{3} + 5;
    _BundleBodyAddress = Zeros{PTO_XLEN} + 0x2200;
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7} + 0x45,
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE,
        selector = Zeros{10} + 0x155,
        data_type_valid = TRUE,
        data_type = Zeros{5} + 0x11,
        mode_valid = TRUE,
        mode = Zeros{2} + 0x2,
        branch_type_valid = TRUE,
        branch_type = Zeros{3} + 0x5
    });
    SetBundleDimension(0, Zeros{PTO_XLEN} + 0x101);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 0x102);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 0x103);
    SetBundleScalarBinding(0, 31, 24, 25, 26, 3);
    SetBundleScalarBinding(31, 23, 1, 2, 3, 2);
    SetBundleTileBinding(0, TRUE, 2, 8, TRUE, TRUE, 40, 41, TRUE,
        FALSE, FALSE);
    SetBundleTileBinding(15, TRUE, 3, 9, TRUE, FALSE, 63, 0, FALSE,
        TRUE, TRUE);
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE);
    _BundleDataAttributes.data_type = Zeros{5} + 0x11;
    _BundleDataAttributes.data_layout = Zeros{5};
    _BundleDataAttributes.pad_value = Zeros{2} + 0x2;
    _BundleDataAttributes.conversion_mode = Zeros{3} + 0x3;
    _BundleDataAttributes.rounding_mode = Zeros{3} + 0x4;
    _BundleDataAttributes.saturating = TRUE;
    _BundleDataAttributes.canonicalize = TRUE;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = Zeros{PTO_XLEN} + 0x900 + index;
        _UQueue[[index]] = Zeros{PTO_XLEN} + 0xa00 + index;
    end;
    WriteExecutionMask(Zeros{PTO_XLEN} + 0x5a5a);
    _PredicateRegisters[[1]] = Zeros{PTO_PREDICATE_WIDTH} + 0x1111;
    _PredicateRegisters[[7]] = Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    _Accumulator.live = TRUE;
    _Accumulator.logical_data_type = TileDataType_S8;
    _Accumulator.info.allocated = TRUE;
    _Accumulator.info.contents_defined = TRUE;
    _Accumulator.info.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Accumulator.info.defined_elements[0] = '1';
    _Accumulator.info.defined_elements[PTO_MODEL_TILE_ELEMENTS - 1] = '1';
    _Accumulator.info.defined_valid_elements = 1;
    _Accumulator.info.capacity_bytes = 2048;
    _Accumulator.info.rows = 16;
    _Accumulator.info.columns = 16;
    _Accumulator.info.valid_rows = 1;
    _Accumulator.info.valid_columns = 1;
    _Accumulator.info.data_type = TileDataType_S64;
    _Accumulator.info.layout = TileLayout_ColumnMajor;
    _Accumulator.info.location = TileLocation_Matrix;
    _Accumulator.info.payload[[0]] = Zeros{PTO_XLEN} + 0xaaa;
    _Accumulator.info.payload[[PTO_MODEL_TILE_ELEMENTS - 1]] =
        Zeros{PTO_XLEN} + 0xbbb;
    assert TileCapacityIsLegal(_Accumulator.info.capacity_bytes);
    assert TileStorageFitsCapacity(_Accumulator.info.rows,
        _Accumulator.info.columns, _Accumulator.info.data_type,
        _Accumulator.info.capacity_bytes);

    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0xdead);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0xdead;
    // TRAP_CONTEXT_PHASE_SAVE_BEGIN
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x1200;
    assert _TrapContexts[[1]].bpc == Zeros{PTO_XLEN} + 0x2200;
    assert _TrapContexts[[1]].core_state[3:0] == Zeros{4} + 15;
    assert _TrapContexts[[1]].bundle_argument ==
        Zeros{PTO_XLEN} + 0x3300;
    assert _TrapContexts[[1]].commit_argument ==
        Zeros{PTO_XLEN} + 0x4400;
    assert _TrapContexts[[1]].bundle_active;
    assert _TrapContexts[[1]].bundle_body_active;
    assert _TrapContexts[[1]].bundle_kind == BundleKind_TileMatrix;
    assert _TrapContexts[[1]].bundle_transfer ==
        BundleTransfer_Conditional;
    assert !_TrapContexts[[1]].bundle_condition;
    assert _TrapContexts[[1]].bundle_target ==
        Zeros{PTO_XLEN} + 0x5500;
    assert _TrapContexts[[1]].bundle_fallthrough ==
        Zeros{PTO_XLEN} + 0x6600;
    assert _TrapContexts[[1]].bundle_return_target ==
        Zeros{PTO_XLEN} + 0x7700;
    assert _TrapContexts[[1]].return_address ==
        Zeros{PTO_XLEN} + 0x8800;
    assert _TrapContexts[[1]].bundle_argument_kind == Zeros{3} + 5;
    assert _TrapContexts[[1]].bundle_body_address ==
        Zeros{PTO_XLEN} + 0x2200;
    assert _TrapContexts[[1]].bundle_operation.valid;
    assert _TrapContexts[[1]].bundle_operation.form_identity ==
        Zeros{7} + 0x45;
    assert _TrapContexts[[1]].bundle_operation.operation_class ==
        BundleOperation_TileMatrix;
    assert _TrapContexts[[1]].bundle_operation.selector_valid;
    assert _TrapContexts[[1]].bundle_operation.selector == Zeros{10} + 0x155;
    assert _TrapContexts[[1]].bundle_operation.data_type_valid;
    assert _TrapContexts[[1]].bundle_operation.data_type == Zeros{5} + 0x11;
    assert _TrapContexts[[1]].bundle_operation.mode_valid;
    assert _TrapContexts[[1]].bundle_operation.mode == Zeros{2} + 0x2;
    assert _TrapContexts[[1]].bundle_operation.branch_type_valid;
    assert _TrapContexts[[1]].bundle_operation.branch_type == Zeros{3} + 0x5;
    assert _TrapContexts[[1]].bundle_dimensions[[0]] ==
        Zeros{PTO_XLEN} + 0x101;
    assert _TrapContexts[[1]].bundle_dimensions[[2]] ==
        Zeros{PTO_XLEN} + 0x103;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].valid;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].destination == 31;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source0 == 24;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source1 == 25;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source2 == 26;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[0]].source_count == 3;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[31]].valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination_valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination == 2;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination_hand ==
        Zeros{2} + 2;
    assert !_TrapContexts[[1]].bundle_tile_bindings[[0]].destination_allocated_by_bundle;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].destination_size == 8;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source0_valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source1_valid;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source0 == 40;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source1 == 41;
    assert _TrapContexts[[1]].bundle_tile_bindings[[0]].source0_reuse;
    assert !_TrapContexts[[1]].bundle_tile_bindings[[0]].source1_reuse;
    assert !_TrapContexts[[1]].bundle_tile_bindings[[0]].last;
    assert _TrapContexts[[1]].bundle_tile_bindings[[15]].valid;
    assert _TrapContexts[[1]].bundle_control_attributes.trap_enabled;
    assert _TrapContexts[[1]].bundle_control_attributes.atomic;
    assert _TrapContexts[[1]].bundle_control_attributes.acquire;
    assert !_TrapContexts[[1]].bundle_control_attributes.release;
    assert _TrapContexts[[1]].bundle_control_attributes.far;
    assert !_TrapContexts[[1]].bundle_control_attributes.direct_register;
    assert _TrapContexts[[1]].bundle_data_attributes.data_type ==
        Zeros{5} + 0x11;
    assert _TrapContexts[[1]].bundle_data_attributes.data_layout == Zeros{5};
    assert _TrapContexts[[1]].bundle_data_attributes.pad_value ==
        Zeros{2} + 0x2;
    assert _TrapContexts[[1]].bundle_data_attributes.conversion_mode ==
        Zeros{3} + 0x3;
    assert _TrapContexts[[1]].bundle_data_attributes.rounding_mode ==
        Zeros{3} + 0x4;
    assert _TrapContexts[[1]].bundle_data_attributes.saturating;
    assert _TrapContexts[[1]].bundle_data_attributes.canonicalize;
    assert _TrapContexts[[1]].t_queue[[0]] == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].t_queue[[3]] == Zeros{PTO_XLEN} + 0x903;
    assert _TrapContexts[[1]].u_queue[[0]] == Zeros{PTO_XLEN} + 0xa00;
    assert _TrapContexts[[1]].u_queue[[3]] == Zeros{PTO_XLEN} + 0xa03;
    assert _TrapContexts[[1]].execution_mask == Zeros{PTO_XLEN} + 0x5a5a;
    assert _TrapContexts[[1]].predicates[[1]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x1111;
    assert _TrapContexts[[1]].predicates[[7]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    assert _TrapContexts[[1]].accumulator.live;
    assert _TrapContexts[[1]].accumulator.logical_data_type ==
        TileDataType_S8;
    assert _TrapContexts[[1]].accumulator.info.allocated;
    assert _TrapContexts[[1]].accumulator.info.contents_defined;
    assert _TrapContexts[[1]].accumulator.info.defined_elements[0] == '1';
    assert _TrapContexts[[1]].accumulator.info.defined_elements[
        PTO_MODEL_TILE_ELEMENTS - 1] == '1';
    assert _TrapContexts[[1]].accumulator.info.defined_valid_elements == 1;
    assert _TrapContexts[[1]].accumulator.info.capacity_bytes == 2048;
    assert _TrapContexts[[1]].accumulator.info.rows == 16;
    assert _TrapContexts[[1]].accumulator.info.columns == 16;
    assert _TrapContexts[[1]].accumulator.info.valid_rows == 1;
    assert _TrapContexts[[1]].accumulator.info.valid_columns == 1;
    assert _TrapContexts[[1]].accumulator.info.data_type == TileDataType_S64;
    assert _TrapContexts[[1]].accumulator.info.layout ==
        TileLayout_ColumnMajor;
    assert _TrapContexts[[1]].accumulator.info.location ==
        TileLocation_Matrix;
    assert _TrapContexts[[1]].accumulator.info.payload[[0]] ==
        Zeros{PTO_XLEN} + 0xaaa;
    assert _TrapContexts[[1]].accumulator.info.payload[[
        PTO_MODEL_TILE_ELEMENTS - 1]] ==
        Zeros{PTO_XLEN} + 0xbbb;
    // TRAP_CONTEXT_PHASE_SAVE_END

    // Every live counterpart is changed after the save. Recovery assertions
    // below bind each evidence row to the same location and saved value.
    // TRAP_CONTEXT_PHASE_MUTATE_BEGIN
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN});
    WriteBPC(Zeros{PTO_XLEN});
    _SystemRegisters.core_state = Zeros{PTO_XLEN};
    _BundleArgument = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    _BundleKind = BundleKind_Standard;
    _BundleArgumentKind = Zeros{3};
    _BundleTransfer = BundleTransfer_Fallthrough;
    _BundleCondition = TRUE;
    _BundleTarget = Zeros{PTO_XLEN};
    _BundleFallthrough = Zeros{PTO_XLEN};
    _BundleReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
    _BundleBodyAddress = Zeros{PTO_XLEN};
    _BundleOperation.valid = FALSE;
    _BundleOperation.form_identity = Zeros{7};
    _BundleOperation.operation_class = BundleOperation_Control;
    _BundleOperation.selector_valid = FALSE;
    _BundleOperation.selector = Zeros{10};
    _BundleOperation.data_type_valid = FALSE;
    _BundleOperation.data_type = Zeros{5};
    _BundleOperation.mode_valid = FALSE;
    _BundleOperation.mode = Zeros{2};
    _BundleOperation.branch_type_valid = FALSE;
    _BundleOperation.branch_type = Zeros{3};
    _BundleDimensions[[2]] = Zeros{PTO_XLEN};
    _BundleScalarBindings[[0]].valid = FALSE;
    _BundleScalarBindings[[0]].destination = 0;
    _BundleScalarBindings[[0]].source0 = 0;
    _BundleScalarBindings[[0]].source1 = 0;
    _BundleScalarBindings[[0]].source2 = 0;
    _BundleScalarBindings[[0]].source_count = 0;
    _BundleTileBindings[[0]].valid = FALSE;
    _BundleTileBindings[[0]].destination_valid = FALSE;
    _BundleTileBindings[[0]].destination = 0;
    _BundleTileBindings[[0]].destination_hand = Zeros{2};
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    _BundleTileBindings[[0]].destination_size = 0;
    _BundleTileBindings[[0]].source0_valid = FALSE;
    _BundleTileBindings[[0]].source1_valid = FALSE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[0]].source0_reuse = FALSE;
    _BundleTileBindings[[0]].source1_reuse = TRUE;
    _BundleTileBindings[[0]].last = TRUE;
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = TRUE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.direct_register = TRUE;
    _BundleDataAttributes.data_type = Zeros{5};
    _BundleDataAttributes.data_layout = Zeros{5} + 1;
    _BundleDataAttributes.pad_value = Zeros{2};
    _BundleDataAttributes.conversion_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
    _TQueue[[3]] = Zeros{PTO_XLEN};
    _UQueue[[3]] = Zeros{PTO_XLEN};
    _ExecutionMask = Zeros{PTO_XLEN};
    _PredicateRegisters[[7]] = Zeros{PTO_PREDICATE_WIDTH};
    _Accumulator.live = FALSE;
    _Accumulator.logical_data_type = TileDataType_U64;
    _Accumulator.info.allocated = FALSE;
    _Accumulator.info.contents_defined = FALSE;
    _Accumulator.info.defined_elements[0] = '0';
    _Accumulator.info.defined_valid_elements = 0;
    _Accumulator.info.capacity_bytes = 0;
    _Accumulator.info.rows = 0;
    _Accumulator.info.columns = 0;
    _Accumulator.info.valid_rows = 0;
    _Accumulator.info.valid_columns = 0;
    _Accumulator.info.data_type = TileDataType_U64;
    _Accumulator.info.layout = TileLayout_RowMajor;
    _Accumulator.info.location = TileLocation_Any;
    _Accumulator.info.payload[[0]] = Zeros{PTO_XLEN};
    _Accumulator.info.payload[[PTO_MODEL_TILE_ELEMENTS - 1]] =
        Zeros{PTO_XLEN};

    // Each row proves that its live counterpart no longer has the saved value.
    // The evidence checker derives these assertions from the recovery ledger.
    assert CurrentACR() != 15;
    assert ReadTPC() != Zeros{PTO_XLEN} + 0x1200;
    assert ReadBPC() != Zeros{PTO_XLEN} + 0x2200;
    assert _SystemRegisters.core_state[3:0] != Zeros{4} + 15;
    assert _BundleArgument != Zeros{PTO_XLEN} + 0x3300;
    assert _CommitArgument != Zeros{PTO_XLEN} + 0x4400;
    assert !_BundleActive;
    assert !_BundleBodyActive;
    assert _BundleKind != BundleKind_TileMatrix;
    assert _BundleTransfer != BundleTransfer_Conditional;
    assert _BundleCondition;
    assert _BundleTarget != Zeros{PTO_XLEN} + 0x5500;
    assert _BundleFallthrough != Zeros{PTO_XLEN} + 0x6600;
    assert _BundleReturnTarget != Zeros{PTO_XLEN} + 0x7700;
    assert _ReturnAddress != Zeros{PTO_XLEN} + 0x8800;
    assert _BundleArgumentKind != Zeros{3} + 5;
    assert _BundleBodyAddress != Zeros{PTO_XLEN} + 0x2200;
    assert !_BundleOperation.valid;
    assert _BundleOperation.form_identity != Zeros{7} + 0x45;
    assert _BundleOperation.operation_class != BundleOperation_TileMatrix;
    assert !_BundleOperation.selector_valid;
    assert _BundleOperation.selector != Zeros{10} + 0x155;
    assert !_BundleOperation.data_type_valid;
    assert _BundleOperation.data_type != Zeros{5} + 0x11;
    assert !_BundleOperation.mode_valid;
    assert _BundleOperation.mode != Zeros{2} + 0x2;
    assert !_BundleOperation.branch_type_valid;
    assert _BundleOperation.branch_type != Zeros{3} + 0x5;
    assert _BundleDimensions[[2]] != Zeros{PTO_XLEN} + 0x103;
    assert !_BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].destination != 31;
    assert _BundleScalarBindings[[0]].source0 != 24;
    assert _BundleScalarBindings[[0]].source1 != 25;
    assert _BundleScalarBindings[[0]].source2 != 26;
    assert _BundleScalarBindings[[0]].source_count != 3;
    assert !_BundleTileBindings[[0]].valid;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination != 2;
    assert _BundleTileBindings[[0]].destination_hand != Zeros{2} + 2;
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _BundleTileBindings[[0]].destination_size != 8;
    assert !_BundleTileBindings[[0]].source0_valid;
    assert !_BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].source0 != 40;
    assert _BundleTileBindings[[0]].source1 != 41;
    assert !_BundleTileBindings[[0]].source0_reuse;
    assert _BundleTileBindings[[0]].source1_reuse;
    assert _BundleTileBindings[[0]].last;
    assert !_BundleControlAttributes.trap_enabled;
    assert !_BundleControlAttributes.atomic;
    assert !_BundleControlAttributes.acquire;
    assert _BundleControlAttributes.release;
    assert !_BundleControlAttributes.far;
    assert _BundleControlAttributes.direct_register;
    assert _BundleDataAttributes.data_type != Zeros{5} + 0x11;
    assert _BundleDataAttributes.data_layout != Zeros{5};
    assert _BundleDataAttributes.pad_value != Zeros{2} + 0x2;
    assert _BundleDataAttributes.conversion_mode != Zeros{3} + 0x3;
    assert _BundleDataAttributes.rounding_mode != Zeros{3} + 0x4;
    assert !_BundleDataAttributes.saturating;
    assert !_BundleDataAttributes.canonicalize;
    assert _TQueue[[3]] != Zeros{PTO_XLEN} + 0x903;
    assert _UQueue[[3]] != Zeros{PTO_XLEN} + 0xa03;
    assert _ExecutionMask != Zeros{PTO_XLEN} + 0x5a5a;
    assert _PredicateRegisters[[7]] !=
        Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    assert !_Accumulator.live;
    assert _Accumulator.logical_data_type != TileDataType_S8;
    assert !_Accumulator.info.allocated;
    assert !_Accumulator.info.contents_defined;
    assert _Accumulator.info.defined_elements[0] != '1';
    assert _Accumulator.info.defined_valid_elements != 1;
    assert _Accumulator.info.capacity_bytes != 2048;
    assert _Accumulator.info.rows != 16;
    assert _Accumulator.info.columns != 16;
    assert _Accumulator.info.valid_rows != 1;
    assert _Accumulator.info.valid_columns != 1;
    assert _Accumulator.info.data_type != TileDataType_S64;
    assert _Accumulator.info.layout != TileLayout_ColumnMajor;
    assert _Accumulator.info.location != TileLocation_Matrix;
    assert _Accumulator.info.payload[[0]] != Zeros{PTO_XLEN} + 0xaaa;
    // TRAP_CONTEXT_PHASE_MUTATE_END

    // TRAP_CONTEXT_RECOVER_CALL
    let recovered_all_leaf_context = RecoverTrapContext(1);
    assert recovered_all_leaf_context;
    // TRAP_CONTEXT_PHASE_RECOVER_BEGIN
    assert CurrentACR() == 15;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x1200;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x2200;
    assert _SystemRegisters.core_state[3:0] == Zeros{4} + 15;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x3300;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x4400;
    assert _BundleActive;
    assert _BundleBodyActive;
    assert _BundleKind == BundleKind_TileMatrix;
    assert _BundleTransfer == BundleTransfer_Conditional;
    assert !_BundleCondition;
    assert _BundleTarget == Zeros{PTO_XLEN} + 0x5500;
    assert _BundleFallthrough == Zeros{PTO_XLEN} + 0x6600;
    assert _BundleReturnTarget == Zeros{PTO_XLEN} + 0x7700;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x8800;
    assert _BundleArgumentKind == Zeros{3} + 5;
    assert _BundleBodyAddress == Zeros{PTO_XLEN} + 0x2200;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} + 0x45;
    assert _BundleOperation.operation_class == BundleOperation_TileMatrix;
    assert _BundleOperation.selector_valid;
    assert _BundleOperation.selector == Zeros{10} + 0x155;
    assert _BundleOperation.data_type_valid;
    assert _BundleOperation.data_type == Zeros{5} + 0x11;
    assert _BundleOperation.mode_valid;
    assert _BundleOperation.mode == Zeros{2} + 0x2;
    assert _BundleOperation.branch_type_valid;
    assert _BundleOperation.branch_type == Zeros{3} + 0x5;
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 0x103;
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].destination == 31;
    assert _BundleScalarBindings[[0]].source0 == 24;
    assert _BundleScalarBindings[[0]].source1 == 25;
    assert _BundleScalarBindings[[0]].source2 == 26;
    assert _BundleScalarBindings[[0]].source_count == 3;
    assert _BundleTileBindings[[0]].valid;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].destination == 2;
    assert _BundleTileBindings[[0]].destination_hand == Zeros{2} + 2;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _BundleTileBindings[[0]].destination_size == 8;
    assert _BundleTileBindings[[0]].source0_valid;
    assert _BundleTileBindings[[0]].source1_valid;
    assert _BundleTileBindings[[0]].source0 == 40;
    assert _BundleTileBindings[[0]].source1 == 41;
    assert _BundleTileBindings[[0]].source0_reuse;
    assert !_BundleTileBindings[[0]].source1_reuse;
    assert !_BundleTileBindings[[0]].last;
    assert _BundleControlAttributes.trap_enabled;
    assert _BundleControlAttributes.atomic;
    assert _BundleControlAttributes.acquire;
    assert !_BundleControlAttributes.release;
    assert _BundleControlAttributes.far;
    assert !_BundleControlAttributes.direct_register;
    assert _BundleDataAttributes.data_type == Zeros{5} + 0x11;
    assert _BundleDataAttributes.data_layout == Zeros{5};
    assert _BundleDataAttributes.pad_value == Zeros{2} + 0x2;
    assert _BundleDataAttributes.conversion_mode == Zeros{3} + 0x3;
    assert _BundleDataAttributes.rounding_mode == Zeros{3} + 0x4;
    assert _BundleDataAttributes.saturating;
    assert _BundleDataAttributes.canonicalize;
    assert _TQueue[[3]] == Zeros{PTO_XLEN} + 0x903;
    assert _UQueue[[3]] == Zeros{PTO_XLEN} + 0xa03;
    assert _ExecutionMask == Zeros{PTO_XLEN} + 0x5a5a;
    assert _PredicateRegisters[[1]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x1111;
    assert _PredicateRegisters[[7]] ==
        Zeros{PTO_PREDICATE_WIDTH} + 0x7777;
    assert _Accumulator.live;
    assert _Accumulator.logical_data_type == TileDataType_S8;
    assert _Accumulator.info.allocated;
    assert _Accumulator.info.contents_defined;
    assert _Accumulator.info.defined_elements[0] == '1';
    assert _Accumulator.info.defined_valid_elements == 1;
    assert _Accumulator.info.capacity_bytes == 2048;
    assert _Accumulator.info.rows == 16;
    assert _Accumulator.info.columns == 16;
    assert _Accumulator.info.valid_rows == 1;
    assert _Accumulator.info.valid_columns == 1;
    assert _Accumulator.info.data_type == TileDataType_S64;
    assert _Accumulator.info.layout == TileLayout_ColumnMajor;
    assert _Accumulator.info.location == TileLocation_Matrix;
    assert _Accumulator.info.payload[[0]] == Zeros{PTO_XLEN} + 0xaaa;
    assert _Accumulator.info.payload[[PTO_MODEL_TILE_ELEMENTS - 1]] ==
        Zeros{PTO_XLEN} + 0xbbb;
    // TRAP_CONTEXT_PHASE_RECOVER_END
    // TRAP_CONTEXT_PHASE_INVALIDATE_BEGIN
    assert !_TrapContexts[[1]].valid;
    // TRAP_CONTEXT_PHASE_INVALIDATE_END

    // Execute the portable default helper directly even under the PTO v0
    // profile, so the concrete override cannot hide default-path drift.
    ResetProfileState();
    SetCurrentACR(15);
    _BundleArgument = Zeros{PTO_XLEN} + 0x1110;
    _CommitArgument = Zeros{PTO_XLEN} + 0x2220;
    _BundleReturnTarget = Zeros{PTO_XLEN} + 0x3330;
    _ReturnAddress = Zeros{PTO_XLEN} + 0x4440;
    _BundleArgumentKind = Zeros{3} + 6;
    SavePortableTrapContext(2, 15);
    _BundleArgument = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _BundleReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
    let recovered_portable_context = RecoverPortableTrapContext(2);
    assert recovered_portable_context;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x1110;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x2220;
    assert _BundleReturnTarget == Zeros{PTO_XLEN} + 0x3330;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x4440;
    assert _BundleArgumentKind == Zeros{3} + 6;

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
    assert TileCapacityIsLegal(128);
    assert TileCapacityIsLegal(256);
    assert TileCapacityIsLegal(262144);
    assert !TileCapacityIsLegal(192);
    assert !TileCapacityIsLegal(32);
    assert TileSizeCodeBytes(3) == 128;
    assert TileSizeCodeBytes(9) == 8192;
    assert !TileSizeCodeIsLegal(2);
    assert !TileSizeCodeIsLegal(10);

    assert TileElementBits(TileDataType_FP64) == 64;
    assert TileElementBits(TileDataType_FP32) == 32;
    assert TileElementBits(TileDataType_TF32) == 32;
    assert TileElementBits(TileDataType_HF32) == 32;
    assert TileElementBits(TileDataType_FP16) == 16;
    assert TileElementBits(TileDataType_BF16) == 16;
    assert TileElementBits(TileDataType_HiF8) == 8;
    assert TileElementBits(TileDataType_E4M3) == 8;
    assert TileElementBits(TileDataType_E5M2) == 8;
    assert TileElementBits(TileDataType_E3M2) == 8;
    assert TileElementBits(TileDataType_E2M3) == 8;
    assert TileElementBits(TileDataType_E2M1X2) == 4;
    assert TileElementBits(TileDataType_E1M2X2) == 4;
    assert TileElementBits(TileDataType_E8M0) == 8;
    assert TileElementBits(TileDataType_HiF4X2) == 4;
    assert TileElementBits(TileDataType_S8) == 8;
    assert TileElementBits(TileDataType_U8) == 8;
    assert TileElementBits(TileDataType_S16) == 16;
    assert TileElementBits(TileDataType_U16) == 16;
    assert TileElementBits(TileDataType_S32) == 32;
    assert TileElementBits(TileDataType_U32) == 32;
    assert TileElementBits(TileDataType_S64) == 64;
    assert TileElementBits(TileDataType_U64) == 64;
    assert TileElementBits(TileDataType_S4X2) == 4;
    assert TileElementBits(TileDataType_U4X2) == 4;

    for code = 0 to 63 do
        let encoded = Zeros{PTO_XLEN} + code;
        let expected = (0 <= code && code <= 14) ||
                       (16 <= code && code <= 20) ||
                       (24 <= code && code <= 28);
        assert TileDataTypeEncodingValid(encoded) == expected;
    end;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN}) == TileDataType_FP64;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 1) == TileDataType_FP32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 2) == TileDataType_TF32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 3) == TileDataType_HF32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 4) == TileDataType_FP16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 5) == TileDataType_BF16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 6) == TileDataType_HiF8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 7) == TileDataType_E4M3;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 8) == TileDataType_E5M2;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 9) == TileDataType_E3M2;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 10) == TileDataType_E2M3;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 11) ==
        TileDataType_E2M1X2;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 12) ==
        TileDataType_E1M2X2;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 13) == TileDataType_E8M0;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 14) ==
        TileDataType_HiF4X2;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 16) == TileDataType_S64;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 17) == TileDataType_S32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 18) == TileDataType_S16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 19) == TileDataType_S8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 20) == TileDataType_S4X2;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 24) == TileDataType_U64;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 25) == TileDataType_U32;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 26) == TileDataType_U16;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 27) == TileDataType_U8;
    assert TileDataTypeFromEncoding(Zeros{PTO_XLEN} + 28) == TileDataType_U4X2;
    assert !TileDataTypeEncodingValid(Zeros{PTO_XLEN} + 15);
    assert TileStorageBytes(1, 1, TileDataType_U4X2) == 1;
    assert TileStorageBytes(1, 2, TileDataType_U4X2) == 1;
    assert TileStorageBytes(1, 3, TileDataType_U4X2) == 2;
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

    // Both endpoints of the architectural interrupt-ID domain become pending
    // without taking a trap when external interrupt entry is disabled.
    WriteSystemRegisterAddress(Zeros{24} + 0x0f07, Zeros{PTO_XLEN} + 2);
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x5150);
    RaiseInterrupt(0, Zeros{24} + 0x50);
    RaiseInterrupt(63, Zeros{24} + 0x5f);
    assert _LastFault == Fault_None;
    assert CurrentACR() == 0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x5150;
    assert _ACRTrapNumber[[0]] == Zeros{6};
    assert !_ACRTrapAsynchronous[[0]];
    assert !_TrapContexts[[0]].valid;
    let boundary_pending = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    let zero_is_top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert boundary_pending[0] == '1' && boundary_pending[63] == '1';
    assert zero_is_top == Zeros{PTO_XLEN};
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN});
    let maximum_is_top = ReadSystemRegisterAddress(Zeros{24} + 0x0f09);
    assert maximum_is_top == Zeros{PTO_XLEN} + 63;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a,
        Zeros{PTO_XLEN} + 63);
    let boundary_acknowledged = ReadSystemRegisterAddress(Zeros{24} + 0x0f08);
    assert boundary_acknowledged == Zeros{PTO_XLEN};

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
