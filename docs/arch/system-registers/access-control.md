<!-- GENERATED FROM: asl/arch/system-registers/access-control.asl -->
# Access Control

**Normative ASL source:** `asl/arch/system-registers/access-control.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/access-control.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL","surface":"arch","classification":["system-registers","access-control"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func CurrentACR() => AccessControlRing
begin
    return _CurrentACR;
end;

func SetCurrentACR(ring: AccessControlRing)
begin
    _CurrentACR = ring;
    _SystemRegisters.core_state[3:0] = Zeros{4} + ring;
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
