<!-- GENERATED FROM: asl/arch/memory-model/address-space.asl -->
# Address Space

**Normative ASL source:** `asl/arch/memory-model/address-space.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/address-space.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}
readonly func IsModelAddress(address: Word) => boolean
begin
    return UInt(address) < PTO_MODEL_MEMORY_BYTES;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    return _Memory[[index]];
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    _Memory[[index]] = value;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
