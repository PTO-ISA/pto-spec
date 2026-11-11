// PTO-TEST: {"id":"PTO-AVS-HSCB-WAIT-EVENT-RACE-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-DISPATCH-001","PTO-ARCH-HSCB-ENDPOINT-001"],"kind":"state-transition","summary":"BWE retires while level-sensitive service availability covers both sides of the wait race","pass_condition":"an empty worker parks, a subsequent LAUNCH wakes it, and another BWE while the packet is pending does not park","related_sources":["asl/arch/state/message-buffer.asl","asl/arch/state/message-buffer-send.asl","asl/arch/state/kernel-lifecycle.asl"]}
func SelectWorker(thread_id: integer {0..7})
begin
    SelectExecutionContext(0, (thread_id MOD 4) as MemoryAgentId);
    SelectMessageBufferThread((thread_id DIVRM 4) as MessageBufferThread);
    SetCurrentACR(0);
end;

func BootWorker(thread_id: integer {0..7})
begin
    SelectWorker(thread_id);
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
end;

func WorkerRequest(pc: integer, words: MessageBufferWordCount)
begin
    WriteTPC(Zeros{64} + pc);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{64}, Zeros{64} + pc, Zeros{64}, FALSE);
    EnterBundleBody();
    WriteGPR(5, Zeros{64} + (words << 32) + 0xffffffff);
    let sent = ExecuteScalarInstruction('000000000000000000000000000000101000000000101011', 32);
    assert sent == ScalarExecution_Executed;
    StopBundle();
    assert _LastFault == Fault_None;
end;

func ReportReady()
begin
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 1);
    WorkerRequest(0x100, 1);
    let accepted = HSCBReceiveWorkerMessage();
    assert accepted == MessageBufferResult_OK;
end;


func WorkerBWE(pc: integer)
begin
    WriteTPC(Zeros{64} + pc);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough, Zeros{64}, Zeros{64} + pc, Zeros{64}, FALSE);
    EnterBundleBody();
    let r = ExecuteScalarInstruction('000000000000000000000000000100101000000000101011', 32);
    assert r == ScalarExecution_Executed;
    assert ReadTPC() == Zeros{64} + pc + 4;
    assert _LastControlRequest == ExecutionControl_WaitEvent;
    StopBundle();
    assert _LastFault == Fault_None;
end;

func main() => integer
begin

    ResetProfileState();
    EnableHSCBService();
    let boot = LaunchKernelInvocation(0, Zeros{64} + 0x100);
    assert boot == KernelLifecycle_Started;

    BootWorker(4); ReportReady();
    WorkerBWE(0x160);
    assert _MessageBufferBanks[[64]].hscb_waiting;
    assert !_MessageBufferBanks[[0]].hscb_waiting;
    let issued = HSCBIssueLaunch(64, Zeros{64} + 9, Zeros{64} + 0x800, Zeros{64});
    assert issued == MessageBufferResult_OK;
    assert !_MessageBufferBanks[[64]].hscb_waiting;
    WorkerBWE(0x170);
    assert !_MessageBufferBanks[[64]].hscb_waiting && HSCBWorkerHasMessage(64);
    return 0;
end;
