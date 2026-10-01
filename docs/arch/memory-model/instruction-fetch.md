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

This unit owns the instruction side of the memory model: turning a `TPC` value into either a length-qualified instruction word or a reason to stop. It defines `PTOInstructionFetchProbe`, `DeterminePTOInstructionLength`, `TranslateInstructionAddress`, `InstructionAccessPermitted`, `ProbeInstructionAccess` and `FetchPTOInstruction`.

The contract is `PTO-REQ-INSTRUCTION-FETCH-001`, and the line-1 metadata declares `PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE` as the dependency supplying `ReadPhysicalMemoryByte` and `PTO_MODEL_MEMORY_BYTES`. `ExecuteNextPTOInstruction` in `asl/arch/dispatch/top-level.asl` calls these helpers and owns the `SetFault` calls.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-concepts role=concepts-state -->
## Probe record, length encoding and the byte read

- `PTOInstructionFetchProbe` has exactly two fields, `permitted` as `boolean` and `physical_address` as `Word`; a later read uses the stored address, not a second translation.
- `DeterminePTOInstructionLength(first_halfword)` maps `first_halfword[3:1]` `'111'` with bit `0` `'0'` to `48` and with bit `0` `'1'` to `64`, other halfwords to `16` when bit `0` is `'0'` and to `32` otherwise.
- `TranslateInstructionAddress(address)` returns `address` unchanged, so instruction fetch is identity-mapped here.
- `InstructionAccessPermitted(physical_address, size_bytes)` returns false only when `UInt(physical_address) + size_bytes` exceeds `PTO_MODEL_MEMORY_BYTES`; `ProbeInstructionAccess(address, size_bytes)` puts that predicate and the translated address into the probe.
- `FetchPTOInstruction(probe, length_bits)` asserts `probe.permitted`, computes `size_bytes` as `length_bits DIV 8`, and writes bytes from `Zeros{64}` while `byte_index < size_bytes`.
- `ReadPhysicalMemoryByte` uses `UInt(address) < PTO_MODEL_MEMORY_BYTES`, the same boundary as the permitted set here.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-rules role=rules-interactions -->
## What the length encoding selects

The accepted lengths are `16`, `32`, `48` and `64`: bit `0` chooses between `16` and `32`, and `first_halfword[3:1] == '111'` chooses between `48` and `64`.

`FetchPTOInstruction` places byte `byte_index` at bit position `byte_index * 8`, so the lowest-addressed byte occupies bits `7:0`, bytes at or above `size_bytes` stay zero, and the read count is `2`, `4`, `6` or `8`.

Design point: the fetch loop allocates a full `bits(64)` result but writes only the first `size_bytes` bytes from `Zeros{64}`, so a `16`-bit instruction returns a word with zero upper 48 bits and a decoder sees a defined value, not leftovers; the length travels separately because the word alone does not carry it.

Design point: `ProbeInstructionAccess` stores the address it checked and `FetchPTOInstruction` reads that stored address; the two are equal here because `TranslateInstructionAddress` is the identity, but a shared probe would send the read elsewhere, so `ExecuteNextPTOInstruction` compares `complete_probe.physical_address` with `prefix_probe.physical_address` first.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-boundaries role=boundaries -->
## Boundaries

The clause lists denied, unmapped, overflowing and truncated ranges as reasons for `Fault_InstructionPage`; the executable predicate checks one condition, `UInt(physical_address) + size_bytes > PTO_MODEL_MEMORY_BYTES`, so `permitted` is false exactly when the range's last byte lies outside the model array, and the clause's denied range cannot be produced here.

The clause also says the next-instruction action rejects an odd `TPC` before memory access and preflights the selected range before reading any remaining byte; this file implements the second half only. The odd-`TPC` test is `instruction_pc[0] == '1'` in `ExecuteNextPTOInstruction`, which also performs the `SetFault(Fault_InstructionPage, instruction_pc)` calls at the original `TPC`; no ASL unit outside `asl/arch/dispatch/top-level.asl` calls these helpers.

`TranslateInstructionAddress` has no caller other than `ProbeInstructionAccess` in the same file, and the catalogue entry for the `IOTTBR_ACR1`, `IOTCR_ACR1` and `IOMAIR_ACR1` registers in `PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS` calls them storage-only, so there is no architectural translation to configure; `InstructionAccessPermitted` is likewise called only from `ProbeInstructionAccess`.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-example role=example-usage -->
## Non-normative fetch example

With the default `PTO_MODEL_MEMORY_BYTES` of `4096`, a `TPC` of `0x40` probes bytes `0x40` and `0x41`, both inside the array, so `permitted` is true; if they decode to a `32`-bit instruction, `size_bytes` is `4` and the complete probe ends at `0x43`.

A `TPC` of `0xfff` probes bytes `0xfff` and `0x1000`, a sum of `4097`, so the probe is not permitted: the caller raises `Fault_InstructionPage` at `0xfff` without reading a byte. `TPC` equal to `0x41` is rejected earlier still, by the odd-address test in the dispatch owner.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-related role=related-owners-navigation -->
## Related owners

- [Address space](address-space.md) owns `ReadPhysicalMemoryByte` and `PTO_MODEL_MEMORY_BYTES`.
- `PTO-ARCH-DISPATCH-TOP-LEVEL` calls these helpers and owns the fault raising, the odd-address test and the full-range re-probe.
- `PTO-ARCH-STATE-PROGRAM-COUNTER` owns `ReadTPC` and `WriteTPC`.
- [Fault precision](fault-precision.md) maps `Fault_InstructionPC` and `Fault_InstructionPage` to trap numbers `32` and `33`.
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

readonly func TranslateInstructionAddress(
    address: Word) => Word
begin
    return address;
end;

readonly func InstructionAccessPermitted(
    physical_address: Word,
    size_bytes: integer {2,4,6,8}) => boolean
begin
    let end_address = UInt(physical_address) + size_bytes;
    if end_address > PTO_MODEL_MEMORY_BYTES then
        return FALSE;
    end;
    return TRUE;
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
