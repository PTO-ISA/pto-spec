<!-- GENERATED FROM: asl/arch/memory-model/instruction-fetch.asl -->
# Instruction Fetch

**Normative ASL source:** `asl/arch/memory-model/instruction-fetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-instruction-fetch-purpose role=purpose-scope -->
## Purpose and scope

This unit isolates functional instruction access from instruction execution. It defines translation and permission hooks, a probe snapshot, and little-endian assembly of one already-approved 16/32/48/64-bit instruction.

<!-- PTO-READER-BLOCK: arch-instruction-fetch-concepts role=concepts-state -->
## Probe model

`TranslateInstructionAddress` maps the architectural byte address to the physical profile address. `InstructionAccessPermitted` decides whether the complete requested size is readable. `ProbeInstructionAccess` captures both results so later fetch uses the approved translated base.

<!-- PTO-READER-BLOCK: arch-instruction-fetch-rules role=rules-interactions -->
## Fetch ordering

The functional-step owner probes two bytes first to obtain the low halfword and length, then probes the complete selected range before reading remaining bytes. `FetchPTOInstruction` places byte zero in bits `[7:0]` and zero-fills all bits above the selected instruction length.

<!-- PTO-READER-BLOCK: arch-instruction-fetch-boundaries role=boundaries -->
## Access boundaries

Denied, unmapped, overflowing, or truncated ranges become `Fault_InstructionPage` at the original TPC before decode. The fetch helper requires a permitted probe and does not itself define caches, MMU structures, devices, or executable-file permissions.

<!-- PTO-READER-BLOCK: arch-instruction-fetch-example role=example-usage -->
## Non-normative byte example

If approved bytes at the translated address are `95 04 e0 05`, a 32-bit fetch produces raw value `0x05e00495`. This illustrates byte placement only; the scalar decoder owns the meaning of that value.

<!-- PTO-READER-BLOCK: arch-instruction-fetch-related role=related-owners-navigation -->
## Related owners

- [Functional step](../dispatch/functional-step.md) orders prefix and complete probes.
- [Address space](address-space.md) owns physical byte storage in the reference profile.
- [Fault precision](fault-precision.md) owns precise fault publication.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/instruction-fetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","surface":"arch","classification":["memory-model","instruction-fetch"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-FETCH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A functional step MUST reject an odd TPC with Fault_InstructionPC before
// memory access. It MUST preflight the first two bytes, determine a 16, 32, 48,
// or 64-bit length from the low halfword, then preflight the complete selected
// range before reading any remaining byte. Fetch is little-endian. A denied,
// unmapped, overflowing, or truncated range MUST raise Fault_InstructionPage
// at the original TPC without a decoded attempt or partial instruction effect.
// NDF-END: PTO-REQ-FUNCTIONAL-FETCH-001

readonly impdef func TranslateInstructionAddress(
    address: Word) => Word
begin
    return address;
end;

readonly impdef func InstructionAccessPermitted(
    address: Word,
    size_bytes: integer {2,4,6,8}) => boolean
begin
    return FALSE;
end;

readonly func ProbeInstructionAccess(
    address: Word,
    size_bytes: integer {2,4,6,8}) => PTOInstructionAccessProbe
begin
    let translated_address = TranslateInstructionAddress(address);
    return PTOInstructionAccessProbe {
        permitted = InstructionAccessPermitted(
            translated_address, size_bytes),
        translated_address = translated_address
    };
end;

readonly func FetchPTOInstruction(
    probe: PTOInstructionAccessProbe,
    length_bits: integer {16,32,48,64}) => bits(64)
begin
    assert probe.permitted;
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    var instruction: bits(64) = Zeros{64};
    for byte_index = 0 to 7 do
        if byte_index < size_bytes then
            let byte_address = probe.translated_address +
                NaturalToWord(byte_index);
            instruction[(byte_index * 8) +: 8] =
                ReadPhysicalMemoryByte(byte_address);
        end;
    end;
    return instruction;
end;
```
<!-- GENERATED-ASL-END: unit -->
