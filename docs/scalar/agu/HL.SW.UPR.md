<!-- GENERATED FROM: asl/scalar/agu/HL.SW.UPR.asl -->
# HL.SW.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SW.UPR.asl`

HL.SW.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SW-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sw-upr-purpose role=purpose -->
## What `HL.SW.UPR` stores

`HL.SW.UPR` is a standalone `48`-bit scalar AGU instruction that stores one `4`-byte little-endian unit from `SrcD` at the sum of `SrcL` and an unshifted register offset.

The canonical assembly is `hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}`.

Design point: the access address is the published base, so a misaligned byte offset fails the store instead of advancing the pointer past bytes that were never written.

<!-- PTO-READER-BLOCK: scalar-hl-sw-upr-mechanism role=mechanism -->
## How the address is formed

The offset is the `SrcR` snapshot selected by `SrcRType`, used without a shift, and it is added to the `SrcL` snapshot modulo `2^PTO_XLEN`, which gives the computed address.

The scale is `0`, so the offset is a byte count and the low bits of the offset are not cleared before it is added to the base.

The update mode is pre-index: the access uses the sum `SrcL` plus the offset, and that same sum is published to `RegDst` after the store succeeds.

The address is probed before the store, and `SrcD` is read before that probe; on success one `4`-byte little-endian store and one relaxed store event are performed.

Design point: with the base `0x2000` and an offset of `5` the access address is `0x2005`, which is not a multiple of `4`, so the alignment probe raises `Fault_DataAlignment` before translation.

<!-- PTO-READER-BLOCK: scalar-hl-sw-upr-inputs role=inputs-outputs -->
## Operands

- `SrcD`, `SrcL`, and `SrcR` are `5`-bit Reg5 source selectors: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `SrcRType` is `2` bits applied to `SrcR` before the shift: `00` keeps the whole register value, `01` and `10` replace it with the signed and unsigned readings of its low `32` bits, and `11` is reserved.

- `RegDst` is a `5`-bit destination selector: codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result without suppressing the store.

Design point: `SrcRType` `10` reads the low `32` bits as unsigned, so a byte offset above `2^31` is available without sign-extending it.

<!-- PTO-READER-BLOCK: scalar-hl-sw-upr-effects role=effects -->
## Effects and ordering

`SrcL`, `SrcR`, and `SrcD` are all read before the store, so a `RegDst` naming one of them cannot change the base, the offset, or the stored data.

A successful execution records one relaxed store event and changes only the `4` bytes of the unit.

A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

The updated base is published after the store, and `TPC` then advances by `6` bytes. A rejected or faulting attempt does not retire.

Design point: a successful store writes the low `4` bytes of `SrcD` and publishes the same sum it used as an address.

<!-- PTO-READER-BLOCK: scalar-hl-sw-upr-constraints role=constraints -->
## Alignment, faults, and restart

- The effective address must be a multiple of `4`. A misaligned address raises `Fault_DataAlignment` before translation or permission; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- `SrcRType` raw `11` is reserved: it raises `Fault_IllegalInstruction` at `PC` before any source is read, so the address modifier decode only defines `00`, `01`, and `10`.

- A fault records no store event and publishes no base: memory, `SrcD`, `RegDst`, and `TPC` keep their values, so recovery recomputes the snapshot, the address, the probe, and the store.

Design point: nothing is written and no base is published when the sum fails alignment, so the pointer and memory always agree about which unit was stored.

<!-- PTO-READER-BLOCK: scalar-hl-sw-upr-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.sw.upr 20, [2, 7], ->4` with `SrcRType` `01`, GPR2 = `0x2000`, GPR7 = `0x8`, and GPR20 = `0xdeadbeef`.

- The index `0x8` is used directly as a byte offset, giving `8`, so the effective address is `0x2008` and the same value is published to `RegDst` `4`.

- The store writes `0xef`, `0xbe`, `0xad`, `0xde` at `0x2008` through `0x200b` in increasing address order.

- `SrcD` and `SrcL` keep their pre-instruction values, and `TPC` advances by `6` bytes after `RegDst` `4` receives `0x2008`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sw_upr_48_d4ccb513944a | HL48 | 48 | 0x00006049002e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sw_upr_48_d4ccb513944a | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sw_upr_48_d4ccb513944a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sw_upr_48_d4ccb513944a | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sw_upr_48_d4ccb513944a | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sw_upr_48_d4ccb513944a | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sw_upr_48_d4ccb513944a | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sw_upr_48_d4ccb513944a | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sw_upr_48_d4ccb513944a.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SW_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SW_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SW_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SW_UPR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SW_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SW_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SW_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SW_UPR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
