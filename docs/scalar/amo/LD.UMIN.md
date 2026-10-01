<!-- GENERATED FROM: asl/scalar/amo/LD.UMIN.asl -->
# LD.UMIN

**Normative ASL source:** `asl/scalar/amo/LD.UMIN.asl`

LD.UMIN atomically stores the width-sized unsigned minimum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-UMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-umin-purpose role=purpose -->
## What LD.UMIN does

`LD.UMIN` stores the smaller of two 64-bit patterns at a memory address, ordering them as unsigned integers. The operand comes from `SrcR`, the address from `SrcL`, and the doubleword that was replaced is published through `RegDst`.

The whole 8-byte access participates in the comparison, so no part of either value is truncated or reinterpreted.

<!-- PTO-READER-BLOCK: scalar-ld-umin-mechanism role=mechanism -->
## Keeping the smaller unsigned value

The form binds `ScalarHandler_AtomicReadModifyWrite` with access size `8` and atomic operation `Atomic_UMIN`. Both access probes run first; then the old doubleword is loaded, compared with `SrcR` as unsigned values, the smaller one is stored back, and one atomic event with `write_performed` set to true is recorded.

Under unsigned order a set top bit makes a pattern numerically large. Storage holding `0x8000000000000000` compared with `SrcR = 0x0000000000000005` keeps `5`, because `0x8000000000000000` is the larger unsigned number; the same two patterns under `LD.SMIN` would keep the pattern with bit 63 set, which reads as a negative value.

Design point: equality stores the operand. When the two unsigned values are equal, the operand's pattern is already the old doubleword's pattern, so the addressed bytes do not change, yet the execution still counts as a performed atomic write.

Design point: the operand is not converted. Access size `8` maps to the identity normalization, so a `SrcR` with its upper bits set is compared as that full 64-bit value, not as a low word.

<!-- PTO-READER-BLOCK: scalar-ld-umin-inputs-outputs role=inputs-outputs -->
## Fields and operand roles

`RegDst` is a `5`-bit field at instruction bits `7..11`, `SrcL` at bits `15..19`, `SrcR` at bits `20..24`, `rl` at bit `25`, `aq` at bit `26`, and `far` at bit `27`.

- `SrcL` reads the atomic address; selector `0` reads the architectural zero register.
- `SrcR` reads the compared value; a T or U selector must name a valid entry and does not consume it.
- `RegDst` receives the published value; destination code `0` and codes `24` to `29` discard it, code `30` pushes U, and code `31` pushes T.

Design point: `aq` and `rl` choose relaxed, acquire, release, or acquire-release ordering for the atomic event, while `far` is decoded and passed to `AtomicAddress`, which returns its argument unchanged, so the hint bit leaves the address, the comparison, and the published value untouched in the reference model.

<!-- PTO-READER-BLOCK: scalar-ld-umin-effects role=effects -->
## Effects

A completed execution writes 8 bytes, records one atomic event with `write_performed` set to true, publishes the pre-instruction doubleword, and advances `TPC` by 4 bytes. If the written range overlaps the reserved 64-byte granule, the local reservation is cleared.

<!-- PTO-READER-BLOCK: scalar-ld-umin-constraints role=constraints -->
## Legality and faults

The address must be a multiple of 8. The read probe raises `Fault_DataAlignment` for a misaligned address and `Fault_DataPage` for an address outside the permitted region, both before the load and both reported at the original address; the write probe repeats the checks, and the two translated addresses must be equal. `Fault_IllegalInstruction` precedes all of this for an undecodable form or an unavailable selected T or U source. A faulting execution has no partial effect and does not advance `TPC`.

Design point: nothing is published on a fault, so the destination register keeps its previous contents and a later read of it returns those contents rather than a comparison result.

<!-- PTO-READER-BLOCK: scalar-ld-umin-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

`ld.umin [a0], a1, ->a2` with an 8-byte aligned address in `a0` compares the stored doubleword with `a1`. When `[a0]` holds `0x8000000000000000` and `a1` holds `0x0000000000000005`, the location receives `0x0000000000000005` and `a2` receives `0x8000000000000000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.umin [SrcL], SrcR, ->Rd
ld.umin.aq [SrcL], SrcR, ->Rd
ld.umin.rl [SrcL], SrcR, ->Rd
ld.umin.f [SrcL], SrcR, ->Rd
ld.umin.aqrl [SrcL], SrcR, ->Rd
ld.umin.aqf [SrcL], SrcR, ->Rd
ld.umin.rlf [SrcL], SrcR, ->Rd
ld.umin.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_umin_32_4bf2f357eff3 | L32 | 32 | 0x7000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_umin_32_4bf2f357eff3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_umin_32_4bf2f357eff3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_umin_32_4bf2f357eff3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_umin_32_4bf2f357eff3 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_umin_32_4bf2f357eff3 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_umin_32_4bf2f357eff3 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_umin_32_4bf2f357eff3 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_umin_32_4bf2f357eff3 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_umin_32_4bf2f357eff3 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_umin_32_4bf2f357eff3 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_umin_32_4bf2f357eff3 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_umin_32_4bf2f357eff3 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.UMIN.asl -->
```asl
readonly func InstructionContractOperation_LD_UMIN() => ScalarOperation
begin
    return ScalarOperation_LD_UMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.UMIN.asl -->
```asl
readonly func InstructionContractHandler_LD_UMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_UMIN()
    => AtomicOperation
begin
    return Atomic_UMIN;
end;

pure func InstructionContractAtomicSizeBytes_LD_UMIN()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_UMIN()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_UMIN()
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
- LD.UMIN computes the unsigned minimum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized unsigned minimum, and write one 8-byte result to the same location.
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

- ld.umin [a0], a1, ->a2
- ld.umin.aqrl [t#1], u#1, ->t
- ld.umin.f [sp], a0, ->u
