<!-- GENERATED FROM: asl/scalar/agu/HL.LBU.PO.asl -->
# HL.LBU.PO

**Normative ASL source:** `asl/scalar/agu/HL.LBU.PO.asl`

HL.LBU.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBU-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-purpose role=purpose -->
## What `HL.LBU.PO` does

`HL.LBU.PO` is a `48`-bit post-indexed byte load with zero extension. It reads one byte at the `SrcL` base, places that byte in bits `7`:`0` of the result with the higher bits cleared, publishes the byte to `Dst0` and the updated base to `Dst1`.

The canonical assembly is `hl.lbu.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: the instruction contains two independent extension decisions, and they apply to different values. `SrcRType` extends the offset register `SrcR`, while the loaded byte is always zero-extended because the form is an unsigned load. A negative offset and a byte value of `255` can therefore appear in the same execution: the offset reaches backwards while the result stays non-negative.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-mechanism role=mechanism -->
## How the offset and the address are formed

The offset is `SrcR` transformed by `SrcRType` and then shifted left by the encoded `shamt`. In post-index mode the access uses the snapshot of `SrcL`, and `SrcL + offset` is computed modulo `2^PTO_XLEN` purely for publication.

`SrcL` is never written, so the only way the updated base reaches a register or a queue is through `Dst1`.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, zero-extends the byte, and publishes both results.

Design point: the unchanged mode `0` passes the complete `PTO_XLEN` value of `SrcR` to the shift, while modes `1` and `2` keep only `SrcR[31:0]`. An offset built in the upper half of a register therefore survives only in mode `0`; switching a descriptor between `.sw` or `.uw` and no modifier changes the address even when `SrcR` itself is unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` the offset source, both `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` is `0` unchanged, `1` for `.sw` on `SrcR[31:0]`, or `2` for `.uw` on `SrcR[31:0]`; `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform, so the offset can be scaled by any power of two from `1` to `2^31`.
- `Dst0` receives the zero-extended byte and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: because the destination codes are independent, `Dst0` may be a discard while `Dst1` still writes a register. The memory access happens either way; only the publication of the byte is skipped.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-effects role=effects -->
## Effects, ordering, and completion

Both source selectors are read before any memory or destination effect, so aliases use pre-instruction values. On success one relaxed `1`-byte load event is recorded and memory and reservation state are unchanged.

`Dst0` is published before `Dst1`. `TPC` advances by `6` bytes after both publications, and a rejected or faulting attempt does not retire.

Design point: the zero extension is part of the published value, not a property of the memory system, so the queue or register holding the result already satisfies any unsigned comparison; no later masking step is required and no state records that the value came from one byte.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, a `SrcRType` of `3` is rejected by the form constraint before any source is read, and an unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement, which every address satisfies, so this form does not raise `Fault_DataAlignment`. The permission and bounded-memory test still applies and raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery recomputes the transform, the shift, the sum, and the load.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbu.po [11, 12<<<0], ->13, 14` with `SrcRType` selecting `.sw`, GPR11 = `0xA000`, and GPR12 = `0xFFFFFFFFFFFFFFFF`.
- The transform sign-extends `SrcR[31:0]`, which is `0xFFFFFFFF`, to `-1`. The shift amount is `0`, so the offset is `-1`.
- The access address is the old base `0xA000`. If the byte there is `FF`, GPR13 receives `255` with all higher bits clear.
- GPR14 receives `0xA000` minus `1`, which is `0x9FFF`, and GPR11 still holds `0xA000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbu.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbu_po_48_5c8a5b39e6c5 | HL48 | 48 | 0x00004009003e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbu_po_48_5c8a5b39e6c5 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbu_po_48_5c8a5b39e6c5 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbu_po_48_5c8a5b39e6c5.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PO()
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
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lbu.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
