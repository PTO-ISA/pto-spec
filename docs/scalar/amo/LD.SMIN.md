<!-- GENERATED FROM: asl/scalar/amo/LD.SMIN.asl -->
# LD.SMIN

**Normative ASL source:** `asl/scalar/amo/LD.SMIN.asl`

LD.SMIN atomically stores the width-sized signed minimum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-SMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-smin-purpose role=purpose -->
## What LD.SMIN does

`LD.SMIN` stores the smaller of two values at a memory address. The stored doubleword and the 64-bit operand are both read as two's-complement signed integers, and the doubleword that was in memory before the instruction is published through `RegDst`.

<!-- PTO-READER-BLOCK: scalar-ld-smin-mechanism role=mechanism -->
## Keeping the smaller signed value

The handler is `ScalarHandler_AtomicReadModifyWrite` with access size `8` and atomic operation `Atomic_SMIN`. After the read and write probes pass, the old doubleword is loaded, compared with `SrcR`, and the smaller signed value is written back; one atomic event with `write_performed` set to true is recorded.

Design point: the comparison reads bit 63 as a sign. Storage holding `0x0000000000000005` compared with `SrcR = 0xfffffffffffffffd`, which is `-3`, ends up holding `0xfffffffffffffffd`, because `-3` is smaller than `5`. The stored bytes are one of the two input patterns, unchanged.

Design point: when the two signed values are equal, the form keeps the operand. Its bit pattern is then identical to the old doubleword, so the location is written with the bytes it already held, and the execution still counts as a performed atomic write.

Design point: the destination is written only when no fault was raised, so a rejected `LD.SMIN` leaves the previous contents of that register in place instead of publishing a value that never came from memory.

<!-- PTO-READER-BLOCK: scalar-ld-smin-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`. `SrcL` supplies the atomic address and `SrcR` the operand; every Reg5 source selector is legal, and a selected T or U entry is read without being popped.

`RegDst` takes the published value: codes `0` and `24` to `29` discard it, code `30` pushes U, code `31` pushes T, and codes `1` to `23` write the named GPR. `aq` and `rl` encode relaxed, acquire, release, and acquire-release ordering for the recorded event.

Design point: `far` is decoded and passed to `AtomicAddress`, which returns the address unchanged. In the reference model the hinted spelling selects the same doubleword as the plain spelling, so the comparison result is identical.

<!-- PTO-READER-BLOCK: scalar-ld-smin-effects role=effects -->
## Effects

A completed execution stores 8 bytes, records one atomic event with `write_performed` set to true, publishes the pre-instruction doubleword, and advances `TPC` by 4 bytes. The store clears the local reservation when the written range overlaps the reserved 64-byte granule.

<!-- PTO-READER-BLOCK: scalar-ld-smin-constraints role=constraints -->
## Legality and faults

The address must be a multiple of 8; misalignment raises `Fault_DataAlignment`, and an address outside the permitted region raises `Fault_DataPage`, each reported at the original address and each checked before the load. An undecodable form or an unavailable selected T or U source raises `Fault_IllegalInstruction` before any effect. A faulting execution publishes nothing, writes nothing, records no event, and does not advance `TPC`.

<!-- PTO-READER-BLOCK: scalar-ld-smin-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

`ld.smin [a0], a1, ->a2` with `a0` holding an 8-byte aligned address compares in place. With `[a0]` holding `0x0000000000000005` and `a1` holding `0xfffffffffffffffd`, the smaller signed value `-3` is stored as `0xfffffffffffffffd`, and `a2` receives `0x0000000000000005`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.smin [SrcL], SrcR, ->Rd
ld.smin.aq [SrcL], SrcR, ->Rd
ld.smin.rl [SrcL], SrcR, ->Rd
ld.smin.f [SrcL], SrcR, ->Rd
ld.smin.aqrl [SrcL], SrcR, ->Rd
ld.smin.aqf [SrcL], SrcR, ->Rd
ld.smin.rlf [SrcL], SrcR, ->Rd
ld.smin.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_smin_32_9461d345718f | L32 | 32 | 0x5000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_smin_32_9461d345718f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_smin_32_9461d345718f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_smin_32_9461d345718f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_smin_32_9461d345718f | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_smin_32_9461d345718f | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_smin_32_9461d345718f | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_smin_32_9461d345718f | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_smin_32_9461d345718f | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_smin_32_9461d345718f | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_smin_32_9461d345718f | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_smin_32_9461d345718f | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_smin_32_9461d345718f | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.SMIN.asl -->
```asl
readonly func InstructionContractOperation_LD_SMIN() => ScalarOperation
begin
    return ScalarOperation_LD_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.SMIN.asl -->
```asl
readonly func InstructionContractHandler_LD_SMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_SMIN()
    => AtomicOperation
begin
    return Atomic_SMIN;
end;

pure func InstructionContractAtomicSizeBytes_LD_SMIN()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_SMIN()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_SMIN()
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
- LD.SMIN computes the signed minimum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized signed minimum, and write one 8-byte result to the same location.
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

- ld.smin [a0], a1, ->a2
- ld.smin.aqrl [t#1], u#1, ->t
- ld.smin.f [sp], a0, ->u
