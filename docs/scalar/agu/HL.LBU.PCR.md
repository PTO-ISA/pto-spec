<!-- GENERATED FROM: asl/scalar/agu/HL.LBU.PCR.asl -->
# HL.LBU.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LBU.PCR.asl`

HL.LBU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-purpose role=purpose -->
## What `HL.LBU.PCR` does

`HL.LBU.PCR` is a `48`-bit PC-relative load of one byte with zero extension. It forms its address from the current program counter, reads one byte, places that byte in bits `7`:`0` of the `PTO_XLEN` result with all higher bits cleared, and publishes the result through `RegDst`.

The canonical assembly is `hl.lbu.pcr [<symbol>], ->{t, u, Rd}`.

Design point: a byte of `FF` published by this form becomes `255`, because bits `63`:`8` of the result are cleared. The published value is therefore never negative, and no sign bit can arrive from memory into the upper half of the word.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is the current `TPC` with bits `1`:`0` cleared. The offset is the sign-extended `29`-bit displacement shifted left by `2` bits, and the sum is taken modulo `2^PTO_XLEN`.

No base register exists and no writeback occurs, so the instruction changes no general register except through the published destination.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load and zero-extends the byte to the full word width before publishing it to `RegDst`.

Design point: because the base is `4`-byte aligned and the displacement is scaled by `4`, an encoded displacement of `0` addresses the `4`-byte-aligned block that contains the instruction itself. That is a defined address, not a missing operand: the `29`-bit field is always present in the encoding.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-inputs role=inputs-outputs -->
## Encoded fields and where the byte goes

- `RegDst` is a `5`-bit selector: codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard the value and nothing else.
- The signed `29`-bit displacement is scaled by `4`, so its assembled byte range is `-1073741824` to `1073741820` in steps of `4`.
- The base is implicit and equal to the aligned `TPC`.

Design point: pushing to the `T` or `U` queue through `RegDst` creates a new newest entry and moves the older entries one slot along, so `hl.lbu.pcr [...] ->t` is not equivalent to writing a GPR: it also changes `T#2`, `T#3`, and `T#4`.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-effects role=effects -->
## Effects, ordering, and completion

A successful execution records one relaxed load event and leaves memory and reservation state unchanged. The destination is written only when the load reported no fault.

After publication, `TPC` advances by `6` bytes, measured from the instruction address that the base was derived from.

Design point: the zero extension is applied before publication, so a queue slot or GPR receives exactly one value with a well-defined upper half; a consumer never has to mask bits `63`:`8` itself.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `48`-bit encoding raises `Fault_IllegalInstruction` before any effect. This form encodes no source selector, so no `T` or `U` availability check can reject it.

The preflight applies the alignment requirement of the access itself. A `1`-byte transfer is satisfied by every address, so no reachable address raises `Fault_DataAlignment` for this form. The address is then translated and tested for permission; a permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery re-derives the aligned base and the scaled displacement and repeats the whole operation.

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbu.pcr [<symbol>], ->t` executing at `TPC` = `0x1040` with an encoded displacement of `3`. The truncated base is `0x1040` and the assembled displacement is `12`.
- The effective address is `0x1040` plus `12`, which is `0x104C`, and the instruction reads the byte there.
- If that byte is `FF`, the value pushed as the new `T#1` is `255`, with bits `63`:`8` all zero.
- `TPC` becomes `0x1040` plus `6`, which is `0x1046`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbu.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbu_pcr_48_504b34c0ec9d | HL48 | 48 | 0x00004039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbu_pcr_48_504b34c0ec9d | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbu_pcr_48_504b34c0ec9d | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbu_pcr_48_504b34c0ec9d | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_pcr_48_504b34c0ec9d | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- hl.lbu.pcr [<symbol>], ->{t, u, Rd}
