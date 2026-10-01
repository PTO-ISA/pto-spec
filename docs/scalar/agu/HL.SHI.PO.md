<!-- GENERATED FROM: asl/scalar/agu/HL.SHI.PO.asl -->
# HL.SHI.PO

**Normative ASL source:** `asl/scalar/agu/HL.SHI.PO.asl`

HL.SHI.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SHI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-shi-po-purpose role=purpose -->
## What `HL.SHI.PO` stores

`HL.SHI.PO` is a standalone `48`-bit scalar AGU instruction that stores one `2`-byte little-endian unit from `SrcD` at the `SrcR` base and publishes an advanced base through `RegDst`.

The canonical assembly is `hl.shi.po SrcD, [SrcR, simm], ->{t, u, Rd}`.

Design point: a displacement scaled by `2` reaches every even byte offset in a `17`-bit signed field, so a `2`-byte traversal can be written with displacements alone and needs no index register.

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-mechanism role=mechanism -->
## How the address is formed

The displacement is the sign-extended `simm17` value multiplied by `2`, and it is added to the `SrcR` snapshot modulo `2^PTO_XLEN`, which gives the computed address.

The scale is `1`, so the displacement counts `2`-byte units: raising it by `1` moves the access by `2` bytes.

The update mode is post-index: the access uses the original `SrcR` value, and the sum `SrcR` plus the offset is published to `RegDst` only after the store succeeds.

The address is probed before the store, and `SrcD` is read before that probe; on success one `2`-byte little-endian store and one relaxed store event are performed.

Design point: the encoded range `-65536..65535` scaled by `2` gives every even byte displacement from `-131072` through `131070`; an odd displacement cannot be encoded at all.

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-inputs role=inputs-outputs -->
## Operands

- `SrcD` and `SrcR` are `5`-bit Reg5 source selectors: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `simm17` is a `17`-bit signed field that assigns every value from `-65536` through `65535`; the encoded byte displacement is that value multiplied by `2`, and encoded zero is a zero displacement rather than omission.

- `RegDst` is a `5`-bit destination selector: codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result without suppressing the store.

Design point: `RegDst` may name `SrcR` or `SrcD`; both the base and the stored value are read before the store, so the write-back cannot affect the address or the data.

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-effects role=effects -->
## Effects and ordering

`SrcR` and `SrcD` are read before the store, so a `RegDst` naming one of them cannot change the base or the stored data.

A successful execution records one relaxed store event and changes only the `2` bytes of the unit.

A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

The updated base is published after the store, and `TPC` then advances by `6` bytes. A rejected or faulting attempt does not retire.

Design point: the advanced base is the original base plus the scaled displacement, so a loop encoded with rising displacements can advance the pointer by the total distance travelled.

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-constraints role=constraints -->
## Alignment, faults, and restart

- The effective address must be a multiple of `2`. A misaligned address raises `Fault_DataAlignment` before translation or permission; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- A fault records no store event and publishes no base: memory, `SrcD`, `RegDst`, and `TPC` keep their values, so recovery recomputes the snapshot, the address, the probe, and the store.

Design point: the alignment rule constrains the post-index access address, which is the original base; the published sum is not constrained and may be odd.

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.shi.po 20, [2, 3], ->4` with GPR2 = `0x1000` and GPR20 = `0xbeef`.

- The displacement `3` multiplied by `2` is `6`; the access uses the original base `0x1000` and the sum `0x1006` is published to `RegDst` `4`.

- The store writes `0xef`, `0xbe` at `0x1000` through `0x1001` in increasing address order.

- `SrcD` and `SrcR` keep their pre-instruction values, and `TPC` advances by `6` bytes after `RegDst` `4` receives `0x1006`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.shi.po SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shi_po_48_636fea832c7b | HL48 | 48 | 0x00001059003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shi_po_48_636fea832c7b | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_shi_po_48_636fea832c7b | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shi_po_48_636fea832c7b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shi_po_48_636fea832c7b | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_shi_po_48_636fea832c7b | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_shi_po_48_636fea832c7b | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shi_po_48_636fea832c7b | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_shi_po_48_636fea832c7b | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SHI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SHI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SHI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SHI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SHI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SHI_PO()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHI_PO()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_SHI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SHI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcR base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.shi.po SrcD, [SrcR, simm], ->{t, u, Rd}
