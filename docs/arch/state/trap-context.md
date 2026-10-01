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

`asl/arch/state/trap-context.asl` owns six functions: `SavePortableTrapContext`, `SaveTrapContext`, `PortableTrapContextRecoverable`, `TrapContextRecoverable`, `RecoverPortableTrapContext` and `RecoverTrapContext`. They work on `_TrapContexts`, declared in `asl/arch/programming-model/execution-context.asl` as `array [[PTO_ACR_COUNT]] of TrapContext` with `PTO_ACR_COUNT` `16`, and on the context-register bank of the target ring.

`TrapContext` is declared in `asl/arch/data-types/trap-context.asl` and has `41` fields; saving bundle control state, memory replay state, the queues and the predicate registers is what makes a trap resumable inside a bundle, not only at a bundle boundary.

<!-- PTO-READER-BLOCK: arch-trap-context-concepts-state role=concepts-state -->
## What the two save paths record

`SavePortableTrapContext(target, source)` marks the target slot valid, records `source_acr` and assigns all `41` fields of `_TrapContexts[[target]]` from the live context, and writes no context register.

`SaveTrapContext(target, source)` assigns the same fields except `memory_replay_state` and then writes the target ring's context registers through `WriteContextRegister`. Register `0x0f00` receives `core_state` with bits `3:0` replaced by `AccessControlRingBits(source)`; register `0x0f40` receives a control word that marks bit `4` with `1` and carries the source ring, `_BundleActive`, `_BundleBodyActive`, `BundleKindCode(_BARG.block_type)`, `BundleTransferCode(_BARG.transfer_type)` and `_BARG.taken`.

The queue loop runs `index` from `0` to `PTO_TEMPORARY_QUEUE_DEPTH - 1` (`3`, since `PTO_TEMPORARY_QUEUE_DEPTH` is `4`), writing `_TQueue[[index]]` to `0x0f45 + index` and `_UQueue[[index]]` to `0x0f49 + index`; the last two writes store `Zeros{PTO_XLEN}` in `0x0f4d` and `0x0f4e`.

Design point: `SavePortableTrapContext` records `memory_replay_state`, but `RecoverPortableTrapContext` never reads it, while `RecoverTrapContext` assigns `_MemoryReplayState` from the slot even though `SaveTrapContext` never wrote it. A portable save followed by a portable recovery therefore leaves the live `_MemoryReplayState` at whatever the running context held.

<!-- PTO-READER-BLOCK: arch-trap-context-rules-interactions role=rules-interactions -->
## Recoverability and recovery

`PortableTrapContextRecoverable(target)` requires the slot to be `valid` and the saved `bpc[0]` and `tpc[0]` bits to be `'0'`. `TrapContextRecoverable(target)` reads context registers `0x0f40`, `0x0f00`, `0x0f41` and `0x0f43` and additionally requires `control[4]` to be `'1'`, `EBARGControlLegal(control)` and `control[3:0]` equal to `ecstate[3:0]`, then applies the same two bit tests to the values read from `0x0f41` and `0x0f43`.

Both recovery functions return `FALSE` before any assignment when their gate fails. On success the portable path writes `WriteTPC` and `WriteBPC`, restores `core_state`, the bundle state, the queues and the predicate registers from the slot, sets `_CurrentACR` to the saved `source_acr`, clears `valid` and returns `TRUE`.

The context-register path rebuilds `_BundleActive`, `_BundleBodyActive`, the four `_BARG` fields, `_ReturnAddress` and the queue entries from the control word, the saved registers and the `BundleKindOf` and `BundleTransferOf` decoders; it sets `_CurrentACR` from `ecstate[3:0]`, assigns `_MemoryReplayState` from the slot, clears `control[4]` in `0x0f40`, clears `valid` and returns `TRUE`.

Design point: a successful recovery consumes the slot: `RecoverTrapContext` clears `control[4]` and writes the control word back, and both paths clear `valid`, so a repeat call stops at `control[4] == '1'` or at `valid` without restoring anything.

<!-- PTO-READER-BLOCK: arch-trap-context-boundaries role=boundaries -->
## Architectural boundaries

`RecoverPortableTrapContext` tests `PortableTrapContextRecoverable` rather than `TrapContextRecoverable`, because a portable save writes no context register: a gate requiring `control[4]` does not describe a context that save created.

`TrapContextRecoverable` re-validates the reconstructed control word through `EBARGControlLegal` in `asl/block/model/schema/bundle-encoding.asl`: bits `63:15` zero, a kind code at most `2` or between `5` and `8`, a transfer code at most `6`, and `control[6]` `'0'` or `control[5]` `'1'`.

Within `asl/`, the portable helpers have no caller; `tests/asl/arch/state/trap-context/arch-fault-trap-portable-004.asl` exercises them. `SaveTrapContext` is called from `asl/arch/memory-model/fault-precision.asl` and `asl/block/model/lifecycle/lifetime.asl`; `RecoverTrapContext` from `asl/block/model/lifecycle/lifetime.asl` and `asl/scalar/model/sys/semantics.asl`.

<!-- PTO-READER-BLOCK: arch-trap-context-example-usage role=example-usage -->
## Non-normative recovery walkthrough

The portable test in `tests/asl/arch/state/trap-context/arch-fault-trap-portable-004.asl` saves with `SavePortableTrapContext(2, 15)` after `SetCurrentACR(15)`, clears the saved argument, frame and return values, and shows that `RecoverPortableTrapContext(2)` restores them and sets `_CurrentACR` back to `15`.

A fault uses the other save: `SetFaultWithCause` routes a fault taken while ring `15` is current through `TrapTargetForFault(15)` to ring `1`, and `SaveTrapContext(1, 15)` fills slot `1` and writes ring `1`'s context registers. Those registers are zero after a reset, so `TrapContextRecoverable(2)` is `FALSE` for a slot that only a portable save filled, while `RecoverPortableTrapContext(2)` returns `TRUE` for it.

<!-- PTO-READER-BLOCK: arch-trap-context-related-owners role=related-owners-navigation -->
## Related owners

- [Program counter](program-counter.md) owns `ReadTPC`, `ReadBPC`, `WriteTPC` and `WriteBPC`.
- [Access control](../system-registers/access-control.md) owns `AccessControlRingBits`, `CurrentACR` and `TrapTargetForFault`.
- [Context registers](../system-registers/context.md) owns the register helpers behind the `0x0f00` to `0x0f4e` writes.
- [Memory ordering](../memory-model/ordering.md) is the dependency named on line 1.
- [Fault precision](../memory-model/fault-precision.md) calls the context-register save on fault, service-request and interrupt entry.
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
