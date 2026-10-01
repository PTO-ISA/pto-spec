<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.UPO.asl -->
# HL.SWI.UPO

**Normative ASL source:** `asl/scalar/agu/HL.SWI.UPO.asl`

HL.SWI.UPO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI-UPO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-purpose role=purpose -->
## What `HL.SWI.UPO` does

`HL.SWI.UPO` is a standalone `48`-bit scalar AGU store. It writes one `4`-byte little-endian unit from `SrcD` at the `SrcR` base and publishes the advanced base to `RegDst`.

The canonical assembly is `hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}`.

Design point: the update mode is post-index, so the address used by the store is the original base and the sum is only a result. The suffix records the update mode; the `simm17` displacement is unscaled, so each encoded unit is one byte.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-mechanism role=mechanism -->
## How the address and the result are formed

Because the decoded address kind is an immediate store, the field named `SrcR` supplies the base rather than an index. The sign-extended `simm17` is added to that base modulo `2^PTO_XLEN`, and the store addresses the base itself.

Preflight tests `4`-byte alignment, then translation, then permission and bounded memory. The store-data source is read from `SrcD`, and only after the whole address passes does the `4`-byte little-endian store happen and one relaxed store event is recorded.

If the store completes without a fault, the sum is published to `RegDst`, where it may be a GPR, a queue push, or a discarding code.

Design point: the write-back is guarded by the same success condition as the store itself. A faulting attempt leaves the base register at its old value and keeps `TPC` on the instruction, so a reissue recomputes exactly the same address.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcD` supplies the `4` bytes that are written. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` supplies the base. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm17` is signed and covers `-65536`..`65535` bytes because the displacement is not scaled. Encoded zero is a zero displacement, not an omitted operand.
- `RegDst` receives the updated base. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: when `SrcD` and `RegDst` name the same register, the store still uses the pre-instruction value: the data source is read before the destination is written.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-effects role=effects -->
## Effects, ordering, and completion

All sources are snapshotted before the memory operation, so an alias between the data source and the base cannot change either the stored bytes or the address.

A successful attempt records one relaxed store event, writes exactly the `4` bytes of the stored range, publishes the sum, and then advances `TPC` by `6` bytes.

Design point: the store invalidates a reservation only when its range overlaps the `64`-byte granule that contains the reservation, so an unrelated store leaves the reservation valid.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch or an unavailable selected `T`/`U` source raises `Fault_IllegalInstruction` at the instruction address before any instruction effect.
- An address that is not a multiple of `4` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no store event, writes no byte of memory, publishes no updated base, and leaves `TPC` on the faulting instruction for a complete reissue.
- Design point: the alignment test applies to the base, because the post-index access address is the base itself; the unscaled immediate moves only the published sum, so a misaligned base is reported as `Fault_DataAlignment` and the address is never rounded to the nearest unit.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With GPR `6` = `0x1000` as the base and `simm` = `4`, the sum is `0x1004` but the access uses `0x1000`, because the update mode is post-index.
- With GPR `5` = `0xDEADBEEF` as `SrcD`, the bytes written at `0x1000`..`0x1003` are `EF BE AD DE`.
- `RegDst` receives `0x1004` only after the store completes; if the address had been misaligned, both the memory and the base register would be unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_upo_48_243d3c38cd1a | HL48 | 48 | 0x00006059003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_upo_48_243d3c38cd1a | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_swi_upo_48_243d3c38cd1a | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_upo_48_243d3c38cd1a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_upo_48_243d3c38cd1a | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_upo_48_243d3c38cd1a | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_swi_upo_48_243d3c38cd1a | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upo_48_243d3c38cd1a | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upo_48_243d3c38cd1a | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_UPO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI_UPO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI_UPO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI_UPO()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI_UPO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI_UPO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI_UPO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI_UPO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}
