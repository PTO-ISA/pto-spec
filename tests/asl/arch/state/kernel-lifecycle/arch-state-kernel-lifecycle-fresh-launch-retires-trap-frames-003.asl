
// PTO-TEST: {"id":"PTO-AVS-ARCH-KERNEL-LIFECYCLE-FRESH-LAUNCH-TRAP-003","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"fresh launch retires all target-Core recovery frames while preserving a different Core and allowing current recovery","pass_condition":"End and Abort both invalidate nested model and EBARG recovery validity for every target PE before a fresh launch, keep the new entry inactive without stale arrival, preserve the selected other Core's handler and valid recovery frame, and permit a new current-invocation trap recovery","related_sources":["asl/arch/state/trap-context.asl","asl/arch/state/pe-execution-context.asl"]}
func WriteSyncProgram(entry: Word)
begin
    WriteMemoryByte(entry, Zeros{8} + 0x81);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x10);
    WriteMemoryByte(entry + 2, Zeros{8});
    WriteMemoryByte(entry + 3, Zeros{8});
    WriteMemoryByte(entry + 4, Zeros{8} + 0x2b);
    WriteMemoryByte(entry + 5, Zeros{8} + 0xa0);
    WriteMemoryByte(entry + 6, Zeros{8} + 0x30);
    WriteMemoryByte(entry + 7, Zeros{8} + 0x03);
    WriteMemoryByte(entry + 8, Zeros{8} + 1);
    WriteMemoryByte(entry + 9, Zeros{8});
    WriteMemoryByte(entry + 10, Zeros{8});
    WriteMemoryByte(entry + 11, Zeros{8});
    WriteMemoryByte(entry + 12, Zeros{8});
    WriteMemoryByte(entry + 13, Zeros{8});
end;

func TestFreshLaunchRetiresTargetFrames(use_abort: boolean)
begin
    ResetProfileState();
    let old_entry = Zeros{PTO_XLEN} + 0x100;
    let new_entry = Zeros{PTO_XLEN} + 0x400;
    let other_entry = Zeros{PTO_XLEN} + 0x800;
    WriteSyncProgram(old_entry);
    WriteSyncProgram(new_entry);
    WriteSyncProgram(other_entry);
    let launched = LaunchKernelInvocation(0, old_entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let start = ExecuteNextPTOInstruction();
    let parked = ExecuteNextPTOInstruction();
    assert start == PTOInstruction_Executed && parked == PTOInstruction_Blocked;
    let old_invocation = _CurrentKernelInvocation;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _TrapContexts[[0]].valid;
    SavePortableTrapContext(2, 0);
    SelectExecutionContext(0, 1);
    SavePortableTrapContext(2, 0);

    let other_launched = LaunchKernelInvocation(1, other_entry);
    assert other_launched == KernelLifecycle_Started;
    SelectExecutionContext(1, 0);
    let other_start = ExecuteNextPTOInstruction();
    let other_parked = ExecuteNextPTOInstruction();
    assert other_start == PTOInstruction_Executed &&
           other_parked == PTOInstruction_Blocked;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 7);
    assert _TrapContexts[[0]].valid;

    SelectExecutionContext(1, 0);
    let caller_pc = ReadTPC();
    let caller_bpc = ReadBPC();
    let caller_acr = CurrentACR();
    let caller_origin = _CurrentMemoryOrigin;
    let aborted = if use_abort then AbortKernelInvocation(0) else EndKernelInvocation(0);
    let restarted = LaunchKernelInvocation(0, new_entry);
    assert aborted == KernelLifecycle_Started && restarted == KernelLifecycle_Started;
    assert _CurrentModelCore == 1 && _CurrentMemoryAgent == 0;
    assert ReadTPC() == caller_pc && ReadBPC() == caller_bpc &&
           CurrentACR() == caller_acr && _CurrentMemoryOrigin == caller_origin;

    SelectExecutionContext(0, 0);
    assert ReadTPC() == new_entry && !_BundleActive;
    assert _CurrentKernelInvocation != old_invocation;
    let recovered = RecoverTrapContext(0);
    assert !recovered && !_BundleActive && ReadTPC() == new_entry;
    assert !_TrapContexts[[0]].valid && !_TrapContexts[[2]].valid;
    let ebarg = ReadContextRegister(0, 0x0f40);
    assert ebarg[4] == '0';
    SelectExecutionContext(0, 1);
    let stale_portable_recovered = RecoverPortableTrapContext(2);
    assert !stale_portable_recovered && !_TrapContexts[[2]].valid;

    // A different Core's saved recovery is neither cleared nor made invalid.
    SelectExecutionContext(1, 0);
    assert _TrapContexts[[0]].valid;
    let other_recovered = RecoverTrapContext(0);
    assert other_recovered && ReadTPC() == other_entry + 4 && _BundleActive;

    // The new invocation can still save and recover its own current frame.
    SelectExecutionContext(0, 0);
    let new_start = ExecuteNextPTOInstruction();
    let new_parked = ExecuteNextPTOInstruction();
    assert new_start == PTOInstruction_Executed &&
           new_parked == PTOInstruction_Blocked;
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _TrapContexts[[0]].valid;
    let current_recovered = RecoverTrapContext(0);
    assert current_recovered && ReadTPC() == new_entry + 4 &&
           _CurrentKernelInvocation != old_invocation;
end;

func main() => integer
begin
    TestFreshLaunchRetiresTargetFrames(TRUE);
    TestFreshLaunchRetiresTargetFrames(FALSE);
    return 0;
end;
