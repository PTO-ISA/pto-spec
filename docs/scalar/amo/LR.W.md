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

`LR.W` loads one word, publishes its zero-extended value, and replaces the local reservation with the containing 64-byte line.

<!-- PTO-READER-BLOCK: scalar-lr-w-mechanism role=mechanism -->
## Atomic mechanism

The ASL DOC contract selects `ScalarHandler_LoadReserved` with an access width of `4` bytes.

`SrcZero` is an ignored five-bit alias field: all 32 encodings select the same operation and consume no source through that field.

<!-- PTO-READER-BLOCK: scalar-lr-w-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 load address source; `SrcZero` carries the ignored 5-bit alias field; `RegDst` carries the Reg5 loaded-value destination; `aq` carries the acquire ordering bit; `rl` carries the release ordering bit; `far` carries the flat-address routing hint.

`aq` and `rl` select relaxed, acquire, release, or acquire-release ordering; `far` is a profile routing hint and does not change the architectural result in the reference profile.

<!-- PTO-READER-BLOCK: scalar-lr-w-effects role=effects -->
## Effects and ordering

A successful load emits one ordered load event, publishes the old value, and establishes the reservation only after access preflight completes.

After the load, the containing 64-byte line becomes the local reservation and `TPC` advances by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-lr-w-constraints role=constraints -->
## Legality and precise faults

The effective address must be aligned to `4` bytes. Alignment, translation, and permission checks precede architectural effects.

A failing preflight publishes no destination, memory event, reservation update, or retirement effect; the saved original `TPC` supports full reissue.

<!-- PTO-READER-BLOCK: scalar-lr-w-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

For a first reading, use `lr.w [SrcL], ->Rd` and then vary only the ordering or route modifiers described above.
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
