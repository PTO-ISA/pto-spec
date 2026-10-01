<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.PO.asl -->
# HL.LDI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LDI.PO.asl`

HL.LDI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-purpose role=purpose -->
## What `HL.LDI.PO` does

`HL.LDI.PO` is a `48`-bit post-indexed load of one `8`-byte little-endian value with an immediate displacement. It reads eight bytes at the `SrcL` base, publishes the complete `64`-bit pattern to `Dst0`, and publishes the updated base `SrcL + 8 * simm17` to `Dst1`.

The canonical assembly is `hl.ldi.po [SrcL, simm], ->Dst0, Dst1`.

Design point: the displacement is scaled by `8`, so the immediate counts `8`-byte elements rather than bytes. The reachable window is `-524288` to `524280` bytes from the base in steps of `8`, and every one of those offsets is a multiple of the access size. An immediate-based stride therefore needs no register and still lands on addresses that the `8`-byte alignment rule accepts.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-mechanism role=mechanism -->
## How the address and the transfer are formed

The immediate is sign-extended and shifted left by `3` bits. In post-index mode the effective address is the snapshot of `SrcL`, and the scaled displacement is added to that snapshot modulo `2^PTO_XLEN` only to produce the value for `Dst1`.

`SrcL` is never written, so the base register keeps its pre-instruction value on the success and the fault path alike.

Once the encoding checks and the address preflight pass, one `8`-byte little-endian load is performed and the bytes are published unchanged to `Dst0`, followed by the updated base to `Dst1`.

Design point: an `8`-byte access on an `8`-byte-aligned base is aligned for every encodable displacement, so `Fault_DataAlignment` can only come from the base itself. A displacement that leaves the base misaligned for a later access is possible through `Dst1` only if the base was already misaligned, because the offset is always a multiple of `8`.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`; a queue source is read without being consumed.
- `simm17` is a signed `17`-bit immediate. Its assembled byte value is the signed immediate multiplied by `8`.
- `Dst0` receives the loaded pattern and `Dst1` the updated base. Codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the `8` bytes are published as one `64`-bit value, so no extension decision exists for this width and the field that records signedness has no visible effect. This form shares its operand field layout with the byte-wide immediate loads; the scale factor and the access size are what separate it from them.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is snapshotted before any memory or destination effect, so a destination that names the base still supplies the pre-instruction value to the address.

A successful execution records one relaxed `8`-byte load event and leaves memory and reservation state unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: the destination write happens after the load completes, so a fault leaves the base register and both destinations untouched. The instruction is therefore safe to retry after a page fault: the retry recomputes the same address from the same base.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and a `SrcL` code selecting an unavailable `T` or `U` slot raises the same fault before execution. No transform or shift field exists in this encoding.

The preflight tests the low `3` bits of the effective address, which for post-index mode is the base, and raises `Fault_DataAlignment` before translation and before the permission check. An aligned address that fails the permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery re-sign-extends the immediate, rescales it, and repeats the access.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.ldi.po [10, 3], ->11, 12` with GPR10 = `0x8000`. The immediate is `3`, scaled by `8` gives `24`.
- The access address is the old base `0x8000`, and the instruction reads the `8` bytes at `0x8000` through `0x8007` into GPR11.
- GPR12 receives `0x8000` plus `24`, which is `0x8018`.
- GPR10 still holds `0x8000`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_po_48_0cc539e6798d | HL48 | 48 | 0x00003019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_po_48_0cc539e6798d | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_po_48_0cc539e6798d | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldi_po_48_0cc539e6798d | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_po_48_0cc539e6798d | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_po_48_0cc539e6798d | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_po_48_0cc539e6798d | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_po_48_0cc539e6798d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_po_48_0cc539e6798d | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_PO()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_PO()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_PO()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.ldi.po [SrcL, simm], ->Dst0, Dst1
