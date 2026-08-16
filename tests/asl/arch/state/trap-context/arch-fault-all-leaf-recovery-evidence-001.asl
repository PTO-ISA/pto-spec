// PTO-TEST: {"id":"PTO-AVS-ARCH-TRAP-CONTROL-FAULT-001","source":"asl/arch/state/trap-context.asl","requirements":[],"kind":"fault","summary":"trap recovery restores control-flow and block-control leaves","pass_condition":"saved control leaves differ before recovery and match after recovery","related_sources":[]}
func TestTrapControlLeafRecovery()
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
    _BARG.block_type = BundleKind_TileMatrix;
    _BARG.transfer_type = BundleTransfer_Conditional;
    _BARG.taken = FALSE;
    _BARG.bpcn = Zeros{PTO_XLEN} + 0x5500;
    _BundleSequentialPC = Zeros{PTO_XLEN} + 0x6600;
    _FrameStackReturnTarget = Zeros{PTO_XLEN} + 0x7700;
    _ReturnAddress = Zeros{PTO_XLEN} + 0x8800;
    _BundleArgumentKind = Zeros{3} + 5;
    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0xdead);
    assert CurrentACR() == 1;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0xdead;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 15;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x1200;
    assert _TrapContexts[[1]].bpc == Zeros{PTO_XLEN} + 0x2200;
    assert _TrapContexts[[1]].core_state[3:0] == '1111';
    assert _TrapContexts[[1]].bundle_argument ==
        Zeros{PTO_XLEN} + 0x3300;
    assert _TrapContexts[[1]].commit_argument ==
        Zeros{PTO_XLEN} + 0x4400;
    assert _TrapContexts[[1]].bundle_active;
    assert _TrapContexts[[1]].bundle_body_active;
    assert _TrapContexts[[1]].barg.block_type == BundleKind_TileMatrix;
    assert _TrapContexts[[1]].barg.transfer_type ==
        BundleTransfer_Conditional;
    assert !_TrapContexts[[1]].barg.taken;
    assert _TrapContexts[[1]].barg.bpcn ==
        Zeros{PTO_XLEN} + 0x5500;
    assert _TrapContexts[[1]].bundle_sequential_pc ==
        Zeros{PTO_XLEN} + 0x6600;
    assert _TrapContexts[[1]].frame_stack_return_target ==
        Zeros{PTO_XLEN} + 0x7700;
    assert _TrapContexts[[1]].return_address ==
        Zeros{PTO_XLEN} + 0x8800;
    assert _TrapContexts[[1]].bundle_argument_kind == Zeros{3} + 5;
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN});
    WriteBPC(Zeros{PTO_XLEN});
    _SystemRegisters.core_state = Zeros{PTO_XLEN};
    _BundleArgument = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    _BARG.block_type = BundleKind_Standard;
    _BundleArgumentKind = Zeros{3};
    _BARG.transfer_type = BundleTransfer_Fallthrough;
    _BARG.taken = TRUE;
    _BARG.bpcn = Zeros{PTO_XLEN};
    _BundleSequentialPC = Zeros{PTO_XLEN};
    _FrameStackReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
    assert CurrentACR() != 15;
    assert ReadTPC() != Zeros{PTO_XLEN} + 0x1200;
    assert ReadBPC() != Zeros{PTO_XLEN} + 0x2200;
    assert _SystemRegisters.core_state[3:0] != '1111';
    assert _BundleArgument != Zeros{PTO_XLEN} + 0x3300;
    assert _CommitArgument != Zeros{PTO_XLEN} + 0x4400;
    assert !_BundleActive;
    assert !_BundleBodyActive;
    assert _BARG.block_type != BundleKind_TileMatrix;
    assert _BARG.transfer_type != BundleTransfer_Conditional;
    assert _BARG.taken;
    assert _BARG.bpcn != Zeros{PTO_XLEN} + 0x5500;
    assert _BundleSequentialPC != Zeros{PTO_XLEN} + 0x6600;
    assert _FrameStackReturnTarget != Zeros{PTO_XLEN} + 0x7700;
    assert _ReturnAddress != Zeros{PTO_XLEN} + 0x8800;
    assert _BundleArgumentKind != Zeros{3} + 5;
    // TRAP_CONTEXT_RECOVER_CALL
    let recovered_all_leaf_context = RecoverTrapContext(1);
    assert recovered_all_leaf_context;
    assert CurrentACR() == 15;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x1200;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x2200;
    assert _SystemRegisters.core_state[3:0] == '1111';
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x3300;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x4400;
    assert _BundleActive;
    assert _BundleBodyActive;
    assert _BARG.block_type == BundleKind_TileMatrix;
    assert _BARG.transfer_type == BundleTransfer_Conditional;
    assert !_BARG.taken;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x5500;
    assert _BundleSequentialPC == Zeros{PTO_XLEN} + 0x6600;
    assert _FrameStackReturnTarget == Zeros{PTO_XLEN} + 0x7700;
    assert _ReturnAddress == Zeros{PTO_XLEN} + 0x8800;
    assert _BundleArgumentKind == Zeros{3} + 5;
    // TRAP_CONTEXT_PHASE_INVALIDATE_BEGIN
    assert !_TrapContexts[[1]].valid;
    // TRAP_CONTEXT_PHASE_INVALIDATE_END
end;
func main() => integer
begin
    ResetProfileState();
    TestTrapControlLeafRecovery();
    return 0;
end;
