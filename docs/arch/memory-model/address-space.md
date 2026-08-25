<!-- GENERATED FROM: asl/arch/memory-model/address-space.asl -->
# Address Space

**Normative ASL source:** `asl/arch/memory-model/address-space.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-address-space-purpose role=purpose-scope -->
## Purpose and scope

This unit provides the bounded byte-address access layer used by the executable memory model. It answers whether a `Word` address is inside the configured model and supplies byte reads and writes for valid addresses.

<!-- PTO-READER-BLOCK: arch-address-space-concepts role=concepts-state -->
## Address and storage concepts

- `IsModelAddress` compares `UInt(address)` with `PTO_MODEL_MEMORY_BYTES`.
- `ReadMemoryByte` returns the `Byte` stored in `_Memory` at the converted model index.
- `WriteMemoryByte` updates the same byte-addressed `_Memory` state.

<!-- PTO-READER-BLOCK: arch-address-space-rules role=rules-interactions -->
## Access sequence

Both accessors assert `IsModelAddress(address)` before converting the address to `ModelAddress`. A caller therefore establishes model-range validity before observing or changing a byte.

<!-- PTO-READER-BLOCK: arch-address-space-boundaries role=boundaries -->
## Model boundary

The configured `_Memory` array is executable verification storage. Its size bounds the model instance; this page does not claim that every PTO implementation exposes that byte count as its architectural address space.

<!-- PTO-READER-BLOCK: arch-address-space-example role=example-usage -->
## Non-normative access example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-address-space-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-STATE-DEFINEDNESS` supplies the state foundation used by this unit.
- Memory-event and instruction access owners build higher-level behavior on these byte helpers.
<!-- SUPPLEMENTARY-END -->

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
