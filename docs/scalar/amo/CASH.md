<!-- GENERATED FROM: asl/scalar/amo/CASH.asl -->
# CASH

**Normative ASL source:** `asl/scalar/amo/CASH.asl`

CASH atomically compares and conditionally replaces one halfword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cash-purpose role=purpose -->
## What CASH does

`CASH` compares the 2-byte halfword at the address named by `SrcL` with the low `2` bytes of `SrcR`, and stores the low `2` bytes of `SrcD` at that address only when the two halfwords are equal.

The prior halfword reaches `RegDst` on a match and on a mismatch, zero-extended to XLEN. `CASH` is a 32-bit encoded form, and a successful execution advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-cash-mechanism role=mechanism -->
## Reading, comparing, and conditionally storing

The dispatch passes `SrcL`, `SrcR`, and `SrcD` and the access size `2` to the shared `CompareAndSwap` helper. The helper runs a read probe and then a write probe over the same 2 bytes, and it refuses to continue when the two probes translate to different addresses.

`LoadTranslatedUnsigned` builds the loaded value from `Zeros{PTO_XLEN}` and fills bits `15:0` from memory, so the memory side of the comparison is already zero-extended. The expected side is normalized the same way, and the store writes the low `2` bytes of `SrcD`.

Design point: both sides of the comparison are zero-extended from `16` bits, so bits `16` to `63` of `SrcR` are ignored. `SrcR` holding `0xffffffffffff1234` still matches a memory halfword of `0x1234`, because the upper bits take no part in the comparison.

Design point: the write probe repeats the `2`-byte size and therefore the same alignment test on the same address, so an odd address raises `Fault_DataAlignment` in the read probe before any byte is loaded or stored.

<!-- PTO-READER-BLOCK: scalar-cash-inputs-outputs role=inputs-outputs -->
## Fields, ordering, and selectors

| Field | Low instruction bit | Width | Role |
| --- | --- | --- | --- |
| `SrcL` | `15` | `5` | atomic address source |
| `SrcR` | `20` | `5` | expected halfword source |
| `SrcD` | `27` | `5` | desired halfword source |
| `RegDst` | `7` | `5` | prior halfword destination |
| `rl` | `25` | `1` | release ordering bit |
| `aq` | `26` | `1` | acquire ordering bit |

`aq=0,rl=0` selects relaxed ordering, `aq=1,rl=0` acquire, `aq=0,rl=1` release, and `aq=1,rl=1` acquire-release. The recorded event carries the same setting for a match and for a mismatch.

Design point: source selectors `24` to `27` read `T#1` to `T#4` and selectors `28` to `31` read `U#1` to `U#4` without consuming the entry, so a form may take its expected halfword from the queue and leave that entry in place for the next instruction.

<!-- PTO-READER-BLOCK: scalar-cash-effects role=effects -->
## What the instruction changes

A matching `CASH` stores the low `2` bytes of `SrcD`; a mismatching `CASH` stores nothing. One atomic event is recorded either way, with `write_performed` equal to the comparison result.

`RegDst` receives `ZeroExtend{PTO_XLEN}(old_value[15:0])` after any nonfaulting run, so a memory halfword of `0xabcd` is published as `0x000000000000abcd`.

Design point: the register result and the memory result are normalized independently. `NormalizeAtomicReturn` widens the `16`-bit value for `RegDst`, while `StoreTranslated` writes `desired[(byte_index * 8) +: 8]` for each of the `2` bytes, so the published register value is `64` bits wide even though memory keeps only `2` bytes.

A match also clears the reservation when the stored `2` bytes overlap the reserved 64-byte granule, and a successful execution advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-cash-constraints role=constraints -->
## Alignment and the order of faults

`CASH` requires an even address: `ProbeDataAccess` reports `Fault_DataAlignment` when `UInt(address) MOD 2` is nonzero, and that test runs before translation and before the permission check.

The read probe is evaluated first, so its fault is reported first. If it passes, the write probe repeats the size and alignment test, and the two translated addresses must then be equal or `Fault_DataPage` is raised.

A fault carries the original `SrcL` address. The helper returns before the load, so nothing is stored, no atomic event is recorded, no reservation changes, and `RegDst` keeps its former value.

`TPC` stays on the faulting instruction, so the compare-and-swap can be reissued whole. A decode failure or an unavailable selected `T#1` to `T#4` or `U#1` to `U#4` source raises `Fault_IllegalInstruction` before the handler runs.

<!-- PTO-READER-BLOCK: scalar-cash-example role=example -->
## A halfword that matches

This example only shows one accepted spelling; the generated contract below remains authoritative.

Take a memory halfword of `0x1234`, `SrcR` holding `0x1234` in its low `2` bytes, and `SrcD` holding `0xabcd`. The comparison succeeds, so `CASH` stores `0xabcd` at the address, publishes `0x0000000000001234` in `RegDst`, and records one atomic event with `write_performed=true`.

With `0x1235` in the low `2` bytes of `SrcR` instead, the comparison fails: memory keeps `0x1234`, the recorded event has `write_performed=false`, and `RegDst` still receives `0x0000000000001234`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cash [SrcL], SrcR, SrcD, ->Rd
cash.aq [SrcL], SrcR, SrcD, ->Rd
cash.rl [SrcL], SrcR, SrcD, ->Rd
cash.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cash_32_cb1315ff6cb5 | L32 | 32 | 0x0000101b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cash_32_cb1315ff6cb5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| cash_32_cb1315ff6cb5 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cash_32_cb1315ff6cb5 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| cash_32_cb1315ff6cb5 | SrcD | 5 | 0–31 | none | none | Reg5 desired halfword source | Encoded zero supplies numeric zero as the desired value. |
| cash_32_cb1315ff6cb5 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| cash_32_cb1315ff6cb5 | SrcR | 5 | 0–31 | none | none | Reg5 expected halfword source | Encoded zero supplies numeric zero as the expected value. |
| cash_32_cb1315ff6cb5 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| cash_32_cb1315ff6cb5 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected halfword source |
| SrcD | Reg5 desired halfword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASH.asl -->
```asl
readonly func InstructionContractOperation_CASH() => ScalarOperation
begin
    return ScalarOperation_CASH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASH.asl -->
```asl
readonly func InstructionContractHandler_CASH() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractHasFarField_CASH()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_CASH()
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
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 2-byte halfword and compare it with SrcR truncated to 2 bytes.
- On equality, store SrcD truncated to 2 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- cash [a0], a1, a2, ->a3
- cash.aqrl [t#1], u#1, a0, ->u
