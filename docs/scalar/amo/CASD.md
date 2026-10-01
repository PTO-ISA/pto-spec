<!-- GENERATED FROM: asl/scalar/amo/CASD.asl -->
# CASD

**Normative ASL source:** `asl/scalar/amo/CASD.asl`

CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casd-purpose role=purpose -->
## What CASD does

`CASD` is the 8-byte compare-and-swap: it reads the doubleword at the address named by `SrcL`, compares all `64` bits with `SrcR`, and stores `SrcD` at that address only when the two doublewords are identical.

The prior doubleword reaches `RegDst` on a match and on a mismatch. `CASD` is a 32-bit encoded form, and a successful execution advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-casd-mechanism role=mechanism -->
## Comparing a whole doubleword

The dispatch calls `CompareAndSwap` with `size_bytes = 8`, so the read probe and the write probe each cover `8` bytes, and both fail the alignment test unless the address is a multiple of `8`.

`LoadTranslatedUnsigned` fills `64` bits from memory, and `NormalizeAtomicUnsigned` and `NormalizeAtomicReturn` both return an `8`-byte value unchanged, so no extension or truncation step stands between the loaded doubleword and the published one.

Design point: size `8` is the identity case in both normalizers, so every bit of `SrcR` takes part in the comparison and every bit of `SrcD` is available to the store. An expected value whose upper half is wrong fails to match, unlike the narrower forms, which discard those bits before comparing.

Design point: `StoreTranslated` writes the low `8` bytes of `SrcD` one byte at a time, and the atomic event carries `NormalizeAtomicUnsigned(desired, 8)`, which is `SrcD` unchanged. The new value in the event and the bytes the store writes are therefore the same value.

<!-- PTO-READER-BLOCK: scalar-casd-inputs-outputs role=inputs-outputs -->
## Fields, ordering, and selectors

The form encodes `SrcL` at instruction bit `15`, `SrcR` at bit `20`, `SrcD` at bit `27`, and `RegDst` at bit `7`, each `5` bits wide, plus `rl` at bit `25` and `aq` at bit `26`.

The four settings are relaxed (`aq=0,rl=0`), acquire (`aq=1,rl=0`), release (`aq=0,rl=1`), and acquire-release (`aq=1,rl=1`), and the recorded atomic event carries the same setting for a match and for a mismatch.

`SrcL`, `SrcR`, and `SrcD` accept every Reg5 source selector, including the T and U selectors, which are read without consuming a queue entry. `RegDst` accepts every Reg5 destination selector.

Design point: an encoded zero source reads the architectural zero register, so `casd` with `SrcR` and `SrcD` both encoded as zero matches only an all-zero doubleword, and stores zero when it matches.

<!-- PTO-READER-BLOCK: scalar-casd-effects role=effects -->
## Architectural effects

A match stores `SrcD` at the address and records one atomic event with `write_performed=true`; a mismatch stores nothing and records one atomic event with `write_performed=false`.

Design point: this is the only width in the group whose published value is neither zero-extended nor sign-extended. `RegDst` receives the `64` bits that memory held, so software can compare the destination directly against a full-width expected value.

Design point: the event is recorded on both paths, and its new value is the desired doubleword even when `write_performed=false`, so a reader of the event can see what was proposed as well as what memory held.

Both nonfaulting outcomes advance `TPC` by `4` bytes, and a match also clears the reservation when the addressed `8` bytes overlap the reserved 64-byte granule.

<!-- PTO-READER-BLOCK: scalar-casd-constraints role=constraints -->
## Alignment, access, and fault order

The address must be a multiple of `8`. `ProbeDataAccess` performs that test before translation and before the permission check that reports `Fault_DataPage`.

The read probe is evaluated before the write probe, and the two translated addresses must agree before any byte is loaded.

On a fault the helper returns immediately: no load, no store, no atomic event, no reservation change, no destination write, and no `TPC` advance, so the compare-and-swap can be reissued whole.

A reported fault carries the original `SrcL` address. A decode failure, or an unavailable selected `T#1` to `T#4` or `U#1` to `U#4` source, raises `Fault_IllegalInstruction` before the handler runs.

<!-- PTO-READER-BLOCK: scalar-casd-example role=example -->
## A doubleword that matches

This example only shows one accepted spelling; the generated contract below remains authoritative.

```asm
casd [a0], a1, a2, ->a3
```

Suppose the addressed doubleword holds `0x0123456789abcdef`, `SrcR` holds `0x0123456789abcdef`, and `SrcD` holds `0xffffffffffffffff`. All `64` bits compare equal, so `CASD` stores `0xffffffffffffffff`, publishes `0x0123456789abcdef` in `RegDst`, and records one atomic event with `write_performed=true`.

With `0x0123456789abcdee` in `SrcR` instead, the comparison fails on the last bit: memory keeps `0x0123456789abcdef`, the recorded event has `write_performed=false`, and `RegDst` still receives `0x0123456789abcdef`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casd [SrcL], SrcR, SrcD, ->Rd
casd.aq [SrcL], SrcR, SrcD, ->Rd
casd.rl [SrcL], SrcR, SrcD, ->Rd
casd.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casd_32_5852c57277a6 | L32 | 32 | 0x0000301b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casd_32_5852c57277a6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casd_32_5852c57277a6 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casd_32_5852c57277a6 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casd_32_5852c57277a6 | SrcD | 5 | 0–31 | none | none | Reg5 desired doubleword source | Encoded zero supplies numeric zero as the desired value. |
| casd_32_5852c57277a6 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casd_32_5852c57277a6 | SrcR | 5 | 0–31 | none | none | Reg5 expected doubleword source | Encoded zero supplies numeric zero as the expected value. |
| casd_32_5852c57277a6 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casd_32_5852c57277a6 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected doubleword source |
| SrcD | Reg5 desired doubleword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASD.asl -->
```asl
readonly func InstructionContractOperation_CASD() => ScalarOperation
begin
    return ScalarOperation_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASD.asl -->
```asl
readonly func InstructionContractHandler_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractHasFarField_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_CASD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- The short form has no far field and therefore uses the default flat-address route.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq and rl combinations are assigned; the short form has implicit far zero.
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword and compare it with SrcR truncated to 8 bytes.
- On equality, store SrcD truncated to 8 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casd [a0], a1, a2, ->a3
- casd.aqrl [t#1], u#1, a0, ->u
