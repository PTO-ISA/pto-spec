<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.PO.asl -->
# HL.SWI.PO

**Normative ASL source:** `asl/scalar/agu/HL.SWI.PO.asl`

HL.SWI.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-po-purpose role=purpose -->
## What `HL.SWI.PO` stores

`HL.SWI.PO` is a standalone `48`-bit scalar AGU instruction that stores one `4`-byte little-endian unit from `SrcD` at the `SrcR` base and publishes an advanced base through `RegDst`.

The canonical assembly is `hl.swi.po SrcD, [SrcR, simm], ->{t, u, Rd}`.

Design point: a `17`-bit displacement scaled by `4` reaches every `4`-byte-aligned offset from `-262144` through `262140`, so a word array can be traversed with displacements alone.

<!-- PTO-READER-BLOCK: scalar-hl-swi-po-mechanism role=mechanism -->
## How the address is formed

The displacement is the sign-extended `simm17` value multiplied by `4`, and it is added to the `SrcR` snapshot modulo `2^PTO_XLEN`, which gives the computed address.

The scale is `2`, so the displacement counts `4`-byte units and the scaled displacement is always a multiple of `4`.

The update mode is post-index: the access uses the original `SrcR` value, and the sum `SrcR` plus the offset is published to `RegDst` only after the store succeeds.

The address is probed before the store, and `SrcD` is read before that probe; on success one `4`-byte little-endian store and one relaxed store event are performed.

Design point: the post-index access address is the original base, so the alignment probe tests the base rather than the base plus the displacement.

<!-- PTO-READER-BLOCK: scalar-hl-swi-po-inputs role=inputs-outputs -->
## Operands

- `SrcD` and `SrcR` are `5`-bit Reg5 source selectors: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `simm17` is a `17`-bit signed field that assigns every value from `-65536` through `65535`; the encoded byte displacement is that value multiplied by `4`, and encoded zero is a zero displacement rather than omission.

- `RegDst` is a `5`-bit destination selector: codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result without suppressing the store.

Design point: `RegDst` and `SrcR` may name the same register, in which case the pointer advances by the scaled displacement after the store has already used the old base.

<!-- PTO-READER-BLOCK: scalar-hl-swi-po-effects role=effects -->
## Effects and ordering

`SrcR` and `SrcD` are read before the store, so a `RegDst` naming one of them cannot change the base or the stored data.

A successful execution records one relaxed store event and changes only the `4` bytes of the unit.

A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

The updated base is published after the store, and `TPC` then advances by `6` bytes. A rejected or faulting attempt does not retire.

Design point: the low `4` bytes of `SrcD` are written in increasing address order, so the unit is stored little-endian at every size.

<!-- PTO-READER-BLOCK: scalar-hl-swi-po-constraints role=constraints -->
## Alignment, faults, and restart

- The effective address must be a multiple of `4`. A misaligned address raises `Fault_DataAlignment` before translation or permission; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- A fault records no store event and publishes no base: memory, `SrcD`, `RegDst`, and `TPC` keep their values, so recovery recomputes the snapshot, the address, the probe, and the store.

Design point: the displacement is scaled by `4`, so the post-index access address is always the base and the alignment rule never depends on the encoded displacement.

<!-- PTO-READER-BLOCK: scalar-hl-swi-po-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.swi.po 20, [2, 3], ->4` with GPR2 = `0x2000` and GPR20 = `0xdeadbeef`.

- The displacement `3` multiplied by `4` is `12`; the access uses the original base `0x2000` and the sum `0x200c` is published to `RegDst` `4`.

- The store writes `0xef`, `0xbe`, `0xad`, `0xde` at `0x2000` through `0x2003` in increasing address order.

- `SrcD` and `SrcR` keep their pre-instruction values, and `TPC` advances by `6` bytes after `RegDst` `4` receives `0x200c`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi.po SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_po_48_66a80d0fa7f5 | HL48 | 48 | 0x00002059003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_po_48_66a80d0fa7f5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_swi_po_48_66a80d0fa7f5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_po_48_66a80d0fa7f5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_po_48_66a80d0fa7f5 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_po_48_66a80d0fa7f5 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_swi_po_48_66a80d0fa7f5 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_po_48_66a80d0fa7f5 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_po_48_66a80d0fa7f5 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI_PO()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI_PO()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI_PO()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
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

- hl.swi.po SrcD, [SrcR, simm], ->{t, u, Rd}
