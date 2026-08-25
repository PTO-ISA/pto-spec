<!-- GENERATED FROM: asl/scalar/agu/HL.SB.PCR.asl -->
# HL.SB.PCR

**Normative ASL source:** `asl/scalar/agu/HL.SB.PCR.asl`

HL.SB.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-purpose role=purpose -->
## What HL.SB.PCR does

`HL.SB.PCR` is a standalone `48`-bit scalar AGU instruction that stores one 1-byte little-endian value using `PCRelative` addressing.

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-mechanism role=mechanism -->
## Address and transfer mechanism

The PC-relative path first clears bits `1:0` of the current `TPC`, then adds the sign-extended `simm` displacement scaled by `4`, modulo `2^PTO_XLEN`.

After complete preflight, one aligned little-endian `1`-byte store commits at the selected address.

This form does not publish an address-base writeback.

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-inputs role=inputs-outputs -->
## Encoded inputs and outputs

- `SrcL` is a `5`-bit field selecting the address base.
- `simm` is a `29`-bit field selecting the signed displacement before the `4` scale factor.

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-effects role=effects -->
## Effects and completion order

All explicit and implicit scalar sources are snapshotted before any memory or destination effect, so aliases use pre-instruction values.

Successful execution records one relaxed store event; an overlapping reservation is invalidated only after complete preflight.

After all result or writeback publication, `HL.SB.PCR` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-constraints role=constraints -->
## Legality, faults, and restart

Each accessed address is aligned to the `1`-byte transfer unit. Misalignment selects `Fault_DataAlignment` before translation; a later permission or bounded-memory failure selects `Fault_DataPage` at the original address.

A fixed-bit mismatch, reserved field value, or unavailable selected T/U source selects `Fault_IllegalInstruction` before instruction effects.

A fault records no successful memory event and commits no partial memory, result, or writeback effect. Re-execution recomputes the source snapshots, address, preflight, transfer, and publication from the beginning.

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.sb.pcr SrcL, [<symbol>]` and identify the encoded address fields.
- Then compare the address mode, transfer action, completion effects, and fault boundary above with the exact generated ASL contract below.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sb.pcr SrcL, [<symbol>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sb_pcr_48_d0ba4b6e0f54 | HL48 | 48 | 0x00000069000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sb_pcr_48_d0ba4b6e0f54 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sb_pcr_48_d0ba4b6e0f54 | simm | 29 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sb_pcr_48_d0ba4b6e0f54 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sb_pcr_48_d0ba4b6e0f54 | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SB.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SB.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_SB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SB_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SB_PCR()
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
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sb.pcr SrcL, [<symbol>]
