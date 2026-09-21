<!-- GENERATED FROM: asl/arch/state/trap-context.asl -->
# Trap Context

**Normative ASL source:** `asl/arch/state/trap-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-TRAP-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-trap-context-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit owns portable trap-context save, recoverability checking, and recovery, together with implementation-defined hooks whose default bodies call the portable path.

<!-- PTO-READER-BLOCK: arch-trap-context-concepts-state role=concepts-state -->
## Saved context

`SavePortableTrapContext` marks the target ACR context valid and snapshots the source ACR, TPC, BPC, `core_state`, bundle control and argument state, scalar/Tile/Shared bindings, local and Shared generations, templates, temporary queues, and predicate registers.

The snapshot is indexed by the target `AccessControlRing`; the saved `source_acr` identifies the ACR restored after recovery.

<!-- PTO-READER-BLOCK: arch-trap-context-rules-interactions role=rules-interactions -->
## Recoverability and recovery

`PortableTrapContextRecoverable` requires a valid saved context and zero low bits in both saved BPC and saved TPC. `RecoverPortableTrapContext` returns `FALSE` immediately when that condition is not met.

On success, recovery restores every portable field saved by the owner, sets `_CurrentACR` to the saved source ACR, clears the target context's valid bit, and returns `TRUE`.

`SaveTrapContext`, `TrapContextRecoverable`, and `RecoverTrapContext` are implementation-defined profile hooks. Their bodies in this owner delegate to the corresponding portable helpers.

<!-- PTO-READER-BLOCK: arch-trap-context-boundaries role=boundaries -->
## Architectural boundaries

Portable recovery deliberately checks `PortableTrapContextRecoverable` directly instead of dispatching through the active profile override. A profile may require additional context-register state, but the portable save helper does not create such target-specific state.

An unsuccessful portable recovery performs none of the restore assignments and does not invalidate the saved context.

<!-- PTO-READER-BLOCK: arch-trap-context-example-usage role=example-usage -->
## Non-normative recovery walkthrough

For an aligned valid snapshot saved from ACR3 into target ACR1, successful portable recovery restores the snapshot, selects ACR3 as current, and consumes the ACR1 snapshot by clearing its valid bit. If either saved low address bit is one, recovery instead returns `FALSE` before changing the live context.

<!-- PTO-READER-BLOCK: arch-trap-context-related-owners role=related-owners-navigation -->
## Related owners

- [Program counter](program-counter.md) owns the TPC and BPC accessors used during save and recovery.
- [Access control](../system-registers/access-control.md) owns ACR state and trap-target selection.
- [Memory ordering](../memory-model/ordering.md) is the declared dependency for this unit.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/trap-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-TRAP-CONTEXT","surface":"arch","classification":["state","trap-context"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ORDERING"]}
func SavePortableTrapContext(target: AccessControlRing,
                             source: AccessControlRing)
begin
    _TrapContexts[[target]].valid = TRUE;
    _TrapContexts[[target]].source_acr = source;
    _TrapContexts[[target]].tpc = ReadTPC();
    _TrapContexts[[target]].bpc = ReadBPC();
    _TrapContexts[[target]].core_state = _SystemRegisters.core_state;
    _TrapContexts[[target]].bundle_argument = _BundleArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].bundle_active = _BundleActive;
    _TrapContexts[[target]].bundle_body_active = _BundleBodyActive;
    _TrapContexts[[target]].bundle_commit_target_set =
        _BundleCommitTargetSet;
    _TrapContexts[[target]].bundle_condition_set =
        _BundleConditionSet;
    _TrapContexts[[target]].system_block_terminal_pending =
        _SystemBlockTerminalPending;
    _TrapContexts[[target]].barg = _BARG;
    _TrapContexts[[target]].bundle_sequential_pc = _BundleSequentialPC;
    _TrapContexts[[target]].frame_stack_return_target =
        _FrameStackReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_dimension_present =
        _BundleDimensionPresent;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_range_group = _BundleRangeGroup;
    _TrapContexts[[target]].bundle_zero_participation_seen =
        _BundleZeroParticipationSeen;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].bundle_data_attributes_present =
        _BundleDataAttributesPresent;
    _TrapContexts[[target]].bundle_hint = _BundleHint;
    _TrapContexts[[target]].bundle_fixed_point_attributes =
        _BundleFixedPointAttributes;
    _TrapContexts[[target]].local_generations = _LocalGenerations;
    _TrapContexts[[target]].shared_generations = _SharedGenerations;
    _TrapContexts[[target]].bundle_execution_domain_token =
        _BundleExecutionDomainToken;
    _TrapContexts[[target]].memory_copy_template = _MemoryCopyTemplate;
    _TrapContexts[[target]].frame_template = _FrameTemplate;
    _TrapContexts[[target]].memory_replay_state = _MemoryReplayState;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].t_queue_valid = _TQueueValid;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].u_queue_valid = _UQueueValid;
    _TrapContexts[[target]].predicates = _PredicateRegisters;
end;

func SaveTrapContext(target: AccessControlRing,
                                    source: AccessControlRing)
begin
    _TrapContexts[[target]].valid = TRUE;
    _TrapContexts[[target]].source_acr = source;
    _TrapContexts[[target]].tpc = ReadTPC();
    _TrapContexts[[target]].bpc = ReadBPC();
    _TrapContexts[[target]].core_state = _SystemRegisters.core_state;
    _TrapContexts[[target]].bundle_argument = _BundleArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].bundle_active = _BundleActive;
    _TrapContexts[[target]].bundle_body_active = _BundleBodyActive;
    _TrapContexts[[target]].bundle_commit_target_set = _BundleCommitTargetSet;
    _TrapContexts[[target]].bundle_condition_set = _BundleConditionSet;
    _TrapContexts[[target]].system_block_terminal_pending =
        _SystemBlockTerminalPending;
    _TrapContexts[[target]].barg = _BARG;
    _TrapContexts[[target]].bundle_sequential_pc = _BundleSequentialPC;
    _TrapContexts[[target]].frame_stack_return_target =
        _FrameStackReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_dimension_present =
        _BundleDimensionPresent;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_range_group = _BundleRangeGroup;
    _TrapContexts[[target]].bundle_zero_participation_seen =
        _BundleZeroParticipationSeen;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].bundle_data_attributes_present =
        _BundleDataAttributesPresent;
    _TrapContexts[[target]].bundle_hint = _BundleHint;
    _TrapContexts[[target]].bundle_fixed_point_attributes =
        _BundleFixedPointAttributes;
    _TrapContexts[[target]].local_generations = _LocalGenerations;
    _TrapContexts[[target]].shared_generations = _SharedGenerations;
    _TrapContexts[[target]].bundle_execution_domain_token =
        _BundleExecutionDomainToken;
    _TrapContexts[[target]].memory_copy_template = _MemoryCopyTemplate;
    _TrapContexts[[target]].frame_template = _FrameTemplate;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].t_queue_valid = _TQueueValid;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].u_queue_valid = _UQueueValid;
    _TrapContexts[[target]].predicates = _PredicateRegisters;

    var ecstate = _SystemRegisters.core_state;
    ecstate[3:0] = AccessControlRingBits(source);
    ecstate[4] = if _BundleBodyActive then '1' else '0';
    WriteContextRegister(target, 0x0f00, ecstate);

    var control: Word = Zeros{PTO_XLEN};
    control[3:0] = AccessControlRingBits(source);
    control[4] = '1';
    control[5] = if _BundleActive then '1' else '0';
    control[6] = if _BundleBodyActive then '1' else '0';
    control[10:7] = BundleKindCode(_BARG.block_type);
    control[13:11] = BundleTransferCode(_BARG.transfer_type);
    control[14] = if _BARG.taken then '1' else '0';
    WriteContextRegister(target, 0x0f40, control);
    WriteContextRegister(target, 0x0f41, ReadBPC());
    WriteContextRegister(target, 0x0f42, _BARG.bpcn);
    WriteContextRegister(target, 0x0f43, ReadTPC());
    WriteContextRegister(target, 0x0f44, _ReturnAddress);
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        WriteContextRegister(target, 0x0f45 + index,
            _TQueue[[index]]);
        WriteContextRegister(target, 0x0f49 + index,
            _UQueue[[index]]);
    end;
    WriteContextRegister(target, 0x0f4d, Zeros{PTO_XLEN});
    WriteContextRegister(target, 0x0f4e, Zeros{PTO_XLEN});
end;

readonly func PortableTrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    return _TrapContexts[[target]].valid &&
           _TrapContexts[[target]].bpc[0] == '0' &&
           _TrapContexts[[target]].tpc[0] == '0';
end;

func TrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    let control = ReadContextRegister(target, 0x0f40);
    let ecstate = ReadContextRegister(target, 0x0f00);
    let recovered_bpc = ReadContextRegister(target, 0x0f41);
    let recovered_tpc = ReadContextRegister(target, 0x0f43);
    return _TrapContexts[[target]].valid &&
           control[4] == '1' &&
           EBARGControlLegal(control) &&
           control[3:0] == ecstate[3:0] &&
           recovered_bpc[0] == '0' &&
           recovered_tpc[0] == '0';
end;

func RecoverPortableTrapContext(target: AccessControlRing) => boolean
begin
    // This helper is the architecture-portable recovery path.  It must not
    // dispatch through the active profile override, because that override may
    // require target-specific context-register state that SavePortableTrapContext
    // deliberately does not create.
    if !PortableTrapContextRecoverable(target) then
        return FALSE;
    end;
    WriteTPC(_TrapContexts[[target]].tpc);
    WriteBPC(_TrapContexts[[target]].bpc);
    _SystemRegisters.core_state = _TrapContexts[[target]].core_state;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = _TrapContexts[[target]].bundle_active;
    _BundleBodyActive = _TrapContexts[[target]].bundle_body_active;
    _BundleCommitTargetSet =
        _TrapContexts[[target]].bundle_commit_target_set;
    _BundleConditionSet =
        _TrapContexts[[target]].bundle_condition_set;
    _SystemBlockTerminalPending =
        _TrapContexts[[target]].system_block_terminal_pending;
    _BARG = _TrapContexts[[target]].barg;
    _BundleSequentialPC = _TrapContexts[[target]].bundle_sequential_pc;
    _FrameStackReturnTarget =
        _TrapContexts[[target]].frame_stack_return_target;
    _ReturnAddress = _TrapContexts[[target]].return_address;
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleOperation = _TrapContexts[[target]].bundle_operation;
    _BundleDimensions = _TrapContexts[[target]].bundle_dimensions;
    _BundleDimensionPresent =
        _TrapContexts[[target]].bundle_dimension_present;
    _BundleScalarBindings = _TrapContexts[[target]].bundle_scalar_bindings;
    _BundleTileBindings = _TrapContexts[[target]].bundle_tile_bindings;
    _BundleSharedBindings = _TrapContexts[[target]].bundle_shared_bindings;
    _BundleRangeGroup = _TrapContexts[[target]].bundle_range_group;
    _BundleZeroParticipationSeen =
        _TrapContexts[[target]].bundle_zero_participation_seen;
    _BundleControlAttributes =
        _TrapContexts[[target]].bundle_control_attributes;
    _BundleDataAttributes = _TrapContexts[[target]].bundle_data_attributes;
    _BundleDataAttributesPresent =
        _TrapContexts[[target]].bundle_data_attributes_present;
    _BundleHint = _TrapContexts[[target]].bundle_hint;
    _BundleFixedPointAttributes =
        _TrapContexts[[target]].bundle_fixed_point_attributes;
    _LocalGenerations = _TrapContexts[[target]].local_generations;
    _SharedGenerations = _TrapContexts[[target]].shared_generations;
    _BundleExecutionDomainToken =
        _TrapContexts[[target]].bundle_execution_domain_token;
    _MemoryCopyTemplate = _TrapContexts[[target]].memory_copy_template;
    _FrameTemplate = _TrapContexts[[target]].frame_template;
    _TQueue = _TrapContexts[[target]].t_queue;
    _TQueueValid = _TrapContexts[[target]].t_queue_valid;
    _UQueue = _TrapContexts[[target]].u_queue;
    _UQueueValid = _TrapContexts[[target]].u_queue_valid;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = _TrapContexts[[target]].source_acr;
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;

func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    if !TrapContextRecoverable(target) then
        return FALSE;
    end;
    var control = ReadContextRegister(target, 0x0f40);
    let ecstate = ReadContextRegister(target, 0x0f00);
    let recovered_bpc = ReadContextRegister(target, 0x0f41);
    let recovered_tpc = ReadContextRegister(target, 0x0f43);
    WriteTPC(recovered_tpc);
    WriteBPC(recovered_bpc);
    _SystemRegisters.core_state = ecstate;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = control[5] == '1';
    _BundleBodyActive = control[6] == '1';
    _BundleCommitTargetSet =
        _TrapContexts[[target]].bundle_commit_target_set;
    _BundleConditionSet =
        _TrapContexts[[target]].bundle_condition_set;
    _SystemBlockTerminalPending =
        _TrapContexts[[target]].system_block_terminal_pending;
    _BARG.block_type = BundleKindOf(control[10:7]);
    _BARG.transfer_type = BundleTransferOf(control[13:11]);
    _BARG.taken = control[14] == '1';
    _BARG.bpcn = ReadContextRegister(target, 0x0f42);
    _FrameStackReturnTarget =
        _TrapContexts[[target]].frame_stack_return_target;
    _ReturnAddress = ReadContextRegister(target, 0x0f44);
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleSequentialPC = _TrapContexts[[target]].bundle_sequential_pc;
    _BundleOperation = _TrapContexts[[target]].bundle_operation;
    _BundleDimensions = _TrapContexts[[target]].bundle_dimensions;
    _BundleDimensionPresent =
        _TrapContexts[[target]].bundle_dimension_present;
    _BundleScalarBindings = _TrapContexts[[target]].bundle_scalar_bindings;
    _BundleTileBindings = _TrapContexts[[target]].bundle_tile_bindings;
    _BundleSharedBindings = _TrapContexts[[target]].bundle_shared_bindings;
    _BundleRangeGroup = _TrapContexts[[target]].bundle_range_group;
    _BundleZeroParticipationSeen =
        _TrapContexts[[target]].bundle_zero_participation_seen;
    _BundleControlAttributes =
        _TrapContexts[[target]].bundle_control_attributes;
    _BundleDataAttributes = _TrapContexts[[target]].bundle_data_attributes;
    _BundleDataAttributesPresent =
        _TrapContexts[[target]].bundle_data_attributes_present;
    _BundleHint = _TrapContexts[[target]].bundle_hint;
    _BundleFixedPointAttributes =
        _TrapContexts[[target]].bundle_fixed_point_attributes;
    _LocalGenerations = _TrapContexts[[target]].local_generations;
    _SharedGenerations = _TrapContexts[[target]].shared_generations;
    _BundleExecutionDomainToken =
        _TrapContexts[[target]].bundle_execution_domain_token;
    _MemoryCopyTemplate = _TrapContexts[[target]].memory_copy_template;
    _FrameTemplate = _TrapContexts[[target]].frame_template;
    _MemoryReplayState = _TrapContexts[[target]].memory_replay_state;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = ReadContextRegister(target, 0x0f45 + index);
        _UQueue[[index]] = ReadContextRegister(target, 0x0f49 + index);
    end;
    _TQueueValid = _TrapContexts[[target]].t_queue_valid;
    _UQueueValid = _TrapContexts[[target]].u_queue_valid;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = UInt(ecstate[3:0]) as AccessControlRing;
    control[4] = '0';
    WriteContextRegister(target, 0x0f40, control);
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
