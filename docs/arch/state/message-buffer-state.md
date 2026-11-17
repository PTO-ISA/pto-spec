<!-- GENERATED FROM: asl/arch/state/message-buffer-state.asl -->
# Message Buffer State

**Normative ASL source:** `asl/arch/state/message-buffer-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-MESSAGE-BUFFER-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/message-buffer-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-MESSAGE-BUFFER-STATE","surface":"arch","classification":["state","message-buffer-state"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-MODEL","PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-MESSAGE-BUFFER","classification":["architecture","message-buffer"],"scope":"system","owner":"PTO-ARCH-STATE-MESSAGE-BUFFER-STATE","members":["_MessageBufferBanks","_MessageBufferConfigSelectors","_MessageBufferCoreDraining","_MessageBufferThreads"],"depends_on":["PTO-STATE-ARCH-KERNEL-LIFECYCLE"]}

// NDF-BEGIN: PTO-ARCH-MSGB-IDENTITY-001
// ndf: kind=contract level=L1 layer=state status=accepted
// An admitted message MUST have the trusted 128-bit transport identity
// {source endpoint, source epoch, transmit sequence}.  Admission MUST allocate
// a nonzero sequence exactly once; retry of one accepted BSE occurrence MUST
// retain that identity.  Every receive claim MUST allocate a fresh nonzero
// {receive epoch, claim sequence} token, including a reclaim of the same
// message.  Epochs and sequences MUST NOT wrap or alias an older identity.
// NDF-END: PTO-ARCH-MSGB-IDENTITY-001

// NDF-BEGIN: PTO-ARCH-MSGB-STATE-001
// ndf: kind=contract level=L1 layer=state status=accepted
// MSGB state MUST be isolated by Core, PE, and ACR, MUST remain outside PE and
// trap save images, and MUST preserve admitted sends, receive claims, ACK
// results, and sequence progress across precise recovery.  The fixed endpoint,
// payload, queue, and replay-receipt bounds in this executable reference are
// model bounds, not implementation capacity claims.  Source retirement MUST
// preserve packets already copied atomically into remote destination banks;
// this reference has no residual source payload after admission.  A disabled
// bank MUST preserve its invocation binding and admitted replay receipts so a
// same-invocation re-enable cannot republish an old BSE occurrence.  Actual
// invocation retirement or rebind MUST scrub private staging, diagnostic,
// ACK, and replay state while preserving domains, epochs, sequence progress,
// and packets already committed to another destination bank.  A disabled bank
// MUST preserve the legacy BSE scheduling-request behavior and MUST NOT expose
// operational payload state.
// NDF-END: PTO-ARCH-MSGB-STATE-001

// NDF-BEGIN: PTO-ARCH-HSCB-ENDPOINT-001
// ndf: kind=contract level=L1 layer=state status=open
// The resident-worker profile MUST isolate a bank and its privileged selector
// by Core, physical PE, hardware-thread slot and ACR. Its reference Core has
// four PEs and two slots per PE: worker = 4 * slot + PE. Its endpoint address
// is 16 * (8 * Core + worker) + ACR. A trusted platform selects the active
// slot, resetting to zero; a guest cannot switch slots by writing CFGSEL.
// The slot qualifies the MSGB/HSCB state only. The scalar register and GM
// obligation owners retain their existing Core/PE/invocation semantics.
// The HSCB service uses endpoint 0xffffffff in its own transport namespace.
// NDF-END: PTO-ARCH-HSCB-ENDPOINT-001
constant PTO_MSGB_THREADS_PER_PE = 2;
constant PTO_MSGB_WORKERS_PER_CORE = PTO_MODEL_MEMORY_AGENTS * PTO_MSGB_THREADS_PER_PE;
constant PTO_MODEL_MESSAGE_BUFFER_ENDPOINTS =
    PTO_MODEL_CORE_INSTANCES * PTO_MSGB_WORKERS_PER_CORE * PTO_ACR_COUNT;
constant PTO_HSCB_BANK = PTO_MODEL_MESSAGE_BUFFER_ENDPOINTS;
constant PTO_HSCB_ENDPOINT = 0xffffffff;
constant PTO_MODEL_MESSAGE_BUFFER_WORDS = 10;
constant PTO_MODEL_MESSAGE_BUFFER_RECEIPTS = 16;
constant PTO_MSGBCR_ADDRESS = 0x0830;
constant PTO_MSGBD1_ADDRESS = 0x0831;
constant PTO_MSGBD10_ADDRESS = 0x083a;
constant PTO_MSGBRXCLAIM_ADDRESS = 0x083b;
constant PTO_MSGBRXSTATE_ADDRESS = 0x083c;
constant PTO_MSGBRXTOKEN_ADDRESS = 0x083d;
constant PTO_MSGBRXMSGID_HI_ADDRESS = 0x083e;
constant PTO_MSGBRXMSGID_LO_ADDRESS = 0x083f;
constant PTO_MSGBRXCONTROL_ADDRESS = 0x0840;
constant PTO_MSGBRXRELEASE_ADDRESS = 0x0841;
constant PTO_MSGBACK_ADDRESS = 0x0842;
constant PTO_MSGBACKSTAT_ADDRESS = 0x0843;
constant PTO_MSGBACKID_ADDRESS = 0x0844;
constant PTO_MSGBTXID_HI_ADDRESS = 0x0845;
constant PTO_MSGBTXID_LO_ADDRESS = 0x0846;
constant PTO_MSGBTXSTAT_ADDRESS = 0x0847;
constant PTO_MSGBENDPOINT_ADDRESS = 0x0848;
constant PTO_MSGB_CFGSEL_ADDRESS = 0x0849;
constant PTO_MSGB_CFG_ADDRESS = 0x084a;
constant PTO_MSGB_DOMAIN_ADDRESS = 0x084b;

type MessageBufferThread of integer {0..PTO_MSGB_THREADS_PER_PE-1};
type MessageBufferEndpointIndex of integer {0..PTO_HSCB_BANK};
type MessageBufferWordIndex of integer {0..PTO_MODEL_MESSAGE_BUFFER_WORDS-1};
type MessageBufferWordCount of integer {0..PTO_MODEL_MESSAGE_BUFFER_WORDS};
type MessageBufferReceiptIndex of integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS-1};
type MessageBufferResult of integer {0..13};
type MessageBufferWords of array [[PTO_MODEL_MESSAGE_BUFFER_WORDS]] of Word;

constant MessageBufferResult_None = 0;
constant MessageBufferResult_OK = 1;
constant MessageBufferResult_Duplicate = 2;
constant MessageBufferResult_Empty = 3;
constant MessageBufferResult_Busy = 4;
constant MessageBufferResult_NoClaim = 5;
constant MessageBufferResult_NotOwner = 6;
constant MessageBufferResult_TokenMismatch = 7;
constant MessageBufferResult_StaleEpoch = 8;
constant MessageBufferResult_BadToken = 9;
constant MessageBufferResult_NotRead = 10;
constant MessageBufferResult_Exhausted = 11;
constant MessageBufferResult_BadCommand = 12;
constant MessageBufferResult_IOError = 13;

type MessageBufferQueuedMessage of record {
    valid: boolean,
    source_invocation: integer,
    destination_invocation: integer,
    control: Word,
    word_count: MessageBufferWordCount,
    words: MessageBufferWords,
    message_id_hi: Word,
    message_id_lo: Word
};

type MessageBufferSnapshot of record {
    valid: boolean,
    acked: boolean,
    owner_invocation: integer,
    token: Word,
    read_mask: bits(10),
    message: MessageBufferQueuedMessage
};

type MessageBufferReplayReceipt of record {
    valid: boolean,
    invocation: integer,
    acr: AccessControlRing,
    execution_domain_token: integer,
    instruction_pc: Word,
    control: Word,
    message_id_hi: Word,
    message_id_lo: Word
};
type MessageBufferReplayReceipts of array [[PTO_MODEL_MESSAGE_BUFFER_RECEIPTS]]
    of MessageBufferReplayReceipt;

type HSCBIssuedIDs of array [[PTO_MODEL_MESSAGE_BUFFER_RECEIPTS]] of Word;
type MessageBufferBank of record {
    enabled: boolean,
    domain_bound: boolean,
    domain: Word,
    bound_invocation: integer,
    rx_epoch: bits(16),
    source_epoch: bits(32),
    transmit_sequence: Word,
    claim_sequence: bits(48),
    staging_words: MessageBufferWords,
    last_accepted_control: Word,
    tx_result: MessageBufferResult,
    tx_result_valid: boolean,
    tx_message_id_hi: Word,
    tx_message_id_lo: Word,
    queued: MessageBufferQueuedMessage,
    snapshot: MessageBufferSnapshot,
    rx_result: MessageBufferResult,
    ack_result: MessageBufferResult,
    ack_result_valid: boolean,
    ack_id: Word,
    last_success_valid: boolean,
    last_success_token: Word,
    hscb_ready: boolean,
    hscb_running: boolean,
    hscb_waiting: boolean,
    hscb_issued_ids: HSCBIssuedIDs,
    hscb_issued_count: integer {0..PTO_MODEL_MESSAGE_BUFFER_RECEIPTS},
    hscb_dispatch_id: Word,
    hscb_return_value: Word,
    receipts: MessageBufferReplayReceipts
};

type MessageBufferBanks of array [[PTO_MODEL_MESSAGE_BUFFER_ENDPOINTS + 1]]
    of MessageBufferBank;
type MessageBufferConfigSelectorBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of array [[PTO_MSGB_THREADS_PER_PE]] of AccessControlRing;
type MessageBufferThreadSelection of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of MessageBufferThread;
type MessageBufferCoreDrainBank of array [[PTO_MODEL_CORE_INSTANCES]] of boolean;

var _MessageBufferThreads : MessageBufferThreadSelection;
var _MessageBufferBanks : MessageBufferBanks;
var _MessageBufferConfigSelectors : MessageBufferConfigSelectorBank;
var _MessageBufferCoreDraining : MessageBufferCoreDrainBank;

func ClearMessageBufferReplayReceipts(index: MessageBufferEndpointIndex)
begin
    for slot = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
        _MessageBufferBanks[[index]].hscb_issued_ids[[slot]] = Zeros{64};
        _MessageBufferBanks[[index]].receipts[[slot]].valid = FALSE;
        _MessageBufferBanks[[index]].receipts[[slot]].invocation = 0;
        _MessageBufferBanks[[index]].receipts[[slot]].acr = 0;
        _MessageBufferBanks[[index]].receipts[[slot]].execution_domain_token = 0;
        _MessageBufferBanks[[index]].receipts[[slot]].instruction_pc =
            Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].receipts[[slot]].control = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].receipts[[slot]].message_id_hi =
            Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].receipts[[slot]].message_id_lo =
            Zeros{PTO_XLEN};
    end;
end;

pure func MessageBufferWorkerEndpoint(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                                      slot: MessageBufferThread, acr: AccessControlRing)
                                      => MessageBufferEndpointIndex
begin
    let worker = core * PTO_MSGB_WORKERS_PER_CORE + slot * PTO_MODEL_MEMORY_AGENTS + pe;
    return (worker * PTO_ACR_COUNT + acr) as MessageBufferEndpointIndex;
end;

pure func MessageBufferEndpointIndexOf(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                                       acr: AccessControlRing) => MessageBufferEndpointIndex
begin
    return MessageBufferWorkerEndpoint(core, pe, 0, acr);
end;

pure func MessageBufferEndpointWord(index: MessageBufferEndpointIndex) => Word
begin
    return Zeros{PTO_XLEN} + (if index == PTO_HSCB_BANK then PTO_HSCB_ENDPOINT else index);
end;

pure func MessageBufferResultWord(result: MessageBufferResult,
                                  valid: boolean) => Word
begin
    var value = Zeros{PTO_XLEN};
    value[7:0] = Zeros{8} + result;
    value[8] = if valid then '1' else '0';
    return value;
end;

readonly func MessageBufferBankQuiescent(index: MessageBufferEndpointIndex)
    => boolean
begin
    return !_MessageBufferBanks[[index]].queued.valid &&
           !_MessageBufferBanks[[index]].snapshot.valid;
end;

readonly func MessageBufferCoreQuiescent(core: PTOModelCoreIdentity) => boolean
begin
    for worker = 0 to PTO_MSGB_WORKERS_PER_CORE - 1 do
        for acr = 0 to PTO_ACR_COUNT - 1 do
            let index = ((core * PTO_MSGB_WORKERS_PER_CORE + worker) *
                PTO_ACR_COUNT + acr) as MessageBufferEndpointIndex;
            if !MessageBufferBankQuiescent(index) then return FALSE; end;
        end;
    end;
    return TRUE;
end;

readonly func HSCBDispatchesComplete(core: PTOModelCoreIdentity) => boolean
begin
    for worker = 0 to PTO_MSGB_WORKERS_PER_CORE - 1 do
        let index = ((core * PTO_MSGB_WORKERS_PER_CORE + worker) * PTO_ACR_COUNT)
                    as MessageBufferEndpointIndex;
        if _MessageBufferBanks[[index]].hscb_running then return FALSE; end;
    end;
    return TRUE;
end;

readonly func MessageBufferReadComplete(index: MessageBufferEndpointIndex)
    => boolean
begin
    let count = _MessageBufferBanks[[index]].snapshot.message.word_count;
    for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        if word < count &&
           _MessageBufferBanks[[index]].snapshot.read_mask[word] == '0' then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func MessageBufferTokenValid(token: Word) => boolean
begin
    return token[63:48] != Zeros{16} && token[47:0] != Zeros{48};
end;

func ClearMessageBufferQueuedMessage(index: MessageBufferEndpointIndex)
begin
    _MessageBufferBanks[[index]].queued.valid = FALSE;
    _MessageBufferBanks[[index]].queued.source_invocation = 0;
    _MessageBufferBanks[[index]].queued.destination_invocation = 0;
    _MessageBufferBanks[[index]].queued.control = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].queued.word_count = 0;
    _MessageBufferBanks[[index]].queued.message_id_hi = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].queued.message_id_lo = Zeros{PTO_XLEN};
    for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        _MessageBufferBanks[[index]].queued.words[[word]] = Zeros{PTO_XLEN};
    end;
end;

func ClearMessageBufferSnapshot(index: MessageBufferEndpointIndex)
begin
    _MessageBufferBanks[[index]].snapshot.valid = FALSE;
    _MessageBufferBanks[[index]].snapshot.acked = FALSE;
    _MessageBufferBanks[[index]].snapshot.owner_invocation = 0;
    _MessageBufferBanks[[index]].snapshot.token = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].snapshot.read_mask = Zeros{10};
    _MessageBufferBanks[[index]].snapshot.message.valid = FALSE;
    _MessageBufferBanks[[index]].snapshot.message.source_invocation = 0;
    _MessageBufferBanks[[index]].snapshot.message.destination_invocation = 0;
    _MessageBufferBanks[[index]].snapshot.message.control = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].snapshot.message.word_count = 0;
    _MessageBufferBanks[[index]].snapshot.message.message_id_hi = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].snapshot.message.message_id_lo = Zeros{PTO_XLEN};
    for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        _MessageBufferBanks[[index]].snapshot.message.words[[word]] =
            Zeros{PTO_XLEN};
    end;
end;

func ClearMessageBufferInvocationState(index: MessageBufferEndpointIndex)
begin
    assert MessageBufferBankQuiescent(index);
    _MessageBufferBanks[[index]].enabled = FALSE;
    _MessageBufferBanks[[index]].bound_invocation = 0;
    _MessageBufferBanks[[index]].hscb_ready = FALSE;
    _MessageBufferBanks[[index]].hscb_running = FALSE;
    _MessageBufferBanks[[index]].hscb_waiting = FALSE;
    _MessageBufferBanks[[index]].hscb_issued_count = 0;
    _MessageBufferBanks[[index]].hscb_dispatch_id = Zeros{64};
    _MessageBufferBanks[[index]].hscb_return_value = Zeros{64};
    _MessageBufferBanks[[index]].last_accepted_control = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].tx_result = MessageBufferResult_None;
    _MessageBufferBanks[[index]].tx_result_valid = FALSE;
    _MessageBufferBanks[[index]].tx_message_id_hi = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].tx_message_id_lo = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].rx_result = MessageBufferResult_None;
    _MessageBufferBanks[[index]].ack_result = MessageBufferResult_None;
    _MessageBufferBanks[[index]].ack_result_valid = FALSE;
    _MessageBufferBanks[[index]].ack_id = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].last_success_valid = FALSE;
    _MessageBufferBanks[[index]].last_success_token = Zeros{PTO_XLEN};
    for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
        _MessageBufferBanks[[index]].staging_words[[word]] = Zeros{PTO_XLEN};
    end;
    ClearMessageBufferReplayReceipts(index);
    ClearMessageBufferQueuedMessage(index);
    ClearMessageBufferSnapshot(index);
end;

func ResetMessageBufferState()
begin
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        _MessageBufferCoreDraining[[core]] = FALSE;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            _MessageBufferThreads[[core]][[pe]] = 0;
            for slot = 0 to PTO_MSGB_THREADS_PER_PE - 1 do
                _MessageBufferConfigSelectors[[core]][[pe]][[slot]] = 0;
            end;
        end;
    end;
    for endpoint = 0 to PTO_HSCB_BANK do
        let index = endpoint as MessageBufferEndpointIndex;
        _MessageBufferBanks[[index]].enabled = FALSE;
        _MessageBufferBanks[[index]].domain_bound = FALSE;
        _MessageBufferBanks[[index]].domain = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].bound_invocation = 0;
        _MessageBufferBanks[[index]].hscb_ready = FALSE;
        _MessageBufferBanks[[index]].hscb_running = FALSE;
        _MessageBufferBanks[[index]].hscb_waiting = FALSE;
        _MessageBufferBanks[[index]].hscb_issued_count = 0;
        _MessageBufferBanks[[index]].hscb_dispatch_id = Zeros{64};
        _MessageBufferBanks[[index]].hscb_return_value = Zeros{64};
        _MessageBufferBanks[[index]].rx_epoch = Zeros{16};
        _MessageBufferBanks[[index]].source_epoch = Zeros{32};
        _MessageBufferBanks[[index]].transmit_sequence = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].claim_sequence = Zeros{48};
        _MessageBufferBanks[[index]].last_accepted_control = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].tx_result = MessageBufferResult_None;
        _MessageBufferBanks[[index]].tx_result_valid = FALSE;
        _MessageBufferBanks[[index]].tx_message_id_hi = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].tx_message_id_lo = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_None;
        _MessageBufferBanks[[index]].ack_result = MessageBufferResult_None;
        _MessageBufferBanks[[index]].ack_result_valid = FALSE;
        _MessageBufferBanks[[index]].ack_id = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].last_success_valid = FALSE;
        _MessageBufferBanks[[index]].last_success_token = Zeros{PTO_XLEN};
        ClearMessageBufferReplayReceipts(index);
        for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
            _MessageBufferBanks[[index]].staging_words[[word]] = Zeros{PTO_XLEN};
        end;
        ClearMessageBufferQueuedMessage(index);
        ClearMessageBufferSnapshot(index);
    end;
end;

readonly func MessageBufferStateIsReset() => boolean
begin
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        if _MessageBufferCoreDraining[[core]] then return FALSE; end;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            if _MessageBufferThreads[[core]][[pe]] != 0 then return FALSE; end;
            for slot = 0 to PTO_MSGB_THREADS_PER_PE - 1 do
                if _MessageBufferConfigSelectors[[core]][[pe]][[slot]] != 0 then return FALSE; end;
            end;
        end;
    end;
    for endpoint = 0 to PTO_HSCB_BANK do
        let index = endpoint as MessageBufferEndpointIndex;
        let bank = _MessageBufferBanks[[index]];
        if bank.hscb_ready || bank.hscb_running || bank.hscb_waiting || bank.hscb_issued_count != 0 ||
           bank.hscb_dispatch_id != Zeros{64} || bank.hscb_return_value != Zeros{64} || bank.enabled || bank.domain_bound ||
           bank.domain != Zeros{PTO_XLEN} || bank.bound_invocation != 0 ||
           bank.rx_epoch != Zeros{16} || bank.source_epoch != Zeros{32} ||
           bank.transmit_sequence != Zeros{PTO_XLEN} ||
           bank.claim_sequence != Zeros{48} ||
           bank.last_accepted_control != Zeros{PTO_XLEN} ||
           bank.tx_result != MessageBufferResult_None || bank.tx_result_valid ||
           bank.tx_message_id_hi != Zeros{PTO_XLEN} ||
           bank.tx_message_id_lo != Zeros{PTO_XLEN} ||
           bank.queued.valid || bank.snapshot.valid ||
           bank.rx_result != MessageBufferResult_None ||
           bank.ack_result != MessageBufferResult_None || bank.ack_result_valid ||
           bank.ack_id != Zeros{PTO_XLEN} || bank.last_success_valid ||
           bank.last_success_token != Zeros{PTO_XLEN} then
            return FALSE;
        end;
        for slot = 0 to PTO_MODEL_MESSAGE_BUFFER_RECEIPTS - 1 do
            if bank.receipts[[slot]].valid then return FALSE; end;
        end;
        for word = 0 to PTO_MODEL_MESSAGE_BUFFER_WORDS - 1 do
            if bank.staging_words[[word]] != Zeros{PTO_XLEN} then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func BeginMessageBufferDrain(core: PTOModelCoreIdentity)
begin
    _MessageBufferCoreDraining[[core]] = TRUE;
end;

func BeginMessageBufferInvocation(core: PTOModelCoreIdentity, invocation: integer)
begin
    if MessageBufferCoreQuiescent(core) then
        _MessageBufferCoreDraining[[core]] = FALSE;
    end;
end;

func RetireMessageBufferInvocation(core: PTOModelCoreIdentity,
                                   invocation: integer)
begin
    assert MessageBufferCoreQuiescent(core);
    for worker = 0 to PTO_MSGB_WORKERS_PER_CORE - 1 do
        for acr = 0 to PTO_ACR_COUNT - 1 do
            let index = ((core * PTO_MSGB_WORKERS_PER_CORE + worker) *
                PTO_ACR_COUNT + acr) as MessageBufferEndpointIndex;
            if _MessageBufferBanks[[index]].bound_invocation == invocation then
                ClearMessageBufferInvocationState(index);
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
