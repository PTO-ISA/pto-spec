<!-- GENERATED FROM: asl/scalar/agu/HL.LW.PR.asl -->
# HL.LW.PR

**Normative ASL source:** `asl/scalar/agu/HL.LW.PR.asl`

HL.LW.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LW-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lw-pr-purpose role=purpose -->
## What HL.LW.PR does

`HL.LW.PR` is a standalone `48`-bit scalar AGU load. It forms its address from the `SrcL` base plus a register offset that is transformed and then shifted, loads one aligned little-endian `4`-byte value, and sign-extends the transferred bits to `PTO_XLEN` when the result is narrower than that width.

It is a load form with pre-index base update: the same encoded address serves both the access and the published base.

Design point: a register offset reaches the whole `PTO_XLEN` value, so a loop-invariant stride can live in `SrcR` instead of in the instruction stream.

<!-- PTO-READER-BLOCK: scalar-hl-lw-pr-mechanism role=mechanism -->
## How HL.LW.PR forms its address and completes the transfer

`SrcR` supplies the offset. `SrcRType` first selects how the whole `PTO_XLEN` value is transformed: `0` leaves it, `1` sign-extends bits `[31:0]`, and `2` zero-extends bits `[31:0]`.

The transformed offset is shifted left by the encoded `shamt`, and that product is added to the `SrcL` value modulo `2^PTO_XLEN`. The sum is both the accessed address and the published base.

After preflight, the single aligned little-endian `4`-byte load is performed and recorded as one relaxed load event. The executable path normalizes the result with `NormalizeScalarLoadResult`, which sign-extends the `4`-byte result to `PTO_XLEN` because `ScalarAGUSignedLoadOfForm` reports `TRUE` here, so bit 31 of the loaded datum is copied into every higher bit.

Design point: the transformation is applied before the shift, so a scaled word offset stays scaled. Shifting first would scale different bits and change what bit `31` means for `SrcRType=1`.

<!-- PTO-READER-BLOCK: scalar-hl-lw-pr-inputs role=inputs-outputs -->
## Encoded fields and what they select

- `RegDst0` is a `5`-bit selector for the loaded value.

- `RegDst1` is a `5`-bit selector for the updated base.

- `SrcL` is a `5`-bit selector for the address base.

- `SrcR` is a `5`-bit selector for the register offset.

- `SrcRType` is a `2`-bit selector for the offset transformation.

- `shamt` is a `5`-bit field supplying the left shift applied after the transformation.

Codes `1`..`23` write absolute GPRs, `30` pushes `U`, `31` pushes `T`, `0` discards only that result, and codes `24`..`29` write nothing.

`SrcL` and `SrcR` use the complete `Reg5` source domain: codes `0`..`23` select absolute GPRs, codes `24`..`27` select `T#1`..`T#4`, and codes `28`..`31` select `U#1`..`U#4` without consuming them; `0` reads the zero GPR.

Design point: only `SrcRType` values `0`, `1`, and `2` are assigned and `3` is reserved, so `3` faults instead of naming a fourth transformation. The address modifier has no negate case either.

<!-- PTO-READER-BLOCK: scalar-hl-lw-pr-effects role=effects -->
## Effects, snapshots, and completion order

- `SrcL` and `SrcR` are snapshotted before the memory operation, so a destination that aliases either source cannot change the address or offset used.

- Successful execution records one relaxed load event, preserves memory contents and reservation state, and publishes the updated base to `RegDst1` only after the memory operation completed.

- After all results have been published, `HL.LW.PR` advances `TPC` by `6` bytes; a rejected or faulting attempt does not retire.

<!-- PTO-READER-BLOCK: scalar-hl-lw-pr-constraints role=constraints -->
## Legality, faults, and restart

Faults are raised in this order: `SrcRType=3` or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any effect; a misaligned address raises `Fault_DataAlignment` before address translation; a permission or bounded-memory failure raises `Fault_DataPage` at the original address, after translation.

Alignment applies to the accessed address, not to `SrcR`. `shamt` may be `0` and `SrcR` is an unconstrained `Reg5` value, so the access is misaligned exactly when the accessed address is not a multiple of `4`.

Design point: the reserved `SrcRType` encoding is rejected during the legality preflight, before any address is formed, so it cannot raise an alignment or page fault instead.

A fault emits no successful memory event and no partial memory or destination effect, and leaves `TPC` at the faulting instruction; a retry recomputes the source snapshots, the address, the preflight, the transfer, and the publication.

<!-- PTO-READER-BLOCK: scalar-hl-lw-pr-example role=example -->
## Non-normative reading walkthrough

This walkthrough explains how to use the page and does not add instruction behavior.

- Start with the canonical assembly `hl.lw.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1` and identify the base, the register offset, the transformation, the shift, and the destination selectors.

- Compute the sum of `SrcL` and the shifted offset modulo `2^PTO_XLEN`, then check the alignment of the address this form actually accesses.

- Then compare what this form publishes with the ASL contract below.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lw.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lw_pr_48_2b0d62d28b57 | HL48 | 48 | 0x00002009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lw_pr_48_2b0d62d28b57 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lw_pr_48_2b0d62d28b57 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lw_pr_48_2b0d62d28b57 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lw_pr_48_2b0d62d28b57 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lw_pr_48_2b0d62d28b57 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lw_pr_48_2b0d62d28b57 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lw_pr_48_2b0d62d28b57 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lw_pr_48_2b0d62d28b57 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lw_pr_48_2b0d62d28b57 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lw_pr_48_2b0d62d28b57 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lw_pr_48_2b0d62d28b57 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lw_pr_48_2b0d62d28b57 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lw_pr_48_2b0d62d28b57.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LW.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LW_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LW_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LW.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LW_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LW_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LW_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LW_PR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LW_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LW_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LW_PR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LW_PR()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lw.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
