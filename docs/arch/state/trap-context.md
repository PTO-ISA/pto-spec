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
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].t_queue_valid = _TQueueValid;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].u_queue_valid = _UQueueValid;
    _TrapContexts[[target]].predicates = _PredicateRegisters;
end;

impdef func SaveTrapContext(target: AccessControlRing,
                            source: AccessControlRing)
begin
    SavePortableTrapContext(target, source);
end;

readonly func PortableTrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    return _TrapContexts[[target]].valid &&
           _TrapContexts[[target]].bpc[0] == '0' &&
           _TrapContexts[[target]].tpc[0] == '0';
end;

impdef func TrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    return PortableTrapContextRecoverable(target);
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

impdef func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    return RecoverPortableTrapContext(target);
end;
```
<!-- GENERATED-ASL-END: unit -->
