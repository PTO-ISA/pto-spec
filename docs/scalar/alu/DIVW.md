<!-- GENERATED FROM: asl/scalar/alu/DIVW.asl -->
# DIVW

**Normative ASL source:** `asl/scalar/alu/DIVW.asl`

DIVW computes the signed low-32-bit quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIVW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-divw-purpose role=purpose -->
## What DIVW does

`DIVW` is a 32-bit L32 form that divides the low word of two Reg5 sources as signed integers and publishes one sign-extended `PTO_XLEN` result. Bits `63` through `32` of both sources are ignored.

Design point: the mnemonic fixes the operand width as well as the signedness. Two registers that agree in their low words produce the same quotient even when their upper words differ, so a `DIVW` result is a function of `32` bits of each source rather than of `64`.

<!-- PTO-READER-BLOCK: scalar-divw-mechanism role=mechanism -->
## How the quotient is formed

Execution sign-extends `SrcL[31:0]` and `SrcR[31:0]` to `PTO_XLEN` and divides those two words with the same total rules `DIV` uses.

- The extension is what makes the low word signed: a low word whose bit `31` is set becomes a negative `PTO_XLEN` value before the division starts.
- A low-word divisor of zero returns `0`, and the signed minimum low word divided by `-1` returns that same low word.

The quotient is then reduced to its low `32` bits and sign-extended again, so bit `31` of the quotient is copied into every higher bit of the published word.

Design point: the second extension is why the published word stays between `-2147483648` and `2147483647`. The one case that would leave the signed 32-bit range in exact arithmetic, the signed minimum low word divided by `-1`, is folded back onto `-2147483648` by that extension instead of becoming a positive value.

<!-- PTO-READER-BLOCK: scalar-divw-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` is the dividend and `SrcR` is the divisor. Only bits `31` through `0` of each source are used, and both are read through the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `RegDst` publishes the sign-extended quotient: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: the destination is always a complete `PTO_XLEN` word. `DIVW` never writes only `32` bits, so a GPR that held a wider value is replaced completely rather than partly updated.

<!-- PTO-READER-BLOCK: scalar-divw-effects role=effects -->
## Effects and ordering

Both sources are read before `RegDst` is written, so a destination that aliases a source still divides the pre-instruction values.

After the result is published or discarded, `TPC` advances by `4` bytes. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no queue entry moves unless `RegDst` is `30` or `31`.

Design point: the same five-bit `SrcL` and `SrcR` fields that `DIV` uses select the operands here. There is no separate word-source map, so the upper halves are read and then dropped rather than never addressed.

<!-- PTO-READER-BLOCK: scalar-divw-constraints role=constraints -->
## Legality and fault boundary

The three selectors assign all `32` codes each, and the form carries no fixed bits beyond its 32-bit match and mask, so `DIVW` reserves no operand value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`; an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination effect and before `TPC` advances.

Design point: the word form does not move the fault boundary. The source availability check runs before the handler reads either operand, so a `DIVW` that faults has not yet examined a single bit of its sources.

<!-- PTO-READER-BLOCK: scalar-divw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `-7` and `a1` whose low `32` bits are `2`, `divw a0, a1, ->a2` writes `-3` to `a2`: the magnitudes divide as `7 / 2 = 3`, the operands have different signs, and the magnitude is subtracted from `0`. Changing the upper `32` bits of `a0` changes nothing. With `a1` holding `0` in its low word the quotient is `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
divw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divw_32_b6366c50ac8c | L32 | 32 | 0x00002057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divw_32_b6366c50ac8c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divw_32_b6366c50ac8c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divw_32_b6366c50ac8c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| divw_32_b6366c50ac8c | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| divw_32_b6366c50ac8c | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| divw_32_b6366c50ac8c | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVW.asl -->
```asl
readonly func InstructionContractOperation_DIVW() => ScalarOperation
begin
    return ScalarOperation_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVW.asl -->
```asl
readonly func InstructionContractHandler_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSignedW;
end;
pure func InstructionContractResult_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
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

- Interpret each source low 32 bits as signed, return the quotient truncated toward zero, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns zero. Signed 32-bit minimum divided by negative one returns sign-extended signed minimum.
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

- divw a0, a1, ->a2
- divw t#1, zero, ->u
