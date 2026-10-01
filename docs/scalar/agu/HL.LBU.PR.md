<!-- GENERATED FROM: asl/scalar/agu/HL.LBU.PR.asl -->
# HL.LBU.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBU.PR.asl`

HL.LBU.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBU-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-purpose role=purpose -->
## What `HL.LBU.PR` does

`HL.LBU.PR` is a `48`-bit pre-indexed byte load with zero extension. It forms an offset from `SrcR` and `shamt`, adds it to `SrcL`, reads one byte at that sum, zero-extends the byte, and publishes the byte to `Dst0` and the sum to `Dst1`.

The canonical assembly is `hl.lbu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: the sum is formed modulo `2^PTO_XLEN`, so a displacement that carries past the top of the address space wraps to a low address instead of being rejected. The wrap itself raises nothing; the wrapped address is then subject to the same preflight as any other, so a wrap that lands outside the permitted region shows up as `Fault_DataPage` and not as a distinct overflow fault.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-mechanism role=mechanism -->
## How the offset and the address are formed

`SrcR` is transformed by `SrcRType`, shifted left by the encoded `shamt`, and added to the snapshot of `SrcL`. That sum is both the address of the access and the value published to `Dst1`.

`SrcL` is only read; the base register keeps its value on the success and the fault path alike.

After the encoding checks and the address preflight pass, one `1`-byte little-endian load is performed, the byte is zero-extended to the word width, and both destinations are published in the order `Dst0` then `Dst1`.

Design point: the shift amount is a `5`-bit field, so the offset spans at most a factor of `2^31`. Combined with the `.uw` transform, which keeps only `SrcR[31:0]`, the largest positive offset that path can produce is `0x7FFFFFFF80000000`, reached with `shamt` of `31` and `SrcR[31:0]` equal to `0xFFFFFFFF`. Larger strides must be built by changing the base instead.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` the offset source, both `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` is `0` unchanged, `1` for `.sw`, or `2` for `.uw` applied to `SrcR[31:0]`; `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform.
- `Dst0` receives the zero-extended byte and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the offset cannot come from an immediate; this form always takes it from a register. A stride that is a compile-time constant therefore needs a register to hold it, and the register must be live for the whole loop because the shift amount is encoded rather than the displacement itself.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-effects role=effects -->
## Effects, ordering, and completion

Both sources are snapshotted before any memory or destination effect, so an alias between `SrcR`, `SrcL`, and a destination uses pre-instruction values.

On success one relaxed `1`-byte load event is recorded and memory and reservation state are unchanged. `TPC` advances by `6` bytes after the two publications; a rejected or faulting attempt does not retire.

Design point: because `Dst1` is written after `Dst0`, naming one register for both results leaves the updated base in it. That is a defined outcome of the write order rather than a conflict, so a pointer bump can be combined with a loaded value that is known to be superseded.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, a `SrcRType` of `3` is rejected by the form constraint before any source read, and an unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement, which every address meets, so no address raises `Fault_DataAlignment` for this form. The translation and permission test can still fail and raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery rebuilds the transform, the shift, the sum, and the load from the snapshots with no retained progress.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbu.pr [15, 16<<<31], ->17, 15` with `SrcRType` selecting `.uw`, GPR15 = `0x1000`, and GPR16 = `1`.
- The transform zero-extends `SrcR[31:0]`, which is `1`, and the shift by `31` gives an offset of `0x80000000`, which is `2147483648`.
- The effective address is `0x1000` plus `0x80000000`, which is `0x80001000`. The byte there is zero-extended into GPR17, and GPR15 receives `0x80001000` because `Dst1` names the base register.
- GPR16 still holds `1`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbu_pr_48_bf9a0ea4b0db | HL48 | 48 | 0x00004009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbu_pr_48_bf9a0ea4b0db | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbu_pr_48_bf9a0ea4b0db | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbu_pr_48_bf9a0ea4b0db.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PR()
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
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.lbu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
