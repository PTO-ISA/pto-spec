<!-- GENERATED FROM: asl/scalar/amo/HL.CASD.asl -->
# HL.CASD

**Normative ASL source:** `asl/scalar/amo/HL.CASD.asl`

HL.CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-casd-purpose role=purpose -->
## What `HL.CASD` does

`HL.CASD` conditionally replaces the 64-bit doubleword at the address in `SrcL`. It compares that doubleword with `SrcR` and stores `SrcD` only when the two are equal. Either way the value that memory held is published through `RegDst`, and because the access is `8` bytes wide the published value is the complete 64-bit prior value with no extension applied.

The form matches `0x3000600b000e` under the mask `0xf000707ff83f`. Its access width is `8` bytes, so both probes require an address that is a multiple of `8`, and its handler is `ScalarHandler_CompareAndSwap`.

<!-- PTO-READER-BLOCK: scalar-hl-casd-mechanism role=mechanism -->
## What happens to the eight bytes

The dispatcher resolves the address through `ScalarDecodedAtomicAddress`, which reads the register selected by `SrcL` and the `far` bit and then calls `AtomicAddress`. `CompareAndSwap` works at a width of `8` bytes:

- The read probe tests `UInt(address) MOD 8` and then the bounds; the write probe repeats both tests, and a difference between the two translated addresses raises `Fault_DataPage`.
- `LoadTranslatedUnsigned` reads the eight bytes into one 64-bit value.
- The comparison is `old_value == NormalizeAtomicUnsigned(SrcR, 8)`, which at size `8` compares the whole of `SrcR` with the whole loaded value.
- On equality `StoreTranslated` writes all `8` bytes of `SrcD`; one atomic event records the order taken from `aq` and `rl` with `write_performed` equal to the match result.

Design point: at width `8` neither `NormalizeAtomicUnsigned` nor `NormalizeAtomicReturn` changes its argument, so the comparison uses every bit of `SrcR` and the publication returns every bit of the prior value. This form has no truncation or extension step: `SrcR` must reproduce the stored doubleword exactly for the swap to happen.

<!-- PTO-READER-BLOCK: scalar-hl-casd-inputs-outputs role=inputs-outputs -->
## Operands, ordering and `far`

- `SrcL`, `SrcR` and `SrcD` are Reg5 source selectors and `RegDst` is a destination selector: codes `0`..`23` name absolute GPRs, `24`..`27` read `T#1`..`T#4` and `28`..`31` read `U#1`..`U#4` without removing the entry, while `RegDst` writes GPRs `1`..`23`, discards codes `0` and `24`..`29`, pushes `U` for code `30` and `T` for code `31`.
- `aq` and `rl` select the recorded order: `0` is relaxed, `aq` is acquire, `rl` is release and both is acquire-release, for a match and a mismatch alike.
- `far` is the profile routing hint at instruction bit 43. `AtomicAddress` returns its argument unchanged, so `far` does not move the doubleword.

Design point: the four forms of this family have match values that differ only at instruction bits 45 and 44, which hold `00` for the byte form, `01` for the halfword form, `10` for the word form and `11` for `HL.CASD`. The width is therefore part of the fixed-bit decode, above the `far` bit, and not a modifier that software can vary at run time.

<!-- PTO-READER-BLOCK: scalar-hl-casd-effects role=effects -->
## Effects and completion

A match rewrites all `8` bytes at the address with `SrcD`. A mismatch leaves memory unchanged and still publishes the prior doubleword, so the instruction reports what memory held even when the swap does not happen.

A matching store invalidates the local reservation when the stored eight bytes overlap the reserved 64-byte granule. A mismatch stores nothing, so the reservation survives it.

Design point: this form is 48 bits long and the dispatcher advances `TPC` by `length_bits DIV 8`, which is 6 here, so the next instruction starts 6 bytes after `HL.CASD`. The `8`-byte data alignment and the `6`-byte instruction step are independent quantities. A fault leaves `TPC` at the start of the form, so recovery re-executes the same 6 bytes.

<!-- PTO-READER-BLOCK: scalar-hl-casd-constraints role=constraints -->
## Legality and faults

- Every field value is assigned: all `32` selector codes for `SrcL`, `SrcR`, `SrcD` and `RegDst`, and all `8` combinations of `aq`, `rl` and `far`. An unavailable `T` or `U` entry, or a failed fixed-bit decode, raises `Fault_IllegalInstruction` at `ReadPC()` before any architectural effect.
- The address must be a multiple of `8`; otherwise the read probe reports `Fault_DataAlignment` with the original address, and the write probe is never reached.
- A probe fault changes no memory, publishes no destination value, records no atomic event, changes no reservation and does not advance `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-casd-example role=example -->
## Replacing a doubleword

This example only shows one accepted spelling; the generated contract below remains authoritative.

With the doubleword at `SrcL` equal to `0x0123456789abcdef`, `SrcR` equal to `0x0123456789abcdef` and `SrcD` equal to `0xffffffffffffffff`, the comparison matches: all `8` bytes become `0xff`, `RegDst` receives `0x0123456789abcdef`, and the event reports `write_performed=true`.

With the same memory doubleword and `SrcR` equal to `0x0123456789abcdee`, the comparison fails: memory keeps `0x0123456789abcdef`, `RegDst` still receives `0x0123456789abcdef`, and the event reports `write_performed=false`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.casd [SrcL], SrcR, SrcD, ->Rd
hl.casd.aq [SrcL], SrcR, SrcD, ->Rd
hl.casd.rl [SrcL], SrcR, SrcD, ->Rd
hl.casd.f [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casd.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casd_48_fbb5c4256d30 | HL48 | 48 | 0x3000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casd_48_fbb5c4256d30 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casd_48_fbb5c4256d30 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casd_48_fbb5c4256d30 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casd_48_fbb5c4256d30 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casd_48_fbb5c4256d30 | SrcD | 5 | 0–31 | none | none | Reg5 desired doubleword source | Encoded zero supplies numeric zero as the desired value. |
| hl_casd_48_fbb5c4256d30 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casd_48_fbb5c4256d30 | SrcR | 5 | 0–31 | none | none | Reg5 expected doubleword source | Encoded zero supplies numeric zero as the expected value. |
| hl_casd_48_fbb5c4256d30 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casd_48_fbb5c4256d30 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casd_48_fbb5c4256d30 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected doubleword source |
| SrcD | Reg5 desired doubleword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractOperation_HL_CASD() => ScalarOperation
begin
    return ScalarOperation_HL_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractHandler_HL_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractHasFarField_HL_CASD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and atomic result.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword and compare it with SrcR truncated to 8 bytes.
- On equality, store SrcD truncated to 8 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casd [a0], a1, a2, ->a3
- hl.casd.aqrlf [t#1], u#1, a0, ->u
