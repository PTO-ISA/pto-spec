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
    if !TrapContextRecoverable(target) then
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
