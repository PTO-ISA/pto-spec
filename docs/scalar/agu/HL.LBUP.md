<!-- GENERATED FROM: asl/scalar/agu/HL.LBUP.asl -->
# HL.LBUP

**Normative ASL source:** `asl/scalar/agu/HL.LBUP.asl`

HL.LBUP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBUP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbup-purpose role=purpose -->
## What `HL.LBUP` does

`HL.LBUP` is a `48`-bit load of a pair of adjacent bytes with a register-sourced offset and zero-extended results. It forms an offset from `SrcR` and `shamt`, adds it to the `SrcL` base, reads the byte at that sum and the byte at that sum plus `1`, clears everything above bit `7` in each result, and publishes the lower byte to `Dst0` and the higher byte to `Dst1`.

The canonical assembly is `hl.lbup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: the offset register participates in the address through a transform and a shift, but it never receives anything back. Neither the base nor the offset register is written by this form, so it has no pointer-bump side effect and cannot be used to advance a walk from within the instruction.

<!-- PTO-READER-BLOCK: scalar-hl-lbup-mechanism role=mechanism -->
## How the offset and the two addresses are formed

`SrcR` is transformed by `SrcRType`, shifted left by the encoded `shamt`, and added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The second address is that sum plus `1` byte, the access size.

The two addresses are probed in ascending order and neither byte is read until both probes succeed. The handler then reads the bytes, records two relaxed load events in address order, zero-extends both values, and publishes `Dst0` before `Dst1`.

Design point: when both destinations are queue pushes, the instruction produces two pushes and therefore advances the queue twice. The older entries move by two slots, so a value that was in `T#1` before the instruction is in `T#3` afterwards.

<!-- PTO-READER-BLOCK: scalar-hl-lbup-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` the offset source, both `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` is `0` unchanged, `1` for `.sw` on `SrcR[31:0]`, or `2` for `.uw` on `SrcR[31:0]`; `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform, so an offset of one element is expressed as a `1` in `SrcR` with the appropriate shift.
- `Dst0` receives the lower byte and `Dst1` the higher byte; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the transform field is shared with the single-element forms, so the reserved value `3` is rejected in the same place and for the same reason: by the form constraint, before any source is read or any probe is attempted.

<!-- PTO-READER-BLOCK: scalar-hl-lbup-effects role=effects -->
## Effects, ordering, and completion

Both source selectors are read before any memory or destination effect, so aliases use the pre-instruction values.

A successful execution records two relaxed `1`-byte load events in address order and leaves memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: all memory effects precede all destination effects, so a consumer that observes the two events knows that both bytes were read before either result was published. There is no interleaving of the two kinds of effect within the instruction.

<!-- PTO-READER-BLOCK: scalar-hl-lbup-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, a `SrcRType` of `3` is rejected by the form constraint before any source read, and an unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement to both addresses, so no address raises `Fault_DataAlignment` for this form. The permission and bounded-memory test applies to each address in ascending order, and the first failure raises `Fault_DataPage` at that original address.

A fault records no load event, publishes neither byte, and leaves `TPC` on the faulting instruction. Recovery recomputes the transform, the shift, both addresses, and both probes.

<!-- PTO-READER-BLOCK: scalar-hl-lbup-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbup [8, 9<<<3], ->10, 11` with `SrcRType` selecting `.uw`, GPR8 = `0xF000`, and GPR9 = `1`.
- The transform zero-extends `SrcR[31:0]`, which is `1`, and the shift by `3` gives an offset of `8`.
- The first address is `0xF008` and the second is `0xF009`. If the byte at `0xF008` is `FF` and the byte at `0xF009` is `01`, GPR10 receives `255` and GPR11 receives `1`.
- GPR8 and GPR9 keep their values, because this form publishes no address result.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbup_48_c9598658dde4 | HL48 | 48 | 0x00004009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbup_48_c9598658dde4 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbup_48_c9598658dde4 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbup_48_c9598658dde4 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbup_48_c9598658dde4 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbup_48_c9598658dde4 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbup_48_c9598658dde4 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbup_48_c9598658dde4 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbup_48_c9598658dde4 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbup_48_c9598658dde4.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUP() => ScalarOperation
begin
    return ScalarOperation_HL_LBUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBUP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBUP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUP()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 1; the instruction performs no base writeback.
- After both 1-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 1-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lbup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
