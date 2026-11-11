// PTO-TEST: {"id":"PTO-AVS-MSGB-CROSS-CORE-SOURCE-END-001","source":"asl/arch/state/message-buffer.asl","requirements":["PTO-ARCH-MSGB-LIFECYCLE-001","PTO-ARCH-MSGB-IDENTITY-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"source-kernel retirement preserves an already admitted message in another Core","pass_condition":"the source ends without waiting for remote ACK, while the destination later reads the same payload and transport identity and consumes it exactly once","related_sources":["asl/arch/state/kernel-lifecycle.asl","asl/arch/state/message-buffer-send.asl"]}
func ConfigureCoreZeroPEZero()
begin
    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN} + 5);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func ConfigureCoreOnePEZero()
begin
    SelectExecutionContext(1, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0849, Zeros{PTO_XLEN});
    WriteSystemRegisterAddress(Zeros{24} + 0x084b, Zeros{PTO_XLEN} + 5);
    WriteSystemRegisterAddress(Zeros{24} + 0x084a,
        Zeros{PTO_XLEN} + (1 << 32) + (1 << 16) + 1);
end;

func main() => integer
begin
    ResetProfileState();
    let source_launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    let destination_launch = LaunchKernelInvocation(1, Zeros{PTO_XLEN} + 0x200);
    assert source_launch == KernelLifecycle_Started;
    assert destination_launch == KernelLifecycle_Started;
    ConfigureCoreZeroPEZero();
    ConfigureCoreOnePEZero();

    SelectExecutionContext(0, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x0831, Zeros{PTO_XLEN} + 0x77);
    ExecuteMessageBufferSend(Zeros{PTO_XLEN} + 128 + (1 << 32));
    let sent_hi = ReadSystemRegisterAddress(Zeros{24} + 0x0845);
    let sent_lo = ReadSystemRegisterAddress(Zeros{24} + 0x0846);
    let ended = EndKernelInvocation(0);
    assert ended == KernelLifecycle_Started;
    assert !_KernelInvocationActiveByCore[[0]];

    SelectExecutionContext(1, 0); SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x083b, Zeros{PTO_XLEN} + 1);
    let token = ReadSystemRegisterAddress(Zeros{24} + 0x083d);
    let received_hi = ReadSystemRegisterAddress(Zeros{24} + 0x083e);
    let received_lo = ReadSystemRegisterAddress(Zeros{24} + 0x083f);
    let payload = ReadSystemRegisterAddress(Zeros{24} + 0x0831);
    assert received_hi == sent_hi;
    assert received_lo == sent_lo;
    assert payload == Zeros{PTO_XLEN} + 0x77;
    WriteSystemRegisterAddress(Zeros{24} + 0x0842, token);
    let ack = ReadSystemRegisterAddress(Zeros{24} + 0x0843);
    assert ack == Zeros{PTO_XLEN} + 0x101;
    return 0;
end;
