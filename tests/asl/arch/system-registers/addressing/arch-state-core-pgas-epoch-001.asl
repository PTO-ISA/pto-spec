// PTO-TEST: {"id":"PTO-AVS-ARCH-CORE-PGAS-EPOCH-001","source":"asl/arch/system-registers/addressing.asl","requirements":["PTO-CORE-PGAS-RANGE-001","PTO-CORE-PGAS-SSR-001"],"kind":"state-transition","summary":"Cold kernel start, interrupt delivery and instruction fetch close platform admission independently","pass_condition":"production admission and reset reject during execution and after kernel exit, ordinary reset and trap recovery, then admit the next epoch after explicit termination","related_sources":["asl/arch/dispatch/top-level.asl","asl/arch/memory-model/fault-precision.asl","asl/arch/state/kernel-lifecycle.asl","asl/arch/state/pe-execution-context.asl","asl/scalar/sys/SSRGET.asl"]}
func main() => integer
begin
    ResetProfileState();
    let initial = ConfigureCorePGAS(1, 0x100000001, 0x100000008);
    assert initial;
    let entry = Zeros{PTO_XLEN} + 0x100;

    // Kernel launch is an execution entry even before its first instruction.
    let launched = LaunchKernelInvocation(1, entry);
    assert launched == KernelLifecycle_Started;
    let rejected_during_kernel = ConfigureCorePGAS(1, 0, 0);
    assert !rejected_during_kernel;
    let rejected_kernel_reset = ResetPlatformExecution();
    assert !rejected_kernel_reset;
    SelectExecutionContext(1, 3);
    assert ReadTPC() == entry;
    let kernel_limit = ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT);
    assert kernel_limit == Zeros{PTO_XLEN} + 0x100000008;

    let ended = EndKernelInvocation(1);
    assert ended == KernelLifecycle_Started;
    let rejected_after_kernel = ConfigureCorePGAS(1, 0, 0);
    assert !rejected_after_kernel;

    // An external interrupt can enter guest state before the first fetch.
    FinishPlatformExecutionEpoch();
    let interrupt_configured = ConfigureCorePGAS(1, 0x200000001, 0x200000009);
    assert interrupt_configured;
    ResetProfileState();
    SelectExecutionContext(1, 3);
    WriteTPC(entry);
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    let rejected_in_handler = ConfigureCorePGAS(1, 0, 0);
    assert !rejected_in_handler;
    let rejected_handler_reset = ResetPlatformExecution();
    assert !rejected_handler_reset;
    let interrupt_limit = ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT);
    assert interrupt_limit == Zeros{PTO_XLEN} + 0x200000009;
    let returned = RecoverTrapContext(CurrentACR());
    assert returned;
    assert ReadTPC() == entry;

    // A fetch fault also seals the direct-boot epoch before a decoded attempt.
    FinishPlatformExecutionEpoch();
    let fetch_configured = ConfigureCorePGAS(1, 0x300000001, 0x300000009);
    assert fetch_configured;
    WriteTPC(entry + 1);
    let fetch_result = ExecuteNextPTOInstruction();
    assert fetch_result == PTOInstruction_Rejected;
    assert _LastFault == Fault_InstructionPC;
    let rejected_after_fetch = ConfigureCorePGAS(1, 0, 0);
    assert !rejected_after_fetch;

    ResetProfileState();
    let rejected_after_profile_reset = ConfigureCorePGAS(1, 0, 0);
    assert !rejected_after_profile_reset;
    ResetPEExecutionContextBank();
    let rejected_after_context_reset = ResetPlatformExecution();
    assert !rejected_after_context_reset;
    SelectExecutionContext(1, 3);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, entry + 4, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let rejected = ExecutePTOInstruction(Zeros{64} + 0x802001bb, 32);
    assert rejected == PTOInstruction_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    let retried = ExecutePTOInstruction(Zeros{64} + 0x028001bb, 32);
    assert retried == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x300000001;
    let rejected_after_retry = ConfigureCorePGAS(1, 0, 0);
    assert !rejected_after_retry;

    FinishPlatformExecutionEpoch();
    let platform_reset = ResetPlatformExecution();
    assert platform_reset;
    let replaced = ConfigureCorePGAS(1, 0, 1);
    assert replaced;
    SelectExecutionContext(1, 2);
    let replacement_limit = ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT);
    assert replacement_limit == Zeros{PTO_XLEN} + 1;
    return 0;
end;
