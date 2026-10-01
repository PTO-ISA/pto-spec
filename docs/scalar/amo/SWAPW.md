<!-- GENERATED FROM: asl/scalar/amo/SWAPW.asl -->
# SWAPW

**Normative ASL source:** `asl/scalar/amo/SWAPW.asl`

SWAPW atomically replaces one word and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swapw-purpose role=purpose -->
## What SWAPW does

`SWAPW` atomically replaces the aligned `4`-byte word at the address in `SrcL` with the low `32` bits of `SrcR`, and publishes the word it displaced.

This is the four-byte member of the `SWAP` family; the byte, halfword, and doubleword members are `SWAPB`, `SWAPH`, and `SWAPD`.

<!-- PTO-READER-BLOCK: scalar-swapw-mechanism role=mechanism -->
## Atomic mechanism

The instruction contract returns `ScalarHandler_AtomicReadModifyWrite` with `Atomic_SWAP` and an access width of `4` bytes. The model then executes `AtomicReadModifyWrite`, which probes read access and write access for the same `4` bytes and requires both probes to translate to the same address before it loads, replaces, and stores.

`SrcL` and `SrcR` are snapshotted before any memory or destination effect, and `RegDst` is written only after the atomic commit reports no fault.

Because the handler reads a `4`-byte value, the published old value is first normalized by `NormalizeAtomicReturn` at width `4`, which returns the sign-extended word.

<!-- PTO-READER-BLOCK: scalar-swapw-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 atomic address source; `SrcR` carries the Reg5 word replacement source; `RegDst` carries the Reg5 old-value destination; `aq` and `rl` carry the ordering bits; `far` carries the flat-address routing hint.

All `32` `SrcL` and `SrcR` encodings are assigned: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`.

All `32` `RegDst` encodings are assigned too. Codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the old value, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue. Encoded zero in either source reads the architectural zero register.

Design point: this form publishes a sign-extended `32`-bit value, which is the same normalization `LW` uses for a `32`-bit load. The replacement side is truncated rather than extended, so `SrcR` never needs to be pre-masked to `32` bits.

<!-- PTO-READER-BLOCK: scalar-swapw-effects role=effects -->
## Effects and ordering

`aq=0,rl=0` records the atomic event with relaxed ordering; `aq=1,rl=0` selects acquire, `aq=0,rl=1` selects release, and `aq=1,rl=1` selects acquire-release. `far=1` is a routing hint only, and the reference profile keeps the same architectural address and result.

On success the instruction records exactly one atomic event, updates memory, leaves `SrcL` and `SrcR` unchanged, and advances `TPC` by `4` bytes.

A completed write invalidates a local reservation when it overlaps the `64`-byte reservation granule and preserves a reservation on a different granule.

No numeric status flag is recorded.

<!-- PTO-READER-BLOCK: scalar-swapw-constraints role=constraints -->
## Legality and precise faults

The effective address must be aligned to `4` bytes. Alignment, read translation and permission, write translation and permission, and translated-address equality are checked before effects, and every failure reports the original address.

Every value of `aq`, `rl`, and `far` is assigned, so there is no reserved modifier combination to reject.

A failing preflight publishes no destination value, records no memory event, leaves the reservation unchanged, and does not advance `TPC`; trap entry saves the original `TPC` for reissue.

Design point: because the destination is published only on the no-fault path, a faulted `SWAPW` cannot be misread as a successful exchange whose old value happened to be zero.

<!-- PTO-READER-BLOCK: scalar-swapw-example role=example -->
## Non-normative example

Take `a0 = 1024`, `a1 = 7`, and `a2 = 0`, and let the `4`-byte word at address `1024` hold `5`.

`swapw [a0], a1, ->a2` replaces the word with `7` and leaves `a2` holding `5`.

Before: the word is `5` and `a2` is `0`. After: the word is `7` and `a2` is `5`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swapw [SrcL], SrcR, ->Rd
swapw.aq [SrcL], SrcR, ->Rd
swapw.rl [SrcL], SrcR, ->Rd
swapw.f [SrcL], SrcR, ->Rd
swapw.aqrl [SrcL], SrcR, ->Rd
swapw.aqf [SrcL], SrcR, ->Rd
swapw.rlf [SrcL], SrcR, ->Rd
swapw.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swapw_32_ef15c3ebac33 | L32 | 32 | 0x2000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swapw_32_ef15c3ebac33 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swapw_32_ef15c3ebac33 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swapw_32_ef15c3ebac33 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swapw_32_ef15c3ebac33 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swapw_32_ef15c3ebac33 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swapw_32_ef15c3ebac33 | SrcR | 5 | 0–31 | none | none | Reg5 word replacement source | Encoded zero supplies numeric zero as the replacement. |
| swapw_32_ef15c3ebac33 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swapw_32_ef15c3ebac33 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swapw_32_ef15c3ebac33 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 word replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPW.asl -->
```asl
readonly func InstructionContractOperation_SWAPW() => ScalarOperation
begin
    return ScalarOperation_SWAPW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPW.asl -->
```asl
readonly func InstructionContractHandler_SWAPW() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPW()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word, store SrcR truncated to 4 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swapw [a0], a1, ->a2
- swapw.aqrl [t#1], u#1, ->u
- swapw.f [sp], zero, ->t
