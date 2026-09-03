<!-- GENERATED FROM: asl/arch/memory-model/instruction-fetch.asl -->
# Instruction Fetch

**Normative ASL source:** `asl/arch/memory-model/instruction-fetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-purpose role=purpose-scope -->
## Purpose and scope

This page is the stable reader entry point for one architecture `ASL` owner. The generated unit below remains the complete source of architectural meaning.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-concepts role=concepts-state -->
## Concepts and visible state

Use the generated declarations and embedded requirement regions to identify the concepts and state referenced by this owner. This guide does not add state or rename an existing concept.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-rules role=rules-interactions -->
## Rules and interactions

Follow the dependency metadata and calls in the generated unit to reach interacting owners. Generated documentation and evidence remain projections of those sources.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-boundaries role=boundaries -->
## Architectural boundaries

Treat every fixed bound, profile hook, fault, and unspecified case exactly as written in the generated owner. No implementation behavior is promoted by this reader guide.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-example role=example-usage -->
## Non-normative reading example

Start with the generated unit identity, locate the relevant requirement region, and then follow referenced owners before consulting executable evidence.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-related role=related-owners-navigation -->
## Related owners

The dependency list and linked source path below are the navigation index for related architecture owners. Current meaning always returns to the named `ASL` source.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/instruction-fetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","surface":"arch","classification":["memory-model","instruction-fetch"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}

// NDF-BEGIN: PTO-REQ-INSTRUCTION-FETCH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A next-instruction action MUST reject an odd TPC with Fault_InstructionPC
// before memory access. It MUST preflight the first two bytes, determine a 16,
// 32, 48, or 64-bit length from the low halfword, then preflight the complete
// selected range before reading any remaining byte. Fetch is little-endian. A
// denied, unmapped, overflowing, or truncated range MUST raise
// Fault_InstructionPage at the original TPC without a decoded attempt or
// partial instruction effect.
// NDF-END: PTO-REQ-INSTRUCTION-FETCH-001

type PTOInstructionFetchProbe of record {
    permitted: boolean,
    physical_address: Word
};

pure func DeterminePTOInstructionLength(
    first_halfword: bits(16)) => integer {16,32,48,64}
begin
    if first_halfword[3:1] == '111' then
        if first_halfword[0] == '0' then return 48;
        else return 64;
        end;
    elsif first_halfword[0] == '0' then
        return 16;
    else
        return 32;
    end;
end;

readonly impdef func TranslateInstructionAddress(address: Word) => Word
begin
    return address;
end;

readonly impdef func InstructionAccessPermitted(
    physical_address: Word,
    size_bytes: integer {2,4,6,8}) => boolean
begin
    return FALSE;
end;

readonly func ProbeInstructionAccess(
    address: Word,
    size_bytes: integer {2,4,6,8}) => PTOInstructionFetchProbe
begin
    let physical_address = TranslateInstructionAddress(address);
    return PTOInstructionFetchProbe {
        permitted = InstructionAccessPermitted(
            physical_address,
            size_bytes),
        physical_address = physical_address
    };
end;

readonly func FetchPTOInstruction(
    probe: PTOInstructionFetchProbe,
    length_bits: integer {16,32,48,64}) => bits(64)
begin
    assert probe.permitted;
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    var instruction: bits(64) = Zeros{64};
    for byte_index = 0 to 7 do
        if byte_index < size_bytes then
            let byte_address = probe.physical_address +
                NaturalToWord(byte_index);
            instruction[(byte_index * 8) +: 8] =
                ReadPhysicalMemoryByte(byte_address);
        end;
    end;
    return instruction;
end;
```
<!-- GENERATED-ASL-END: unit -->
