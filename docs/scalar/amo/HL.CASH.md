<!-- GENERATED FROM: asl/scalar/amo/HL.CASH.asl -->
# HL.CASH

**Normative ASL source:** `asl/scalar/amo/HL.CASH.asl`

HL.CASH atomically compares and conditionally replaces one halfword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cash-purpose role=purpose -->
## What `HL.CASH` does

`HL.CASH` compares the 16-bit value at the address in `SrcL` with the low halfword of `SrcR`, and replaces it with the low halfword of `SrcD` only when the two are equal. Either way it publishes the value memory held, zero-extended to the 64-bit `PTO_XLEN` width, through the destination named by `RegDst`.

The form matches `0x1000600b000e` under the mask `0xf000707ff83f`. Its access width is `2` bytes, so the dispatcher calls `ExecuteDecodedCompareAndSwap` with a width of `2`, and both probes require an address that is a multiple of `2`.

<!-- PTO-READER-BLOCK: scalar-hl-cash-mechanism role=mechanism -->
## Read, compare, then maybe store

`CompareAndSwap` probes the address for read access, then for write access. Each probe tests `UInt(address) MOD 2` and reports `Fault_DataAlignment` for an odd address; when alignment passes, the bounds test can report `Fault_DataPage`. It then compares the two translated addresses and reports `Fault_DataPage` if they differ.

Only then does it load the two bytes, compare them with the normalized expected halfword, and store the desired halfword when the comparison succeeded. One atomic event records the order selected by `aq` and `rl` and a `write_performed` flag that is true only on the matching path.

Design point: `HL.CASH` is a 48-bit form and the dispatcher advances `TPC` by `length_bits DIV 8`, which is 6 here. Code that derives the next instruction address from this one must add 6, and a faulted `HL.CASH` leaves `TPC` unchanged, so a retry re-executes the same 6 bytes.

<!-- PTO-READER-BLOCK: scalar-hl-cash-inputs-outputs role=inputs-outputs -->
## Operands and the two bytes in memory

`SrcL`, `SrcR` and `SrcD` are Reg5 source selectors and `RegDst` is a destination selector: codes `0`..`23` name absolute GPRs, `24`..`27` read `T#1`..`T#4` and `28`..`31` read `U#1`..`U#4`, without removing the entry. As a destination, `RegDst` writes GPRs `1`..`23`, discards codes `0` and `24`..`29`, pushes `U` for code `30` and `T` for code `31`.

- `SrcL` supplies the atomic address of the halfword.
- `SrcR` supplies the expected halfword in its low `16` bits.
- `SrcD` supplies the desired halfword in its low `16` bits.
- `aq` and `rl` select the recorded order: `0` is relaxed, `aq` is acquire, `rl` is release, both is acquire-release. `far` is a profile routing hint.

Design point: the halfword is assembled from the bytes at `SrcL` and `SrcL + 1`, the first becoming bits `7:0` and the second bits `15:8`. Storing `0xabcd` therefore writes `0xcd` at `SrcL` and `0xab` at `SrcL + 1`, an order a byte-wise reader can observe.

<!-- PTO-READER-BLOCK: scalar-hl-cash-effects role=effects -->
## Effects and ordering

A matching `HL.CASH` writes exactly two bytes; a mismatch leaves memory unchanged. Both nonfaulting paths publish `ZeroExtend(old[15:0])`, so the published value always lies between `0` and `65535`, and the halfword `0xffff` is published as `0x000000000000ffff`.

A matching store invalidates the local reservation when the two stored bytes overlap the reserved 64-byte granule. A mismatch stores nothing and leaves the reservation as it was.

<!-- PTO-READER-BLOCK: scalar-hl-cash-constraints role=constraints -->
## Legality and faults

1. All `32` selector codes are assigned for the three sources and for `RegDst`, and all `8` combinations of `aq`, `rl` and `far` decode to this form.
2. An unavailable `T` or `U` entry, or a failed fixed-bit decode, raises `Fault_IllegalInstruction` at `ReadPC()` before any architectural effect.
3. The address must be a multiple of `2`; otherwise the read probe reports `Fault_DataAlignment` with the original address.
4. A probe fault publishes no destination value, records no atomic event, changes no reservation and does not advance `TPC`.

Design point: the comparison normalizes only `SrcR[15:0]`, so the upper `48` bits of the expected register never affect the outcome: `0xffffffffffff1234` and `0x0000000000001234` match the same memory halfword.

<!-- PTO-READER-BLOCK: scalar-hl-cash-example role=example -->
## Replacing a halfword

This example only shows one accepted spelling; the generated contract below remains authoritative.

With the halfword at `SrcL` equal to `0x1234`, the low halfword of `SrcR` equal to `0x1234` and the low halfword of `SrcD` equal to `0xabcd`, the comparison matches: `0xabcd` is stored, `0x0000000000001234` is published through `RegDst`, and the event reports `write_performed=true`.

With the same memory halfword and a low halfword of `SrcR` equal to `0x1235`, the comparison fails: memory keeps `0x1234`, the destination still receives `0x0000000000001234`, and the event reports `write_performed=false`. Every spelling decodes the `far` bit, so `hl.cash.aqrlf [a0], a1, a2, ->a3` reaches the same address and result as `hl.cash.aqrl [a0], a1, a2, ->a3`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cash [SrcL], SrcR, SrcD, ->Rd
hl.cash.aq [SrcL], SrcR, SrcD, ->Rd
hl.cash.rl [SrcL], SrcR, SrcD, ->Rd
hl.cash.f [SrcL], SrcR, SrcD, ->Rd
hl.cash.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.cash.aqf [SrcL], SrcR, SrcD, ->Rd
hl.cash.rlf [SrcL], SrcR, SrcD, ->Rd
hl.cash.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cash_48_eee12c324d97 | HL48 | 48 | 0x1000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cash_48_eee12c324d97 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_cash_48_eee12c324d97 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_cash_48_eee12c324d97 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cash_48_eee12c324d97 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_cash_48_eee12c324d97 | SrcD | 5 | 0–31 | none | none | Reg5 desired halfword source | Encoded zero supplies numeric zero as the desired value. |
| hl_cash_48_eee12c324d97 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_cash_48_eee12c324d97 | SrcR | 5 | 0–31 | none | none | Reg5 expected halfword source | Encoded zero supplies numeric zero as the expected value. |
| hl_cash_48_eee12c324d97 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_cash_48_eee12c324d97 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_cash_48_eee12c324d97 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected halfword source |
| SrcD | Reg5 desired halfword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASH.asl -->
```asl
readonly func InstructionContractOperation_HL_CASH() => ScalarOperation
begin
    return ScalarOperation_HL_CASH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASH.asl -->
```asl
readonly func InstructionContractHandler_HL_CASH() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractHasFarField_HL_CASH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASH()
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
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 2-byte halfword and compare it with SrcR truncated to 2 bytes.
- On equality, store SrcD truncated to 2 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.cash [a0], a1, a2, ->a3
- hl.cash.aqrlf [t#1], u#1, a0, ->u
