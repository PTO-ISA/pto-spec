<!-- GENERATED FROM: asl/scalar/amo/CASB.asl -->
# CASB

**Normative ASL source:** `asl/scalar/amo/CASB.asl`

CASB atomically compares and conditionally replaces one byte, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casb-purpose role=purpose -->
## What CASB does

`CASB` compares the byte at the address named by `SrcL` with the low byte of `SrcR`, and writes the low byte of `SrcD` back to that address when the two bytes are equal. A mismatch leaves memory untouched.

Either nonfaulting outcome publishes the byte that memory held before the instruction into `RegDst`. `CASB` is one 32-bit encoded form, and a successful execution advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-casb-mechanism role=mechanism -->
## How the byte compare-and-swap runs

The dispatch reads `SrcL`, `SrcR`, and `SrcD`, then calls the shared `CompareAndSwap` helper with an access size of `1` byte. The helper probes the address for read access, probes it again for write access, and requires one translated address from both probes.

It loads the byte at that translated address and compares it with the expected value. Equality stores the desired byte; inequality stores nothing. Either way it records one atomic event whose `write_performed` flag is the comparison result.

Design point: `NormalizeAtomicUnsigned` extends only `value[7:0]`, so bits `8` to `63` of `SrcR` never reach the comparison. An expected value of `0xffffffffffffff7f` still matches a memory byte of `0x7f`, so an unmasked machine word in `SrcR` behaves as written.

Design point: the read probe demands `1`-byte alignment, and `ProbeDataAccess` reports `Fault_DataAlignment` only when `UInt(address) MOD 1` is nonzero. That remainder is always zero, so the alignment fault is unreachable for `CASB`; the first address fault it can raise is the `Fault_DataPage` permission and bounds result.

<!-- PTO-READER-BLOCK: scalar-casb-inputs-outputs role=inputs-outputs -->
## Encoded fields and selectors

The form encodes `SrcL` at instruction bit `15`, `SrcR` at bit `20`, `SrcD` at bit `27`, and `RegDst` at bit `7`, each `5` bits wide, plus `rl` at bit `25` and `aq` at bit `26`.

`aq=0,rl=0` records relaxed ordering, `aq=1,rl=0` acquire, `aq=0,rl=1` release, and `aq=1,rl=1` acquire-release, for a match and for a mismatch alike.

`SrcL`, `SrcR`, and `SrcD` accept every Reg5 source selector, and reading a T or U entry leaves it in place on the queue. `RegDst` accepts every Reg5 destination selector.

Design point: the 32-bit form carries no `far` bit, so the encoding cannot ask for a routing hint. An absent field decodes as zero, and `AtomicAddress` returns its argument unchanged, so the byte named by `SrcL` is the byte the instruction touches.

<!-- PTO-READER-BLOCK: scalar-casb-effects role=effects -->
## What the instruction changes

A match stores the low byte of `SrcD` and records one atomic event with `write_performed=true`; a mismatch records one atomic event with `write_performed=false` and leaves memory alone.

`RegDst` receives `ZeroExtend{PTO_XLEN}(old_value[7:0])` on both nonfaulting paths, so the prior byte is always reported. A match also clears the reservation when the stored byte overlaps the reserved 64-byte granule.

Design point: a value zero-extended from `8` bits can never be negative. A stored byte of `0x80` publishes `0x0000000000000080`, not `0xffffffffffffff80`, so software that needs the signed byte must sign-extend bit `7` itself.

A successful execution advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-casb-constraints role=constraints -->
## Alignment, faults, and reissue

`CASB` completes the read probe, the write probe, and the translated-address equality test before touching memory, so a failing access leaves no partial effect.

A reported fault carries the original `SrcL` address. After a fault the helper returns before the load: no atomic event, no reservation change and no destination write, because the dispatch publishes only while `_LastFault` is `Fault_None`.

`TPC` does not advance, so the whole compare-and-swap can be reissued. A decode failure, or an unavailable `T#1` to `T#4` or `U#1` to `U#4` source, raises `Fault_IllegalInstruction` before the handler runs.

<!-- PTO-READER-BLOCK: scalar-casb-example role=example -->
## A byte that matches

This example only shows one accepted spelling; the generated contract below remains authoritative.

Suppose the addressed byte holds `0x7f`, `SrcR` supplies `0x7f` in its low byte, and `SrcD` supplies `0x80`. The comparison succeeds: `CASB` stores `0x80`, records one atomic event with `write_performed=true`, and publishes `0x000000000000007f` in `RegDst`.

With `0x00` in the low byte of `SrcR` instead, memory keeps `0x7f`, the event records `write_performed=false`, and `RegDst` still receives `0x000000000000007f`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casb [SrcL], SrcR, SrcD, ->Rd
casb.aq [SrcL], SrcR, SrcD, ->Rd
casb.rl [SrcL], SrcR, SrcD, ->Rd
casb.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casb_32_7e529b871832 | L32 | 32 | 0x0000001b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casb_32_7e529b871832 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casb_32_7e529b871832 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casb_32_7e529b871832 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casb_32_7e529b871832 | SrcD | 5 | 0–31 | none | none | Reg5 desired byte source | Encoded zero supplies numeric zero as the desired value. |
| casb_32_7e529b871832 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casb_32_7e529b871832 | SrcR | 5 | 0–31 | none | none | Reg5 expected byte source | Encoded zero supplies numeric zero as the expected value. |
| casb_32_7e529b871832 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casb_32_7e529b871832 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected byte source |
| SrcD | Reg5 desired byte source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractOperation_CASB() => ScalarOperation
begin
    return ScalarOperation_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractHandler_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractHasFarField_CASB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_CASB()
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
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte and compare it with SrcR truncated to 1 bytes.
- On equality, store SrcD truncated to 1 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casb [a0], a1, a2, ->a3
- casb.aqrl [t#1], u#1, a0, ->u
