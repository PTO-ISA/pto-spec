<!-- GENERATED FROM: asl/scalar/alu/HL.CCAT.asl -->
# HL.CCAT

**Normative ASL source:** `asl/scalar/alu/HL.CCAT.asl`

HL.CCAT logically right-shifts {SrcL, SrcR}, writes the low 64-bit result to Dst0, then writes the high result to Dst1.

## Normative identity {#PTO-INST-SCALAR-HL-CCAT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ccat-purpose role=purpose -->
## What HL.CCAT does

`HL.CCAT` is a 48-bit scalar ALU instruction. It forms one 128-bit value with `SrcL` as the upper half and `SrcR` as the lower half, shifts that value logically right by the 7-bit `shamt`, and publishes bits `63:0` to `Dst0` and bits `127:64` to `Dst1`.

Design point: the concatenation never exists as a register value. The halves are computed separately, so a shift below `64` carries the low bits of the upper half down into the top of the low result: with `SrcL` equal to `1`, `SrcR` equal to `2`, and `shamt=8`, the low result is `0x0100000000000000`.

<!-- PTO-READER-BLOCK: scalar-hl-ccat-mechanism role=mechanism -->
## How the result is formed

`InstructionContractLowResult_HL_CCAT` returns bits `63:0` and `InstructionContractHighResult_HL_CCAT` returns bits `127:64` (`asl/scalar/alu/HL.CCAT.asl:26-55`).

- For `shamt=0` the low result is `SrcR` and the high result is `SrcL`.
- For `shamt` in `1..63` the low result is `LSR(SrcR, shamt) OR LSL(SrcL, 64 - shamt)`, and the high result is `LSR(SrcL, shamt)`.
- For `shamt` in `64..127` the low result is `LSR(SrcL, shamt - 64)` and the high result is zero.

Design point: the zero shift returns the sources directly, so `hl.ccat a0, a1, 0, ->a2, a3` publishes `a1` to `a2` and `a0` to `a3`.

Design point: `shamt=127` keeps only bit 127, which is bit 63 of `SrcL`, and moves it to bit 0 of the low result. For `shamt` of `64` or more the high result is zero, so nothing reaches the high destination.

<!-- PTO-READER-BLOCK: scalar-hl-ccat-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0` receives the low result or discards it.
- `RegDst1` receives the high result or discards it.
- `SrcL` is the upper source and supplies bits `127:64`.
- `SrcR` is the lower source and supplies bits `63:0`.
- `shamt` is the 7-bit unsigned logical-right shift amount.

Both sources use the full source map: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, `28..31` select `U#1..U#4`, without consuming a queue entry. Both destinations use the common destination map: codes `1..23` write a GPR, codes `0` and `24..29` discard, code `30` pushes `U`, and code `31` pushes `T`.

Design point: in a destination position the spelling `zero` is the discard code `0`. The metadata example `hl.ccat t#1, u#1, 64, ->zero, a0` discards the low result `T#1` and writes the high result `0` to `a0`.

<!-- PTO-READER-BLOCK: scalar-hl-ccat-effects role=effects -->
## Effects and ordering

Both results are computed before either write, and the writes follow a fixed order: `Dst0` first with bits `63:0`, then `Dst1` with bits `127:64`.

Design point: the order is observable when both destinations name one place. For one GPR the `Dst1` write is final, so the register holds the high result. For one queue `Dst0` is enqueued first, so the high result becomes the newest entry.

`HL.CCAT` has no memory effect and changes no other architectural state; a discard destination has no effect. `TPC` advances by `6` bytes after both destination effects.

<!-- PTO-READER-BLOCK: scalar-hl-ccat-constraints role=constraints -->
## Legality and fault boundary

All `128` values of `shamt` are assigned and the shift fills with zeros, so no `shamt` value is reserved; every source code and destination code is assigned as well.

An encoding whose fixed bits do not match the `HL48` form does not decode, and an encoding that matches no accepted form raises `Fault_IllegalInstruction` at `PC` before any source read. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination effect and before `TPC` advances. An instruction not applicable to the active bundle faults with `Fault_BundleControl` at `TPC` (`asl/scalar/model/dispatch/top-level.asl:17-37`, `asl/scalar/model/types/operands.asl:6-19`).

Design point: the shift is total, so every `shamt` and source pair produces a defined pair of XLEN results, and the instruction has no arithmetic fault path.

<!-- PTO-READER-BLOCK: scalar-hl-ccat-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `shamt=0` there is no shift: `hl.ccat a0, a1, 0, ->a2, a3` publishes `a1` to `a2` and `a0` to `a3`.

With `a0` equal to `1`, `a1` equal to `2`, and `shamt=8`, the low result is `LSR(2, 8) OR LSL(1, 56)`, which is `0x0100000000000000`, and the high result is `LSR(1, 8)`, which is `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ccat_48_a1200d8bf5ac | HL48 | 48 | 0x0000105d000e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ccat_48_a1200d8bf5ac | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | shamt | 7 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":7}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ccat_48_a1200d8bf5ac | RegDst0 | 5 | 0–31 | none | none | ordered low-result Reg5 destination or discard | Encoded zero discards the low result. |
| hl_ccat_48_a1200d8bf5ac | RegDst1 | 5 | 0–31 | none | none | ordered high-result Reg5 destination or discard | Encoded zero discards the high result. |
| hl_ccat_48_a1200d8bf5ac | SrcL | 5 | 0–31 | none | none | upper Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccat_48_a1200d8bf5ac | SrcR | 5 | 0–31 | none | none | lower Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccat_48_a1200d8bf5ac | shamt | 7 | 0–127 | none | none | unsigned seven-bit logical-right shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | ordered low-result Reg5 destination or discard |
| RegDst1 | ordered high-result Reg5 destination or discard |
| SrcL | upper Reg5 source |
| SrcR | lower Reg5 source |
| shamt | unsigned seven-bit logical-right shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCAT.asl -->
```asl
readonly func InstructionContractOperation_HL_CCAT() => ScalarOperation
begin
    return ScalarOperation_HL_CCAT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCAT.asl -->
```asl
readonly func InstructionContractHandler_HL_CCAT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePair;
end;

pure func InstructionContractLowResult_HL_CCAT(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount == 0 then
        return right;
    elsif shift_amount < 64 then
        return LSR(right, shift_amount) OR
            LSL(left, 64 - shift_amount);
    else
        return LSR(left, shift_amount - 64);
    end;
end;

pure func InstructionContractHighResult_HL_CCAT(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount == 0 then
        return left;
    elsif shift_amount < 64 then
        return LSR(left, shift_amount);
    else
        return Zeros{PTO_XLEN};
    end;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, shamt, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- Encoded shamt zero performs no shift.

## Legality

- SrcL and SrcR independently use the complete Reg5 source map: GPR0..GPR23, T#1..T#4, and U#1..U#4.
- RegDst0 and RegDst1 independently use the common destination map: GPR writes, discard codes, U push, or T push.
- shamt 0..127 is fully assigned and zero-filling.

## State effects

- Form {SrcL, SrcR}, logically shift the 128-bit value right by shamt, publish bits 63:0 to Dst0, then publish bits 127:64 to Dst1.
- Apply the complete Reg5 destination map independently in Dst0 then Dst1 order; discard destinations have no effect.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before either destination effect; relative source reads do not consume queue entries.
- Publish Dst0 first and Dst1 second. Equal GPR destinations retain Dst1; equal queue destinations enqueue Dst0 before Dst1.
- After both destination effects, advance TPC by six bytes.

## Exceptions

- The concatenation shift is total for every shamt and raises no arithmetic exception.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.ccat a0, a1, 0, ->a2, a3
- hl.ccat t#1, u#1, 64, ->zero, a0
- hl.ccat a0, a1, 127, ->t, t
