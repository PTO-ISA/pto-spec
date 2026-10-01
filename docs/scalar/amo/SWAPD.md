<!-- GENERATED FROM: asl/scalar/amo/SWAPD.asl -->
# SWAPD

**Normative ASL source:** `asl/scalar/amo/SWAPD.asl`

SWAPD atomically replaces one doubleword and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swapd-purpose role=purpose -->
## What SWAPD does

`SWAPD` atomically replaces the aligned `8`-byte doubleword at the address in `SrcL` with the low `64` bits of `SrcR`, and publishes the doubleword it displaced.

This is the doubleword member of the `SWAP` family; the byte, halfword, and word members are `SWAPB`, `SWAPH`, and `SWAPW`.

<!-- PTO-READER-BLOCK: scalar-swapd-mechanism role=mechanism -->
## Atomic mechanism

The instruction contract returns `ScalarHandler_AtomicReadModifyWrite` with `Atomic_SWAP` and an access width of `8` bytes. The model then executes `AtomicReadModifyWrite`, which probes read access and write access for the same `8` bytes and requires both probes to translate to the same address before it loads, replaces, and stores.

`SrcL` and `SrcR` are snapshotted before any memory or destination effect, and `RegDst` is written only after the atomic commit reports no fault.

Because the handler reads a `8`-byte value, the published old value passes through `NormalizeAtomicReturn` at width `8` unchanged.

<!-- PTO-READER-BLOCK: scalar-swapd-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 atomic address source; `SrcR` carries the Reg5 doubleword replacement source; `RegDst` carries the Reg5 old-value destination; `aq` and `rl` carry the ordering bits; `far` carries the flat-address routing hint.

All `32` `SrcL` and `SrcR` encodings are assigned: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`.

All `32` `RegDst` encodings are assigned too. Codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the old value, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue. Encoded zero in either source reads the architectural zero register.

Design point: at `8` bytes the displaced value fills the whole register, so no extension applies and no bit of the result is synthesized. That is the case that distinguishes this form from `SWAPW`, where the upper half of the destination is a sign extension of the loaded word.

<!-- PTO-READER-BLOCK: scalar-swapd-effects role=effects -->
## Effects and ordering

`aq=0,rl=0` records the atomic event with relaxed ordering; `aq=1,rl=0` selects acquire, `aq=0,rl=1` selects release, and `aq=1,rl=1` selects acquire-release. `far=1` is a routing hint only, and the reference profile keeps the same architectural address and result.

On success the instruction records exactly one atomic event, updates memory, leaves `SrcL` and `SrcR` unchanged, and advances `TPC` by `4` bytes.

A completed write invalidates a local reservation when it overlaps the `64`-byte reservation granule and preserves a reservation on a different granule.

No numeric status flag is recorded.

<!-- PTO-READER-BLOCK: scalar-swapd-constraints role=constraints -->
## Legality and precise faults

The effective address must be aligned to `8` bytes. Alignment, read translation and permission, write translation and permission, and translated-address equality are checked before effects, and every failure reports the original address.

Every value of `aq`, `rl`, and `far` is assigned, so there is no reserved modifier combination to reject.

A failing preflight publishes no destination value, records no memory event, leaves the reservation unchanged, and does not advance `TPC`; trap entry saves the original `TPC` for reissue.

Design point: an exchange whose read probe succeeds but whose write probe fails changes nothing, because the load happens after both probes. Software that relies on the returned value as proof of a completed exchange therefore cannot be fooled by a partially checked access.

<!-- PTO-READER-BLOCK: scalar-swapd-example role=example -->
## Non-normative example

Take `a0 = 1024`, `a1 = 7`, and `a2 = 0`, and let the `8`-byte doubleword at address `1024` hold `9`.

`swapd [a0], a1, ->a2` replaces the doubleword with `7` and leaves `a2` holding `9`.

Before: the doubleword is `9` and `a2` is `0`. After: the doubleword is `7` and `a2` is `9`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swapd [SrcL], SrcR, ->Rd
swapd.aq [SrcL], SrcR, ->Rd
swapd.rl [SrcL], SrcR, ->Rd
swapd.f [SrcL], SrcR, ->Rd
swapd.aqrl [SrcL], SrcR, ->Rd
swapd.aqf [SrcL], SrcR, ->Rd
swapd.rlf [SrcL], SrcR, ->Rd
swapd.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swapd_32_cd31ccde2303 | L32 | 32 | 0x3000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swapd_32_cd31ccde2303 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swapd_32_cd31ccde2303 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swapd_32_cd31ccde2303 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swapd_32_cd31ccde2303 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swapd_32_cd31ccde2303 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swapd_32_cd31ccde2303 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swapd_32_cd31ccde2303 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swapd_32_cd31ccde2303 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swapd_32_cd31ccde2303 | SrcR | 5 | 0–31 | none | none | Reg5 doubleword replacement source | Encoded zero supplies numeric zero as the replacement. |
| swapd_32_cd31ccde2303 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swapd_32_cd31ccde2303 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swapd_32_cd31ccde2303 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 doubleword replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPD.asl -->
```asl
readonly func InstructionContractOperation_SWAPD() => ScalarOperation
begin
    return ScalarOperation_SWAPD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPD.asl -->
```asl
readonly func InstructionContractHandler_SWAPD() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPD()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPD()
    => boolean
begin
    return FALSE;
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
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword, store SrcR truncated to 8 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swapd [a0], a1, ->a2
- swapd.aqrl [t#1], u#1, ->u
- swapd.f [sp], zero, ->t
