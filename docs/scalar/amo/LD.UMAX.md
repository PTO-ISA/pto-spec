<!-- GENERATED FROM: asl/scalar/amo/LD.UMAX.asl -->
# LD.UMAX

**Normative ASL source:** `asl/scalar/amo/LD.UMAX.asl`

LD.UMAX atomically stores the width-sized unsigned maximum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-UMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-umax-purpose role=purpose -->
## What LD.UMAX does

`LD.UMAX` writes the larger of two 64-bit values to a memory address. The comparison is unsigned, so it follows the numeric magnitude of the pattern rather than its sign, and the replaced doubleword is published through `RegDst`.

<!-- PTO-READER-BLOCK: scalar-ld-umax-mechanism role=mechanism -->
## Selecting the larger unsigned value

The handler is `ScalarHandler_AtomicReadModifyWrite`, the access size is `8`, and the atomic operation is `Atomic_UMAX`. The read and write probes settle the address first; then the old doubleword is loaded, the larger unsigned value is selected, the selected bits are stored back, one atomic event with `write_performed` set to true is recorded, and the old doubleword is returned.

Storage holding `0x0000000000000005` compared with `SrcR = 0x8000000000000000` ends up holding `0x8000000000000000`, because unsigned order reads that pattern as a very large value; a signed reading would call it negative.

Design point: this form and `LD.SMAX` compare the same two 64-bit patterns under different rules, so the signed and unsigned spellings can disagree only when exactly one of the two patterns has bit `63` set. Choosing the wrong spelling changes the stored bytes even though the address and the operands are identical.

Design point: the winner keeps its original encoding. Access size `8` means the loaded doubleword and `SrcR` are used unmodified, so the store writes one of the two input patterns, never a normalized or extended copy.

<!-- PTO-READER-BLOCK: scalar-ld-umax-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`.

Every Reg5 source selector is legal for `SrcL` and `SrcR`: `0` reads the architectural zero register, `1` to `23` read GPRs, `24` to `27` read `T#1` to `T#4`, and `28` to `31` read `U#1` to `U#4`; reading a queue entry leaves it in place. Destination codes `1` to `23` write a GPR, `0` and `24` to `29` discard, `30` pushes U, and `31` pushes T.

Design point: `aq` and `rl` select relaxed, acquire, release, or acquire-release ordering for the recorded event, and `far` enters the address path through `AtomicAddress`, which returns its argument unchanged; the reference model therefore ignores the hint bit when it picks the larger value.

<!-- PTO-READER-BLOCK: scalar-ld-umax-effects role=effects -->
## Effects

A completed `LD.UMAX` stores 8 bytes, records one atomic event with `write_performed` set to true, publishes the pre-instruction doubleword through `RegDst`, and advances `TPC` by 4 bytes. A store that overlaps the reserved 64-byte granule clears the local reservation.

Design point: the write is unconditional, so an execution whose operand is the smaller unsigned value still stores the old bytes, still reports `write_performed` as true, and still invalidates an overlapping reservation.

<!-- PTO-READER-BLOCK: scalar-ld-umax-constraints role=constraints -->
## Legality and faults

The address must be aligned to 8 bytes and must pass the permission and bounds test; the write probe repeats both checks, and the two translated addresses must be equal. Misalignment reports `Fault_DataAlignment` and a failed bounds test reports `Fault_DataPage`, each at the original address and each before the load. An undecodable form or an unavailable selected T or U source raises `Fault_IllegalInstruction` first. After any fault the destination is not written, memory is unchanged, no atomic event is recorded, no reservation is cleared, and `TPC` does not advance.

Design point: the probes run before the load, so a rejected execution needs no rollback: memory and the register file are exactly as they were, apart from the reported fault.

<!-- PTO-READER-BLOCK: scalar-ld-umax-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

With `a0` holding an 8-byte aligned address, `ld.umax [a0], a1, ->a2` compares in place. If `[a0]` holds `0x0000000000000005` and `a1` holds `0x8000000000000000`, the location receives `0x8000000000000000` and `a2` receives `0x0000000000000005`.

```text
ld.umax [a0], a1, ->a2
```
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.umax [SrcL], SrcR, ->Rd
ld.umax.aq [SrcL], SrcR, ->Rd
ld.umax.rl [SrcL], SrcR, ->Rd
ld.umax.f [SrcL], SrcR, ->Rd
ld.umax.aqrl [SrcL], SrcR, ->Rd
ld.umax.aqf [SrcL], SrcR, ->Rd
ld.umax.rlf [SrcL], SrcR, ->Rd
ld.umax.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_umax_32_a84af75745d9 | L32 | 32 | 0x6000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_umax_32_a84af75745d9 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_umax_32_a84af75745d9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_umax_32_a84af75745d9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_umax_32_a84af75745d9 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_umax_32_a84af75745d9 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_umax_32_a84af75745d9 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_umax_32_a84af75745d9 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_umax_32_a84af75745d9 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_umax_32_a84af75745d9 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_umax_32_a84af75745d9 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_umax_32_a84af75745d9 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_umax_32_a84af75745d9 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.UMAX.asl -->
```asl
readonly func InstructionContractOperation_LD_UMAX() => ScalarOperation
begin
    return ScalarOperation_LD_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.UMAX.asl -->
```asl
readonly func InstructionContractHandler_LD_UMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_UMAX()
    => AtomicOperation
begin
    return Atomic_UMAX;
end;

pure func InstructionContractAtomicSizeBytes_LD_UMAX()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_UMAX()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_UMAX()
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
- LD.UMAX computes the unsigned maximum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized unsigned maximum, and write one 8-byte result to the same location.
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

- ld.umax [a0], a1, ->a2
- ld.umax.aqrl [t#1], u#1, ->t
- ld.umax.f [sp], a0, ->u
