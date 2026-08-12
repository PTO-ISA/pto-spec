<!-- GENERATED FROM: asl/arch/state/trap-context.asl -->
# Trap Context

**Normative ASL source:** `asl/arch/state/trap-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-TRAP-CONTEXT}

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
    _TrapContexts[[target]].bundle_kind = _BundleKind;
    _TrapContexts[[target]].bundle_transfer = _BundleTransfer;
    _TrapContexts[[target]].bundle_condition = _BundleCondition;
    _TrapContexts[[target]].bundle_target = _BundleTarget;
    _TrapContexts[[target]].bundle_fallthrough = _BundleFallthrough;
    _TrapContexts[[target]].bundle_return_target = _BundleReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_body_address = _BundleBodyAddress;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].bundle_fixed_point_attributes =
        _BundleFixedPointAttributes;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].execution_mask = _ExecutionMask;
    _TrapContexts[[target]].predicates = _PredicateRegisters;
end;

impdef func SaveTrapContext(target: AccessControlRing,
                            source: AccessControlRing)
begin
    SavePortableTrapContext(target, source);
end;

func RecoverPortableTrapContext(target: AccessControlRing) => boolean
begin
    if !_TrapContexts[[target]].valid then
        return FALSE;
    end;
    WriteTPC(_TrapContexts[[target]].tpc);
    WriteBPC(_TrapContexts[[target]].bpc);
    _SystemRegisters.core_state = _TrapContexts[[target]].core_state;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = _TrapContexts[[target]].bundle_active;
    _BundleBodyActive = _TrapContexts[[target]].bundle_body_active;
    _BundleKind = _TrapContexts[[target]].bundle_kind;
    _BundleTransfer = _TrapContexts[[target]].bundle_transfer;
    _BundleCondition = _TrapContexts[[target]].bundle_condition;
    _BundleTarget = _TrapContexts[[target]].bundle_target;
    _BundleFallthrough = _TrapContexts[[target]].bundle_fallthrough;
    _BundleReturnTarget = _TrapContexts[[target]].bundle_return_target;
    _ReturnAddress = _TrapContexts[[target]].return_address;
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleBodyAddress = _TrapContexts[[target]].bundle_body_address;
    _BundleOperation = _TrapContexts[[target]].bundle_operation;
    _BundleDimensions = _TrapContexts[[target]].bundle_dimensions;
    _BundleScalarBindings = _TrapContexts[[target]].bundle_scalar_bindings;
    _BundleTileBindings = _TrapContexts[[target]].bundle_tile_bindings;
    _BundleSharedBindings = _TrapContexts[[target]].bundle_shared_bindings;
    _BundleControlAttributes =
        _TrapContexts[[target]].bundle_control_attributes;
    _BundleDataAttributes = _TrapContexts[[target]].bundle_data_attributes;
    _BundleFixedPointAttributes =
        _TrapContexts[[target]].bundle_fixed_point_attributes;
    _TQueue = _TrapContexts[[target]].t_queue;
    _UQueue = _TrapContexts[[target]].u_queue;
    _ExecutionMask = _TrapContexts[[target]].execution_mask;
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
