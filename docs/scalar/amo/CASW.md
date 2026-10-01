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

`CASW` atomically reads the 4-byte word at the address named by `SrcL`, compares it with the low `4` bytes of `SrcR`, and stores the low `4` bytes of `SrcD` there when the comparison succeeds.

A nonfaulting match and a nonfaulting mismatch both publish the prior word through `RegDst`. `CASW` is a 32-bit form whose successful execution advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-casw-mechanism role=mechanism -->
## The compare-and-swap sequence

`ExecuteDecodedCompareAndSwap` reads `SrcL`, `SrcR`, and `SrcD` before calling `CompareAndSwap` with the access size `4`, so the operands are snapshotted before the first probe. The helper probes the address for read access, probes it again for write access, and requires one translated address from both probes.

The helper loads the word at that translated address and compares it with the normalized expected value. Equality calls the store, inequality skips it, and either way one atomic event is recorded with the loaded word, the normalized desired value, and `write_performed` set to the comparison result.

Design point: `NormalizeAtomicReturn` applies `SignExtend{PTO_XLEN}(value[31:0])` at this width, so a memory word of `0x80000001` reaches `RegDst` as `0xffffffff80000001`. `CASW` can publish a negative XLEN value; `CASB` and `CASH` cannot.

Design point: the comparison uses `NormalizeAtomicUnsigned(SrcR, 4)`, which zero-extends from `32` bits, so the upper `32` bits of `SrcR` are ignored. A memory word of `0x00000001` matches `SrcR = 0xdeadbeef00000001`.

<!-- PTO-READER-BLOCK: scalar-casw-inputs role=inputs-outputs -->
## Operands, ordering, and the destination

- `SrcL` supplies the atomic address, `SrcR` the expected word, and `SrcD` the desired word; all three accept the absolute GPR, T, and U selectors, and reading a queue entry does not consume it.
- `RegDst` selects where the prior word goes: codes `1` to `23` write that GPR, code `0` and codes `24` to `29` discard it, and codes `30` and `31` push it onto the U queue or the T queue.

`aq=0,rl=0` records relaxed ordering, `aq=1,rl=0` acquire, `aq=0,rl=1` release, and `aq=1,rl=1` acquire-release, for match and mismatch alike.

Design point: the 32-bit form has no `far` bit, so the encoding offers only the default flat-address route. An absent field decodes as zero and `AtomicAddress` returns its argument unchanged, so no route choice here can move the access.

<!-- PTO-READER-BLOCK: scalar-casw-effects role=effects -->
## Architectural effects

A match writes the desired low word to memory and records one atomic event with `write_performed=true`; a mismatch records one atomic event with `write_performed=false` and leaves memory unchanged.

Design point: the destination write is driven by the loaded word and is skipped only while a fault is set, so an instruction that fails to replace the word still reports what memory held, and a retry can take that value from `RegDst` without a second load.

Design point: the recorded event carries `NormalizeAtomicUnsigned(desired, 4)` rather than the XLEN register value, so its new value is the low `32` bits that the store actually writes.

Both nonfaulting outcomes advance `TPC` by `4` bytes; a match also clears the reservation when the stored word overlaps the reserved 64-byte granule.

<!-- PTO-READER-BLOCK: scalar-casw-constraints role=constraints -->
## Alignment, access checks, and fault order

The address must be a multiple of `4`. `ProbeDataAccess` tests `UInt(address) MOD 4` before translation and before the permission check, and reports `Fault_DataAlignment` when the remainder is nonzero.

The read probe runs first, so its alignment or `Fault_DataPage` result is reported first. The write probe follows with the same size and alignment, and only then must the two translated addresses agree, or `Fault_DataPage` is raised.

Design point: these checks finish before the load, so a faulting `CASW` stores nothing, records no atomic event, clears no reservation, writes no destination, and leaves `TPC` on the same instruction. The reference model translates an address to itself, so that comparison cannot fail there, while the bounds check can.

A reported fault carries the original `SrcL` address. A decode failure, or an unavailable selected `T#1` to `T#4` or `U#1` to `U#4` source, raises `Fault_IllegalInstruction` before the handler runs.

<!-- PTO-READER-BLOCK: scalar-casw-example role=example -->
## A word that matches, and one that does not

This walkthrough illustrates the current contract; it does not replace the atomic operation.

Suppose the addressed word holds `0x80000001`, `SrcR` holds `0x80000001` in its low `4` bytes, and `SrcD` holds `0x55667788`. The comparison succeeds, so `CASW` stores `0x55667788`, publishes `0xffffffff80000001` in `RegDst`, and records one atomic event with `write_performed=true`.

Suppose the same word `0x80000001` is in memory but `SrcR` holds `0x00000002` in its low `4` bytes. The comparison fails, memory keeps `0x80000001`, the recorded event has `write_performed=false`, and `RegDst` still receives `0xffffffff80000001`.
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
