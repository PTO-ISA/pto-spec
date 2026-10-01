<!-- GENERATED FROM: asl/scalar/amo/LR.B.asl -->
# LR.B

**Normative ASL source:** `asl/scalar/amo/LR.B.asl`

LR.B loads one byte, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-b-purpose role=purpose -->
## What LR.B does

`LR.B` loads one byte from the address in `SrcL`, publishes it through the Reg5 destination `RegDst`, and establishes a reservation on the loaded location. It is a standalone encoded 32-bit form, so a successful execution advances `TPC` by `4` bytes.

Design point: the published value is the loaded byte zero-extended to `PTO_XLEN` bits, so the byte `0x80` is published as `0x0000000000000080`. A byte load never sign-extends, and a program that wants a signed byte must extend the published value itself.

<!-- PTO-READER-BLOCK: scalar-lr-b-mechanism role=mechanism -->
## How the load and reservation are ordered

Dispatch calls `ExecuteDecodedLoadReserved(instruction, form, 1)`, where `1` is this mnemonic's access width. The helper reads `SrcL`, decodes `aq` and `rl` into a memory order, and calls `LoadReserved(address, 1, order)`; when no fault has been recorded, it writes `NormalizeAtomicReturn(old_value, 1)` to `RegDst`.

`LoadReserved` calls `LoadWithOrder`, which runs the access preflight, reads the byte and records one load event at the translated address with the requested order. Only then, and only when `_LastFault` is `Fault_None`, does `LoadReserved` set `_ReservationValid` and store the original address with the width `1`.

Design point: the reservation update sits inside the fault-free branch, so a faulting `lr.b` preserves an older reservation instead of replacing or clearing it; a retry after a fault starts from the reservation state the program already had.

<!-- PTO-READER-BLOCK: scalar-lr-b-inputs-outputs role=inputs-outputs -->
## Fields, sources and destinations

The encoded fields are `RegDst@7:5`, `SrcL@15:5`, `SrcZero@20:5`, `rl@25:1`, `aq@26:1` and `far@27:1`; each entry names the low instruction bit and the field width.

`SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. `RegDst` is a Reg5 destination: `1..23` write that GPR, `0` and `24..29` discard the value, `30` pushes `U`, and `31` pushes `T`. `aq` and `rl` select relaxed, acquire, release or acquire-release ordering; `far` is a routing hint, and `AtomicAddress` returns the address unchanged whichever value it takes.

Design point: `SrcZero` is decoded as a five-bit field but no code path reads it. All `32` encodings of that field select the same operation, no encoding of it is reserved, and the field is absent from the assembly spelling `lr.b [SrcL], ->Rd`.

<!-- PTO-READER-BLOCK: scalar-lr-b-effects role=effects -->
## Effects and ordering

A successful load reads one little-endian byte, records one load event at the translated address while memory-event capture is enabled, publishes the zero-extended byte through `RegDst`, and leaves the local reservation valid, addressed at the original `SrcL` value, with the recorded width `1`. `TPC` then advances by `4` bytes.

The reservation is later matched by the containing `64`-byte granule, not by the byte that was loaded.

Design point: `StoreConditional` compares only the containing granule and the reservation-valid flag, so the recorded width never narrows a match; a conditional store anywhere in the same `64`-byte granule still matches a reservation taken by this byte load.

<!-- PTO-READER-BLOCK: scalar-lr-b-constraints role=constraints -->
## Legality and precise faults

`LoadWithOrder` probes alignment first, then translation, then read permission and bounds. This form loads one byte, so its alignment requirement is one byte: every byte address passes the alignment test and `LR.B` cannot report `Fault_DataAlignment`, while a rejected address reports `Fault_DataPage`.

On a fault nothing is published, no load event is recorded, the prior reservation is preserved, and `TPC` does not advance. A decode failure or an unavailable selected T/U source raises `Fault_IllegalInstruction` before those checks.

Design point: since a fault publishes nothing through `RegDst`, a destination that pushes a queue (codes `30` and `31`) pushes nothing either, so a faulting byte load leaves the `T` and `U` queue depths unchanged.

<!-- PTO-READER-BLOCK: scalar-lr-b-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

When the addressed byte holds `0x80`, `lr.b [a0], ->a1` publishes `0x0000000000000080` in `a1` and establishes a reservation covering the `64`-byte granule that contains the byte.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.b [SrcL], ->Rd
lr.b.aq [SrcL], ->Rd
lr.b.rl [SrcL], ->Rd
lr.b.f [SrcL], ->Rd
lr.b.aqrl [SrcL], ->Rd
lr.b.aqf [SrcL], ->Rd
lr.b.rlf [SrcL], ->Rd
lr.b.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_b_32_cf80903a761a | L32 | 32 | 0x0000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_b_32_cf80903a761a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_b_32_cf80903a761a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_b_32_cf80903a761a | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_b_32_cf80903a761a | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_b_32_cf80903a761a | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_b_32_cf80903a761a | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_b_32_cf80903a761a | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_b_32_cf80903a761a | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_b_32_cf80903a761a | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_b_32_cf80903a761a | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_b_32_cf80903a761a | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_b_32_cf80903a761a | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.B.asl -->
```asl
readonly func InstructionContractOperation_LR_B() => ScalarOperation
begin
    return ScalarOperation_LR_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.B.asl -->
```asl
readonly func InstructionContractHandler_LR_B() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_B()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractIgnoresSrcZero_LR_B()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_B()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsResult_LR_B()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractReservationGranuleBytes_LR_B()
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
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the byte old value only after the load completes and establish the 64-byte-line reservation.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 1-byte little-endian byte after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 1; SC matching uses the containing 64-byte reservation granule.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- Every byte address is naturally aligned. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.b [a0], ->a1
- lr.b.aqrl [t#1], ->u
- lr.b.f [sp], ->t
