<!-- GENERATED FROM: asl/scalar/alu/DIVUW.asl -->
# DIVUW

**Normative ASL source:** `asl/scalar/alu/DIVUW.asl`

DIVUW computes the unsigned low-32-bit quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIVUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-divuw-purpose role=purpose -->
## What DIVUW does

`DIVUW` divides the low word of two Reg5 sources as unsigned integers and publishes one `PTO_XLEN` word. The low words are zero-extended, so they run from `0` through `4294967295`, and the quotient is then sign-extended from bit `31`.

Design point: that last step is a sign extension, not a zero extension. An unsigned quotient of `4294967295` has bit `31` set, so with a low-word dividend of `4294967295` and a divisor of `1`, `divuw a0, a1, ->a2` publishes `-1` even though the computed unsigned quotient is the largest value the operands can produce.

<!-- PTO-READER-BLOCK: scalar-divuw-mechanism role=mechanism -->
## How the quotient is formed

Execution zero-extends `SrcL[31:0]` and `SrcR[31:0]` to `PTO_XLEN`, divides those two words with the unsigned total rules, and sign-extends the low `32` bits of the quotient.

- Zero-extending the operands first is what makes the low word unsigned: bit `31` of a source contributes `2147483648` instead of a sign.
- A low-word divisor of zero returns `0`, and `0` has bit `31` clear, so the published word is `0` in that case.

The mechanism is uniform for every operand pair: one divide, then one sign extension.

Design point: because the operands stop at `32` bits, the unsigned quotient cannot exceed `4294967295`. The published word still has all `64` bits defined, and only the low `32` of them carry the unsigned quotient; the upper ones repeat bit `31` of the quotient.

<!-- PTO-READER-BLOCK: scalar-divuw-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` is the dividend and `SrcR` is the divisor, both read through the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Only the low `32` bits of each source reach the divider.
- `RegDst` publishes the one result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: a consumer that wants the unsigned quotient back has to clear the upper bits itself. A `DIVUW` destination is a complete `PTO_XLEN` word, and the form offers no zero-extending destination variant.

<!-- PTO-READER-BLOCK: scalar-divuw-effects role=effects -->
## Effects and ordering

Both sources are read before `RegDst` is written, so an aliasing destination still divides the pre-instruction low words.

The word is then published and `TPC` advances by `4` bytes. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes; the only queue movement a successful `DIVUW` can cause is the single push selected by a `30` or `31` destination.

Design point: `DIVUW` records no numeric status. Neither the sign extension nor the discarded remainder leaves a trace, so the published word is the only place where the outcome of the instruction is observable.

<!-- PTO-READER-BLOCK: scalar-divuw-constraints role=constraints -->
## Legality and fault boundary

Every code of `SrcL`, `SrcR` and `RegDst` is assigned, so no selector value is reserved for this mnemonic.

An undecodable form raises `Fault_IllegalInstruction` at `PC`, an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination effect and before `TPC` advances.

Design point: the divisor value is total here. The low-word divisor is zero exactly when `SrcR[31:0]` is zero, and that case is answered with `0` rather than with a fault, so the unsigned mnemonic has no trap path selected by an operand.

<!-- PTO-READER-BLOCK: scalar-divuw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `10` and `a1` whose low `32` bits are `4`, `divuw a0, a1, ->a2` writes `2` to `a2`. With `a0` whose low `32` bits are all ones and `a1` whose low `32` bits are `1`, the unsigned quotient is `4294967295`, bit `31` is set, and the published word is `-1`. Setting `a1` to `0` in its low word publishes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
divuw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divuw_32_9c9470ef8982 | L32 | 32 | 0x00003057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divuw_32_9c9470ef8982 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divuw_32_9c9470ef8982 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divuw_32_9c9470ef8982 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| divuw_32_9c9470ef8982 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| divuw_32_9c9470ef8982 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| divuw_32_9c9470ef8982 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVUW.asl -->
```asl
readonly func InstructionContractOperation_DIVUW() => ScalarOperation
begin
    return ScalarOperation_DIVUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVUW.asl -->
```asl
readonly func InstructionContractHandler_DIVUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsignedW;
end;
pure func InstructionContractResult_DIVUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsignedW(
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

- Interpret each source low 32 bits as unsigned, return the unsigned quotient, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns zero.
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

- divuw a0, a1, ->a2
- divuw t#1, zero, ->u
