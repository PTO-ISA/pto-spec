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

This unit defines current Access Control Ring state, its four-bit representation, portable trap targets, permitted service requests, and trap-vector lookup.

<!-- PTO-READER-BLOCK: arch-access-control-concepts-state role=concepts-state -->
## ACR state and encoding

`CurrentACR` returns `_CurrentACR`. `AccessControlRingBits` maps ring values `0` through `15` to the corresponding four-bit binary value.

`SetCurrentACR` updates both `_CurrentACR` and `core_state[3:0]`, keeping the stored ring and its system-register representation synchronized.

<!-- PTO-READER-BLOCK: arch-access-control-rules-interactions role=rules-interactions -->
## Trap and service routing

`TrapTargetForFault` maps source ACR0 to target ACR0 and every nonzero source to target ACR1. `TrapTargetForInterrupt` uses the same rule.

From ACR1, service request types `0000` and `0010` are permitted. From ACR2 through ACR15, request types whose unsigned value is at most `2` are permitted; ACR0 permits none.

For a permitted request, type `0001` targets ACR1 and every other permitted type targets ACR0.

<!-- PTO-READER-BLOCK: arch-access-control-boundaries role=boundaries -->
## Trap-vector lookup boundary

`TrapVectorEntry` reads extended-system-register index `target * 4096 + 0x0f01`. A nonzero entry is the vector base; a zero entry falls back to the supplied fault address.

`ServiceRequestTarget` asserts that the request is permitted. Callers must establish permission before asking for a target.

<!-- PTO-READER-BLOCK: arch-access-control-example-usage role=example-usage -->
## Non-normative routing example

A type-`0001` request from ACR2 is permitted and targets ACR1. The same request from ACR1 is not permitted, so it must not be passed to `ServiceRequestTarget`.

<!-- PTO-READER-BLOCK: arch-access-control-related-owners role=related-owners-navigation -->
## Related owners

- [Execution context](../programming-model/execution-context.md) is the declared dependency.
- [Context registers](context.md) defines the ring-plus-low-index addressing rule.
- [Trap context](../state/trap-context.md) saves the source ACR and restores it after portable recovery.
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
