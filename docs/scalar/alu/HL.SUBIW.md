<!-- GENERATED FROM: asl/scalar/alu/HL.SUBIW.asl -->
# HL.SUBIW

**Normative ASL source:** `asl/scalar/alu/HL.SUBIW.asl`

HL.SUBIW applies word subtraction to SrcL[31:0] and the low word of a zero-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-subiw-purpose role=purpose -->
## What HL.SUBIW does

`HL.SUBIW` is a 48-bit scalar ALU instruction that subtracts the low word of a zero-extended `uimm24` from `SrcL[31:0]` modulo `2^32`, sign-extends bit `31` of that word difference, and publishes the XLEN result through one Reg5 destination.

`SrcL` contributes only its low `32` bits, and the immediate contributes only its low `24` bits because the rest of the zero-extended field is zero.

<!-- PTO-READER-BLOCK: scalar-hl-subiw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_SUBIW`, which builds `right = ZeroExtend{PTO_XLEN}(immediate)` and returns `ScalarBinaryW(ScalarBinary_SUB, left, right)`. `ScalarBinaryW` subtracts the two low words into a 32-bit value and returns `SignExtend{PTO_XLEN}` of it. Dispatch selects the path with `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB, ScalarField_uimm24, TRUE)`.

```asm
hl.subiw SrcL, uimm, ->{t, u, Rd}
```

Design point: the underflow is confined to the word and then broadcast by the sign extension. `hl.subiw zero, 1, ->a0` publishes `0xFFFFFFFFFFFFFFFF`, all `64` bits set, even though only one bit of borrow was generated in the low word.

<!-- PTO-READER-BLOCK: scalar-hl-subiw-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the sign-extended word result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies a value whose bits `31:0` participate.
- `uimm24`, instruction slices `[36 +: 12]` and `[4 +: 12]`, supplies value bits `11:0` and `23:12`.

`SrcL` is read through the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, without consuming the entry. An encoded zero reads architectural GPR zero.

Design point: `SrcL[63:32]` is outside the operation. Two registers that agree in their low word produce the same published value under `HL.SUBIW`, however much their upper halves differ.

<!-- PTO-READER-BLOCK: scalar-hl-subiw-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a destination that also names `SrcL` observes the pre-instruction value.

The sign-extended difference is published through `RegDst`, and `TPC` then advances by `6` bytes. `HL.SUBIW` performs no memory access and changes no numeric-status, reservation, descriptor, Tile, bundle, privilege or control-flow state; the only queue change it can make is the `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-hl-subiw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes and all `32` `RegDst` codes are assigned, and every unsigned 24-bit immediate is legal, so only an unavailable temporary source can fail the operand checks. Fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. A word underflow is not an exception.

Design point: the extension of the immediate is still zero, so the word form shares the unsigned rule of `HL.SUBI` and not the signed rule of `HL.ORIW`. The only difference the `W` suffix makes is which source bits and which result bits are kept.

<!-- PTO-READER-BLOCK: scalar-hl-subiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 3` and `uimm24 = 5`, the word difference is `-2`, `SignExtend(0xFFFFFFFE)` is `0xFFFFFFFFFFFFFFFE`, and `RegDst` receives that value. With `SrcL` held at the architectural zero GPR and `uimm24 = 1`, the word underflows to `0xFFFFFFFF`, so `RegDst` receives `0xFFFFFFFFFFFFFFFF`. With `uimm24 = 0` the published value is `SignExtend(SrcL[31:0])`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | HL48 | 48 | 0x00001035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractOperation_HL_SUBIW() => ScalarOperation
begin
    return ScalarOperation_HL_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractHandler_HL_SUBIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_SUBIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_SUBIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_SUB,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm24, and RegDst are required encoded fields; no field can be omitted.
- uimm24 has the complete unsigned 24-bit range 0 through 16777215; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every unsigned 24-bit value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the zero-extended uimm24, compute word subtraction modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.SUBIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.subiw a0, 1, ->a0
- hl.subiw t#1, 16777215, ->u
- hl.subiw zero, 0, ->zero
