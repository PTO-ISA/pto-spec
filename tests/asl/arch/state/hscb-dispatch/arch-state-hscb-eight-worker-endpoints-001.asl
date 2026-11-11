// PTO-TEST: {"id":"PTO-AVS-HSCB-EIGHT-WORKER-ENDPOINTS-001","source":"asl/arch/state/hscb-dispatch.asl","requirements":["PTO-ARCH-HSCB-ENDPOINT-001"],"kind":"state-transition","summary":"eight hardware threads on four physical PEs have distinct current endpoints and private staging","pass_condition":"each thread reads the endpoint selected by its physical PE, slot and ACR and retains its own staged word","related_sources":["asl/arch/state/message-buffer-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let started = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert started == KernelLifecycle_Started;
    for tid = 0 to 7 do
        SelectExecutionContext(0, (tid MOD 4) as MemoryAgentId);
        SelectMessageBufferThread((tid DIVRM 4) as MessageBufferThread);
        WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{64} + 1);
        WriteSystemRegisterAddress(Zeros{24} + 0x084a, Zeros{64} + 0x100010001);
        WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{64} + 17 + tid);
        let endpoint = ReadSystemRegisterAddress(Zeros{24} + 0x0848);
        assert endpoint == Zeros{64} + tid * 16;
    end;
    for tid = 0 to 7 do
        SelectExecutionContext(0, (tid MOD 4) as MemoryAgentId);
        SelectMessageBufferThread((tid DIVRM 4) as MessageBufferThread);
        assert _MessageBufferBanks[[CurrentMessageBufferIndex()]].staging_words[[0]] ==
            Zeros{64} + 17 + tid;
    end;
    return 0;
end;
