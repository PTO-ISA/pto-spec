<!-- GENERATED FROM: asl/arch/profile/trap-context-recovery.asl -->
# Trap Context Recovery

**Normative ASL source:** `asl/arch/profile/trap-context-recovery.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-trap-recovery-purpose role=purpose-scope -->
## Purpose and scope

This unit implements PTO v0 validation and restoration of a saved trap context. Recovery is a checked, one-use state transition: an invalid envelope returns false without restoring execution state.

<!-- PTO-READER-BLOCK: arch-trap-recovery-concepts role=concepts-state -->
## Recoverability checks

`TrapContextRecoverable` requires a valid saved context, control bit `4` set, legal `EBARG` control, matching low `4` ACR bits in control and `ECSTATE`, and even recovered `BPC` and `TPC` values. It reads context registers `0x0f40`, `0x0f00`, `0x0f41`, and `0x0f43`.

<!-- PTO-READER-BLOCK: arch-trap-recovery-rules role=rules-interactions -->
## Restoration sequence

`RecoverTrapContext` first repeats the recoverability check. On success it restores `TPC`, `BPC`, core state, bundle arguments and activity, bundle descriptors and bindings, generation state, templates, queues, predicates, return address, and the current ACR from the saved context and context registers.

<!-- PTO-READER-BLOCK: arch-trap-recovery-boundaries role=boundaries -->
## One-use and failure boundaries

Failed validation returns false before restoration. Successful recovery clears control bit `4`, writes the updated control register, invalidates the saved context, and returns true. A second recovery attempt therefore requires a newly saved valid context.

<!-- PTO-READER-BLOCK: arch-trap-recovery-example role=example-usage -->
## Non-normative recovery walkthrough

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-trap-recovery-related role=related-owners-navigation -->
## Related owners

- Reference profile defines the PTO v0 context-register encoding helpers used here.
- Fault precision and trap-context state own entry and saved-state creation that precede recovery.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/trap-context-recovery.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY","surface":"arch","classification":["profile","trap-context-recovery"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-PROFILE"]}
implementation func TrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    let control = PTOv0ReadContextRegister(target, 0x0f40);
    let ecstate = PTOv0ReadContextRegister(target, 0x0f00);
    let recovered_bpc = PTOv0ReadContextRegister(target, 0x0f41);
    let recovered_tpc = PTOv0ReadContextRegister(target, 0x0f43);
    return _TrapContexts[[target]].valid &&
           control[4] == '1' &&
           PTOv0EBARGControlLegal(control) &&
           control[3:0] == ecstate[3:0] &&
           recovered_bpc[0] == '0' &&
           recovered_tpc[0] == '0';
end;

implementation func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    if !TrapContextRecoverable(target) then
        return FALSE;
    end;
    var control = PTOv0ReadContextRegister(target, 0x0f40);
    let ecstate = PTOv0ReadContextRegister(target, 0x0f00);
    let recovered_bpc = PTOv0ReadContextRegister(target, 0x0f41);
    let recovered_tpc = PTOv0ReadContextRegister(target, 0x0f43);
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
    _BARG.block_type = PTOv0BundleKindOf(control[10:7]);
    _BARG.transfer_type = PTOv0BundleTransferOf(control[13:11]);
    _BARG.taken = control[14] == '1';
    _BARG.bpcn = PTOv0ReadContextRegister(target, 0x0f42);
    _FrameStackReturnTarget =
        _TrapContexts[[target]].frame_stack_return_target;
    _ReturnAddress = PTOv0ReadContextRegister(target, 0x0f44);
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
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = PTOv0ReadContextRegister(target, 0x0f45 + index);
        _UQueue[[index]] = PTOv0ReadContextRegister(target, 0x0f49 + index);
    end;
    _TQueueValid = _TrapContexts[[target]].t_queue_valid;
    _UQueueValid = _TrapContexts[[target]].u_queue_valid;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = UInt(ecstate[3:0]) as AccessControlRing;
    control[4] = '0';
    PTOv0WriteContextRegister(target, 0x0f40, control);
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
