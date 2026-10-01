<!-- GENERATED FROM: asl/scalar/amo/HL.CASB.asl -->
# HL.CASB

**Normative ASL source:** `asl/scalar/amo/HL.CASB.asl`

HL.CASB atomically compares and conditionally replaces one byte, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-casb-purpose role=purpose -->
## What `HL.CASB` does

`HL.CASB` is a 48-bit scalar atomic form that swaps one byte under a comparison. It compares the byte at the address in `SrcL` with the low byte of `SrcR`, and writes the low byte of `SrcD` there only on equality. Either way it publishes the byte it read, zero-extended to the 64-bit `PTO_XLEN` width, through `RegDst`.

The form is selected by the match `0x0000600b000e` under the mask `0xf000707ff83f`. Its access width is fixed at `1` byte and its handler is `ScalarHandler_CompareAndSwap`.

<!-- PTO-READER-BLOCK: scalar-hl-casb-mechanism role=mechanism -->
## The order of the byte operation

The dispatcher decodes the Reg5 fields, reads the `far` bit, and enters `CompareAndSwap` at a width of `1` byte:

1. `ProbeDataAccess(address, 1, 1, FALSE)` checks alignment, then read permission.
2. `ProbeDataAccess(address, 1, 1, TRUE)` checks alignment, then write permission.
3. A difference between the two translated addresses raises `Fault_DataPage`.
4. `LoadTranslatedUnsigned` reads the one addressed byte.
5. The byte is compared with `NormalizeAtomicUnsigned(SrcR, 1)`, the zero-extended `SrcR[7:0]`.
6. On equality `StoreTranslated` writes `SrcD[7:0]`; one atomic event records the selected order and `write_performed`, and the loaded byte is returned.

Design point: the three sources are read before `CompareAndSwap` is entered, and the destination is written only after it returns, so a `RegDst` that aliases `SrcR` or `SrcD` cannot disturb the comparison.

<!-- PTO-READER-BLOCK: scalar-hl-casb-inputs-outputs role=inputs-outputs -->
## Fields, selectors and the routing bit

All four register fields are Reg5 selectors: codes `0`..`23` name absolute GPRs, `24`..`27` read `T#1`..`T#4` and `28`..`31` read `U#1`..`U#4`, without removing the entry. As a destination, `RegDst` writes GPRs `1`..`23`, discards codes `0` and `24`..`29`, pushes onto `U` for code `30` and onto `T` for code `31`.

| Field | Lsb | Width | Role in this instruction |
| --- | ---: | ---: | --- |
| `SrcD` | 6 | 5 | desired byte source |
| `RegDst` | 23 | 5 | prior-value destination |
| `SrcL` | 31 | 5 | atomic address source |
| `SrcR` | 36 | 5 | expected byte source |
| `rl` | 41 | 1 | release ordering bit |
| `aq` | 42 | 1 | acquire ordering bit |
| `far` | 43 | 1 | profile routing hint |

Design point: `far` is decoded from instruction bit 43 and handed to `AtomicAddress`, which returns its argument unchanged. In the reference profile `hl.casb.f [a0], a1, a2, ->a3` and `hl.casb [a0], a1, a2, ->a3` read and write the same address and publish the same value; the `.f` spelling changes only the encoded routing hint.

<!-- PTO-READER-BLOCK: scalar-hl-casb-effects role=effects -->
## What changes

On a match the addressed byte receives `SrcD[7:0]`; a mismatch leaves memory alone. Both paths offer the loaded byte to `RegDst`, zero-extended to 64 bits, so the result is never negative: `0xff` is published as `0x00000000000000ff`.

A completed match also invalidates the local reservation when the reserved 64-byte granule overlaps the stored byte; a mismatch stores nothing and cannot invalidate it.

Design point: this form is encoded in 48 bits and the dispatcher advances `TPC` by `length_bits DIV 8`, so a completed `HL.CASB` moves the program counter on by 6 bytes. The advance happens only after a fault-free handler, so a fault leaves `TPC` at the start of the form and recovery re-executes the same 6 bytes.

<!-- PTO-READER-BLOCK: scalar-hl-casb-constraints role=constraints -->
## Where it is rejected

- Every field value is assigned: all `32` selector codes for `SrcL`, `SrcR`, `SrcD` and `RegDst`, and all `8` combinations of `aq`, `rl` and `far`.
- An unavailable selected `T` or `U` queue entry makes the operands illegal, and an undecodable fixed-bit pattern fails the decode; both raise `Fault_IllegalInstruction` at `ReadPC()` before any architectural effect.
- Every byte address is naturally aligned, so the alignment test cannot report `Fault_DataAlignment` here; the bounds test can still report `Fault_DataPage`.
- A fault offers no destination value, records no atomic event, changes no reservation and does not advance `TPC`.

Design point: only the low byte of the expected value is normalized, so `SrcR` values that differ above bit `7` compare equal to the same memory byte; two encodings that share the low byte `0x7f` behave identically.

<!-- PTO-READER-BLOCK: scalar-hl-casb-example role=example -->
## A byte that matches, and one that does not

This example only shows one accepted spelling; the generated contract below remains authoritative.

Suppose the addressed byte holds `0x7f`, the low byte of `SrcR` is `0x7f`, and the low byte of `SrcD` is `0x80`. The comparison matches, the byte becomes `0x80`, and the destination receives `0x000000000000007f`. The recorded atomic event reports `write_performed=true`.

With the same memory byte `0x7f` and a low byte of `SrcR` equal to `0x7e`, the comparison fails: nothing is written, the destination still receives `0x000000000000007f`, and the event reports `write_performed=false`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.casb [SrcL], SrcR, SrcD, ->Rd
hl.casb.aq [SrcL], SrcR, SrcD, ->Rd
hl.casb.rl [SrcL], SrcR, SrcD, ->Rd
hl.casb.f [SrcL], SrcR, SrcD, ->Rd
hl.casb.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casb.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casb.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casb.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casb_48_21fb578617a8 | HL48 | 48 | 0x0000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casb_48_21fb578617a8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casb_48_21fb578617a8 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casb_48_21fb578617a8 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casb_48_21fb578617a8 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casb_48_21fb578617a8 | SrcD | 5 | 0–31 | none | none | Reg5 desired byte source | Encoded zero supplies numeric zero as the desired value. |
| hl_casb_48_21fb578617a8 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casb_48_21fb578617a8 | SrcR | 5 | 0–31 | none | none | Reg5 expected byte source | Encoded zero supplies numeric zero as the expected value. |
| hl_casb_48_21fb578617a8 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casb_48_21fb578617a8 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casb_48_21fb578617a8 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected byte source |
| SrcD | Reg5 desired byte source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractOperation_HL_CASB() => ScalarOperation
begin
    return ScalarOperation_HL_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractHandler_HL_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractHasFarField_HL_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASB()
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
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte and compare it with SrcR truncated to 1 bytes.
- On equality, store SrcD truncated to 1 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casb [a0], a1, a2, ->a3
- hl.casb.aqrlf [t#1], u#1, a0, ->u
