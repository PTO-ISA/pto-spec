<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PO.asl -->
# HL.LD.PO

**Normative ASL source:** `asl/scalar/agu/HL.LD.PO.asl`

HL.LD.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-po-purpose role=purpose -->
## What HL.LD.PO does

`HL.LD.PO` is a standalone `48`-bit scalar AGU instruction that loads one 8-byte little-endian value and zero-extends the transferred bits when the result is narrower than `PTO_XLEN` using `Register` addressing.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-mechanism role=mechanism -->
## Address and transfer mechanism

The register-offset path applies the encoded `SrcRType` transformation to `SrcR`, shifts that result left by `shamt`, and adds it to the snapshotted `SrcL` value modulo `2^PTO_XLEN`.

After complete preflight, one aligned little-endian `8`-byte load is performed. Its result is kept as the complete 64-bit pattern before destination publication.

Post-index mode accesses the original base and publishes base plus offset only after the memory operation succeeds.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-inputs role=inputs-outputs -->
## Encoded inputs and outputs

- `RegDst0` is a `5`-bit field selecting the first loaded-value result.
- `RegDst1` is a `5`-bit field selecting the updated-base result.
- `SrcL` is a `5`-bit field selecting the address base.
- `SrcR` is a `5`-bit field selecting the register offset.
- `SrcRType` is a `2`-bit field selecting the register-offset transformation.
- `shamt` is a `5`-bit field selecting the post-transformation left shift.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-effects role=effects -->
## Effects and completion order

All explicit and implicit scalar sources are snapshotted before any memory or destination effect, so aliases use pre-instruction values.

Successful execution records one relaxed load event; memory and reservation state are preserved.

After all result or writeback publication, `HL.LD.PO` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-constraints role=constraints -->
## Legality, faults, and restart

Each accessed address is aligned to the `8`-byte transfer unit. Misalignment selects `Fault_DataAlignment` before translation; a later permission or bounded-memory failure selects `Fault_DataPage` at the original address.

A fixed-bit mismatch, reserved field value, or unavailable selected T/U source selects `Fault_IllegalInstruction` before instruction effects.

A fault records no successful memory event and commits no partial memory, result, or writeback effect. Re-execution recomputes the source snapshots, address, preflight, transfer, and publication from the beginning.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.ld.po [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1` and identify the encoded address fields.
- Then compare the address mode, transfer action, completion effects, and fault boundary above with the exact generated ASL contract below.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_po_48_870e30995d10 | HL48 | 48 | 0x00003009003e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_po_48_870e30995d10 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_ld_po_48_870e30995d10 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_po_48_870e30995d10 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_po_48_870e30995d10 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_po_48_870e30995d10 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ld_po_48_870e30995d10 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_ld_po_48_870e30995d10 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_ld_po_48_870e30995d10 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_ld_po_48_870e30995d10.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PO()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PO()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ld.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
