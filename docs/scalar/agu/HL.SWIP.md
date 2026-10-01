<!-- GENERATED FROM: asl/scalar/agu/HL.SWIP.asl -->
# HL.SWIP

**Normative ASL source:** `asl/scalar/agu/HL.SWIP.asl`

HL.SWIP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SWIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swip-purpose role=purpose -->
## What `HL.SWIP` does

`HL.SWIP` stores two adjacent `4`-byte little-endian units from `SrcD` and `SrcD1` at a scaled signed-immediate distance from the `SrcR` base.

The canonical assembly is `hl.swip SrcD, SrcD1, [SrcR, simm]`.

Design point: one encoding writes two adjacent units, so an `8`-byte payload is written from two source registers in a single instruction. The pair is `address` and `address + 4`.

<!-- PTO-READER-BLOCK: scalar-hl-swip-mechanism role=mechanism -->
## How the two addresses and the transfers are formed

The immediate store address kind makes `SrcR` the base. The sign-extended `simm17` is scaled by `4` and added to the base modulo `2^PTO_XLEN`.

Both addresses are probed before either store: the first, then the first plus `4`. Only when both pass are `SrcD` and `SrcD1` read and the two relaxed stores committed in address order.

No destination selector exists in this encoding, so the sum is used only as the pair base.

Design point: the immediate counts `4`-byte units, so an odd immediate cannot make an aligned base produce a misaligned address; the alignment risk sits entirely in the base.

<!-- PTO-READER-BLOCK: scalar-hl-swip-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcD` supplies the first unit and `SrcD1` the second. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` supplies the base. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm17` is signed and covers `-65536`..`65535` units of `4` bytes, that is `-262144`..`262140` bytes.
- Design point: both source selectors can read queue entries, and reading them does not consume the entries, so a pushed pair can be stored more than once.

<!-- PTO-READER-BLOCK: scalar-hl-swip-effects role=effects -->
## Effects, ordering, and completion

Every source is snapshotted before the first store, so aliasing between the sources and any other operand cannot change the stored bytes.

Success writes the two adjacent `4`-byte ranges, records two relaxed store events in address order, and advances `TPC` by `6` bytes.

Design point: the two store events are recorded in address order, so the record of this instruction names the lower-addressed unit first.

<!-- PTO-READER-BLOCK: scalar-hl-swip-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch or an unavailable `T`/`U` source raises `Fault_IllegalInstruction` before any instruction effect.
- Either address that is not a multiple of `4` raises `Fault_DataAlignment` before either store; a later permission or bounded-memory failure raises `Fault_DataPage` at the address that failed.
- A fault records no event, writes neither unit, and leaves `TPC` on the faulting instruction for a complete reissue.
- Design point: because both probes precede both stores, the pair has no partially completed state to recover from; a reissue either performs both units or neither.

<!-- PTO-READER-BLOCK: scalar-hl-swip-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With GPR `6` = `0x2000` and `simm` = `1`, the byte displacement is `4` and the addresses are `0x2004` and `0x2008`.
- With `SrcD` = `0x0000000011223344` and `SrcD1` = `0x0000000055667788`, the bytes `44 33 22 11` land at `0x2004` and `88 77 66 55` at `0x2008`.
- With a base of `0x2002`, the two addresses become `0x2006` and `0x200A`; the first is not a multiple of `4`, so neither unit is written.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swip SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swip_48_e2fca8cde001 | HL48 | 48 | 0x00002059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swip_48_e2fca8cde001 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swip_48_e2fca8cde001 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swip_48_e2fca8cde001 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swip_48_e2fca8cde001 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swip_48_e2fca8cde001 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swip_48_e2fca8cde001 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swip_48_e2fca8cde001 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swip_48_e2fca8cde001 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SWIP() => ScalarOperation
begin
    return ScalarOperation_HL_SWIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SWIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SWIP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SWIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWIP()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWIP()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SWIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWIP()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.swip SrcD, SrcD1, [SrcR, simm]
