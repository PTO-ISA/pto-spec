// PTO-UNIT: {"id":"PTO-ARCH-STATE-MESSAGE-BUFFER","surface":"arch","classification":["state","message-buffer"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-STATE-MESSAGE-BUFFER-STATE","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL","PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
// NDF-BEGIN: PTO-ARCH-MSGB-SSR-001
// ndf: kind=contract level=L1 layer=state status=accepted
// The base-register MSGB family at 0x0830..0x084b MUST expose one current-
// context operational bank.  The executing kernel ACR MAY access its enabled
// operational registers; only ACR0 MAY select and configure a bank.  MSGBD
// writes stage transmit words while MSGBD reads access only the current stable
// receive snapshot.  A rejected or blocked read MUST NOT write its destination,
// mark a word read, dequeue a message, or mutate another context.  SSRSWAP of
// any MSGB register is illegal because no member has ordinary storage semantics.
// NDF-END: PTO-ARCH-MSGB-SSR-001
// NDF-BEGIN: PTO-ARCH-MSGB-ACK-001
// ndf: kind=contract level=L1 layer=state status=accepted
// MSGBACK MUST atomically validate the complete claim-specific token, current
// receive epoch, invocation owner, and the successful-read mask before popping
// exactly the claimed message.  Every successful claim, including reclaim of
// the same message after RELEASE, MUST use a fresh token.  The latest successful
// token MUST remain separate from ACKSTAT/ACKID so a failed attempt cannot erase
// duplicate recognition.  An ACKED snapshot MUST remain immutable and readable
// until exact-token RELEASE; a duplicate old ACK MUST NOT affect a newer claim.
// NDF-END: PTO-ARCH-MSGB-ACK-001
// NDF-BEGIN: PTO-ARCH-MSGB-LIFECYCLE-001
// ndf: kind=contract level=L1 layer=state status=accepted
// An enabled bank MUST bind a nonzero kernel invocation.  End or abort drain
// MUST freeze new work admission to and from the Core while preserving a
// matching DONE for an outstanding HSCB call, as well as receive read,
// ACK, and RELEASE needed to reach quiescence. Retirement MUST drain only
// queues and snapshots owned by the retiring Core, then disable its banks.
// Already admitted remote packets MUST survive source retirement. Epochs,
// sequences, and committed effects MUST NOT rewind.
// Configuration MAY rebind only a quiescent bank; domain is immutable after its
// first binding, and simultaneous epoch advancement MUST be exact and nonwrapping.
// NDF-END: PTO-ARCH-MSGB-LIFECYCLE-001
pure func IsMessageBufferAddress(address: SystemRegisterAddress) => boolean
begin
    return address[23:16] == Zeros{8} &&
           UInt(address[15:0]) >= PTO_MSGBCR_ADDRESS &&
           UInt(address[15:0]) <= PTO_MSGB_DOMAIN_ADDRESS;
end;
pure func IsMessageBufferConfigAddress(address: SystemRegisterAddress) => boolean
begin
    return address == Zeros{24} + PTO_MSGB_CFGSEL_ADDRESS ||
           address == Zeros{24} + PTO_MSGB_CFG_ADDRESS ||
           address == Zeros{24} + PTO_MSGB_DOMAIN_ADDRESS;
end;
pure func IsMessageBufferDataAddress(address: SystemRegisterAddress) => boolean
begin
    return address[23:16] == Zeros{8} &&
           UInt(address[15:0]) >= PTO_MSGBD1_ADDRESS &&
           UInt(address[15:0]) <= PTO_MSGBD10_ADDRESS;
end;
readonly func CurrentMessageBufferThread() => MessageBufferThread
begin
    return _MessageBufferThreads[[_CurrentModelCore]][[_CurrentMemoryAgent]];
end;

func SelectMessageBufferThread(slot: MessageBufferThread)
begin
    _MessageBufferThreads[[_CurrentModelCore]][[_CurrentMemoryAgent]] = slot;
end;

readonly func CurrentMessageBufferIndex() => MessageBufferEndpointIndex
begin
    return MessageBufferWorkerEndpoint(_CurrentModelCore, _CurrentMemoryAgent,
                                       CurrentMessageBufferThread(), CurrentACR());
end;

readonly func SelectedMessageBufferIndex() => MessageBufferEndpointIndex
begin
    let slot = CurrentMessageBufferThread();
    return MessageBufferWorkerEndpoint(_CurrentModelCore, _CurrentMemoryAgent, slot,
        _MessageBufferConfigSelectors[[_CurrentModelCore]][[_CurrentMemoryAgent]][[slot]]);
end;
readonly func MessageBufferEnabledForCurrentContext() => boolean
begin
    let bank = _MessageBufferBanks[[CurrentMessageBufferIndex()]];
    return bank.enabled &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
           _KernelInvocationActiveByCore[[_CurrentModelCore]] &&
           _CurrentKernelInvocation != 0 &&
           bank.bound_invocation == _CurrentKernelInvocation;
end;
func MessageBufferEffectPermitted(require_enabled: boolean) => boolean
begin
    if _CurrentMemoryOrigin != MemoryEventOrigin_Kernel ||
       !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 ||
       (require_enabled && !MessageBufferEnabledForCurrentContext()) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return FALSE;
    end;
    if _BundleControlAttributes.atomic || _BundleControlAttributes.far then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !CoreGMObligationsPermitArrival(
           _CurrentModelCore, _CurrentMemoryAgent,
           _CurrentKernelInvocation, _CurrentProgramOrder) then
        _ScalarExecutionBlocked = TRUE;
        return FALSE;
    end;
    return TRUE;
end;
func MessageBufferOperationalAccessPermitted() => boolean
begin
    return MessageBufferEffectPermitted(TRUE);
end;
func MessageBufferWritePreflight(address: SystemRegisterAddress) => boolean
begin
    if !IsMessageBufferAddress(address) then return TRUE; end;
    if IsMessageBufferConfigAddress(address) && CurrentACR() != 0 then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return FALSE;
    end;
    return MessageBufferEffectPermitted(!IsMessageBufferConfigAddress(address));
end;
readonly func MessageBufferActorInvocation(index: MessageBufferEndpointIndex) => integer
begin
    return if index == PTO_HSCB_BANK then _MessageBufferBanks[[index]].bound_invocation
           else _CurrentKernelInvocation;
end;

readonly func MessageBufferSnapshotOwnerMatches(index: MessageBufferEndpointIndex)
    => boolean
begin
    return _MessageBufferBanks[[index]].snapshot.valid &&
           _MessageBufferBanks[[index]].snapshot.owner_invocation ==
               MessageBufferActorInvocation(index);
end;
func SetMessageBufferACKResult(index: MessageBufferEndpointIndex,
                               result: MessageBufferResult,
                               token: Word)
begin
    _MessageBufferBanks[[index]].ack_result = result;
    _MessageBufferBanks[[index]].ack_result_valid = TRUE;
    _MessageBufferBanks[[index]].ack_id = token;
end;
func ClaimMessageBufferSnapshot(index: MessageBufferEndpointIndex,
                                command: Word)
begin
    if command == Zeros{PTO_XLEN} then return; end;
    if command != Zeros{PTO_XLEN} + 1 then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_BadCommand;
        return;
    end;
    if _MessageBufferBanks[[index]].snapshot.valid then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_Busy;
        return;
    end;
    if !_MessageBufferBanks[[index]].queued.valid then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_Empty;
        return;
    end;
    if _MessageBufferBanks[[index]].claim_sequence == Ones{48} then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_Exhausted;
        return;
    end;
    _MessageBufferBanks[[index]].claim_sequence =
        _MessageBufferBanks[[index]].claim_sequence + 1;
    _MessageBufferBanks[[index]].snapshot.valid = TRUE;
    _MessageBufferBanks[[index]].snapshot.acked = FALSE;
    _MessageBufferBanks[[index]].snapshot.owner_invocation =
        MessageBufferActorInvocation(index);
    _MessageBufferBanks[[index]].snapshot.token = Zeros{PTO_XLEN};
    _MessageBufferBanks[[index]].snapshot.token[63:48] =
        _MessageBufferBanks[[index]].rx_epoch;
    _MessageBufferBanks[[index]].snapshot.token[47:0] =
        _MessageBufferBanks[[index]].claim_sequence;
    _MessageBufferBanks[[index]].snapshot.read_mask = Zeros{10};
    _MessageBufferBanks[[index]].snapshot.message =
        _MessageBufferBanks[[index]].queued;
    _MessageBufferBanks[[index]].rx_result = MessageBufferResult_OK;
end;
func AcknowledgeMessageBufferSnapshot(index: MessageBufferEndpointIndex,
                                      token: Word)
begin
    var result: MessageBufferResult = MessageBufferResult_OK;
    if !MessageBufferTokenValid(token) then
        result = MessageBufferResult_BadToken;
    elsif token[63:48] != _MessageBufferBanks[[index]].rx_epoch then
        result = MessageBufferResult_StaleEpoch;
    elsif _MessageBufferBanks[[index]].last_success_valid &&
          token == _MessageBufferBanks[[index]].last_success_token then
        result = MessageBufferResult_Duplicate;
    elsif !_MessageBufferBanks[[index]].snapshot.valid then
        result = MessageBufferResult_NoClaim;
    elsif !MessageBufferSnapshotOwnerMatches(index) then
        result = MessageBufferResult_NotOwner;
    elsif token != _MessageBufferBanks[[index]].snapshot.token then
        result = MessageBufferResult_TokenMismatch;
    elsif !MessageBufferReadComplete(index) then
        result = MessageBufferResult_NotRead;
    elsif !_MessageBufferBanks[[index]].queued.valid ||
          _MessageBufferBanks[[index]].queued.message_id_hi !=
              _MessageBufferBanks[[index]].snapshot.message.message_id_hi ||
          _MessageBufferBanks[[index]].queued.message_id_lo !=
              _MessageBufferBanks[[index]].snapshot.message.message_id_lo then
        result = MessageBufferResult_IOError;
    else
        ClearMessageBufferQueuedMessage(index);
        _MessageBufferBanks[[index]].snapshot.acked = TRUE;
        _MessageBufferBanks[[index]].last_success_valid = TRUE;
        _MessageBufferBanks[[index]].last_success_token = token;
    end;
    SetMessageBufferACKResult(index, result, token);
end;
func ReleaseMessageBufferSnapshot(index: MessageBufferEndpointIndex,
                                  token: Word)
begin
    if !MessageBufferTokenValid(token) then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_BadToken;
    elsif token[63:48] != _MessageBufferBanks[[index]].rx_epoch then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_StaleEpoch;
    elsif !_MessageBufferBanks[[index]].snapshot.valid then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_NoClaim;
    elsif !MessageBufferSnapshotOwnerMatches(index) then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_NotOwner;
    elsif token != _MessageBufferBanks[[index]].snapshot.token then
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_TokenMismatch;
    else
        ClearMessageBufferSnapshot(index);
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_OK;
    end;
end;
func ReadMessageBufferData(index: MessageBufferEndpointIndex,
                           word: MessageBufferWordIndex) => Word
begin
    if !MessageBufferSnapshotOwnerMatches(index) ||
       word >= _MessageBufferBanks[[index]].snapshot.message.word_count then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    _MessageBufferBanks[[index]].snapshot.read_mask[word] = '1';
    return _MessageBufferBanks[[index]].snapshot.message.words[[word]];
end;
func ReadMessageBufferRegister(address: SystemRegisterAddress) => Word
begin
    var config_value = Zeros{PTO_XLEN};
    var state = Zeros{PTO_XLEN};
    let raw = UInt(address[15:0]);
    if address == Zeros{24} + PTO_MSGB_CFGSEL_ADDRESS then
        if CurrentACR() != 0 then
            SetFault(Fault_IllegalInstruction, ReadPC());
            return Zeros{PTO_XLEN};
        end;
        return Zeros{PTO_XLEN} +
            _MessageBufferConfigSelectors[[_CurrentModelCore]][[_CurrentMemoryAgent]][[CurrentMessageBufferThread()]];
    end;
    let index = if IsMessageBufferConfigAddress(address) then
        SelectedMessageBufferIndex() else CurrentMessageBufferIndex();
    if address == Zeros{24} + PTO_MSGB_CFG_ADDRESS then
        if CurrentACR() != 0 then
            SetFault(Fault_IllegalInstruction, ReadPC());
            return Zeros{PTO_XLEN};
        end;
        config_value[0] = if _MessageBufferBanks[[index]].enabled then '1' else '0';
        config_value[31:16] = _MessageBufferBanks[[index]].rx_epoch;
        config_value[63:32] = _MessageBufferBanks[[index]].source_epoch;
        return config_value;
    elsif address == Zeros{24} + PTO_MSGB_DOMAIN_ADDRESS then
        if CurrentACR() != 0 then
            SetFault(Fault_IllegalInstruction, ReadPC());
            return Zeros{PTO_XLEN};
        end;
        return _MessageBufferBanks[[index]].domain;
    elsif address == Zeros{24} + PTO_MSGBENDPOINT_ADDRESS then
        return MessageBufferEndpointWord(CurrentMessageBufferIndex());
    elsif address == Zeros{24} + PTO_MSGBCR_ADDRESS then
        return _MessageBufferBanks[[index]].last_accepted_control;
    elsif IsMessageBufferDataAddress(address) then
        if !MessageBufferOperationalAccessPermitted() then return Zeros{PTO_XLEN}; end;
        return ReadMessageBufferData(index,
            (raw - PTO_MSGBD1_ADDRESS) as MessageBufferWordIndex);
    elsif address == Zeros{24} + PTO_MSGBRXSTATE_ADDRESS then
        state[7:0] = Zeros{8} + _MessageBufferBanks[[index]].rx_result;
        if MessageBufferSnapshotOwnerMatches(index) then
            state[8] = '1';
            state[9] = if _MessageBufferBanks[[index]].snapshot.acked then '1' else '0';
            state[15:12] = Zeros{4} +
                _MessageBufferBanks[[index]].snapshot.message.word_count;
        end;
        return state;
    elsif address == Zeros{24} + PTO_MSGBRXTOKEN_ADDRESS then
        return if MessageBufferSnapshotOwnerMatches(index) then
            _MessageBufferBanks[[index]].snapshot.token else Zeros{PTO_XLEN};
    elsif address == Zeros{24} + PTO_MSGBRXMSGID_HI_ADDRESS ||
          address == Zeros{24} + PTO_MSGBRXMSGID_LO_ADDRESS ||
          address == Zeros{24} + PTO_MSGBRXCONTROL_ADDRESS then
        if !MessageBufferOperationalAccessPermitted() then
            return Zeros{PTO_XLEN};
        end;
        if !MessageBufferSnapshotOwnerMatches(index) then
            SetFault(Fault_IllegalInstruction, ReadPC());
            return Zeros{PTO_XLEN};
        end;
        if address == Zeros{24} + PTO_MSGBRXMSGID_HI_ADDRESS then
            return _MessageBufferBanks[[index]].snapshot.message.message_id_hi;
        elsif address == Zeros{24} + PTO_MSGBRXMSGID_LO_ADDRESS then
            return _MessageBufferBanks[[index]].snapshot.message.message_id_lo;
        else
            return _MessageBufferBanks[[index]].snapshot.message.control;
        end;
    elsif address == Zeros{24} + PTO_MSGBACKSTAT_ADDRESS then
        return MessageBufferResultWord(_MessageBufferBanks[[index]].ack_result,
            _MessageBufferBanks[[index]].ack_result_valid);
    elsif address == Zeros{24} + PTO_MSGBACKID_ADDRESS then
        return _MessageBufferBanks[[index]].ack_id;
    elsif address == Zeros{24} + PTO_MSGBTXID_HI_ADDRESS then
        return _MessageBufferBanks[[index]].tx_message_id_hi;
    elsif address == Zeros{24} + PTO_MSGBTXID_LO_ADDRESS then
        return _MessageBufferBanks[[index]].tx_message_id_lo;
    elsif address == Zeros{24} + PTO_MSGBTXSTAT_ADDRESS then
        return MessageBufferResultWord(_MessageBufferBanks[[index]].tx_result,
            _MessageBufferBanks[[index]].tx_result_valid);
    end;
    SetFault(Fault_IllegalInstruction, ReadPC());
    return Zeros{PTO_XLEN};
end;
func ConfigureMessageBuffer(index: MessageBufferEndpointIndex, value: Word)
begin
    if value[15:1] != Zeros{15} then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    if value[0] == '0' then
        if value != Zeros{PTO_XLEN} || !MessageBufferBankQuiescent(index) then
            SetFault(Fault_IllegalInstruction, ReadPC());
            return;
        end;
        if _MessageBufferBanks[[index]].hscb_running then
            SetFault(Fault_IllegalInstruction, ReadPC());
            return;
        end;
        _MessageBufferBanks[[index]].hscb_waiting = FALSE;
        _MessageBufferBanks[[index]].enabled = FALSE;
        return;
    end;
    if !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 ||
       !MessageBufferBankQuiescent(index) ||
       !_MessageBufferBanks[[index]].domain_bound ||
       value[31:16] == Zeros{16} || value[63:32] == Zeros{32} then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let old_rx = _MessageBufferBanks[[index]].rx_epoch;
    let old_source = _MessageBufferBanks[[index]].source_epoch;
    let invocation_changed =
        _MessageBufferBanks[[index]].bound_invocation != _CurrentKernelInvocation;
    let first_enable = old_rx == Zeros{16} && old_source == Zeros{32};
    let same_epochs = value[31:16] == old_rx && value[63:32] == old_source;
    let advancing = old_rx != Ones{16} && old_source != Ones{32} &&
        UInt(value[31:16]) == UInt(old_rx) + 1 &&
        UInt(value[63:32]) == UInt(old_source) + 1;
    if !first_enable && !same_epochs && !advancing then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    if first_enable || advancing then
        _MessageBufferBanks[[index]].rx_epoch = value[31:16];
        _MessageBufferBanks[[index]].source_epoch = value[63:32];
        _MessageBufferBanks[[index]].transmit_sequence = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].claim_sequence = Zeros{48};
    end;
    if advancing then
        _MessageBufferBanks[[index]].last_success_valid = FALSE;
        _MessageBufferBanks[[index]].last_success_token = Zeros{PTO_XLEN};
        _MessageBufferBanks[[index]].ack_result_valid = FALSE;
        _MessageBufferBanks[[index]].rx_result = MessageBufferResult_None;
    end;
    if invocation_changed then
        ClearMessageBufferInvocationState(index);
    end;
    _MessageBufferBanks[[index]].bound_invocation = _CurrentKernelInvocation;
    _MessageBufferBanks[[index]].enabled = TRUE;
end;
func WriteMessageBufferRegister(address: SystemRegisterAddress, value: Word)
begin
    let raw = UInt(address[15:0]);
    if !MessageBufferWritePreflight(address) then return; end;
    if IsMessageBufferConfigAddress(address) then
        if address == Zeros{24} + PTO_MSGB_CFGSEL_ADDRESS then
            if value[63:4] != Zeros{60} then
                SetFault(Fault_IllegalInstruction, ReadPC());
            else
                _MessageBufferConfigSelectors[[_CurrentModelCore]]
                    [[_CurrentMemoryAgent]][[CurrentMessageBufferThread()]] =
                    UInt(value[3:0]) as AccessControlRing;
            end;
            return;
        end;
        let selected = SelectedMessageBufferIndex();
        if address == Zeros{24} + PTO_MSGB_DOMAIN_ADDRESS then
            if _MessageBufferBanks[[selected]].enabled ||
               !MessageBufferBankQuiescent(selected) ||
               (_MessageBufferBanks[[selected]].domain_bound &&
                _MessageBufferBanks[[selected]].domain != value) then
                SetFault(Fault_IllegalInstruction, ReadPC());
            else
                _MessageBufferBanks[[selected]].domain = value;
                _MessageBufferBanks[[selected]].domain_bound = TRUE;
            end;
        else
            ConfigureMessageBuffer(selected, value);
        end;
        return;
    end;
    let index = CurrentMessageBufferIndex();
    if IsMessageBufferDataAddress(address) then
        _MessageBufferBanks[[index]].staging_words[[
            (raw - PTO_MSGBD1_ADDRESS) as MessageBufferWordIndex]] = value;
    elsif address == Zeros{24} + PTO_MSGBRXCLAIM_ADDRESS then
        ClaimMessageBufferSnapshot(index, value);
    elsif address == Zeros{24} + PTO_MSGBRXRELEASE_ADDRESS then
        ReleaseMessageBufferSnapshot(index, value);
    elsif address == Zeros{24} + PTO_MSGBACK_ADDRESS then
        AcknowledgeMessageBufferSnapshot(index, value);
    else
        SetFault(Fault_IllegalInstruction, ReadPC());
    end;
end;
