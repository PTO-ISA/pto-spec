<!-- GENERATED FROM: asl/scalar/alu/HL.XORIW.asl -->
# HL.XORIW

**Normative ASL source:** `asl/scalar/alu/HL.XORIW.asl`

HL.XORIW applies word bitwise exclusive-or to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-XORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-xoriw-purpose role=purpose -->
## What HL.XORIW does

`HL.XORIW` is a 48-bit scalar ALU instruction that applies word exclusive-or to `SrcL[31:0]` and the low word of the sign-extended `simm24`, then sign-extends the 32-bit result to XLEN and publishes it through one Reg5 destination.

The result is a `32`-bit value that is widened afterwards, so the published high half is a copy of result bit `31` rather than a copy of `SrcL[63:32]`.

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_XORIW`, which builds `right = SignExtend{PTO_XLEN}(immediate)` and returns `ScalarBinaryW(ScalarBinary_XOR, left, right)`. `ScalarBinaryW` exclusive-ors `left[31:0]` with `right[31:0]` into a 32-bit value and returns `SignExtend{PTO_XLEN}` of it. Dispatch selects the path with `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR, ScalarField_simm24, TRUE)`.

```asm
hl.xoriw SrcL, simm, ->{t, u, Rd}
```

Design point: the word result clears the source's upper half unless the word result sets bit `31`. With `a0 = 0x00000000F0F0F0F0` and `simm24 = -1`, the operand word is `0xFFFFFFFF`, the word result is `0x0F0F0F0F`, and the published value is `0x000000000F0F0F0F`, while `hl.xori` on the same source publishes `0xFFFFFFFF0F0F0F0F`.

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the sign-extended word result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies a value whose bits `31:0` participate.
- `simm24`, instruction slices `[36 +: 12]` and `[4 +: 12]`, supplies value bits `11:0` and `23:12`.

`SrcL` is read through the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, leaving the entry in place. Encoded zero reads the architectural zero GPR.

Design point: only the low word of the immediate operand reaches the exclusive-or, so the sign extension of the immediate is invisible here while the sign extension of the result is not. Bits `31:24` of that operand word are copies of `simm24` bit `23`.

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a destination that also names `SrcL` receives a value derived from the pre-instruction register contents.

The widened word is published through `RegDst`, and `TPC` then advances by `6` bytes. No memory is accessed, and no numeric-status, reservation, descriptor, Tile, bundle, privilege or control-flow state changes; only the `T` or `U` push selected by the destination can alter a queue.

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes and all `32` `RegDst` codes are assigned, and every signed 24-bit immediate is legal, so only an unavailable temporary source can fail the operand checks. Fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: the word form and the XLEN form share the same immediate range and the same two fault checks. The `W` suffix narrows which bits are combined and widens the result again by sign extension; it does not add or remove any legality rule.

<!-- PTO-READER-BLOCK: scalar-hl-xoriw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0x00000000F0F0F0F0` and `simm24 = -1`, the operand word is `0xFFFFFFFF`, the word result is `0x0F0F0F0F`, and `RegDst` receives `0x000000000F0F0F0F`. With `SrcL = 0xFFFFFFFF00000000` and `simm24 = 0`, only the low words participate: the word result is `0`, so `RegDst` receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.xoriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_xoriw_48_9a3edbd09746 | HL48 | 48 | 0x00004035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_xoriw_48_9a3edbd09746 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_xoriw_48_9a3edbd09746 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_xoriw_48_9a3edbd09746 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_xoriw_48_9a3edbd09746 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_xoriw_48_9a3edbd09746 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_xoriw_48_9a3edbd09746 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.XORIW.asl -->
```asl
readonly func InstructionContractOperation_HL_XORIW() => ScalarOperation
begin
    return ScalarOperation_HL_XORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.XORIW.asl -->
```asl
readonly func InstructionContractHandler_HL_XORIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_XORIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_XORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_XORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_XORIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_XOR,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm24, and RegDst are required encoded fields; no field can be omitted.
- simm24 has the complete signed 24-bit range -8388608 through 8388607; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every signed 24-bit two's-complement value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise exclusive-or modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.XORIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.xoriw a0, -1, ->a0
- hl.xoriw t#1, -8388608, ->u
- hl.xoriw zero, 8388607, ->zero
