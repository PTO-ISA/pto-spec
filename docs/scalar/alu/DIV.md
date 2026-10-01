<!-- GENERATED FROM: asl/scalar/alu/DIV.asl -->
# DIV

**Normative ASL source:** `asl/scalar/alu/DIV.asl`

DIV computes the signed XLEN quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-div-purpose role=purpose -->
## What DIV does

`DIV` is a 32-bit L32 scalar ALU form. It reads one Reg5 dividend and one Reg5 divisor, interprets both complete `PTO_XLEN` words as signed two's-complement integers, and publishes the quotient truncated toward zero through a third Reg5 field. `DIV` produces no remainder.

Design point: `DIV` and `DIVU` share one field layout and differ only in the mnemonic and in the fixed match bits of the 32-bit encoding. Signedness is not a mode field, so no operand value can turn an unsigned divide into a signed one; the executed instruction word alone selects the interpretation.

<!-- PTO-READER-BLOCK: scalar-div-mechanism role=mechanism -->
## How the quotient is formed

Execution resolves the three selectors, reads `SrcL` and `SrcR`, and computes one value.

- `ScalarDivideSigned` returns `0` when the divisor is zero.
- Otherwise it forms the magnitude of each operand, divides the magnitudes with restoring division, and subtracts the magnitude from `0` when exactly one operand is negative.

The computed word reaches `RegDst` only after both source reads have happened.

Design point: the sign is applied after the magnitude division, so the quotient of the signed minimum (the word whose only set bit is the top bit) and `-1` is that same word. Computing `0 - minimum` in `PTO_XLEN` two's-complement returns `minimum`, and the model keeps no wider intermediate that could hold the mathematically positive result.

<!-- PTO-READER-BLOCK: scalar-div-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` is the dividend and `SrcR` is the divisor. Both use the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `RegDst` publishes the single result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard the result.

Design point: a source read never removes a queue entry, so a divisor held in `T#1` survives the instruction. Only a `30` or `31` destination shifts a queue, and that shift is what makes the pushed word the newest entry of that queue.

<!-- PTO-READER-BLOCK: scalar-div-effects role=effects -->
## Effects and ordering

Both sources are read before `RegDst` is written, so `div a0, a0, ->a0` divides the pre-instruction `a0` by itself, and a destination that aliases a source still uses the snapshotted value.

After the result is published or discarded, `TPC` advances by `4` bytes, the length of the 32-bit form. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

Design point: the divisor word selects the whole result, and a `T` or `U` divisor is read without being consumed. A divide whose `SrcR` names `T#1` therefore reads the same `T#1` word on every execution until something else changes that slot.

<!-- PTO-READER-BLOCK: scalar-div-constraints role=constraints -->
## Legality and fault boundary

Every code of `SrcL`, `SrcR` and `RegDst` is assigned, and the form adds no fixed-bit constraint beyond the match and mask of its 32-bit encoding, so `DIV` reserves no selector value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination effect and before `TPC` advances. An undecodable form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`.

Design point: no divisor value can fault. `ScalarDivideSigned` tests for a zero divisor before calling the restoring-division helper, whose assertion requires a nonzero divisor, so no `SrcR` encoding can reach that assertion.

<!-- PTO-READER-BLOCK: scalar-div-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=-13` and `a1=5`, `div a0, a1, ->a2` writes `-2` to `a2`: the magnitudes divide as `13 / 5 = 2`, and exactly one operand is negative. With `SrcR` encoded as zero the divisor is the architectural zero GPR, so, while `T#1` is available, `div t#1, zero, ->u` pushes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
div SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| div_32_a6efe85f8662 | L32 | 32 | 0x00000057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| div_32_a6efe85f8662 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| div_32_a6efe85f8662 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| div_32_a6efe85f8662 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| div_32_a6efe85f8662 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| div_32_a6efe85f8662 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| div_32_a6efe85f8662 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractOperation_DIV() => ScalarOperation
begin
    return ScalarOperation_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractHandler_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSigned;
end;
pure func InstructionContractResult_DIV(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret both complete XLEN sources as signed two-complement integers and return the quotient truncated toward zero.
- A zero divisor returns zero. Signed minimum divided by negative one returns signed minimum.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- div a0, a1, ->a2
- div t#1, zero, ->u
