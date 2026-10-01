<!-- GENERATED FROM: asl/scalar/alu/HL.ORIW.asl -->
# HL.ORIW

**Normative ASL source:** `asl/scalar/alu/HL.ORIW.asl`

HL.ORIW applies word bitwise inclusive-or to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-oriw-purpose role=purpose -->
## What HL.ORIW does

`HL.ORIW` is a 48-bit scalar ALU instruction that applies word inclusive-or to `SrcL[31:0]` and the low word of the sign-extended `simm24`, then sign-extends the 32-bit result to XLEN and publishes it through one Reg5 destination.

Only `32` result bits are computed, but the published word is a full XLEN value whose upper half repeats bit `31` of that result.

<!-- PTO-READER-BLOCK: scalar-hl-oriw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_ORIW`, which builds `right = SignExtend{PTO_XLEN}(immediate)` and returns `ScalarBinaryW(ScalarBinary_OR, left, right)`. `ScalarBinaryW` takes `left[31:0]` and `right[31:0]`, or-combines them into a 32-bit value, and returns `SignExtend{PTO_XLEN}` of that value. Dispatch selects the path with `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR, ScalarField_simm24, TRUE)`.

```asm
hl.oriw SrcL, simm, ->{t, u, Rd}
```

Design point: the upper half of the sign-extended immediate is discarded before the or, so extending the immediate changes nothing here. What the sign extension of the result does change is the published high half: `hl.oriw a0, 0, ->a0` with `a0 = 0x00000000FFFFFFFF` publishes `0xFFFFFFFFFFFFFFFF`, because bit `31` of the word result is `1`.

<!-- PTO-READER-BLOCK: scalar-hl-oriw-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the sign-extended word result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies a value whose bits `31:0` participate.
- `simm24`, instruction slices `[36 +: 12]` and `[4 +: 12]`, supplies value bits `11:0` and `23:12`.

`SrcL` is read through the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, without consuming a queue entry. Encoded zero reads the architectural zero GPR.

Design point: the operand word is the sign-extended immediate's low `32` bits, so bits `31:24` of that operand repeat bit `23` of `simm24`. A non-negative immediate therefore contributes zeros above bit `23`, while a negative one contributes ones.

<!-- PTO-READER-BLOCK: scalar-hl-oriw-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a destination that names `SrcL` receives the result of the pre-instruction value.

The sign-extended result is published through `RegDst`, and `TPC` then advances by `6` bytes. The instruction has no memory effect and no numeric-status effect; only the destination-selected `T` or `U` push can change a queue.

<!-- PTO-READER-BLOCK: scalar-hl-oriw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes and all `32` `RegDst` codes are assigned, and every signed 24-bit immediate is legal, so only an unavailable temporary source can fail the operand checks. Fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. No arithmetic exception is defined for any operand pair.

Design point: the word form still costs the same fault surface as the XLEN form. Narrowing the arithmetic to `32` bits removes result bits, not legality checks, so the immediate range `-8388608` through `8388607` is unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-oriw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0x00000000FFFFFFFF` and `simm24 = 0`, the or leaves the word unchanged at `0xFFFFFFFF`, and `SignExtend` of that word is `0xFFFFFFFFFFFFFFFF`, so `RegDst` receives `0xFFFFFFFFFFFFFFFF`. With `SrcL = 0` and `simm24 = 8388607`, the operand word is `0x007FFFFF`, the word result is `0x007FFFFF`, and `RegDst` receives `0x00000000007FFFFF`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.oriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_oriw_48_17673d186249 | HL48 | 48 | 0x00003035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_oriw_48_17673d186249 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_oriw_48_17673d186249 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_oriw_48_17673d186249 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_oriw_48_17673d186249 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_oriw_48_17673d186249 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_oriw_48_17673d186249 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ORIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ORIW() => ScalarOperation
begin
    return ScalarOperation_HL_ORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ORIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ORIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ORIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ORIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_OR,
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

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise inclusive-or modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ORIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.oriw a0, -1, ->a0
- hl.oriw t#1, -8388608, ->u
- hl.oriw zero, 8388607, ->zero
