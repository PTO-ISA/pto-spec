// PTO-TEST: {"id":"PTO-AVS-MSGB-SEND-RECEIPT-CAPACITY-001","source":"asl/arch/state/message-buffer-send.asl","requirements":["PTO-ARCH-MSGB-SEND-001","PTO-ARCH-MSGB-IDENTITY-001"],"kind":"boundary","summary":"the bounded replay-receipt table fails closed without losing any admitted occurrence identity","pass_condition":"sixteen distinct occurrences retain exact replay and changed-control rejection, while a seventeenth empty-target admission reports BUSY without advancing sequence or publishing","related_sources":["asl/arch/state/message-buffer-state.asl","asl/arch/state/message-buffer.asl"]}
func ConfigureMessageContext(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func ConsumeOneWord()
begin
    SelectExecutionContext(0, 1); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    - = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    WriteSystemRegisterAddress(Zeros{24} + 0x0841, token);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    ConfigureMessageContext(0); ConfigureMessageContext(1);
    let control = Zeros{PTO_XLEN} + 16 + (1 << 32);
    let source = MessageBufferEndpointIndexOf(0, 0, 0);
    let target = MessageBufferEndpointIndexOf(0, 1, 0);

    for occurrence = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
        SelectExecutionContext(0, 0); SetCurrentACR(0);
        _BundleExecutionDomainToken = occurrence + 1;
        WriteTPC(Zeros{PTO_XLEN} + 0x200 + occurrence * 4);
        WriteSystemRegisterAddress(Zeros{24} + 0x0831,
            Zeros{PTO_XLEN} + occurrence + 1);
        ExecuteMessageBufferSend(control);
        assert _MessageBufferBanks[[source]].tx_result == MessageBufferResult_OK;
        assert _MessageBufferBanks[[source]].tx_message_id_lo ==
            Zeros{PTO_XLEN} + occurrence + 1;
        ConsumeOneWord();
    end;
    assert MessageBufferBankQuiescent(target);
    assert _MessageBufferBanks[[source]].transmit_sequence ==
        Zeros{PTO_XLEN} + PTO_MODEL_MESSAGE_BUFFER_RECEIPTS;

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    _BundleExecutionDomainToken = PTO_MODEL_MESSAGE_BUFFER_RECEIPTS + 1;
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    ExecuteMessageBufferSend(control);
    assert _MessageBufferBanks[[source]].tx_result == MessageBufferResult_Busy;
    assert _MessageBufferBanks[[source]].transmit_sequence ==
        Zeros{PTO_XLEN} + PTO_MODEL_MESSAGE_BUFFER_RECEIPTS;
    assert !_MessageBufferBanks[[target]].queued.valid;

    for occurrence = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
        _BundleExecutionDomainToken = occurrence + 1;
        WriteTPC(Zeros{PTO_XLEN} + 0x200 + occurrence * 4);
        ExecuteMessageBufferSend(control);
        assert _MessageBufferBanks[[source]].tx_result ==
            MessageBufferResult_Duplicate;
        assert _MessageBufferBanks[[source]].tx_message_id_lo ==
            Zeros{PTO_XLEN} + occurrence + 1;
        ExecuteMessageBufferSend(control + (1 << 32));
        assert _MessageBufferBanks[[source]].tx_result ==
            MessageBufferResult_BadCommand;
        assert _MessageBufferBanks[[source]].tx_message_id_lo ==
            Zeros{PTO_XLEN} + occurrence + 1;
        assert !_MessageBufferBanks[[target]].queued.valid;
    end;
    return 0;
end;
