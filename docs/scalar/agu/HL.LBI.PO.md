<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.PO.asl -->
# HL.LBI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LBI.PO.asl`

HL.LBI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-purpose role=purpose -->
## What `HL.LBI.PO` does

`HL.LBI.PO` is a `48`-bit post-indexed byte load with a signed `17`-bit immediate displacement. It reads one byte at the `SrcL` base, sign-extends it to `PTO_XLEN`, publishes the byte to `Dst0`, and publishes the updated base `SrcL + simm17` to `Dst1`.

The canonical assembly is `hl.lbi.po [SrcL, simm], ->Dst0, Dst1`.

Design point: the displacement is encoded in the instruction rather than read from a register. This form therefore has one source selector, `SrcL`, and no `SrcR` and no shift amount, so there is no transform field that could be reserved and no second source whose availability could reject the instruction. The whole displacement range is available without spending a register on it.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `17`-bit immediate, used without scaling. In post-index mode the access uses the snapshot of `SrcL`, and `SrcL + displacement` is computed modulo `2^PTO_XLEN` for publication only.

`SrcL` is never written, so the updated base exists only as the value delivered to `Dst1`.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, sign-extends bit `7`, and publishes `Dst0` then `Dst1`.

Design point: the scale factor is `1`, so every byte displacement from `-65536` to `65535` is reachable, and because a `1`-byte access has no alignment requirement, no value in that window is ever refused by the preflight. The byte granularity of the immediate matches the byte granularity of the access exactly.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`; reading a queue entry does not consume it.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535`; the scale is `1`.
- `Dst0` receives the sign-extended byte and `Dst1` the updated base. Codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the two destinations are separate fields, so a load used only to step a pointer can discard `Dst0`. The access still happens and the load event is still recorded; discarding suppresses the publication of the byte, not the memory reference.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so a destination that names `SrcL` still contributes the pre-instruction base to the address.

A successful execution records one relaxed `1`-byte load event and leaves memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: `Dst0` is published before `Dst1`, so one register named for both results ends up holding the updated base. The loaded byte is not lost from memory, only from that register.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `48`-bit encoding raises `Fault_IllegalInstruction` before any effect, and a `SrcL` code selecting an unavailable `T` or `U` slot raises the same fault before execution. This form encodes no transform and no shift, so nothing else can be rejected at that stage.

The preflight applies the `1`-byte alignment requirement, which every address satisfies, so this form does not raise `Fault_DataAlignment`. The translation and permission test can still fail and raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery recomputes the displacement, the sum, and the load from the snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbi.po [2, -1], ->3, 4` with GPR2 = `0x7000`. The immediate is `-1`, so the updated base is `0x7000` minus `1`, which is `0x6FFF`.
- The access address is the old base `0x7000`, not the updated base, because the mode is post-index.
- If the byte at `0x7000` is `80`, GPR3 receives `-128`, which is `0xFFFFFFFFFFFFFF80`.
- GPR4 receives `0x6FFF`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbi.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_po_48_afbc00c48aba | HL48 | 48 | 0x00000019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_po_48_afbc00c48aba | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_po_48_afbc00c48aba | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbi_po_48_afbc00c48aba | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_po_48_afbc00c48aba | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbi_po_48_afbc00c48aba | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_po_48_afbc00c48aba | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_po_48_afbc00c48aba | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbi_po_48_afbc00c48aba | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBI_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBI_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBI_PO()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBI_PO()
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

- hl.lbi.po [SrcL, simm], ->Dst0, Dst1
