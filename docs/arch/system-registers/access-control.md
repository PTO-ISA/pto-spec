<!-- GENERATED FROM: asl/arch/system-registers/access-control.asl -->
# Access Control

**Normative ASL source:** `asl/arch/system-registers/access-control.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-access-control-purpose-scope role=purpose-scope -->
## Purpose and scope

`asl/arch/system-registers/access-control.asl` owns the current Access Control Ring and the ring arithmetic around it: `CurrentACR`, `AccessControlRingBits`, `SetCurrentACR`, `TrapTargetForFault`, `TrapTargetForInterrupt`, `ServiceRequestPermitted`, `ServiceRequestTarget` and `TrapVectorEntry`. `AccessControlRing` is `integer {0..15}` and `PTO_ACR_COUNT` in `asl/arch/programming-model/core-pe-topology.asl` is `16`.

The file declares no `NDF-BEGIN` clause; its normative content is the eight function bodies plus the state they read, `_CurrentACR` and `_ExtendedSystemRegisters`, declared in `asl/arch/programming-model/execution-context.asl`.

<!-- PTO-READER-BLOCK: arch-access-control-concepts-state role=concepts-state -->
## Ring state and its encoding

`CurrentACR()` returns `_CurrentACR`. `SetCurrentACR(ring)` writes `_CurrentACR` and also writes `AccessControlRingBits(ring)` into `_SystemRegisters.core_state[3:0]`, so the ring appears in its own variable and in the low nibble of the `CORE_STATE` word. `AccessControlRingBits` maps `0` to `0000` through `15` to `1111`, making the nibble the ring number itself.

The reverse direction lives in the system-register write path: `WriteSystemRegister` in `asl/scalar/model/sys/semantics.asl` stores a software `CORE_STATE` write and then sets `_CurrentACR` from `value[3:0]`, and `ResetProfileState` in `asl/arch/system-registers/addressing.asl` ends with `_CurrentACR = 0`.

Design point: the ring needs no encoding table lookup and no separate valid flag, because `AccessControlRing` is already constrained to `0..15` and `AccessControlRingBits` is total over that range. A value read from `_CurrentACR` can always be written into the nibble, and a saved nibble can always be converted back with `UInt(ecstate[3:0]) as AccessControlRing`.

<!-- PTO-READER-BLOCK: arch-access-control-rules-interactions role=rules-interactions -->
## Trap and service routing

`TrapTargetForFault(source)` returns `0` for source `0` and `1` for any other source, and `TrapTargetForInterrupt(source)` returns exactly `TrapTargetForFault(source)`: a trap taken while ring `0` is current stays in ring `0`, and a trap taken in rings `1` to `15` is delivered to ring `1`.

`ServiceRequestPermitted(source, request_type)` accepts, from source `1`, only `0000` and `0010`; from source `2` and above it accepts any `request_type` whose unsigned value is at most `2`; from source `0` it returns `FALSE`. `ServiceRequestTarget(source, request_type)` asserts that permission and returns `1` for `0001` and `0` otherwise.

Design point: two-level routing means one slot serves many rings. `SetFaultWithCause` calls `SaveTrapContext(ring, source_ring)` with the routed target ring, and `_TrapContexts` holds one slot per ring, so faults in rings `7` and `2` both save into slot `1` and the later save replaces the earlier; the saved `source_acr` field keeps each origin recoverable.

<!-- PTO-READER-BLOCK: arch-access-control-boundaries role=boundaries -->
## Trap-vector lookup boundary

`TrapVectorEntry(target, fault_address)` computes the index `(target * 4096) + 0x0f01` as a `SystemRegisterFileIndex` and returns the word stored there unless it is `Zeros{PTO_XLEN}`, in which case it returns `fault_address`. The highest ring's index, `15 * 4096 + 0x0f01` = `65281`, is inside the declared range `0` to `65535`.

`ResetProfileState` clears low indices `0x0f00` through `0x0fb7` for all `16` rings, so the vector base at `0x0f01` is zero for every ring in the reset state. The one exception is low index `0x0f07`, preset to `3` so external and timer interrupt collection starts enabled.

Design point: a zero vector base means "use the fault address" instead of "invalid entry", so the reset state is a working identity vector: a fault re-enters the model at the address it was reported for until software stores a nonzero base in the target ring's `0x0f01` register, and a stored zero cannot vector a ring to address `0`.

<!-- PTO-READER-BLOCK: arch-access-control-example-usage role=example-usage -->
## Non-normative routing example

`TrapTargetForFault(0)` is `0` and `TrapTargetForFault(3)` is `1`, so a fault taken while ring `3` is current goes to ring `1`. `ServiceRequestPermitted(2, '0001')` is `TRUE` because the unsigned value of `0001` is at most `2`, and `ServiceRequestTarget(2, '0001')` returns `1`; from ring `1` the same type is not permitted, since the set there is `0000` and `0010` only, so `ServiceRequestTarget(1, '0001')` would fail its assertion.

`RaiseServiceRequest` in `asl/arch/memory-model/fault-precision.asl` runs the whole sequence: it computes a resume address, saves context into the ring chosen by `ServiceRequestTarget`, rewrites the saved TPC and context register `0x0f43`, records trap number `6`, selects the target with `SetCurrentACR` and installs `TrapVectorEntry(target_ring, source_tpc)`.

Within `asl/arch/memory-model/fault-precision.asl` alone, `CurrentACR` appears `4` times, `SetCurrentACR` and `TrapVectorEntry` `3` times each, and `TrapTargetForFault`, `TrapTargetForInterrupt`, `ServiceRequestPermitted` and `ServiceRequestTarget` once each.

<!-- PTO-READER-BLOCK: arch-access-control-related-owners role=related-owners-navigation -->
## Related owners

- [Execution context](../programming-model/execution-context.md) is the line-1 dependency and declares `_CurrentACR` and `_ExtendedSystemRegisters`.
- [Context registers](context.md) owns `ContextRegisterIndex` and the ring-plus-low-index addressing rule.
- [Trap context](../state/trap-context.md) saves `source_acr`, writes the saved ring nibble and restores `_CurrentACR`.
- [Fault precision](../memory-model/fault-precision.md) calls the trap-target and service-request helpers.
- [System-register addressing](addressing.md) owns `core_state`, which carries the ring nibble.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/access-control.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL","surface":"arch","classification":["system-registers","access-control"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func CurrentACR() => AccessControlRing
begin
    return _CurrentACR;
end;

pure func AccessControlRingBits(ring: AccessControlRing) => bits(4)
begin
    case ring of
        when 0 => return '0000';
        when 1 => return '0001';
        when 2 => return '0010';
        when 3 => return '0011';
        when 4 => return '0100';
        when 5 => return '0101';
        when 6 => return '0110';
        when 7 => return '0111';
        when 8 => return '1000';
        when 9 => return '1001';
        when 10 => return '1010';
        when 11 => return '1011';
        when 12 => return '1100';
        when 13 => return '1101';
        when 14 => return '1110';
        when 15 => return '1111';
    end;
end;

func SetCurrentACR(ring: AccessControlRing)
begin
    _CurrentACR = ring;
    _SystemRegisters.core_state[3:0] = AccessControlRingBits(ring);
end;

pure func TrapTargetForFault(source: AccessControlRing) => AccessControlRing
begin
    if source == 0 then return 0; else return 1; end;
end;

pure func TrapTargetForInterrupt(source: AccessControlRing) => AccessControlRing
begin
    return TrapTargetForFault(source);
end;

pure func ServiceRequestPermitted(source: AccessControlRing,
                                  request_type: bits(4)) => boolean
begin
    if source == 1 then
        return request_type == '0000' || request_type == '0010';
    elsif source >= 2 then
        return UInt(request_type) <= 2;
    else
        return FALSE;
    end;
end;

pure func ServiceRequestTarget(source: AccessControlRing,
                               request_type: bits(4)) => AccessControlRing
begin
    assert ServiceRequestPermitted(source, request_type);
    if request_type == '0001' then return 1; else return 0; end;
end;

readonly func TrapVectorEntry(target: AccessControlRing,
                              fault_address: Word) => Word
begin
    let index = ((target * 4096) + 0x0f01) as SystemRegisterFileIndex;
    let vector_base = _ExtendedSystemRegisters[[index]];
    if vector_base == Zeros{PTO_XLEN} then return fault_address;
    else return vector_base;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
