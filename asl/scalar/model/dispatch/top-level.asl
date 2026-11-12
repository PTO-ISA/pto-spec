// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL","surface":"scalar","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","PTO-SCALAR-MODEL-DISPATCH-AGU","PTO-SCALAR-MODEL-DISPATCH-ALU","PTO-SCALAR-MODEL-DISPATCH-AMO","PTO-SCALAR-MODEL-DISPATCH-BRU","PTO-SCALAR-MODEL-DISPATCH-FSU","PTO-SCALAR-MODEL-DISPATCH-SYS","PTO-SCALAR-SYNC-CORE"],"catalog_projection":{"catalog":"scalar-forms","family_constraints":[],"isa":"PTO Instruction Set Architecture","schema_version":2,"reviewed_encoding_overlaps":[{"broad_form_id":"addtpc_32_e5aa0f0abca3","narrow_form_id":"setret_32_72003dcf3b59","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"},{"broad_form_id":"c_movi_16_2c84faf1bc72","narrow_form_id":"c_setret_16_335651ef6c27","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"},{"broad_form_id":"hl_addtpc_48_2e8e692eea09","narrow_form_id":"hl_setret_48_302bb793a800","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"}]}}

// NDF-BEGIN: PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// A supported Scalar GM load, store, or atomic/RMW form MAY be wrapped in the
// standalone 64-bit Scalar Shareability Carrier. Its low halfword has fixed
// mask/match 0xf0ff/0x001f; bits[9:8] select Private=00, IntraCore=01,
// InterCore=10, with 11 reserved; bits[11:10] select inner length 16=00,
// 32=01, 48=10, with 11 reserved. Bits[63:16] contain the original 16/32/48-bit
// instruction zero-extended to 48 bits. Bits above the selected inner length
// MUST be zero. Canonical assembly appends `.private`, `.intra`, or `.inter`
// to the original mnemonic and retains its operands. Existing unqualified
// encodings remain unchanged and have Private shareability by default.
// The carrier MUST decode only when the inner encoding is an accepted covered
// Scalar load/store/atomic form; DMA and Prefetch are excluded. Reserved
// scope/length, nonzero padding, excluded or unmatched inner forms raise
// Fault_IllegalInstruction without memory, register, or queue effects. A valid
// carrier is one architectural instruction attempt with the original source
// snapshots, applicability and operand-fault ordering, memory effects and GM
// obligation; its scope applies to every constituent access. Success advances
// TPC by eight bytes. Fetch faults identify the outer TPC and recovery fetches
// the complete eight-byte envelope. Scope is transient to that request and
// cannot affect later Scalar, DMA, Tile, or IndexedGenerated work.
// NDF-END: PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001

// NDF-BEGIN: PTO-REQ-SCALAR-BODY-ENTRY-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// After a scalar form decodes successfully, scalar dispatch MUST enter any
// active body-inactive bundle, including a Tile block, before operation
// applicability or operand legality. An unmatched carrier MUST reject without
// entering the body. Once decoded, a later scalar fault preserves the
// body-active transition and the active block kind.
// NDF-END: PTO-REQ-SCALAR-BODY-ENTRY-001

func ExecuteScalarInstruction(instruction: bits(48),
                              length_bits: integer {16,32,48})
                              => ScalarExecutionStatus
begin
    return ExecuteScalarInstructionWithShareability(instruction,
        length_bits, MemoryShareability_Private, length_bits);
end;

func ExecuteScalarInstructionWithShareability(
    instruction: bits(48), length_bits: integer {16,32,48},
    shareability: MemoryShareability,
    retire_length_bits: integer {16,32,48,64}) => ScalarExecutionStatus
begin
    _CurrentMemoryShareability = shareability;
    _CurrentMemoryRequestClass = MemoryRequestClass_Scalar;
    let status = ExecuteScalarInstructionCore(instruction, length_bits,
        retire_length_bits);
    // Scope and class are instruction-local request parameters. Reset on every
    // status path so a following legacy, DMA, Tile, or indexed operation cannot
    // inherit this request's Scope.
    _CurrentMemoryShareability = MemoryShareability_Private;
    _CurrentMemoryRequestClass = MemoryRequestClass_Scalar;
    return status;
end;

func ExecuteScalarInstructionCore(instruction: bits(48),
                                  length_bits: integer {16,32,48},
                                  retire_length_bits: integer {16,32,48,64})
                                  => ScalarExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    let decoded = DecodeScalarForm(instruction, length_bits);
    if decoded == PTO_SCALAR_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_SCALAR_FORM_COUNT-1};
    let operation = ScalarOperationOfForm(form);
    if operation == ScalarOperation_SYNC_CORE &&
       !PreflightSyncCoreEnvelope(instruction, form, length_bits) then
        return ScalarExecution_Rejected;
    end;
    if BundleIsActive() && !BundleBodyIsActive() then
        EnterBundleBody();
    end;
    if !ScalarOperationApplicable(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarRegisterOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarImplicitSourceOperandsLegal(operation) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    var tracks_gm = FALSE;
    var request_class = GMRequest_Scalar;
    var gm_address = Zeros{PTO_XLEN};
    var gm_order = MemoryOrder_Relaxed;
    if ScalarFamilyOfForm(form) == ScalarSemantic_AGU then
        tracks_gm = TRUE;
        let action = ScalarAGUActionOfForm(form);
        let address_kind = ScalarAGUAddressKindOfForm(form);
        let update_mode = ScalarAGUUpdateModeOfForm(form);
        let base = ScalarDecodedAGUBase(instruction, form, action,
            address_kind);
        let offset = ScalarDecodedAGUOffset(instruction, form,
            address_kind);
        gm_address = if update_mode == AddressUpdate_PostIndex then base
                     else base + offset;
        if action == ScalarAGU_Prefetch then
            request_class = GMRequest_Prefetch;
            _CurrentMemoryRequestClass = MemoryRequestClass_Prefetch;
        end;
    elsif ScalarFamilyOfForm(form) == ScalarSemantic_AMO then
        tracks_gm = TRUE;
        request_class = GMRequest_Atomic;
        gm_order = ScalarDecodedMemoryOrder(instruction, form);
        if operation == ScalarOperation_DMA then
            _CurrentMemoryRequestClass = MemoryRequestClass_LegacyExcluded;
            gm_address = ReadDecodedScalarRegister(instruction, form,
                ScalarField_SrcL);
        else
            gm_address = ScalarDecodedAtomicAddress(instruction, form,
                ScalarField_SrcL);
        end;
    end;
    var obligation_slot: GMObligationIndex = 0;
    var obligation_identity : integer = 0;
    var obligation_invocation : integer = 0;
    let tracks_kernel_gm = tracks_gm &&
        _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
        _KernelInvocationActiveByCore[[_CurrentModelCore]] &&
        _CurrentKernelInvocation != 0;
    if tracks_kernel_gm then
        obligation_slot = RegisterKernelGMObligation(request_class,
            _CurrentEncodedInstruction, ReadPC(), _BundleOperation,
            _BundleArgument, _BundleTileBindings, _BundleScalarBindings,
            _BundleSharedBindings, _BundleDimensions,
            0 as TileIndex, Zeros{PTO_XLEN}, _Tiles[[0]],
            _BundleExecutionMask, gm_address, Zeros{PTO_XLEN}, gm_order,
            TRUE, FALSE, FALSE, FALSE, TRUE);
        IssueGMObligation(_CurrentModelCore, _CurrentMemoryAgent,
            obligation_slot);
        obligation_identity =
            _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
                [[obligation_slot]].identity;
        obligation_invocation =
            _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
                [[obligation_slot]].invocation;
    end;
    case ScalarFamilyOfForm(form) of
        when ScalarSemantic_AGU => ExecuteDecodedAGUForm(instruction, form);
        when ScalarSemantic_ALU => ExecuteDecodedALUForm(instruction, form);
        when ScalarSemantic_AMO => ExecuteDecodedAMOForm(instruction, form);
        when ScalarSemantic_BRU => ExecuteDecodedBRUForm(instruction, form);
        when ScalarSemantic_FSU => ExecuteDecodedFSUForm(instruction, form);
        when ScalarSemantic_SYS => ExecuteDecodedSYSForm(instruction, form);
        otherwise => unreachable;
    end;
    if tracks_kernel_gm then
        if _LastFault == Fault_None then
            CompleteGMObligationForIdentity(_CurrentModelCore,
                _CurrentMemoryAgent, obligation_slot,
                obligation_invocation, obligation_identity);
        else
            FaultGMObligation(_CurrentModelCore, _CurrentMemoryAgent,
                obligation_slot);
        end;
    end;
    if _LastFault != Fault_None then
        return ScalarExecution_Rejected;
    end;
    if _ScalarExecutionBlocked then
        return ScalarExecution_Blocked;
    end;
    if !ScalarHandlerWritesTPC(ScalarHandlerOfForm(form)) then
        WriteTPC(ReadTPC() + NaturalToWord(retire_length_bits DIV 8));
    end;
    return ScalarExecution_Executed;
end;
