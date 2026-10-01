<!-- GENERATED FROM: asl/scalar/agu/HL.LBP.asl -->
# HL.LBP

**Normative ASL source:** `asl/scalar/agu/HL.LBP.asl`

HL.LBP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbp-purpose role=purpose -->
## What `HL.LBP` does

`HL.LBP` is a `48`-bit load of a pair of adjacent bytes with a register-sourced offset. It forms an offset from `SrcR` and `shamt`, adds it to the `SrcL` base, reads the bytes at that sum and at that sum plus `1`, sign-extends both, and publishes the lower byte to `Dst0` and the higher byte to `Dst1`.

The canonical assembly is `hl.lbp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: this form has two destinations but no base update, unlike the single-element register-offset loads. The offset register is read and the base register is read, and neither is written; the pair of loaded bytes is the only result. A program that also wants to advance the base must do it separately.

<!-- PTO-READER-BLOCK: scalar-hl-lbp-mechanism role=mechanism -->
## How the offset and the two addresses are formed

`SrcR` is transformed by `SrcRType` and then shifted left by the encoded `shamt`. The transformed and shifted value is added to the snapshot of `SrcL` modulo `2^PTO_XLEN`, and the second address of the pair is that sum plus the access size, which is `1` byte.

Both addresses are probed in ascending order before either byte is read; the handler returns on the first fault. When both probes succeed, the two bytes are read, two relaxed load events are recorded in address order, and the results are published with `Dst0` first.

Design point: the offset transformation is applied before the shift here as well, so `.sw` and `.uw` clip `SrcR` to `32` bits and only the unchanged mode passes the complete `PTO_XLEN` value. Because the pair addresses differ by one byte, the shift amount sets the distance to the previous pair, not the spacing inside the pair.

<!-- PTO-READER-BLOCK: scalar-hl-lbp-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` the offset source, both `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` is `0` unchanged, `1` for `.sw` on `SrcR[31:0]`, or `2` for `.uw` on `SrcR[31:0]`; `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform.
- `Dst0` receives the lower byte and `Dst1` the higher byte; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: because there is no updated-base destination, both destination fields are free for loaded data. A caller that needs only one of the two bytes can discard the other one without losing any address information, since no address information is published by this form at all.

<!-- PTO-READER-BLOCK: scalar-hl-lbp-effects role=effects -->
## Effects, ordering, and completion

Both sources are snapshotted before any memory or destination effect, so an alias between `SrcR`, `SrcL`, and a destination uses pre-instruction values.

On success two relaxed `1`-byte load events are recorded in address order and memory and reservation state are unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: if both destinations name one register, the higher byte survives because `Dst1` is written last. If both name the same queue, two pushes occur and the higher byte becomes the newest entry.

<!-- PTO-READER-BLOCK: scalar-hl-lbp-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect. A `SrcRType` value of `3` is rejected by the form constraint at the same point, before any source is read, so a reserved transform cannot influence either address or either probe. An unavailable `T` or `U` slot named by `SrcL` or `SrcR` also raises that fault before execution.

The preflight applies the `1`-byte alignment requirement to both addresses, so neither can raise `Fault_DataAlignment`. A permission or bounded-memory failure on the first failing address raises `Fault_DataPage` at that original address.

A fault records no load event, publishes neither byte, and leaves `TPC` on the faulting instruction. Recovery recomputes the transform, the shift, both addresses, and both probes.

<!-- PTO-READER-BLOCK: scalar-hl-lbp-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbp [2, 3<<<1], ->4, 5` with `SrcRType` selecting `.sw`, GPR2 = `0xE000`, and GPR3 = `0xFFFFFFFFFFFFFFFE`.
- The transform sign-extends `SrcR[31:0]`, which is `0xFFFFFFFE`, to `-2`. The shift by `1` gives an offset of `-4`.
- The first address is `0xE000` minus `4`, which is `0xDFFC`, and the second is `0xDFFD`.
- If the byte at `0xDFFC` is `01` and the byte at `0xDFFD` is `80`, GPR4 receives `1` and GPR5 receives `-128`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbp_48_9d1fd0b3105b | HL48 | 48 | 0x00000009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbp_48_9d1fd0b3105b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbp_48_9d1fd0b3105b | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbp_48_9d1fd0b3105b | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbp_48_9d1fd0b3105b | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbp_48_9d1fd0b3105b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbp_48_9d1fd0b3105b | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbp_48_9d1fd0b3105b | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbp_48_9d1fd0b3105b | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbp_48_9d1fd0b3105b.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBP() => ScalarOperation
begin
    return ScalarOperation_HL_LBP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBP()
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
- After both 1-byte probes succeed, sign-extend each result at PTO_XLEN and publish first then second.
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

- hl.lbp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
