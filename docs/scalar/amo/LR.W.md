<!-- GENERATED FROM: asl/scalar/amo/LR.W.asl -->
# LR.W

**Normative ASL source:** `asl/scalar/amo/LR.W.asl`

LR.W loads one word, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-w-purpose role=purpose -->
## What LR.W does

`LR.W` loads one word of `4` bytes from the address in `SrcL`, publishes it through `RegDst`, and establishes a reservation on the loaded location. Successful execution advances `TPC` by `4` bytes.

Design point: the loaded `32` bits are sign-extended to `PTO_XLEN`, so the published value is not the raw memory word. The word `0x80000000` is published as `0xffffffff80000000`, and a program that needs the unsigned word must mask the published value.

<!-- PTO-READER-BLOCK: scalar-lr-w-mechanism role=mechanism -->
## How the word load is ordered

Dispatch selects `ExecuteDecodedLoadReserved(instruction, form, 4)` for this mnemonic. The helper reads `SrcL`, decodes the ordering from `aq` and `rl`, and calls `LoadReserved(address, 4, order)`; when the fault flag is clear it writes `NormalizeAtomicReturn(old_value, 4)` to `RegDst`.

`LoadWithOrder` probes alignment to `4` bytes, translation and read permission, reads four little-endian bytes, and records one load event at the translated address. `LoadReserved` then sets the reservation-valid flag, the original address and the width `4`.

Design point: the reservation match is granule-based, so the saved width `4` does not restrict it. After a successful `lr.w [0x1004], ->a1` the reservation covers the `64` bytes starting at `0x1000`, and a conditional store to `0x1000` still matches even though that address differs from the load address.

<!-- PTO-READER-BLOCK: scalar-lr-w-inputs-outputs role=inputs-outputs -->
## Fields, sources and destinations

The encoding is `RegDst@7:5`, `SrcL@15:5`, `SrcZero@20:5`, `rl@25:1`, `aq@26:1` and `far@27:1`; each entry is the low instruction bit and the field width.

`SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`. `RegDst` is a Reg5 destination: `1..23` write that GPR, `0` and `24..29` discard, `30` pushes `U`, `31` pushes `T`.

Design point: `far` is decoded and passed to `AtomicAddress`, which returns its argument unchanged, so `lr.w [a0], ->a1` and `lr.w.f [a0], ->a1` produce the same address, the same loaded value and the same reservation in the reference model.

<!-- PTO-READER-BLOCK: scalar-lr-w-effects role=effects -->
## Effects and ordering

A successful load reads one little-endian word, records one load event at the translated address with the order selected by `aq` and `rl` while memory-event capture is enabled, publishes the sign-extended word through `RegDst`, and leaves the reservation valid at the original address. `TPC` then advances by `4` bytes.

The published value is `SignExtend{PTO_XLEN}(old_value[31:0])`, so bit `31` of the loaded word decides the upper `32` bits of the destination.

Design point: publication happens only while the fault flag is clear, so a faulting word load leaves `RegDst` at its pre-instruction value; when the destination is a `T` or `U` push, that push does not occur either.

<!-- PTO-READER-BLOCK: scalar-lr-w-constraints role=constraints -->
## Legality and precise faults

Alignment is checked first, then translation, then read permission and bounds, all before any effect. This form requires `4`-byte alignment, so an address that is not a multiple of `4` reports `Fault_DataAlignment`, and an address that fails the bounds check reports `Fault_DataPage` with the original address.

On a fault nothing is published, no load event is recorded, the prior reservation is preserved, and `TPC` does not advance. An undecodable form or an unavailable selected T/U source raises `Fault_IllegalInstruction` before the memory checks.

Design point: the reservation is written only after a fault-free load, so a reservation taken by an earlier successful load survives a later `lr.w` that faults; the older reservation is not replaced or cleared.

<!-- PTO-READER-BLOCK: scalar-lr-w-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

When the addressed word holds `0x80000000`, `lr.w [a0], ->a1` publishes `0xffffffff80000000` in `a1`; after `lr.w [0x1004], ->a1` a conditional store to `0x1000` still matches the reservation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.w [SrcL], ->Rd
lr.w.aq [SrcL], ->Rd
lr.w.rl [SrcL], ->Rd
lr.w.f [SrcL], ->Rd
lr.w.aqrl [SrcL], ->Rd
lr.w.aqf [SrcL], ->Rd
lr.w.rlf [SrcL], ->Rd
lr.w.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_w_32_efecc735bb75 | L32 | 32 | 0x2000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_w_32_efecc735bb75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_w_32_efecc735bb75 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_w_32_efecc735bb75 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_w_32_efecc735bb75 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_w_32_efecc735bb75 | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_w_32_efecc735bb75 | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_w_32_efecc735bb75 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_w_32_efecc735bb75 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_w_32_efecc735bb75 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.W.asl -->
```asl
readonly func InstructionContractOperation_LR_W() => ScalarOperation
begin
    return ScalarOperation_LR_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.W.asl -->
```asl
readonly func InstructionContractHandler_LR_W() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_W()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractIgnoresSrcZero_LR_W()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_W()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsResult_LR_W()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractReservationGranuleBytes_LR_W()
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
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the word old value only after the load completes and establish the 64-byte-line reservation.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 4-byte little-endian word after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 4; SC matching uses the containing 64-byte reservation granule.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.w [a0], ->a1
- lr.w.aqrl [t#1], ->u
- lr.w.f [sp], ->t
