<!-- GENERATED FROM: asl/scalar/agu/HL.SD.PR.asl -->
# HL.SD.PR

**Normative ASL source:** `asl/scalar/agu/HL.SD.PR.asl`

HL.SD.PR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SD-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sd-pr-purpose role=purpose -->
## What `HL.SD.PR` does

`HL.SD.PR` is a standalone `48`-bit scalar AGU instruction that stores one `8`-byte little-endian unit from `SrcD` through a register offset.

The canonical assembly is `hl.sd.pr SrcD, [SrcL, SrcR<{.sw,.uw}><<3], ->{t, u, Rd}`.

Design point: this is the pre-index form, so the access uses the updated base and the same updated base is published after the store succeeds. One instruction both advances a pointer and stores through the new pointer.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pr-mechanism role=mechanism -->
## Addressing

The offset is the `SrcR` snapshot transformed by `SrcRType` and left-shifted by the fixed amount of `3` that the form declares, then added to the `SrcL` snapshot modulo `2^PTO_XLEN`.

This register-addressing form carries no `shamt` field, so the scale is fixed by the form rather than chosen per instruction.

The address is preflighted before the store. On success one `8`-byte little-endian store is performed and one relaxed store event is recorded.

Design point: the pre-index address is the base plus the transformed offset, so the offset moves this access as well as the published value: both are the same sum. The fixed shift of `3` makes the offset register a count of `8`-byte units.

Design point: the accessed address and the published value are the same sum, so `->6` with `SrcL` = GPR6 publishes the base it just stored through. The write-back is still gated on the store succeeding, so a fault leaves the register on its old value.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pr-inputs role=inputs-outputs -->
## Encoded fields

- `SrcD` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcL` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcRType` is `2` bits: `00` leaves the whole `SrcR` value unchanged, `01` and `10` replace it with the signed and unsigned readings of its low `32` bits, and `11` is reserved.
- `RegDst` is a `5`-bit selector. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result without suppressing the other effects.

Design point: `SrcD` may name the same register as `RegDst`. The store data is read before any destination effect, so the memory operation stores the pre-instruction value while the register afterwards holds the updated base.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pr-effects role=effects -->
## Effects

Every scalar source is snapshotted before any memory or destination effect, so a source that a destination also names still contributes the pre-instruction value.

In memory, a successful execution changes only the bytes inside the stored range. The updated base is published to `RegDst` when the store completes without fault. A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

`TPC` advances by `6` bytes after the memory operation completes. A rejected or faulting attempt does not retire.

Design point: all `8` bytes of `SrcD` are the transfer, so the low byte lands at the lowest address of the unit. There is no truncation on this form.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pr-constraints role=constraints -->
## Legality and faults

- A fixed-bit mismatch, a reserved `SrcRType` value, or a source code selecting an unavailable `T` or `U` slot raises `Fault_IllegalInstruction` before any instruction effect.
- A misaligned `8`-byte address raises `Fault_DataAlignment` before translation or permission. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.
- A fault records no store event, leaves memory and destination registers unchanged, and keeps `TPC` on the faulting instruction. Recovery recomputes the snapshot, the address, the probe, and the store from the beginning.
- Design point: the offset reaches the access and the write-back alike, so an unaligned base faults on the first element instead of publishing a rounded pointer first and faulting later. The register therefore never holds a value the instruction failed to store through.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pr-example role=example -->
## Worked example

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.sd.pr 5, [6, 7], ->8` with GPR6 = `0x2000`, GPR7 = `2`, GPR5 = `0x0807060504030201`.
- The offset is `2` shifted by `3`, which is `0x10`; the store goes to `0x2010`.
- GPR8 receives `0x2010`, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sd.pr SrcD, [SrcL, SrcR<{.sw,.uw}><<3], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sd_pr_48_4f96249f5efe | HL48 | 48 | 0x00003049002e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sd_pr_48_4f96249f5efe | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sd_pr_48_4f96249f5efe | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sd_pr_48_4f96249f5efe | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sd_pr_48_4f96249f5efe | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sd_pr_48_4f96249f5efe | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sd_pr_48_4f96249f5efe | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sd_pr_48_4f96249f5efe | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sd_pr_48_4f96249f5efe | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sd_pr_48_4f96249f5efe | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sd_pr_48_4f96249f5efe | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sd_pr_48_4f96249f5efe.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_PR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SD_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SD_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SD_PR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SD_PR()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_SD_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SD_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SD_PR()
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

- Form offset = LSL(Modify(SrcR, SrcRType), 3) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sd.pr SrcD, [SrcL, SrcR<{.sw,.uw}><<3], ->{t, u, Rd}
