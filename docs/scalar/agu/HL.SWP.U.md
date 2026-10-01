<!-- GENERATED FROM: asl/scalar/agu/HL.SWP.U.asl -->
# HL.SWP.U

**Normative ASL source:** `asl/scalar/agu/HL.SWP.U.asl`

HL.SWP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SWP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swp-u-purpose role=purpose -->
## What `HL.SWP.U` does

`HL.SWP.U` stores two adjacent `4`-byte little-endian units from `SrcD` and `SrcD1` at a `SrcL` base plus a `SrcR` index that is added without scaling.

The canonical assembly is `hl.swp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]`.

Design point: dropping the fixed shift lets the index count bytes, so the pair can start at an arbitrary byte offset. Alignment then becomes a property of the index and the base together.

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-mechanism role=mechanism -->
## How the two addresses and the transfers are formed

The index is `SrcR` after the `SrcRType` transformation, added to the `SrcL` snapshot modulo `2^PTO_XLEN` with no shift. The first address is that sum and the second is the first plus `4`.

Both addresses are probed before either store; only then are `SrcD` and `SrcD1` read and the two relaxed stores committed in address order.

This encoding has no destination field, so neither the base nor the index is updated.

Design point: the modifier still runs before the addition and no shift follows it, so `.sw` and `.uw` change the index by the full `32`-bit difference between the sign-extended and zero-extended readings.

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcD` and `SrcD1` supply the two stored units. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcL` supplies the base and `SrcR` the byte index. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcRType` selects unchanged, `.sw`, or `.uw`, and reserves the raw value `3`.
- Design point: the same register can be named as base and as index; both are read before the addition, so the sum uses pre-instruction values for both.

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-effects role=effects -->
## Effects, ordering, and completion

All sources are snapshotted before the first store, so the two units are written from pre-instruction register values.

Success writes two adjacent `4`-byte ranges, records two relaxed store events in address order, and advances `TPC` by `6` bytes.

Design point: nothing is published after the stores, because this form has no destination selector.

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, a `SrcRType` of `3`, or an unavailable `T`/`U` source raises `Fault_IllegalInstruction` before the index, the base, or the data is read.
- Either address that is not a multiple of `4` raises `Fault_DataAlignment` before either store; a later permission or bounded-memory failure raises `Fault_DataPage` at the address that failed.
- A fault records no event, writes neither unit, and keeps `TPC` on the faulting instruction for a complete reissue.
- Design point: an odd index produces a first address that is not a multiple of `4`, which is rejected before either unit is written.

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x3000`, `SrcR` = `2`, and `SrcRType` `0`, the addresses are `0x3002` and `0x3006`; the first is not a multiple of `4`, so `Fault_DataAlignment` is raised.
- With `SrcR` = `4` the addresses become `0x3004` and `0x3008`, and both units are written.
- Because the index is added unscaled, an index of `4` moves the pair by `4` bytes while the scaled `HL.SWP` would move it by `16`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swp_u_48_c244a576be8e | HL48 | 48 | 0x00006049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swp_u_48_c244a576be8e | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swp_u_48_c244a576be8e | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_swp_u_48_c244a576be8e.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SWP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SWP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SWP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SWP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SWP_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWP_U()
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
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.swp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
