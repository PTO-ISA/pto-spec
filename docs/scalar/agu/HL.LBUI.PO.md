<!-- GENERATED FROM: asl/scalar/agu/HL.LBUI.PO.asl -->
# HL.LBUI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LBUI.PO.asl`

HL.LBUI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBUI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-purpose role=purpose -->
## What `HL.LBUI.PO` does

`HL.LBUI.PO` is a `48`-bit post-indexed byte load with a signed `17`-bit immediate displacement and a zero-extended result. It reads one byte at the `SrcL` base, places that byte in bits `7`:`0` with the higher bits cleared, publishes it to `Dst0`, and publishes the updated base to `Dst1`.

The canonical assembly is `hl.lbui.po [SrcL, simm], ->Dst0, Dst1`.

Design point: the instruction treats two values with opposite sign conventions in one operation. The displacement is signed, so it can reach backwards and forwards in a `131072`-byte window, while the loaded byte is unsigned, so a byte of `FF` becomes `255` and never `-1`. A caller that needs the signed reading of the byte must select the other form of the same width.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-mechanism role=mechanism -->
## How the address and the transfer are formed

The immediate is sign-extended and used with a scale of `1`. In post-index mode the access address is the snapshot of `SrcL`, and the sum `SrcL + displacement` is computed modulo `2^PTO_XLEN` for publication.

`SrcL` is never written. There is no offset register, no transform field, and no shift amount in this encoding.

After the encoding checks and the address preflight pass, one `1`-byte little-endian load is performed, the byte is zero-extended to `PTO_XLEN`, and both destinations are published with `Dst0` first.

Design point: because the offset is applied as an immediate rather than through a register shift, the displacement is byte-granular and never scaled. Every byte in the window is reachable, which is what a byte-granular access needs; there is no alignment-induced gap in the reachable set.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535`, scaled by `1`.
- `Dst0` receives the zero-extended byte and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the two destination fields are independent, so the useful pointer-bump idiom works without a spare destination: encode a discard for `Dst0` when only the updated base is wanted. The load still occurs, so the discard cannot be used to skip a fault that the access would raise.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-effects role=effects -->
## Effects, ordering, and completion

The `SrcL` read precedes every memory and destination effect, so an alias uses the pre-instruction base.

A successful execution records one relaxed `1`-byte load event and leaves memory and reservation state unchanged. `TPC` advances by `6` bytes after the publications; a rejected or faulting attempt does not retire.

Design point: the zero extension is applied before publication, so the destination never contains the raw `8` bits; a later comparison against an unsigned bound in the same width works directly on the published value.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement, which every address satisfies, so this form does not raise `Fault_DataAlignment`. The translation and permission test can still fail and raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery recomputes the sign-extended immediate, the sum, and the load with no retained progress.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbui.po [12, -2], ->13, 14` with GPR12 = `0x6000`.
- The immediate is `-2`, so the updated base is `0x6000` minus `2`, which is `0x5FFE`.
- The access address is the old base `0x6000`. If the byte there is `80`, GPR13 receives `128`.
- GPR14 receives `0x5FFE`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbui.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbui_po_48_c889b4445022 | HL48 | 48 | 0x00004019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbui_po_48_c889b4445022 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbui_po_48_c889b4445022 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbui_po_48_c889b4445022 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbui_po_48_c889b4445022 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbui_po_48_c889b4445022 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_po_48_c889b4445022 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_po_48_c889b4445022 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbui_po_48_c889b4445022 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBUI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBUI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUI_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUI_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lbui.po [SrcL, simm], ->Dst0, Dst1
