<!-- GENERATED FROM: asl/scalar/agu/HL.LB.PR.asl -->
# HL.LB.PR

**Normative ASL source:** `asl/scalar/agu/HL.LB.PR.asl`

HL.LB.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LB-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-purpose role=purpose -->
## What `HL.LB.PR` does

`HL.LB.PR` is a `48`-bit pre-indexed byte load. It builds an offset from `SrcR` and `shamt`, adds it to the `SrcL` base, reads one byte at that sum, sign-extends the byte to `PTO_XLEN`, and publishes the loaded value to `Dst0` and the same sum to `Dst1`.

The canonical assembly is `hl.lb.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: the address used for the access and the value published to `Dst1` are the same quantity, computed once. Pre-index therefore does not mean "read at the old base and publish the new one"; it means "read and publish at the new base". A fault on that address publishes nothing, so a reissue recomputes the identical address from the unchanged `SrcL` instead of advancing twice.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-mechanism role=mechanism -->
## How the offset and the address are formed

`SrcR` is transformed according to `SrcRType` and then shifted left by the encoded `shamt`; the resulting offset is added to the snapshot of `SrcL` modulo `2^PTO_XLEN`.

That sum is the effective address. `SrcL` itself is never written, so the pre-index update reaches the register file only through `Dst1`.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, sign-extends bit `7`, publishes `Dst0` with the loaded value, and publishes `Dst1` with the updated base.

Design point: because the base is only read from `SrcL` and the updated value is delivered to a separate destination, this form cannot lose an update to a fault. The access depends on the sum, but the base register itself is never advanced, so a reissue after a fault recomputes the same sum from the same unchanged `SrcL` rather than moving the pointer twice.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` is the offset source; both are `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` transforms the offset: `0` unchanged, `1` sign-extends `SrcR[31:0]`, `2` zero-extends `SrcR[31:0]`, and `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform.
- `Dst0` receives the sign-extended byte and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that single result.

Design point: if `Dst1` names `SrcR`, the offset still comes from the pre-instruction `SrcR`, because both sources are read before either publication. The same holds when `Dst1` names `SrcL`, which is the usual pointer-bump idiom: the old base is read for the sum and the new one replaces it afterwards.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-effects role=effects -->
## Effects, ordering, and completion

The `SrcL` and `SrcR` reads precede every memory and destination effect, so aliases observe pre-instruction values.

A successful execution records one relaxed `1`-byte load event and leaves memory and reservation state unchanged. `Dst0` is written before `Dst1`, so a shared destination ends up holding the updated base.

`TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: the loaded value and the updated base are published in a fixed order rather than simultaneously, which makes the aliasing case defined instead of unspecified. There is no option to reverse the order.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and a `SrcRType` of `3` is rejected by the form constraint at the same point without reading a source. An unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement, which every address meets, so this form does not raise `Fault_DataAlignment`. The translation and permission test can still fail and raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither destination, and leaves `TPC` on the faulting instruction. Recovery recomputes the transform, the shift, the sum, and the load from the same snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lb.pr [8, 9<<<4], ->10, 8` with `SrcRType` selecting the zero-extended transform, GPR8 = `0x9000`, and GPR9 = `3`.
- The transform zero-extends `SrcR[31:0]`, which is `3`, and the shift by `4` gives an offset of `48`.
- The effective address is `0x9000` plus `48`, which is `0x9030`. The byte there is sign-extended into GPR10, and GPR8 receives the same `0x9030` because `Dst1` names the base register.
- GPR9 still holds `3`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lb.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lb_pr_48_cf73675cad50 | HL48 | 48 | 0x00000009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lb_pr_48_cf73675cad50 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lb_pr_48_cf73675cad50 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lb_pr_48_cf73675cad50 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_pr_48_cf73675cad50 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_pr_48_cf73675cad50 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lb_pr_48_cf73675cad50 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lb_pr_48_cf73675cad50 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lb_pr_48_cf73675cad50 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lb_pr_48_cf73675cad50.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LB_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LB_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LB_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LB_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LB_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LB_PR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LB_PR()
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
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- hl.lb.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
