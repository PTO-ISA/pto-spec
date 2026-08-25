<!-- GENERATED FROM: asl/scalar/amo/CASW.asl -->
# CASW

**Normative ASL source:** `asl/scalar/amo/CASW.asl`

CASW atomically compares and conditionally replaces one word, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casw-purpose role=purpose -->
## What CASW does

`CASW` atomically reads one aligned 4-byte word, compares it with an expected word, conditionally stores a desired word, and publishes the prior memory value after either a nonfaulting match or mismatch.

<!-- PTO-READER-BLOCK: scalar-casw-mechanism role=mechanism -->
## Compare-and-swap mechanism

Before any effect, `CASW` snapshots the address source `SrcL`, expected source `SrcR`, and desired source `SrcD`, then completes alignment plus read/write translation and permission preflight for one translated location.

The comparison uses the low 4 bytes of `SrcR`. On equality, the instruction stores the low 4 bytes of `SrcD`; on mismatch, it preserves memory.

Both outcomes emit one ordered atomic event. A matching event records `write_performed=true`; a mismatching event records `write_performed=false` and acts as an ordered atomic read without a coherence write.

The prior 32-bit word is sign-extended to XLEN before destination publication.

<!-- PTO-READER-BLOCK: scalar-casw-inputs role=inputs-outputs -->
## Inputs, ordering, and output

- `SrcL`, `SrcR`, and `SrcD` accept every Reg5 source selector, including non-consuming T/U sources; `RegDst` accepts every Reg5 destination or discard selector.
- `aq=0,rl=0` selects relaxed ordering; `aq=1,rl=0` acquire; `aq=0,rl=1` release; and `aq=1,rl=1` acquire-release.

The short form has no far-address field and always uses the default flat-address route.

<!-- PTO-READER-BLOCK: scalar-casw-effects role=effects -->
## Architectural effects

On a match, `CASW` writes the desired low word, emits one read/write atomic event, and invalidates an overlapping local 64-byte-line reservation.

On a mismatch, it leaves memory and the reservation unchanged while still emitting the ordered atomic read event.

Every nonfaulting outcome publishes the sign-extended prior word and advances `TPC` by `4` bytes; a fault publishes no destination.

<!-- PTO-READER-BLOCK: scalar-casw-constraints role=constraints -->
## Alignment and precise faults

The effective address must be aligned to `4` bytes. Alignment, read access, write access, and translated-address equality are checked before memory, destination, event, reservation, or `TPC` effects.

On fault, trap entry preserves the original `TPC`; recovery restores it so the complete instruction can be reissued without retained progress.

<!-- PTO-READER-BLOCK: scalar-casw-example role=example -->
## Non-normative walkthrough

This walkthrough illustrates the current contract; it does not replace the atomic operation.

Suppose memory holds the word `0x80000001`, the expected word matches, and the desired XLEN value is `0x1122334455667788`. `CASW.aqrl` stores `0x55667788`, publishes the prior word sign-extended to XLEN, emits one acquire-release atomic event with `write_performed=true`, and invalidates an overlapping reservation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casw [SrcL], SrcR, SrcD, ->Rd
casw.aq [SrcL], SrcR, SrcD, ->Rd
casw.rl [SrcL], SrcR, SrcD, ->Rd
casw.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casw_32_cb29e4287223 | L32 | 32 | 0x0000201b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casw_32_cb29e4287223 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casw_32_cb29e4287223 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casw_32_cb29e4287223 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casw_32_cb29e4287223 | SrcD | 5 | 0–31 | none | none | Reg5 desired word source | Encoded zero supplies numeric zero as the desired value. |
| casw_32_cb29e4287223 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casw_32_cb29e4287223 | SrcR | 5 | 0–31 | none | none | Reg5 expected word source | Encoded zero supplies numeric zero as the expected value. |
| casw_32_cb29e4287223 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casw_32_cb29e4287223 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected word source |
| SrcD | Reg5 desired word source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASW.asl -->
```asl
readonly func InstructionContractOperation_CASW() => ScalarOperation
begin
    return ScalarOperation_CASW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASW.asl -->
```asl
readonly func InstructionContractHandler_CASW() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractHasFarField_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_CASW()
    => boolean
begin
    return TRUE;
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
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word and compare it with SrcR truncated to 4 bytes.
- On equality, store SrcD truncated to 4 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casw [a0], a1, a2, ->a3
- casw.aqrl [t#1], u#1, a0, ->u
