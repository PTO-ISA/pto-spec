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

func ExecuteMessageBufferSend(control: Word)
begin
    var message_id_hi = Zeros{PTO_XLEN};
    if !MessageBufferOperationalAccessPermitted() then return; end;
    let source_index = CurrentMessageBufferIndex();
    let replay_slot = FindMessageBufferReplayReceipt(source_index);
    if replay_slot != PTO_MODEL_MESSAGE_BUFFER_RECEIPTS then
        ReportMessageBufferReplay(source_index,
            replay_slot as MessageBufferReceiptIndex, control);
        return;
    end;
    let destination = UInt(control[31:0]);
    let word_count = UInt(control[35:32]);
    if control[63:36] != Zeros{28} || word_count > 10 ||
       destination >= PTO_MODEL_MESSAGE_BUFFER_ENDPOINTS then
        _MessageBufferBanks[[source_index]].tx_result =
            MessageBufferResult_BadCommand;
        _MessageBufferBanks[[source_index]].tx_result_valid = TRUE;
        return;
    end;
    let target_index = destination as MessageBufferEndpointIndex;
    let target_core = (destination DIVRM
        (PTO_MODEL_MEMORY_AGENTS * PTO_ACR_COUNT)) as PTOModelCoreIdentity;
    if _MessageBufferCoreDraining[[_CurrentModelCore]] ||
       _MessageBufferCoreDraining[[target_core]] ||
       !_MessageBufferBanks[[target_index]].enabled ||
       _MessageBufferBanks[[target_index]].bound_invocation == 0 ||
       !_KernelInvocationActiveByCore[[target_core]] ||
       _MessageBufferBanks[[target_index]].bound_invocation !=
           _KernelInvocationByCore[[target_core]] ||
       _MessageBufferBanks[[target_index]].domain !=
           _MessageBufferBanks[[source_index]].domain then
        _MessageBufferBanks[[source_index]].tx_result =
            MessageBufferResult_BadCommand;
        _MessageBufferBanks[[source_index]].tx_result_valid = TRUE;
        return;
    end;
    if _MessageBufferBanks[[target_index]].queued.valid then
        _MessageBufferBanks[[source_index]].tx_result = MessageBufferResult_Busy;
        _MessageBufferBanks[[source_index]].tx_result_valid = TRUE;
        return;
    end;
    let free_receipt = FindFreeMessageBufferReplayReceipt(source_index);
    if free_receipt == PTO_MODEL_MESSAGE_BUFFER_RECEIPTS then
        _MessageBufferBanks[[source_index]].tx_result = MessageBufferResult_Busy;
        _MessageBufferBanks[[source_index]].tx_result_valid = TRUE;
        return;
    end;
    if _MessageBufferBanks[[source_index]].transmit_sequence == Ones{PTO_XLEN} then
        _MessageBufferBanks[[source_index]].tx_result =
            MessageBufferResult_Exhausted;
        _MessageBufferBanks[[source_index]].tx_result_valid = TRUE;
        return;
    end;
    _MessageBufferBanks[[source_index]].transmit_sequence =
        _MessageBufferBanks[[source_index]].transmit_sequence + 1;
    message_id_hi[63:32] = MessageBufferEndpointWord(source_index)[31:0];
    message_id_hi[31:0] = _MessageBufferBanks[[source_index]].source_epoch;
    let message_id_lo = _MessageBufferBanks[[source_index]].transmit_sequence;
    _MessageBufferBanks[[target_index]].queued.valid = TRUE;
    _MessageBufferBanks[[target_index]].queued.destination_invocation =
        _MessageBufferBanks[[target_index]].bound_invocation;
    _MessageBufferBanks[[target_index]].queued.control = control;
    _MessageBufferBanks[[target_index]].queued.word_count =
        word_count as MessageBufferWordCount;
    _MessageBufferBanks[[target_index]].queued.message_id_hi = message_id_hi;
    _MessageBufferBanks[[target_index]].queued.message_id_lo = message_id_lo;
    for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        _MessageBufferBanks[[target_index]].queued.words[[word]] =
            if word < word_count then
                _MessageBufferBanks[[source_index]].staging_words[[word]]
            else Zeros{PTO_XLEN};
    end;
    CaptureMessageBufferReplayReceipt(source_index,
        free_receipt as MessageBufferReceiptIndex,
        control, message_id_hi, message_id_lo);
    _MessageBufferBanks[[source_index]].last_accepted_control = control;
    _MessageBufferBanks[[source_index]].tx_result = MessageBufferResult_OK;
    _MessageBufferBanks[[source_index]].tx_result_valid = TRUE;
    _MessageBufferBanks[[source_index]].tx_message_id_hi = message_id_hi;
    _MessageBufferBanks[[source_index]].tx_message_id_lo = message_id_lo;
end;
