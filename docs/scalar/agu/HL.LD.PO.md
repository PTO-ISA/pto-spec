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
## What `HL.LD.PO` does

`HL.LD.PO` is a `48`-bit post-indexed load of one `8`-byte little-endian value. It reads eight bytes at the `SrcL` base, publishes the complete `64`-bit pattern to `Dst0`, and publishes the updated base `SrcL + offset` to `Dst1`.

The canonical assembly is `hl.ld.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`. The offset is `SrcR` after an optional `32`-bit transform, shifted left by `shamt`.

Design point: in post-index mode the access address is the snapshot of `SrcL` alone, so the offset has no influence on whether the access is legal. An odd increment is therefore a valid post-index step for an `8`-byte load; it simply leaves `Dst1` on an address that a later access of the same kind would reject for misalignment.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-mechanism role=mechanism -->
## How the offset and the address are formed

`SrcR` is transformed by `SrcRType` and shifted left by the encoded `shamt`; the offset is added to the snapshot of `SrcL` modulo `2^PTO_XLEN`.

The effective address is the base itself, and `SrcL` is never written. The updated base exists only as the value delivered to `Dst1`.

After the encoding checks and the address preflight pass, one `8`-byte little-endian load is performed and the `64` bits are published unchanged to `Dst0`, followed by the updated base to `Dst1`.

Design point: the offset is applied through a shift, so its encoded form is a register value plus a shift amount rather than a signed displacement. A negative stride is produced by putting a negative value in `SrcR` and using the `.sw` transform, which sign-extends `SrcR[31:0]` before the shift.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and `SrcR` the offset source; both are `5`-bit Reg5 selectors over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `SrcRType` is `0` for an unchanged `SrcR`, `1` for `.sw` on `SrcR[31:0]`, or `2` for `.uw` on `SrcR[31:0]`; `3` is reserved.
- `shamt` is the `5`-bit left shift applied after the transform, giving strides from `1` to `2^31` times the transformed value.
- `Dst0` receives the loaded pattern and `Dst1` the updated base. Codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the two destinations are published in a fixed order, `Dst0` first. If both name one register, the updated base survives and the eight loaded bytes are overwritten within the same instruction, so a caller cannot rely on the loaded value in that case.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-effects role=effects -->
## Effects, ordering, and completion

The two sources are read before any memory or destination effect, so an alias between them and a destination contributes pre-instruction values.

A successful execution records one relaxed `8`-byte load event, leaving memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: the address is formed from the snapshot of `SrcL` taken before any effect, and the destination is written after the load completes. There is no window in which `Dst1` already holds the new base while the load is still outstanding, which is what makes a fault on the load leave both the base register and the destination untouched.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, a `SrcRType` of `3` is rejected by the form constraint before any source is read, and an unavailable `T` or `U` slot named by `SrcL` or `SrcR` raises the same fault before execution.

The preflight tests the low `3` bits of the effective address, which here is the base, and raises `Fault_DataAlignment` before translation and before the permission check. An `8`-byte-aligned address that fails the permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery rebuilds the transform, the shift, the base, and the load from the snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.ld.po [6, 7<<<0], ->8, 6` with `SrcRType` selecting the unchanged transform, GPR6 = `0x4000`, and GPR7 = `3`.
- The offset is `3` with no shift. The access address is the old base `0x4000`, so the odd offset raises no alignment fault here.
- GPR8 receives the `8` bytes at `0x4000` through `0x4007`, and GPR6 receives `0x4000` plus `3`, which is `0x4003`.
- A later load of this kind using `0x4003` as its base would raise `Fault_DataAlignment`, because `0x4003` is not `8`-byte aligned.
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
