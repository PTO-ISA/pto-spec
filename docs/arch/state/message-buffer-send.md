<!-- GENERATED FROM: asl/arch/state/message-buffer-send.asl -->
# Message Buffer Send

**Normative ASL source:** `asl/arch/state/message-buffer-send.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-MESSAGE-BUFFER-SEND}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/message-buffer-send.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-MESSAGE-BUFFER-SEND","surface":"arch","classification":["state","message-buffer-send"],"depends_on":["PTO-ARCH-STATE-MESSAGE-BUFFER"]}

// NDF-BEGIN: PTO-ARCH-MSGB-SEND-001
// ndf: kind=contract level=L1 layer=state status=accepted
// When the current bank is enabled, BSE MUST interpret bits [31:0] as the
// destination endpoint, bits [35:32] as 0..10 valid staged words, and bits
// [63:36] as reserved zero.  Admission MUST atomically snapshot those words,
// allocate one nonzero transport identity, and publish one message, or publish
// none and report BUSY, BAD_COMMAND, or EXHAUSTED.  Every admitted dynamic BSE
// occurrence MUST retain a separate replay receipt in the bounded executable
// model.  Exact retry MUST reuse its identity without republishing; a changed
// control for that occurrence MUST reject.  Receipt exhaustion MUST block new
// admission without overwriting any live receipt.  Same-invocation configuration,
// including epoch advancement, MUST preserve all admitted occurrence receipts.
// Enabled BSE MUST reject atomic/far SYS envelopes and MUST wait before effects
// while an older fault-capable kernel GM obligation can still require recovery.
// NDF-END: PTO-ARCH-MSGB-SEND-001

readonly func FindMessageBufferReplayReceipt(index: MessageBufferEndpointIndex)
    => integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS}
begin
    for slot = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
        let receipt = _MessageBufferBanks[[index]].receipts[[slot]];
        if receipt.valid && receipt.invocation == _CurrentKernelInvocation &&
           receipt.acr == CurrentACR() &&
           receipt.execution_domain_token == _BundleExecutionDomainToken &&
           receipt.instruction_pc == ReadTPC() then
            return slot as integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS};
        end;
    end;
    return PTO_MODEL_MESSAGE_BUFFER_RECEIPTS;
end;

readonly func FindFreeMessageBufferReplayReceipt(
    index: MessageBufferEndpointIndex)
    => integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS}
begin
    for slot = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
        if !_MessageBufferBanks[[index]].receipts[[slot]].valid then
            return slot as integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS};
        end;
    end;
    return PTO_MODEL_MESSAGE_BUFFER_RECEIPTS;
end;

func ReportMessageBufferReplay(index: MessageBufferEndpointIndex,
                               slot: MessageBufferReceiptIndex,
                               control: Word)
begin
    let receipt = _MessageBufferBanks[[index]].receipts[[slot]];
    _MessageBufferBanks[[index]].tx_result = if receipt.control == control then
        MessageBufferResult_Duplicate else MessageBufferResult_BadCommand;
    _MessageBufferBanks[[index]].tx_result_valid = TRUE;
    _MessageBufferBanks[[index]].last_accepted_control = receipt.control;
    _MessageBufferBanks[[index]].tx_message_id_hi = receipt.message_id_hi;
    _MessageBufferBanks[[index]].tx_message_id_lo = receipt.message_id_lo;
end;

func CaptureMessageBufferReplayReceipt(index: MessageBufferEndpointIndex,
                                       slot: MessageBufferReceiptIndex,
                                       control: Word,
                                       message_id_hi: Word,
                                       message_id_lo: Word)
begin
    _MessageBufferBanks[[index]].receipts[[slot]].valid = TRUE;
    _MessageBufferBanks[[index]].receipts[[slot]].invocation =
        _CurrentKernelInvocation;
    _MessageBufferBanks[[index]].receipts[[slot]].acr = CurrentACR();
    _MessageBufferBanks[[index]].receipts[[slot]].execution_domain_token =
        _BundleExecutionDomainToken;
    _MessageBufferBanks[[index]].receipts[[slot]].instruction_pc = ReadTPC();
    _MessageBufferBanks[[index]].receipts[[slot]].control = control;
    _MessageBufferBanks[[index]].receipts[[slot]].message_id_hi = message_id_hi;
    _MessageBufferBanks[[index]].receipts[[slot]].message_id_lo = message_id_lo;
end;

// NDF-BEGIN: PTO-ARCH-HSCB-TRANSPORT-001
// ndf: kind=contract level=L1 layer=state status=accepted
// HSCB (High Speed Config Bus) MUST carry complete MSGB messages from a
// trusted source endpoint to the addressed destination. A worker BSE to
// 0xffffffff and a service submission to a worker MUST share the same atomic
// queue admission, domain checks, identity allocation and backpressure. The
// payload is opaque to transport. Only a service transaction can originate
// a message with source endpoint 0xffffffff. No transport ACK implies kernel
// completion or ordering of separate memory transactions.
// NDF-END: PTO-ARCH-HSCB-TRANSPORT-001
func AdmitMessageBufferPacket(source_index: MessageBufferEndpointIndex,
                              control: Word, capacity_available: boolean) => MessageBufferResult
begin
    let destination = UInt(control[31:0]);
    let count = UInt(control[35:32]);
    if control[63:36] != Zeros{28} || count > PTO_MODEL_MESSAGE_BUFFER_WORDS ||
       (destination >= PTO_MODEL_MESSAGE_BUFFER_ENDPOINTS &&
        destination != PTO_HSCB_ENDPOINT) then
        return MessageBufferResult_BadCommand;
    end;
    let target_index = (if destination == PTO_HSCB_ENDPOINT then PTO_HSCB_BANK
                        else destination) as MessageBufferEndpointIndex;
    if !_MessageBufferBanks[[target_index]].enabled ||
       !_MessageBufferBanks[[source_index]].enabled ||
       _MessageBufferBanks[[target_index]].domain != _MessageBufferBanks[[source_index]].domain then
        return MessageBufferResult_BadCommand;
    end;
    if target_index != PTO_HSCB_BANK then
        let target_core = (destination DIVRM (PTO_MSGB_WORKERS_PER_CORE * PTO_ACR_COUNT))
                          as PTOModelCoreIdentity;
        if _MessageBufferCoreDraining[[target_core]] ||
           !_KernelInvocationActiveByCore[[target_core]] ||
           _MessageBufferBanks[[target_index]].bound_invocation !=
               _KernelInvocationByCore[[target_core]] then
            return MessageBufferResult_BadCommand;
        end;
    end;
    if _MessageBufferBanks[[target_index]].queued.valid || !capacity_available then
        return MessageBufferResult_Busy;
    end;
    if _MessageBufferBanks[[source_index]].transmit_sequence == Ones{PTO_XLEN} then
        return MessageBufferResult_Exhausted;
    end;
    let id_hi = MessageBufferEndpointWord(source_index)[31:0] ::
                _MessageBufferBanks[[source_index]].source_epoch;
    let id_lo = _MessageBufferBanks[[source_index]].transmit_sequence + 1;
    _MessageBufferBanks[[source_index]].transmit_sequence = id_lo;
    _MessageBufferBanks[[target_index]].hscb_waiting = FALSE;
    _MessageBufferBanks[[target_index]].queued.valid = TRUE;
    _MessageBufferBanks[[target_index]].queued.source_invocation =
        _MessageBufferBanks[[source_index]].bound_invocation;
    _MessageBufferBanks[[target_index]].queued.destination_invocation =
        _MessageBufferBanks[[target_index]].bound_invocation;
    _MessageBufferBanks[[target_index]].queued.control = control;
    _MessageBufferBanks[[target_index]].queued.word_count = count as MessageBufferWordCount;
    _MessageBufferBanks[[target_index]].queued.message_id_hi = id_hi;
    _MessageBufferBanks[[target_index]].queued.message_id_lo = id_lo;
    for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        _MessageBufferBanks[[target_index]].queued.words[[word]] =
            if word < count then _MessageBufferBanks[[source_index]].staging_words[[word]]
            else Zeros{PTO_XLEN};
    end;
    _MessageBufferBanks[[source_index]].last_accepted_control = control;
    _MessageBufferBanks[[source_index]].tx_message_id_hi = id_hi;
    _MessageBufferBanks[[source_index]].tx_message_id_lo = id_lo;
    return MessageBufferResult_OK;
end;

func ExecuteMessageBufferSend(control: Word)
begin
    if !MessageBufferOperationalAccessPermitted() then return; end;
    let source = CurrentMessageBufferIndex();
    let replay = FindMessageBufferReplayReceipt(source);
    if replay != PTO_MODEL_MESSAGE_BUFFER_RECEIPTS then
        ReportMessageBufferReplay(source, replay as MessageBufferReceiptIndex, control);
        return;
    end;
    let free = FindFreeMessageBufferReplayReceipt(source);
    var result: MessageBufferResult = MessageBufferResult_BadCommand;
    let draining_done = control == Zeros{64} + (3 << 32) + PTO_HSCB_ENDPOINT &&
        _MessageBufferBanks[[source]].hscb_running &&
        _MessageBufferBanks[[source]].staging_words[[0]] == Zeros{64} + 3 &&
        _MessageBufferBanks[[source]].staging_words[[1]] ==
            _MessageBufferBanks[[source]].hscb_dispatch_id;
    if !_MessageBufferCoreDraining[[_CurrentModelCore]] || draining_done then
        result = AdmitMessageBufferPacket(source, control, free != PTO_MODEL_MESSAGE_BUFFER_RECEIPTS);
    end;
    if result == MessageBufferResult_OK then
        CaptureMessageBufferReplayReceipt(source, free as MessageBufferReceiptIndex, control,
            _MessageBufferBanks[[source]].tx_message_id_hi,
            _MessageBufferBanks[[source]].tx_message_id_lo);
    end;
    _MessageBufferBanks[[source]].tx_result = result;
    _MessageBufferBanks[[source]].tx_result_valid = TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
