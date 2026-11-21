<!-- GENERATED FROM: asl/arch/state/hscb-dispatch.asl -->
# HSCB Dispatch

**Normative ASL source:** `asl/arch/state/hscb-dispatch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-HSCB-DISPATCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-state-hscb-dispatch-purpose role=purpose-scope -->
## HSCB 派发协调什么

高速配置总线（HSCB）通过各端点的消息缓冲区（MSGB）连接调度器与常驻工作线程。参考核心包含四个物理 PE，每个 PE 上有两个可独立寻址的硬件线程。工作线程初始化自己的bank 后发送 READY。调度器向该线程发送 LAUNCH，载荷包含派发 ID、kernel 入口 PC 和参数。kernel 返回后，线程用相同 ID 和返回值发送 DONE，再次等待派发。派发身份与消息接收分开，使 worker 能在 kernel 返回前释放收件槽。

<!-- PTO-READER-BLOCK: arch-state-hscb-dispatch-state role=concepts-state -->
## Worker 与派发身份

READY 根据可信的传输源识别 worker。未完成的派发记录 worker 的 invocation、派发 ID 和确切的 LAUNCH 消息身份。目标 ACR0 端点还为该次派发保存 `BLOCKNUM` 和 `BLOCKID`。

<!-- PTO-READER-BLOCK: arch-state-hscb-dispatch-rules role=rules-interactions -->
## 从接纳到完成

就绪 worker 认领匹配的 LAUNCH，读完载荷后确认并释放快照。调度器消费该 worker 的匹配 DONE 时清除派发。

<!-- PTO-READER-BLOCK: arch-state-hscb-dispatch-boundary role=boundaries -->
## 几何绑定的生命周期

派发未完成时，worker 读取绑定的几何。完成或清理 invocation 后，恢复基础寄存器视图。现有 `HSCBIssueLaunch` 入口提供 `1/0`。

BWE 发布架构级 WaitEvent 请求后退休。启用 HSCB 的平台可以观察该请求，在 bank 为空时
停驻请求线程。若已有消息排队，或后续接纳了新消息，工作线程可以继续执行。线程被唤醒后
再次检查自己的 bank。

<!-- PTO-READER-BLOCK: arch-state-hscb-dispatch-example role=example-usage -->
## 交错执行的 worker

同级 worker 可以使用不同的逻辑 block 编号。调度器消费其中一个 worker 的匹配 DONE 后，另一个 worker 继续读取自己的几何。

<!-- PTO-READER-BLOCK: arch-state-hscb-dispatch-related role=related-owners-navigation -->
## 相关规范源

有关接纳，参见 [Message Buffer 发送](message-buffer-send.md)，有关接收流程，参见 [接收与确认](message-buffer.md)，有关端点选择，参见 [Message Buffer 状态](message-buffer-state.md)。
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
// MUST match the worker's one outstanding dispatch ID and exact transport
// identity allocated by HSCBIssueLaunch. It acknowledges and releases that
// exact claim before calling the entry. Peers and other HSCB-origin packets
// may use identical payload bytes as ordinary data.
// NDF-END: PTO-ARCH-HSCB-DISPATCH-001

// NDF-BEGIN: PTO-ARCH-HSCB-BLOCK-LAUNCH-001
// ndf: kind=contract level=L1 layer=state status=accepted
// HSCBIssueBlockLaunch MUST bind a positive 32-bit BLOCKNUM and a 32-bit
// BLOCKID smaller than BLOCKNUM to the addressed ACR0 endpoint's outstanding
// dispatch without changing the four-word LAUNCH payload. From successful
// admission until matching DONE is consumed, permitted reads at that endpoint
// MUST return the zero-extended bound values. A rejected launch or unmatched
// DONE MUST NOT change an existing binding. Other endpoints retain their
// own bindings or read the ambient base registers when unbound.
// Clearing a dispatch at matching DONE, invocation retirement, or reset
// restores the ambient base-register view. Reset supplies zero for both.
// HSCBIssueLaunch MUST bind BLOCKNUM=1 and BLOCKID=0.
// NDF-END: PTO-ARCH-HSCB-BLOCK-LAUNCH-001

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
       !_MessageBufferBanks[[worker]].hscb_running || snap.acked ||
       snap.message.word_count != 4 || !MessageBufferReadComplete(worker) then
        return FALSE;
    end;
    let pc = snap.message.words[[2]];
    return snap.message.message_id_hi[63:32] == Ones{32} &&
           snap.message.message_id_hi ==
               _MessageBufferBanks[[worker]].hscb_launch_message_id_hi &&
           snap.message.message_id_lo ==
               _MessageBufferBanks[[worker]].hscb_launch_message_id_lo &&
           snap.message.words[[0]] == Zeros{64} + 2 &&
           snap.message.words[[1]] == _MessageBufferBanks[[worker]].hscb_dispatch_id &&
           pc != Zeros{64} && pc[0] == '0';
end;

func HSCBIssueBlockLaunch(worker: MessageBufferEndpointIndex, dispatch_id: Word,
                          kernel_pc: Word, argument: Word, block_num: Word,
                          block_id: Word) => MessageBufferResult
begin
    if !_MessageBufferBanks[[PTO_HSCB_BANK]].enabled || worker == PTO_HSCB_BANK || worker MOD PTO_ACR_COUNT != 0 ||
       kernel_pc == Zeros{64} || kernel_pc[0] == '1' ||
       block_num == Zeros{64} || block_num[63:32] != Zeros{32} ||
       block_id[63:32] != Zeros{32} || UInt(block_id) >= UInt(block_num) ||
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
        _MessageBufferBanks[[worker]].hscb_launch_message_id_hi =
            _MessageBufferBanks[[worker]].queued.message_id_hi;
        _MessageBufferBanks[[worker]].hscb_launch_message_id_lo =
            _MessageBufferBanks[[worker]].queued.message_id_lo;
        _MessageBufferBanks[[worker]].hscb_blocknum = block_num;
        _MessageBufferBanks[[worker]].hscb_blockid = block_id;
    end;
    return status;
end;

func HSCBIssueLaunch(worker: MessageBufferEndpointIndex, dispatch_id: Word,
                     kernel_pc: Word, argument: Word) => MessageBufferResult
begin
    return HSCBIssueBlockLaunch(worker, dispatch_id, kernel_pc, argument,
                                Zeros{64} + 1, Zeros{64});
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
        _MessageBufferBanks[[worker]].hscb_launch_message_id_hi = Zeros{64};
        _MessageBufferBanks[[worker]].hscb_launch_message_id_lo = Zeros{64};
        _MessageBufferBanks[[worker]].hscb_blocknum = Zeros{64};
        _MessageBufferBanks[[worker]].hscb_blockid = Zeros{64};
        _MessageBufferBanks[[worker]].hscb_return_value = payload[[2]];
    else
        return MessageBufferResult_BadCommand;
    end;
    return MessageBufferResult_OK;
end;
```
<!-- GENERATED-ASL-END: unit -->
