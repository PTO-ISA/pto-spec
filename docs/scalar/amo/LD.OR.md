<!-- GENERATED FROM: asl/scalar/amo/LD.OR.asl -->
# LD.OR

**Normative ASL source:** `asl/scalar/amo/LD.OR.asl`

LD.OR atomically stores the width-sized bitwise OR and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-or-purpose role=purpose -->
## What LD.OR does

`LD.OR` sets bits in one 8-byte memory doubleword: every bit that is `1` in the 64-bit operand becomes `1` in the stored value, and the doubleword that was there before the instruction is published through `RegDst`.

The address is `SrcL` and the operand is `SrcR`. The form is 32 bits wide and advances `TPC` by 4 bytes when it completes.

<!-- PTO-READER-BLOCK: scalar-ld-or-mechanism role=mechanism -->
## Combining the operand with the stored doubleword

The handler is `ScalarHandler_AtomicReadModifyWrite` with access size `8` and atomic operation `Atomic_OR`. After the read probe and the write probe agree on one translated address, the old doubleword is loaded, ORed with the operand, stored back to the same location, and recorded as one atomic event whose `write_performed` is true.

Because OR can only turn a `0` into a `1`, the stored value is a bitwise superset of the old doubleword: storage holding `0x00000000000000f0` combined with `SrcR = 0x0000000000000f00` ends up holding `0x0000000000000ff0`.

Design point: no stored bit can be cleared by this form, and the operation is idempotent, so applying the same operand twice stores the same bits both times. A program that must clear bits needs the AND form with the complement held in a register.

Design point: `SrcL` is read before the destination is written, so `RegDst` may name the same register as `SrcL` without changing which location is accessed; the published old doubleword simply lands in the register that supplied the address.

<!-- PTO-READER-BLOCK: scalar-ld-or-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`.

Sources are read through Reg5 selectors: `0` reads the architectural zero register, `1` to `23` read absolute GPRs, `24` to `27` read `T#1` to `T#4`, and `28` to `31` read `U#1` to `U#4` without consuming the queue entry. `aq` and `rl` select relaxed, acquire, release, or acquire-release ordering for the recorded event.

Design point: `far` reaches `AtomicAddress`, which returns the address unchanged, so in the reference model the `.f` spelling does not move the access; the bit selects a profile route hint that the reference model does not act on.

<!-- PTO-READER-BLOCK: scalar-ld-or-effects role=effects -->
## Effects

A completed execution stores 8 bytes at the addressed location, records one atomic event with `write_performed` set to true, publishes the pre-instruction doubleword through `RegDst` unless that destination discards, and advances `TPC` by 4 bytes. A write that overlaps the reserved 64-byte granule clears the local reservation.

Design point: because the destination holds the pre-instruction value, a single execution exposes both results: memory has the new bits and `RegDst` has the old ones. No status flag is written for the operation.

<!-- PTO-READER-BLOCK: scalar-ld-or-constraints role=constraints -->
## Legality and faults

Two preflight checks guard the access, and the write probe repeats them for write permission. A misaligned address raises `Fault_DataAlignment` at the original address before the load; an address outside the permitted region raises `Fault_DataPage`. An unavailable selected T or U source or an undecodable form raises `Fault_IllegalInstruction` even earlier. After any fault nothing is published, memory is unchanged, no atomic event is recorded, no reservation is cleared, and `TPC` stays at its saved value.

Design point: both probes complete before the load, and the reference model takes its read and write access decisions from the same bounds check, so either probe can report `Fault_DataPage` and the reported address is always the original one.

<!-- PTO-READER-BLOCK: scalar-ld-or-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

`ld.or [a0], a1, ->a2` with an 8-byte aligned address in `a0` sets bits in place. With `[a0]` holding `0x00000000000000f0` and `a1` holding `0x0000000000000f00`, the location receives `0x0000000000000ff0` and `a2` receives `0x00000000000000f0`.

```text
ld.or [a0], a1, ->a2
```
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.or [SrcL], SrcR, ->Rd
ld.or.aq [SrcL], SrcR, ->Rd
ld.or.rl [SrcL], SrcR, ->Rd
ld.or.f [SrcL], SrcR, ->Rd
ld.or.aqrl [SrcL], SrcR, ->Rd
ld.or.aqf [SrcL], SrcR, ->Rd
ld.or.rlf [SrcL], SrcR, ->Rd
ld.or.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_or_32_456d270cfc7d | L32 | 32 | 0x2000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_or_32_456d270cfc7d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_or_32_456d270cfc7d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_or_32_456d270cfc7d | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_or_32_456d270cfc7d | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_or_32_456d270cfc7d | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_or_32_456d270cfc7d | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_or_32_456d270cfc7d | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_or_32_456d270cfc7d | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_or_32_456d270cfc7d | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_or_32_456d270cfc7d | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_or_32_456d270cfc7d | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_or_32_456d270cfc7d | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.OR.asl -->
```asl
readonly func InstructionContractOperation_LD_OR() => ScalarOperation
begin
    return ScalarOperation_LD_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.OR.asl -->
```asl
readonly func InstructionContractHandler_LD_OR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_OR()
    => AtomicOperation
begin
    return Atomic_OR;
end;

pure func InstructionContractAtomicSizeBytes_LD_OR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_OR()
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
- LD.OR computes the bitwise OR at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized bitwise OR, and write one 8-byte result to the same location.
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

- ld.or [a0], a1, ->a2
- ld.or.aqrl [t#1], u#1, ->t
- ld.or.f [sp], a0, ->u
