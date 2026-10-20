// PTO-INSTRUCTION: {"assembly":["sync.core"],"block":[],"catalog_indices":[466],"catalog_records":[{"asm":"sync.core","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0330a02b","width_bits":32}],"encoding_kind":"L32","fields":[],"length_bits":32,"mnemonic":"SYNC.CORE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SyncCore","semantic_summary":"Waits for all four PEs at the same Core-local phase boundary and completes their earlier GM obligations.","status":"accepted","form_id":"sync_core_32_0330a02b7c32"}],"classification":["sys"],"contract":{"block_composition":["The only canonical body is BSTART.SYS FALL, sync.core, BSTOP."],"canonical_assembly":["sync.core"],"defaults":["SYNC.CORE has no operands and includes PE0, PE1, PE2, and PE3."],"encoding_class":"standalone-encoded","examples":["sync.core"],"exceptions":["The complete SYS envelope is validated before collective arrival. Wrong block composition raises Fault_BundleControl; a nonmatching instruction encoding raises Fault_IllegalInstruction."],"field_contracts":{},"field_zero_meanings":{},"legality":["Only the exact 32-bit word 0x0330a02b decodes as SYNC.CORE. The active bundle must be a Fallthrough SYS block with exactly one SYNC.CORE body operation and a required BSTOP."],"memory_effects":["Completion orders earlier qualifying GM operations before later qualifying GM operations for every participant pair, after those earlier operations reach their existing completion and visibility point."],"operands":[],"ordering":["A PE parks at SYNC.CORE until all four PEs have irrevocably arrived at the same static instruction in the same dynamic order and invocation and every earlier GM obligation has completed. Arrival cannot be irrevocable while older work may still fault or require recovery."],"standalone_opcode":true,"state_effects":["A blocked PE does not advance its PC. On completion, the barrier generation is retained until each parked PE consumes its release once, and each participant's current local reservation is invalidated."]},"depends_on":["PTO-ARCH-STATE-CORE-SYNCHRONIZATION","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-BLOCK-MODEL-DISPATCH-DECODE","PTO-TILE-MODEL-MEMORY-GM-OBLIGATION-PROGRESS","PTO-TILE-MODEL-MEMORY-LOAD-STORE"],"id":"PTO-SCALAR-SYNC-CORE","mnemonic":"SYNC.CORE","summary":"Waits for all four PEs at the same Core-local phase boundary and completes their earlier GM obligations.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SYNC-CORE-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// SYNC.CORE MUST implement the exact operand-free L32 encoding, legal SYS
// envelope, four-participant Core-local phase rendezvous, irrevocable arrival,
// prior GM obligation completion, cross-agent memory ordering, retained
// once-only release, reservation invalidation, and fault/recovery boundaries
// defined by this owner and its referenced state and memory contracts.
// NDF-END: PTO-SYNC-CORE-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SYNC_CORE() => ScalarOperation
begin
    return ScalarOperation_SYNC_CORE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SYNC_CORE() => ScalarSemanticHandler
begin
    return ScalarHandler_SyncCore;
end;

pure func InstructionContractRequiresSystemBlock_SYNC_CORE() => boolean
begin
    return TRUE;
end;

func ExecuteSyncCore()
begin
    if _CurrentMemoryOrigin == MemoryEventOrigin_Handler then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    if !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    if !VerificationGMProgressIsDeferred() then
        ProgressKernelGMObligationsForCore(_CurrentModelCore,
            _CurrentKernelInvocation);
    end;
    if _LastFault != Fault_None then return; end;
    SyncCore();
end;

pure func InstructionContractParticipantCount_SYNC_CORE() => integer {4}
begin
    return 4;
end;

pure func InstructionContractExactMatch_SYNC_CORE() => bits(32)
begin
    return '00000011001100001010000000101011';
end;

pure func InstructionContractExactMask_SYNC_CORE() => bits(32)
begin
    return Ones{32};
end;
// DOC-END: operation

func PreflightSyncCoreEnvelope(instruction: bits(48),
                               form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                               length_bits: integer {16,32,48})
                               => boolean
begin
    if _CurrentMemoryOrigin == MemoryEventOrigin_Handler then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 || length_bits != 32 ||
       !_BundleActive || _BARG.block_type != BundleKind_System ||
       _BARG.transfer_type != BundleTransfer_Fallthrough ||
       _BARG.taken || _BARG.bpcn != Zeros{PTO_XLEN} ||
       ReadTPC() != ReadBPC() + NaturalToWord(4) ||
       _BundleSequentialPC != ReadTPC() then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if instruction[31:0] != InstructionContractExactMatch_SYNC_CORE() then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    let start_pc = ReadBPC();
    let start_probe = ProbeInstructionAccess(start_pc, 4);
    if !start_probe.permitted then
        SetFault(Fault_InstructionPage, start_pc);
        return FALSE;
    end;
    let start_instruction = FetchPTOInstruction(start_probe, 32);
    let start_form = DecodeCommandForm(start_instruction, 32);
    if start_form == PTO_COMMAND_FORM_COUNT ||
       CommandHandlerOfForm(start_form as
           integer {0..PTO_COMMAND_FORM_COUNT-1}) !=
           CommandHandler_ExecuteBundleStart ||
       CommandBundleKindOfForm(start_form as
           integer {0..PTO_COMMAND_FORM_COUNT-1}) != BundleKind_System ||
       CommandBundleTransferOfForm(start_form as
           integer {0..PTO_COMMAND_FORM_COUNT-1}) !=
           BundleTransfer_Fallthrough ||
       !CommandFormOperandsLegal(start_instruction,
           start_form as integer {0..PTO_COMMAND_FORM_COUNT-1}) then
        SetFault(Fault_BundleControl, start_pc);
        return FALSE;
    end;

    let stop_pc = ReadTPC() + NaturalToWord(4);
    let stop_probe = ProbeInstructionAccess(stop_pc, 4);
    if !stop_probe.permitted then
        SetFault(Fault_InstructionPage, stop_pc);
        return FALSE;
    end;
    let stop_instruction = FetchPTOInstruction(stop_probe, 32);
    let stop_form = DecodeCommandForm(stop_instruction, 32);
    if stop_form == PTO_COMMAND_FORM_COUNT ||
       CommandHandlerOfForm(stop_form as
           integer {0..PTO_COMMAND_FORM_COUNT-1}) !=
           CommandHandler_ExecuteBundleStop ||
       stop_instruction[31:0] != '00000000000000000000000000000001' ||
       !CommandFormOperandsLegal(stop_instruction,
           stop_form as integer {0..PTO_COMMAND_FORM_COUNT-1}) then
        SetFault(Fault_BundleControl, stop_pc);
        return FALSE;
    end;

    let continuation = stop_pc + NaturalToWord(4);
    if continuation[0] == '1' ||
       BARGCommitPC(continuation)[0] == '1' then
        SetFault(Fault_InstructionPC, continuation);
        return FALSE;
    end;
    let continuation_probe = ProbeInstructionAccess(continuation, 2);
    if !continuation_probe.permitted then
        SetFault(Fault_InstructionPage, continuation);
        return FALSE;
    end;
    return TRUE;
end;
