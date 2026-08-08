<!-- GENERATED FROM: asl/arch/system-registers/context.asl -->
# Context

**Normative ASL source:** `asl/arch/system-registers/context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-CONTEXT}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-CONTEXT","surface":"arch","classification":["system-registers","context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL"]}
pure func ContextRegisterIndex(ring: AccessControlRing,
                               low_index: integer {0..4095})
    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

pure func PTOv0ContextRegisterIndex(ring: AccessControlRing,
                                    low_index: integer {0..4095})
                                    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

readonly func PTOv0ReadContextRegister(ring: AccessControlRing,
                                       low_index: integer {0..4095}) => Word
begin
    return _ExtendedSystemRegisters[[
        PTOv0ContextRegisterIndex(ring, low_index)]];
end;

func PTOv0WriteContextRegister(ring: AccessControlRing,
                               low_index: integer {0..4095}, value: Word)
begin
    _ExtendedSystemRegisters[[PTOv0ContextRegisterIndex(ring, low_index)]] =
        value;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
