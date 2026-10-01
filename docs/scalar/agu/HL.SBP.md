<!-- GENERATED FROM: asl/scalar/agu/HL.SBP.asl -->
# HL.SBP

**Normative ASL source:** `asl/scalar/agu/HL.SBP.asl`

HL.SBP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SBP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sbp-purpose role=purpose -->
## What `HL.SBP` does

`HL.SBP` is a standalone `48`-bit scalar AGU instruction that stores two adjacent `1`-byte little-endian units from `SrcD` and `SrcD1`.

The canonical assembly is `hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]`.

Design point: both stored values come from registers, and the pair covers two adjacent bytes. A one-byte write of each of two sources is therefore a single instruction, and neither source is modified.

<!-- PTO-READER-BLOCK: scalar-hl-sbp-mechanism role=mechanism -->
## How the address and the transfer are formed

The offset is the `SrcR` snapshot transformed by `SrcRType` and left-shifted by the fixed amount of `0`, then added to the `SrcL` snapshot modulo `2^PTO_XLEN`.

That sum is the first address, and the second address is that sum plus `1`. The update mode is none, so no base write-back is published.

Both addresses are probed and both store-data sources are read before the first store. On a fault, neither unit is written.

Design point: both units are probed before either byte is written, so a fault on the second unit cannot leave the first byte of the pair already stored.

Design point: the register offset is scaled by `0`, so `SrcR` counts bytes and the second byte of the pair is exactly one byte above the first. The same offset register can be reused as a byte cursor.

<!-- PTO-READER-BLOCK: scalar-hl-sbp-inputs role=inputs-outputs -->
## Encoded fields and what they select

- `SrcD` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcD1` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcL` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcRType` is `2` bits: `00` leaves the whole `SrcR` value unchanged, `01` and `10` replace it with the signed and unsigned readings of its low `32` bits, and `11` is reserved.
- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: `SrcD` and `SrcD1` may name the same register, in which case both bytes receive the same value from one pre-instruction read. The second read does not observe the first store, because both sources are read before the first store.

<!-- PTO-READER-BLOCK: scalar-hl-sbp-effects role=effects -->
## Effects, snapshots, and completion

Every scalar source is snapshotted before any memory or destination effect, so a source that a destination also names still contributes the pre-instruction value.

A successful execution records two relaxed store events in increasing address order.

In memory, a successful execution changes only the bytes inside the stored range. A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

Design point: only the low `8` bits of each source are written, so wider sources are truncated silently. The rest of each register is untouched.

<!-- PTO-READER-BLOCK: scalar-hl-sbp-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect.
- Every address is a whole number of `1`-byte units, so preflight cannot raise `Fault_DataAlignment` for this form. A permission or bounded-memory failure raises `Fault_DataPage` at the failing unit's own address: when only the second unit fails the bound or permission check, that second address is reported.
- A fault records no store event, leaves memory and destination registers unchanged, and keeps `TPC` on the faulting instruction. Recovery recomputes the snapshot, the address, the probe, and the store from the beginning.

Design point: `SrcRType` raw `11` is reserved and rejects before the sources are read, so a reserved selector cannot expose a half-formed offset.

<!-- PTO-READER-BLOCK: scalar-hl-sbp-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.sbp 20, 21, [2, 7]` with GPR2 = `0x8000`, GPR7 = `0x10`, GPR20 = `0xAA`, and GPR21 = `0xBB`.
- The offset is `0x10`, so the two addresses are `0x8010` and `0x8011`.
- Byte `0xAA` is stored at `0x8010` and byte `0xBB` at `0x8011`.
- No register changes, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sbp_48_12e03c011f0a | HL48 | 48 | 0x00000049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sbp_48_12e03c011f0a | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sbp_48_12e03c011f0a | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sbp_48_12e03c011f0a.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBP.asl -->
```asl
readonly func InstructionContractOperation_HL_SBP() => ScalarOperation
begin
    return ScalarOperation_HL_SBP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBP.asl -->
```asl
readonly func InstructionContractHandler_HL_SBP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SBP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SBP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SBP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SBP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SBP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SBP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SBP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. The register offset uses a fixed scale factor of 1; no shamt field is encoded.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- All four SrcRType values are assigned; apply the selected modifier with the fixed scale factor of 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 1; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 1-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
