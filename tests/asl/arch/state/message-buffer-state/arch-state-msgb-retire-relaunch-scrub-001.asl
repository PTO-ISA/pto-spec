// PTO-TEST: {"id":"PTO-AVS-MSGB-RETIRE-RELAUNCH-SCRUB-001","source":"asl/arch/state/message-buffer-state.asl","requirements":["PTO-ARCH-MSGB-STATE-001","PTO-ARCH-MSGB-LIFECYCLE-001","PTO-ARCH-MSGB-IDENTITY-001"],"kind":"state-transition","summary":"invocation retirement scrubs private message staging and diagnostic state before relaunch","pass_condition":"relaunch preserves epochs and sequence progress but observes zero staging and ACK state, and a send without restaging transfers zero rather than the retired payload","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/arch/state/message-buffer.asl","asl/arch/state/message-buffer-send.asl"]}
func ConfigureRelaunchContext(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    if !_MessageBufferBanks[[MessageBufferEndpointIndexOf(0, pe, 0)]].domain_bound then
        WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    end;
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func ConsumeRelaunchWord(expected: Word)
begin
    SelectExecutionContext(0, 1);
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert payload == expected;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let read_observed_1 = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert read_observed_1 ==
        Zeros{PTO_XLEN} + 0x101;
    let read_observed_2 = ReadSystemRegisterAddress(Zeros{24} + 0x0844);
    assert read_observed_2 == token;
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
end;

func main() => integer
begin
    ResetProfileState();
    let first_launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert first_launch == KernelLifecycle_Started;
    ConfigureRelaunchContext(0);
    ConfigureRelaunchContext(1);

    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    let source_index = MessageBufferEndpointIndexOf(0, 0, 0);
    let destination_index = MessageBufferEndpointIndexOf(0, 1, 0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0xaa);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    assert _MessageBufferBanks[[source_index]].transmit_sequence ==
        Zeros{PTO_XLEN} + 1;
    ConsumeRelaunchWord(Zeros{PTO_XLEN} + 0xaa);

    let ended = EndKernelInvocation(0);
    assert ended == KernelLifecycle_Started;
    assert !_KernelInvocationActiveByCore[[0]];
    assert _MessageBufferBanks[[source_index]].rx_epoch == Zeros{16} + 1;
    assert _MessageBufferBanks[[source_index]].source_epoch == Zeros{32} + 1;
    assert _MessageBufferBanks[[source_index]].transmit_sequence ==
        Zeros{PTO_XLEN} + 1;
    assert _MessageBufferBanks[[source_index]].staging_words[[0]] ==
        Zeros{PTO_XLEN};
    assert _MessageBufferBanks[[destination_index]].ack_result ==
        MessageBufferResult_None;
    assert !_MessageBufferBanks[[destination_index]].ack_result_valid;
    assert _MessageBufferBanks[[destination_index]].ack_id == Zeros{PTO_XLEN};

    let second_launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x200);
    assert second_launch == KernelLifecycle_Started;
    ConfigureRelaunchContext(0);
    ConfigureRelaunchContext(1);
    SelectExecutionContext(0, 0);
    SetCurrentACR(0);
    let read_observed_3 = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert read_observed_3 == Zeros{PTO_XLEN};
    let read_observed_4 = ReadSystemRegisterAddress(Zeros{24} + 0x0844);
    assert read_observed_4 == Zeros{PTO_XLEN};
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 16 + (1 << 32));
    assert _MessageBufferBanks[[source_index]].transmit_sequence ==
        Zeros{PTO_XLEN} + 2;
    ConsumeRelaunchWord(Zeros{PTO_XLEN});
    return 0;
end;
