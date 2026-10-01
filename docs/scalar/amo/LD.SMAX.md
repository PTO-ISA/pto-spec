<!-- GENERATED FROM: asl/scalar/amo/LD.SMAX.asl -->
# LD.SMAX

**Normative ASL source:** `asl/scalar/amo/LD.SMAX.asl`

LD.SMAX atomically stores the width-sized signed maximum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-SMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-smax-purpose role=purpose -->
## What LD.SMAX does

`LD.SMAX` replaces one 8-byte memory doubleword with the larger of that doubleword and a 64-bit operand, comparing both as signed two's-complement values. The value that was in memory before the instruction is published through `RegDst`.

<!-- PTO-READER-BLOCK: scalar-ld-smax-mechanism role=mechanism -->
## Choosing the larger signed value

The form runs through `ScalarHandler_AtomicReadModifyWrite` with access size `8` and atomic operation `Atomic_SMAX`: read probe, write probe, load, signed comparison, store of the winner, one atomic event with `write_performed` set to true, and the old doubleword returned for publication.

A negative pattern loses to a small positive one. Storage holding `0xfffffffffffffffd`, which is `-3`, compared with `SrcR = 0x0000000000000005`, ends up holding `0x0000000000000005`.

Design point: the sign bit decides the comparison. Compared under the unsigned rules of `LD.UMAX`, the same two patterns would keep `0xfffffffffffffffd` instead, because unsigned order reads it as an extremely large number; the two forms accept the same operands and differ in how they interpret them.

Design point: only the winner's bytes are written. At access size `8` the values are used as loaded, so the stored doubleword is either the old pattern or the operand, never a converted form.

<!-- PTO-READER-BLOCK: scalar-ld-smax-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`.

`SrcL` is the address source and `SrcR` the operand source. Encoded source zero reads the architectural zero register; selectors `24` to `27` read `T#1` to `T#4` and `28` to `31` read `U#1` to `U#4` without consuming an entry. Encoded destination zero discards the published value, as do codes `24` to `29`; code `30` pushes U and code `31` pushes T.

Design point: `far` is a route hint only. It is decoded and passed to `AtomicAddress`, which returns the address unchanged, so a `.f` spelling cannot redirect the comparison to a different doubleword in the reference model.

<!-- PTO-READER-BLOCK: scalar-ld-smax-effects role=effects -->
## Effects

A completed `LD.SMAX` writes 8 bytes to the addressed location, records one atomic event with `write_performed` set to true, publishes the pre-instruction doubleword, and advances `TPC` by 4 bytes. A write overlapping the reserved 64-byte granule clears the local reservation.

Design point: the store is not conditional. When the operand is the smaller value, the old doubleword is written back unchanged, `write_performed` is still true, and an overlapping reservation is still cleared.

<!-- PTO-READER-BLOCK: scalar-ld-smax-constraints role=constraints -->
## Legality and faults

The address must be 8-byte aligned. Alignment is checked before translation, and translation before the permission and bounds test; the write probe repeats that sequence for write access, and the two translated addresses must match. `Fault_DataAlignment` and `Fault_DataPage` are reported at the original address, and `Fault_IllegalInstruction` is raised earlier for an undecodable form or an unavailable selected T or U source. On a fault nothing is published, no byte is loaded or stored, no atomic event is recorded, no reservation changes, and `TPC` does not advance.

<!-- PTO-READER-BLOCK: scalar-ld-smax-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

With `a0` holding an 8-byte aligned address, `ld.smax [a0], a1, ->a2` compares in place. If `[a0]` holds `0xfffffffffffffffd` and `a1` holds `0x0000000000000005`, the location receives `0x0000000000000005` and `a2` receives `0xfffffffffffffffd`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.smax [SrcL], SrcR, ->Rd
ld.smax.aq [SrcL], SrcR, ->Rd
ld.smax.rl [SrcL], SrcR, ->Rd
ld.smax.f [SrcL], SrcR, ->Rd
ld.smax.aqrl [SrcL], SrcR, ->Rd
ld.smax.aqf [SrcL], SrcR, ->Rd
ld.smax.rlf [SrcL], SrcR, ->Rd
ld.smax.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_smax_32_a3aad6120226 | L32 | 32 | 0x4000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_smax_32_a3aad6120226 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_smax_32_a3aad6120226 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_smax_32_a3aad6120226 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_smax_32_a3aad6120226 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_smax_32_a3aad6120226 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_smax_32_a3aad6120226 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_smax_32_a3aad6120226 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_smax_32_a3aad6120226 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_smax_32_a3aad6120226 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_smax_32_a3aad6120226 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_smax_32_a3aad6120226 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_smax_32_a3aad6120226 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.SMAX.asl -->
```asl
readonly func InstructionContractOperation_LD_SMAX() => ScalarOperation
begin
    return ScalarOperation_LD_SMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.SMAX.asl -->
```asl
readonly func InstructionContractHandler_LD_SMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_SMAX()
    => AtomicOperation
begin
    return Atomic_SMAX;
end;

pure func InstructionContractAtomicSizeBytes_LD_SMAX()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_SMAX()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_SMAX()
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
- LD.SMAX computes the signed maximum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized signed maximum, and write one 8-byte result to the same location.
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

- ld.smax [a0], a1, ->a2
- ld.smax.aqrl [t#1], u#1, ->t
- ld.smax.f [sp], a0, ->u
