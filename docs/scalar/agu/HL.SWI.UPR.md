<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.UPR.asl -->
# HL.SWI.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SWI.UPR.asl`

HL.SWI.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-purpose role=purpose -->
## What `HL.SWI.UPR` does

`HL.SWI.UPR` stores one `4`-byte little-endian unit from `SrcD` at the sum of the `SrcR` base and an unscaled signed immediate, and publishes that same sum to `RegDst`.

The canonical assembly is `hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}`.

Design point: pre-index mode makes the memory address and the published value the same word. The store and the base update can never refer to two different addresses.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-mechanism role=mechanism -->
## How the address and the result are formed

The immediate store address kind makes `SrcR` the base. The sign-extended `simm17` is added to the `SrcR` snapshot modulo `2^PTO_XLEN`, and that sum is used both as the address and as the published result.

Preflight tests `4`-byte alignment, then translation, then permission and bounded memory. The store-data source is read from `SrcD`, and only after the whole address passes does the `4`-byte little-endian store happen and one relaxed store event is recorded.

The sum reaches `RegDst` after the store, and only if the store completed without a fault.

Design point: the base register keeps its old value on a fault, because the write-back shares the store's success condition; the published base and the stored address are therefore always the same word.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcD` supplies the stored `4` bytes. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` supplies the base. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm17` is signed and unscaled, so it covers `-65536`..`65535` bytes.
- `RegDst` receives the updated base. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: a queue destination receives the updated base without disturbing the `SrcD` data path, so a store can advance a pointer and push it in one instruction.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-effects role=effects -->
## Effects, ordering, and completion

Every source is snapshotted before the memory operation, so a destination that aliases the data source or the base does not change what is stored where.

Success records one relaxed store event, writes exactly the `4` bytes of the range, publishes the updated base, and advances `TPC` by `6` bytes.

Design point: the reservation is invalidated only when the stored range overlaps the `64`-byte granule holding it, so a store elsewhere in memory leaves it valid.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch or an unavailable `T`/`U` source raises `Fault_IllegalInstruction` before any instruction effect.
- A sum that is not a multiple of `4` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, writes no byte, publishes no base value, and keeps `TPC` on the faulting instruction so the attempt can be reissued.
- Design point: the same `4`-byte alignment rule applies to the updated address, so a misaligned sum is rejected before translation and nothing at all changes.

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With GPR `6` = `0x1000` as the base and `simm` = `4`, both the access address and the published base are `0x1004`.
- With `SrcD` = `0xDEADBEEF`, the bytes `EF BE AD DE` land at `0x1004`..`0x1007`.
- A base of `0x1002` with `simm` = `1` would give `0x1003`, an address that is not a multiple of `4`, so `Fault_DataAlignment` would be raised and the base would stay `0x1002`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_upr_48_15c2fb96aab0 | HL48 | 48 | 0x00006059002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_upr_48_15c2fb96aab0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_swi_upr_48_15c2fb96aab0 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_upr_48_15c2fb96aab0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_upr_48_15c2fb96aab0 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_upr_48_15c2fb96aab0 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_swi_upr_48_15c2fb96aab0 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upr_48_15c2fb96aab0 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upr_48_15c2fb96aab0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI_UPR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI_UPR()
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

- hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
