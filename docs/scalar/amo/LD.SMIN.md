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

`LD.SMIN` atomically applies signed minimum to one doubleword, stores the result, and publishes the prior memory value.

<!-- PTO-READER-BLOCK: scalar-ld-smin-mechanism role=mechanism -->
## Atomic mechanism

The ASL DOC contract selects `ScalarHandler_AtomicReadModifyWrite` with an access width of `8` bytes.

Read and write access are preflighted before the same-location atomic read-modify-write is allowed to commit.

<!-- PTO-READER-BLOCK: scalar-ld-smin-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 atomic address source; `SrcR` carries the Reg5 atomic operand source; `RegDst` carries the Reg5 old-value destination; `aq` carries the acquire ordering bit; `rl` carries the release ordering bit; `far` carries the flat-address routing hint.

`aq` and `rl` select relaxed, acquire, release, or acquire-release ordering; `far` is a profile routing hint and does not change the architectural result in the reference profile.

<!-- PTO-READER-BLOCK: scalar-ld-smin-effects role=effects -->
## Effects and ordering

The old memory value is published only after the read-modify-write commits; source aliases are captured before any destination effect.

A completed write invalidates an overlapping local 64-byte-line reservation, preserves a nonoverlapping reservation, and advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-ld-smin-constraints role=constraints -->
## Legality and precise faults

The effective address must be aligned to `8` bytes. Alignment, translation, and permission checks precede architectural effects.

A failing preflight publishes no destination, memory event, reservation update, or retirement effect; the saved original `TPC` supports full reissue.

<!-- PTO-READER-BLOCK: scalar-ld-smin-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

For a first reading, use `ld.smin [SrcL], SrcR, ->Rd` and then vary only the ordering or route modifiers described above.
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
