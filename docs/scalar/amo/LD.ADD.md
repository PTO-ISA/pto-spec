<!-- GENERATED FROM: asl/scalar/amo/LD.ADD.asl -->
# LD.ADD

**Normative ASL source:** `asl/scalar/amo/LD.ADD.asl`

LD.ADD atomically stores the width-sized modular sum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-add-purpose role=purpose -->
## What LD.ADD does

`LD.ADD` adds one 64-bit operand to the doubleword stored at a memory address, writes the sum back to that address, and publishes the doubleword it replaced. The address comes from `SrcL`, the operand from `SrcR`, and the replaced value is published through `RegDst`. It is a standalone 32-bit encoded form with a memory effect, so a successful execution advances `TPC` by 4 bytes.

<!-- PTO-READER-BLOCK: scalar-ld-add-mechanism role=mechanism -->
## How the sum reaches memory

The form binds the semantic handler `ScalarHandler_AtomicReadModifyWrite`, access size `8`, and atomic operation `Atomic_ADD`. Dispatch runs a read probe and a write probe for the same address first, then loads the old doubleword, computes the 64-bit sum, stores it, records one atomic event with `write_performed` set to true, and returns the old value.

Design point: the addition is `old + operand` at `XLEN` width, so it wraps. Storage holding `0xffffffffffffffff` combined with `SrcR = 0x0000000000000001` ends up holding `0x0`; the carry out of bit 63 is discarded, and no scalar status flag records that it happened.

Design point: the value published to `RegDst` is the pre-instruction doubleword, not the sum just written. One execution therefore both replaces the contents and reports what they were, so the new sum is visible only by reading the location again.

<!-- PTO-READER-BLOCK: scalar-ld-add-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`.

- `SrcL` reads the address; encoded zero selects the architectural zero register, so the access targets address zero.
- `SrcR` reads the operand; a T or U selector is read without consuming a queue entry.
- `RegDst` receives the old value; destination code 0 discards it, code 30 pushes U, and code 31 pushes T.
- `aq` and `rl` select relaxed, acquire, release, or acquire-release ordering for the recorded event.

Design point: `far` is decoded and handed to `AtomicAddress`, which returns its argument unchanged, so `ld.add [a0], a1, ->a2` and `ld.add.f [a0], a1, ->a2` reach the same address and produce the same result in the reference model; the bit only selects a route hint.

<!-- PTO-READER-BLOCK: scalar-ld-add-effects role=effects -->
## Effects

A successful execution writes 8 bytes to the addressed location, records one atomic event with `write_performed` set to true, and publishes the old doubleword unless `RegDst` encodes a discarding destination. The store also invalidates the local reservation when the written 8-byte range overlaps the reserved 64-byte granule; a reservation elsewhere is untouched. `TPC` advances by 4 bytes.

Design point: the store is unconditional, even when the sum equals the old doubleword, for example when `SrcR` reads the architectural zero register. That store still clears an overlapping reservation, so a later conditional store to the same granule fails even though the bytes did not change.

<!-- PTO-READER-BLOCK: scalar-ld-add-constraints role=constraints -->
## Legality and faults

The address must be a multiple of 8. A decoding failure or an unavailable selected T or U source raises `Fault_IllegalInstruction` before any effect. Address misalignment then reports `Fault_DataAlignment`; an address outside the permitted region reports `Fault_DataPage`. Both are reported at the original, pre-translation address, and a fault publishes no destination, performs no load or store, records no event, and does not advance `TPC`.

Design point: because the alignment test happens inside the read probe and both probes complete before the load, a misaligned address never reads or writes a byte, and the saved `TPC` lets software correct the address and reissue the same instruction.

<!-- PTO-READER-BLOCK: scalar-ld-add-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

With `a0` holding an 8-byte aligned address, `ld.add [a0], a1, ->a2` adds `a1` to the doubleword at `[a0]`. If that doubleword holds `0xffffffffffffffff` and `a1` holds `0x0000000000000001`, memory receives `0x0` and `a2` receives `0xffffffffffffffff`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.add [SrcL], SrcR, ->Rd
ld.add.aq [SrcL], SrcR, ->Rd
ld.add.rl [SrcL], SrcR, ->Rd
ld.add.f [SrcL], SrcR, ->Rd
ld.add.aqrl [SrcL], SrcR, ->Rd
ld.add.aqf [SrcL], SrcR, ->Rd
ld.add.rlf [SrcL], SrcR, ->Rd
ld.add.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_add_32_a4038a6c7e86 | L32 | 32 | 0x0000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_add_32_a4038a6c7e86 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_add_32_a4038a6c7e86 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_add_32_a4038a6c7e86 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_add_32_a4038a6c7e86 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_add_32_a4038a6c7e86 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_add_32_a4038a6c7e86 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_add_32_a4038a6c7e86 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_add_32_a4038a6c7e86 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_add_32_a4038a6c7e86 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_add_32_a4038a6c7e86 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_add_32_a4038a6c7e86 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_add_32_a4038a6c7e86 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.ADD.asl -->
```asl
readonly func InstructionContractOperation_LD_ADD() => ScalarOperation
begin
    return ScalarOperation_LD_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.ADD.asl -->
```asl
readonly func InstructionContractHandler_LD_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_LD_ADD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_ADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_ADD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the published old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 Reg5 destination encodings are assigned. Destination code 0 and destination codes 24..29 discard. Destination code 30 pushes U, destination code 31 pushes T, and codes 1..23 write the named absolute GPR.
- The effective address must be aligned to 8 bytes. aq, rl, and far have no reserved combinations.

## State effects

- Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.
- LD.ADD computes the modular sum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized modular sum, and write one 8-byte result to the same location.
- On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.
- The published result is the unchanged 64-bit old value.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.
- On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- ld.add [a0], a1, ->a2
- ld.add.aqrl [t#1], u#1, ->t
- ld.add.f [sp], a0, ->u
