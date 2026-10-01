<!-- GENERATED FROM: asl/scalar/agu/HL.LB.PO.asl -->
# HL.LB.PO

**Normative ASL source:** `asl/scalar/agu/HL.LB.PO.asl`

HL.LB.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LB-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lb-po-purpose role=purpose -->
## What `HL.LB.PO` does

`HL.LB.PO` is a `48`-bit post-indexed byte load. It reads one byte at the value of the `SrcL` base, sign-extends that byte to `PTO_XLEN`, and publishes two independent results: the loaded value to `Dst0` and the updated base `SrcL + offset` to `Dst1`.

The canonical assembly is `hl.lb.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`. The offset is built from a second register, `SrcR`, whose low `32` bits can optionally be extended, followed by a left shift.

Design point: post-index reads at the old base and publishes the new base afterwards. The base register is only read, so `SrcL` itself never changes; naming `SrcL` as `Dst1` puts the updated value there only after the load completes.

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-mechanism role=mechanism -->
## How the offset and the address are formed

The offset is built in two steps: `SrcR` is first transformed according to `SrcRType`, then the transformed value is shifted left by the encoded `shamt`. The sum `SrcL + offset` is taken modulo `2^PTO_XLEN`.

For post-index addressing the effective address is the snapshot of `SrcL`, and `Dst1` receives `SrcL + offset`. The base selector `SrcL` is never written by this instruction.

After the encoding checks and the address preflight pass, one `1`-byte little-endian load is performed, bit `7` is sign-extended, and both publications happen.

Design point: the transform runs before the shift, so `SrcRType` clips `SrcR` to `32` bits and the shift then scales the clipped value. In `.sw` and `.uw` the bits above `31` can never influence the address, and a nonzero transformed offset stays nonzero, because `32` bits shifted by at most `31` cannot leave the `64`-bit word.

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the address base and `SrcR` the offset source; both are `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`. A queue selector is read without being consumed.
- `SrcRType` selects the transform: `0` unchanged, `1` sign-extends `SrcR[31:0]`, `2` zero-extends `SrcR[31:0]`; the fourth encoding is reserved.
- `shamt` is the `5`-bit left shift applied after the transform.
- `Dst0` receives the sign-extended byte and `Dst1` the updated base. Codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that one result.

Design point: the two destinations are encoded separately, so a load whose only purpose is to advance a pointer can discard `Dst0` and still receive the updated base in `Dst1`. Discarding `Dst0` removes the publication, not the memory access.

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-effects role=effects -->
## Effects, ordering, and completion

`SrcL` and `SrcR` are both read before any memory or destination effect, so any alias between a source and a destination uses the pre-instruction values.

On success one relaxed `1`-byte load event is recorded, and memory and reservation state are unchanged. `Dst0` is published first and `Dst1` second.

`TPC` advances by `6` bytes after both publications. A rejected or faulting attempt does not retire.

Design point: because the updated base is written after the loaded value, a program that names the same register for `Dst0` and `Dst1` ends with the updated base in that register and the loaded byte lost. There is no encoding that produces the opposite order.

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and a `SrcRType` of `3` is rejected by the form constraint before any source is read, so a reserved transform cannot influence an address or a probe. An unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement, which every address satisfies, so this form does not raise `Fault_DataAlignment`. A permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery recomputes the transform, the shift, the address, and the load from the snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lb.po [1, 2<<<3], ->3, 4` with `SrcRType` selecting the sign-extended transform, GPR1 = `0x8000`, and GPR2 = `0xFFFFFFFFFFFFFFFE`.
- The transform takes `SrcR[31:0]`, which is `0xFFFFFFFE`, and sign-extends it to `-2`. The shift by `3` gives an offset of `-16`.
- The access address is the old base `0x8000`. The byte there is sign-extended into GPR3, and GPR4 receives `0x8000` minus `16`, which is `0x7FF0`.
- GPR1 still holds `0x8000`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lb.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lb_po_48_5c7f5c82b186 | HL48 | 48 | 0x00000009003e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lb_po_48_5c7f5c82b186 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lb_po_48_5c7f5c82b186 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lb_po_48_5c7f5c82b186 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_po_48_5c7f5c82b186 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_po_48_5c7f5c82b186 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lb_po_48_5c7f5c82b186 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lb_po_48_5c7f5c82b186 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lb_po_48_5c7f5c82b186 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lb_po_48_5c7f5c82b186.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LB_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LB_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LB_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LB_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LB_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LB_PO()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LB_PO()
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

- hl.lb.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
