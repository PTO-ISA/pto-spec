<!-- GENERATED FROM: asl/arch/state/hscb-dispatch.asl -->
# HSCB Dispatch

**Normative ASL source:** `asl/arch/state/hscb-dispatch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-HSCB-DISPATCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
The High Speed Config Bus (HSCB) connects the scheduler with resident worker
threads through their Message Buffers (MSGBs). Each of the four physical PEs
in the reference core runs two independently addressable hardware threads.
A worker announces READY after it has initialized its bank. The scheduler
sends it a LAUNCH containing a dispatch ID, the kernel entry PC, and an
argument. After the kernel returns, that worker sends DONE with the same ID
and the return value, then waits for another launch.

BWE retires after publishing the architectural WaitEvent request. An enabled
HSCB platform can observe that request and park its caller while the bank is
empty. An already queued or subsequently admitted message allows the worker
to proceed. The worker checks its bank after waking.

The receiver uses the transport source identity to associate READY and DONE
with a worker. A mailbox ACK records consumption of a packet. Kernel
completion is established by a matching DONE. The scheduler service below
uses the [message-buffer send](message-buffer-send.md) and
[receive and acknowledgement](message-buffer.md) rules; the
[state owner](message-buffer-state.md) describes the banks and identifiers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/hscb-dispatch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-HSCB-DISPATCH","surface":"arch","classification":["state","hscb-dispatch"],"depends_on":["PTO-ARCH-STATE-MESSAGE-BUFFER-SEND"]}

// NDF-BEGIN: PTO-ARCH-HSCB-DISPATCH-001
// ndf: kind=contract level=L1 layer=state status=accepted
// The resident-worker service MUST use [1] for READY, [2, ID, PC, argument]
// for LAUNCH and [3, ID, return_value] for DONE. Each entry is one XLEN word.
// READY identifies its worker by trusted transport source. LAUNCH is valid
// for one ready idle worker and an even nonzero PC. The scheduler assigns an
// ID unique to that worker's invocation. Only the matched worker's exact
// outstanding ID can complete, and its return value MUST come from DONE.
// Transport replay MUST NOT issue another launch. A stale invocation or
// malformed service message MUST NOT advance worker state. Receiving LAUNCH,
// its transport ACK, a wait event or another worker's DONE cannot establish
// completion. BWE remains the existing nonblocking WaitEvent handoff. A
// platform that parks the worker MUST allow progress when its queue is
// already populated or a packet subsequently arrives. Bus timing, arbitration,
// memory visibility and the worker's kernel-call implementation are outside
// this functional profile. The reference bounds issued-ID history without
// eviction during the invocation; a full table returns EXHAUSTED. Normal end
// waits for an outstanding DONE; abort invalidates the old service binding.
// LAUNCH MUST serialize against pending service ingress and MUST reserve the
// worker replay receipt, worker transmit identity, and service receive claim
// needed by its matching DONE. Other sends MUST preserve those reservations.
// The worker MUST accept a kernel entry only from the read-complete claimed
// four-word LAUNCH sent by HSCB with a nonzero halfword-aligned PC. It
// acknowledges and releases that exact claim before calling the entry. Peers
// may use identical payload bytes as ordinary data.
// NDF-END: PTO-ARCH-HSCB-DISPATCH-001

func EnableHSCBService()
begin
    // Platform cold-boot action. Repeated enables preserve transport identity.
    if !_MessageBufferBanks[[PTO_HSCB_BANK]].enabled then
        _MessageBufferBanks[[PTO_HSCB_BANK]].domain_bound = TRUE;
        _MessageBufferBanks[[PTO_HSCB_BANK]].domain = Zeros{64} + 1;
        _MessageBufferBanks[[PTO_HSCB_BANK]].bound_invocation = 1;
        _MessageBufferBanks[[PTO_HSCB_BANK]].source_epoch = Zeros{32} + 1;
        _MessageBufferBanks[[PTO_HSCB_BANK]].rx_epoch = Zeros{16} + 1;
        _MessageBufferBanks[[PTO_HSCB_BANK]].enabled = TRUE;
    end;
end;

readonly func HSCBWorkerHasMessage(worker: MessageBufferEndpointIndex) => boolean
begin
    return worker < PTO_HSCB_BANK && _MessageBufferBanks[[worker]].enabled &&
           _MessageBufferBanks[[worker]].queued.valid;
end;

func HSCBObserveWaitEvent()
begin
    let worker = CurrentMessageBufferIndex();
    if _MessageBufferBanks[[PTO_HSCB_BANK]].enabled && MessageBufferEnabledForCurrentContext() then
        _MessageBufferBanks[[worker]].hscb_waiting = !HSCBWorkerHasMessage(worker);
    end;
end;

readonly func HSCBWorkerAcceptsLaunch() => boolean
begin
    let worker = CurrentMessageBufferIndex();
    let snap = _MessageBufferBanks[[worker]].snapshot;
    if !MessageBufferEnabledForCurrentContext() || !MessageBufferSnapshotOwnerMatches(worker) ||
       snap.acked || snap.message.word_count != 4 || !MessageBufferReadComplete(worker) then
        return FALSE;
    end;
    let pc = snap.message.words[[2]];
    return snap.message.message_id_hi[63:32] == Ones{32} &&
           snap.message.words[[0]] == Zeros{64} + 2 && pc != Zeros{64} && pc[0] == '0';
end;

func HSCBIssueLaunch(worker: MessageBufferEndpointIndex, dispatch_id: Word,
                     kernel_pc: Word, argument: Word) => MessageBufferResult
begin
    if !_MessageBufferBanks[[PTO_HSCB_BANK]].enabled || worker == PTO_HSCB_BANK || worker MOD PTO_ACR_COUNT != 0 ||
       kernel_pc == Zeros{64} || kernel_pc[0] == '1' ||
       !_MessageBufferBanks[[worker]].hscb_ready then
        return MessageBufferResult_BadCommand;
    end;
    if _MessageBufferBanks[[worker]].hscb_running || !MessageBufferBankQuiescent(PTO_HSCB_BANK) then
        return MessageBufferResult_Busy;
    end;
    let used = _MessageBufferBanks[[worker]].hscb_issued_count;
    for i = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
        if i < used && _MessageBufferBanks[[worker]].hscb_issued_ids[[i]] == dispatch_id then
            return MessageBufferResult_BadCommand;
        end;
    end;
    let host_claims_left = UInt(Ones{48}) - UInt(_MessageBufferBanks[[PTO_HSCB_BANK]].claim_sequence);
    if used == PTO_MODEL_MESSAGE_BUFFER_RECEIPTS ||
       FindFreeMessageBufferReplayReceipt(worker, FALSE) == PTO_MODEL_MESSAGE_BUFFER_RECEIPTS ||
       _MessageBufferBanks[[worker]].transmit_sequence == Ones{64} ||
       _MessageBufferBanks[[worker]].claim_sequence == Ones{48} ||
       host_claims_left <= HSCBOutstandingDispatchCount() then
        return MessageBufferResult_Exhausted;
    end;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[0]] = Zeros{64} + 2;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[1]] = dispatch_id;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[2]] = kernel_pc;
    _MessageBufferBanks[[PTO_HSCB_BANK]].staging_words[[3]] = argument;
    let status = AdmitMessageBufferPacket(PTO_HSCB_BANK, Zeros{64} + (4 << 32) + worker, TRUE);
    if status == MessageBufferResult_OK then
        _MessageBufferBanks[[worker]].hscb_issued_ids[[used as MessageBufferReceiptIndex]] = dispatch_id;
        _MessageBufferBanks[[worker]].hscb_issued_count =
            (used + 1) as integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS};
        _MessageBufferBanks[[worker]].hscb_running = TRUE;
        _MessageBufferBanks[[worker]].hscb_dispatch_id = dispatch_id;
    end;
    return status;
end;

func HSCBReceiveWorkerMessage() => MessageBufferResult
begin
    let host = PTO_HSCB_BANK;
    if !_MessageBufferBanks[[host]].enabled then return MessageBufferResult_BadCommand; end;
    ClaimMessageBufferSnapshot(host, Zeros{64} + 1);
    let claim_result = _MessageBufferBanks[[host]].rx_result;
    if claim_result != MessageBufferResult_OK then return claim_result; end;
    let packet = _MessageBufferBanks[[host]].snapshot.message;
    let token = _MessageBufferBanks[[host]].snapshot.token;
    var payload: MessageBufferWords;
    for i = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        if i < packet.word_count then
            payload[[i]] = ReadMessageBufferData(host, i as MessageBufferWordIndex);
        end;
    end;
    AcknowledgeMessageBufferSnapshot(host, token);
    let ack = _MessageBufferBanks[[host]].ack_result;
    if ack != MessageBufferResult_OK then return ack; end;
    ReleaseMessageBufferSnapshot(host, token);
    let released = _MessageBufferBanks[[host]].rx_result;
    if released != MessageBufferResult_OK then return released; end;
    let source = UInt(packet.message_id_hi[63:32]);
    if source >= PTO_HSCB_BANK || source MOD PTO_ACR_COUNT != 0 then
        return MessageBufferResult_BadCommand;
    end;
    let worker = source as MessageBufferEndpointIndex;
    if !_MessageBufferBanks[[worker]].enabled ||
       _MessageBufferBanks[[worker]].bound_invocation != packet.source_invocation then
        return MessageBufferResult_NotOwner;
    end;
    if packet.word_count == 1 && payload[[0]] == Zeros{64} + 1 &&
       !_MessageBufferBanks[[worker]].hscb_ready then
        _MessageBufferBanks[[worker]].hscb_ready = TRUE;
    elsif packet.word_count == 3 && payload[[0]] == Zeros{64} + 3 &&
          _MessageBufferBanks[[worker]].hscb_running &&
          _MessageBufferBanks[[worker]].hscb_dispatch_id == payload[[1]] then
        _MessageBufferBanks[[worker]].hscb_running = FALSE;
        _MessageBufferBanks[[worker]].hscb_return_value = payload[[2]];
    else
        return MessageBufferResult_BadCommand;
    end;
    return MessageBufferResult_OK;
end;
```
<!-- GENERATED-ASL-END: unit -->
