<!-- GENERATED FROM: asl/scalar/amo/LR.H.asl -->
# LR.H

**Normative ASL source:** `asl/scalar/amo/LR.H.asl`

LR.H loads one halfword, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-H}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-h-purpose role=purpose -->
## What LR.H does

`LR.H` loads one halfword from the address in `SrcL`, publishes it through `RegDst`, and establishes a reservation on the loaded location. Successful execution advances `TPC` by `4` bytes.

Design point: the two loaded bytes land in the low half of the destination and the upper `48` bits are cleared, so the halfword `0x8000` is never published as a negative XLEN value.

<!-- PTO-READER-BLOCK: scalar-lr-h-mechanism role=mechanism -->
## How the halfword load is ordered

Dispatch routes the form to `ExecuteDecodedLoadReserved(instruction, form, 2)`. That helper snapshots `SrcL`, converts `aq` and `rl` into a memory order with `ScalarDecodedMemoryOrder`, and calls `LoadReserved(address, 2, order)`; on a fault-free return it writes `NormalizeAtomicReturn(old_value, 2)` to `RegDst`.

Inside `LoadReserved`, `LoadWithOrder` performs the access: `ProbeDataAccess(address, 2, 2, FALSE)` for alignment, translation and read permission, then a two-byte little-endian read, then one load event at the translated address. The reservation is written only while the fault flag stays clear.

Design point: `ProbeDataAccess` tests `UInt(address) MOD alignment_bytes` before it calls `TranslateDataAddress`, so an odd address reports `Fault_DataAlignment` here and the bounds check is never consulted for that address.

<!-- PTO-READER-BLOCK: scalar-lr-h-inputs-outputs role=inputs-outputs -->
## Fields, sources and destinations

`SrcL@15:5` supplies the load address, `RegDst@7:5` receives the published halfword, and `SrcZero@20:5`, `rl@25:1`, `aq@26:1` and `far@27:1` complete the encoding; each entry names the low instruction bit and the field width.

`SrcL` accepts every Reg5 source selector: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, and reading a queue entry does not pop it. `RegDst` accepts every destination selector: `1..23` write that GPR, `0` and `24..29` discard, `30` pushes `U`, and `31` pushes `T`. `aq` and `rl` select the load order, and `far` is a routing hint that leaves the address unchanged.

Design point: no code path reads `SrcZero`, so the `32` bit patterns of that field select one instruction, and the field has no assembly spelling; `LR.H` cannot be given an operand through it.

<!-- PTO-READER-BLOCK: scalar-lr-h-effects role=effects -->
## Effects and ordering

A successful load reads one little-endian halfword, records one load event at the translated address with the order selected by `aq` and `rl` while memory-event capture is enabled, publishes the loaded `16` bits zero-extended through `RegDst`, and updates the local reservation to the original address with the width `2`. `TPC` then advances by `4` bytes.

Design point: the publication rule follows the access width, not the destination register width. The halfword `0x8000` is published as `0x0000000000008000`, while `LR.W` publishes `0xffffffff80000000` for the word `0x80000000`, so the same top bit set gives a zero-extended value at this width and a negative value at word width.

<!-- PTO-READER-BLOCK: scalar-lr-h-constraints role=constraints -->
## Legality and precise faults

The access preflight runs before any effect: alignment to `2` bytes, then translation, then read permission and bounds. A rejected address reports the original architectural address, which `TranslateDataAddress` returns unchanged in the reference model.

After a fault nothing is published, no load event is recorded, an older reservation is preserved, and `TPC` stays on the instruction. A decode failure or an unavailable selected T/U source raises `Fault_IllegalInstruction` earlier.

Design point: an odd address fails the alignment test, so `LR.H` reports `Fault_DataAlignment` for it and never reaches the bounds check, while the next byte address above it is even and does reach that check.

<!-- PTO-READER-BLOCK: scalar-lr-h-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

When the addressed halfword holds `0x8000`, `lr.h [a0], ->a1` publishes `0x0000000000008000` in `a1`, and the reservation covers the `64`-byte granule that contains the halfword.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.h [SrcL], ->Rd
lr.h.aq [SrcL], ->Rd
lr.h.rl [SrcL], ->Rd
lr.h.f [SrcL], ->Rd
lr.h.aqrl [SrcL], ->Rd
lr.h.aqf [SrcL], ->Rd
lr.h.rlf [SrcL], ->Rd
lr.h.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_h_32_f936df218d63 | L32 | 32 | 0x1000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_h_32_f936df218d63 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_h_32_f936df218d63 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_h_32_f936df218d63 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_h_32_f936df218d63 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_h_32_f936df218d63 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_h_32_f936df218d63 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_h_32_f936df218d63 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_h_32_f936df218d63 | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_h_32_f936df218d63 | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_h_32_f936df218d63 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_h_32_f936df218d63 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_h_32_f936df218d63 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 load address source |
| SrcZero | ignored 5-bit alias field |
| RegDst | Reg5 loaded-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.H.asl -->
```asl
readonly func InstructionContractOperation_LR_H() => ScalarOperation
begin
    return ScalarOperation_LR_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.H.asl -->
```asl
readonly func InstructionContractHandler_LR_H() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_H()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractIgnoresSrcZero_LR_H()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_H()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsResult_LR_H()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractReservationGranuleBytes_LR_H()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the loaded value.
- SrcZero is an ignored alias field. Every encoding 0..31 selects the same operation and no register or queue is read through SrcZero.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and reservation behavior.

## Legality

- All 32 SrcL Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All 32 SrcZero encodings are ignored aliases. All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the halfword old value only after the load completes and establish the 64-byte-line reservation.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 2-byte little-endian halfword after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 2; SC matching uses the containing 64-byte reservation granule.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.h [a0], ->a1
- lr.h.aqrl [t#1], ->u
- lr.h.f [sp], ->t
