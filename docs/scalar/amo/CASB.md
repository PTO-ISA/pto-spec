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

`CASB` atomically compares the byte at `SrcL` with `SrcR`; equality stores `SrcD`, while both paths publish the prior 8-bit value.

<!-- PTO-READER-BLOCK: scalar-casb-mechanism role=mechanism -->
## Atomic mechanism

The ASL DOC contract selects `ScalarHandler_CompareAndSwap` with an access width of `1` byte.

Match and mismatch both emit one ordered atomic event; only the matching path marks a write as performed.

<!-- PTO-READER-BLOCK: scalar-casb-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 atomic address source; `SrcR` carries the Reg5 expected byte source; `SrcD` carries the Reg5 desired byte source; `RegDst` carries the Reg5 old-value destination; `aq` carries the acquire ordering bit; `rl` carries the release ordering bit.

`aq` and `rl` select relaxed, acquire, release, or acquire-release ordering.

<!-- PTO-READER-BLOCK: scalar-casb-effects role=effects -->
## Effects and ordering

After successful preflight, the old value is published even on comparison mismatch; memory changes only on equality.

A completed write invalidates an overlapping local 64-byte-line reservation, preserves a nonoverlapping reservation, and advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-casb-constraints role=constraints -->
## Legality and precise faults

Every byte address is naturally aligned. Alignment, translation, and permission checks precede architectural effects.

A failing preflight publishes no destination, memory event, reservation update, or retirement effect; the saved original `TPC` supports full reissue.

<!-- PTO-READER-BLOCK: scalar-casb-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

For a first reading, use `casb [SrcL], SrcR, SrcD, ->Rd` and then vary only the ordering or route modifiers described above.
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
