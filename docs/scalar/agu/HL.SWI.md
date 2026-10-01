<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.asl -->
# HL.SWI

**Normative ASL source:** `asl/scalar/agu/HL.SWI.asl`

HL.SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-purpose role=purpose -->
## What `HL.SWI` does

`HL.SWI` is a standalone `48`-bit scalar AGU store with a wide scaled immediate and no result. It writes one `4`-byte little-endian unit from `SrcD` at the `SrcR` base plus a `simm22` displacement.

The canonical assembly is `hl.swi SrcD, [SrcR, simm]`.

Design point: the encoding has no destination field at all, so `HL.SWI` can never publish an updated base. The sum of base and displacement exists only as the address of this one store.

<!-- PTO-READER-BLOCK: scalar-hl-swi-mechanism role=mechanism -->
## How the address and the transfer are formed

The decoded address kind is an immediate store, so `SrcR` is the base. The sign-extended `simm22` is scaled by `4` and added to that base modulo `2^PTO_XLEN`.

Preflight tests `4`-byte alignment, then translation, then permission and bounded memory. The store-data source is read from `SrcD`, and only after the whole address passes does the `4`-byte little-endian store happen and one relaxed store event is recorded.

Nothing is published afterwards: with no `RegDst` field the instruction ends after the store event, and `TPC` advances by `6` bytes.

Design point: the `22`-bit field is scaled by `4`, so the immediate counts `4`-byte units and reaches `-8388608`..`8388604` bytes. The low two bits of the byte displacement are always `0`.

<!-- PTO-READER-BLOCK: scalar-hl-swi-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcD` supplies the stored `4` bytes. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` supplies the base. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm22` is signed and covers `-2097152`..`2097151` units of `4` bytes.
- Design point: the field name `SrcR` means the base here. In a register-offset form the same name means the scaled index, and the base is `SrcL`; the decoded address kind decides which role applies.
- Design point: no destination selector exists, so the sum is used only as this store's address and no register records it afterwards.

<!-- PTO-READER-BLOCK: scalar-hl-swi-effects role=effects -->
## Effects, ordering, and completion

The base is snapshotted before the memory operation, so the stored bytes and the address come from pre-instruction values even when the data source is the base register.

A successful attempt records one relaxed store event, changes exactly the `4` bytes of the stored range, and advances `TPC` by `6` bytes.

Design point: the store invalidates a reservation only if its range overlaps the `64`-byte granule containing that reservation.

<!-- PTO-READER-BLOCK: scalar-hl-swi-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch or an unavailable `T`/`U` source raises `Fault_IllegalInstruction` before any instruction effect.
- An address that is not a multiple of `4` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no store event, writes no byte, and leaves `TPC` on the faulting instruction for a full reissue.
- Design point: because the displacement is a multiple of `4` and the access needs `4`-byte alignment, the alignment of the effective address is the alignment of the base; the immediate cannot repair a misaligned base.

<!-- PTO-READER-BLOCK: scalar-hl-swi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With GPR `6` = `0x2000` as the base and `simm` = `-2`, the byte displacement is `-8` and the address is `0x1FF8`.
- With GPR `5` = `0x0000000055667788` as `SrcD`, the bytes written at `0x1FF8`..`0x1FFB` are `88 77 66 55`.
- No register records the address afterwards, because the encoding has no destination field.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_48_13deb2849df5 | HL48 | 48 | 0x00002059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_48_13deb2849df5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_48_13deb2849df5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_48_13deb2849df5 | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_48_13deb2849df5 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_48_13deb2849df5 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_48_13deb2849df5 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI() => ScalarOperation
begin
    return ScalarOperation_HL_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.swi SrcD, [SrcR, simm]
