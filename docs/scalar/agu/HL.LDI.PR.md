<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.PR.asl -->
# HL.LDI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LDI.PR.asl`

HL.LDI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-purpose role=purpose -->
## What `HL.LDI.PR` does

`HL.LDI.PR` is a `48`-bit pre-indexed load of one `8`-byte little-endian value with an immediate displacement. It scales the immediate by `8`, adds it to the `SrcL` base, reads eight bytes at the sum, publishes the `64`-bit pattern to `Dst0`, and publishes the same sum to `Dst1`.

The canonical assembly is `hl.ldi.pr [SrcL, simm], ->Dst0, Dst1`.

Design point: because the offset is always a multiple of `8`, an `8`-byte-aligned base stays `8`-byte aligned after the update. A loop that feeds `Dst1` back into `SrcL` therefore keeps every access aligned, and no iteration can be rejected for misalignment as long as the first base was aligned.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-mechanism role=mechanism -->
## How the address and the transfer are formed

The signed `17`-bit immediate is sign-extended and shifted left by `3` bits, then added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. That sum is the access address and the value delivered to `Dst1`.

`SrcL` is only read. The register file changes only through the destination fields, and the base change reaches it only if `Dst1` names a register.

After the encoding checks and the address preflight pass, the handler performs one `8`-byte little-endian load and publishes `Dst0` before `Dst1`.

Design point: the scale makes the immediate an element index rather than a byte count. An immediate of `1` means one element, which is `8` bytes, so a single-byte step is impossible to express here: every reachable displacement is a multiple of `8`.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535` elements, which is `-524288` to `524280` bytes after scaling by `8`.
- `Dst0` receives the loaded pattern and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: an immediate of `0` leaves `SrcL` unchanged and the access at the base, so `Dst1` republishes the base. The zero is an element count, not an absent displacement, and this form has no alternative address source to fall back on.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so `SrcL` aliasing either destination still supplies the pre-instruction base to the address.

Success records one relaxed `8`-byte load event and leaves memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after both publications, and a rejected or faulting attempt does not retire.

Design point: the loaded bytes are published unchanged, so the destination holds the exact memory image of the eight bytes; no normalization step can alter the value at this width.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution. The encoding has no transform or shift field, so no other value can be reserved.

The preflight tests the low `3` bits of the effective address, which here is the sum, and raises `Fault_DataAlignment` before translation and before the permission check. An `8`-byte-aligned address that fails the permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery rescales the immediate and recomputes the complete sum, because `SrcL` was never advanced.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.ldi.pr [13, 2], ->14, 13` with GPR13 = `0x9000`. The immediate is `2` elements, scaled by `8` gives `16`.
- The effective address is `0x9000` plus `16`, which is `0x9010` and is `8`-byte aligned.
- GPR14 receives the `8` bytes at `0x9010` through `0x9017`, and GPR13 receives `0x9010` because `Dst1` names the base register.
- `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_pr_48_d07cced5a281 | HL48 | 48 | 0x00003019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_pr_48_d07cced5a281 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_pr_48_d07cced5a281 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldi_pr_48_d07cced5a281 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_pr_48_d07cced5a281 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_pr_48_d07cced5a281 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_pr_48_d07cced5a281 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_pr_48_d07cced5a281 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_pr_48_d07cced5a281 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_PR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_PR()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_PR()
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
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.ldi.pr [SrcL, simm], ->Dst0, Dst1
