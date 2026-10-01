<!-- GENERATED FROM: asl/scalar/alu/DIVU.asl -->
# DIVU

**Normative ASL source:** `asl/scalar/alu/DIVU.asl`

DIVU computes the unsigned XLEN quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIVU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-divu-purpose role=purpose -->
## What DIVU does

`DIVU` is the unsigned partner of `DIV`: a 32-bit L32 form that reads two Reg5 operands and publishes one quotient through `RegDst`. Both complete `PTO_XLEN` words are read as unsigned integers from `0` through `2^64 - 1`, so the truncated quotient is also the floor of the exact ratio.

Design point: the top bit of a source is data here, not a sign. With `a0` holding all `64` bits set and `a1` holding `2`, `divu a0, a1, ->a2` publishes `9223372036854775807`, while `DIV` on those same two register values would read them as `-1` and `2` and publish `0`.

<!-- PTO-READER-BLOCK: scalar-divu-mechanism role=mechanism -->
## How the quotient is formed

Execution reads `SrcL` and `SrcR` and calls the unsigned divider.

- A zero divisor returns `0` immediately, before any division loop runs.
- Otherwise the restoring loop walks the dividend from bit `63` down to bit `0`, shifting a partial remainder left, bringing in one dividend bit, and subtracting the divisor whenever the partial remainder has reached it.

The quotient is published unchanged. There is no extension step, because the unsigned quotient of two `PTO_XLEN` operands is already a complete `PTO_XLEN` value.

Design point: only the quotient leaves the divider. The partial remainder the loop builds is a local value that is never written, so `DIVU` cannot report how much of the dividend was left over; the pair form `HL.DIVU` is the spelling that returns both halves.

<!-- PTO-READER-BLOCK: scalar-divu-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` is the dividend and `SrcR` is the divisor, both read through the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `RegDst` publishes the quotient: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: a source read does not consume a queue entry and a discard destination still lets the instruction retire. While `t#1` and `t#2` are both available, `divu t#1, t#2, ->u` therefore leaves those two slots in place and appends one new `U` entry.

<!-- PTO-READER-BLOCK: scalar-divu-effects role=effects -->
## Effects and ordering

The two reads happen before `RegDst` is written, so `divu a0, a1, ->a1` stores the quotient over the divisor using the divisor's pre-instruction value.

Once the quotient is published or discarded, `TPC` advances by `4` bytes. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

Design point: only the destination push touches a temporary queue, so an unsigned divide aimed at a GPR or at a discard code leaves both queues exactly as they were; a later read of `T#1` sees the same word it would have seen before the instruction.

<!-- PTO-READER-BLOCK: scalar-divu-constraints role=constraints -->
## Legality and fault boundary

All `32` codes of `SrcL`, `SrcR` and `RegDst` are assigned, and the only fixed requirement is that the 32-bit word matches the `DIVU` mask and match, so the unsigned mnemonic reserves no operand value of its own.

An undecodable form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination effect and before `TPC` advances.

Design point: the model never derives an arithmetic fault from the divisor. A zero divisor is answered inside the unsigned divider with `0`, so `DIVU` has no divisor value that traps or that leaves the result unwritten.

<!-- PTO-READER-BLOCK: scalar-divu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=13` and `a1=5`, `divu a0, a1, ->a2` writes `2` to `a2`. With `a0` holding all `64` bits set and `a1=2`, the same instruction writes `9223372036854775807`, because the dividend is read as `18446744073709551615`; `DIV` on those two register values would return `0` instead.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
divu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divu_32_cfbc0d1760e4 | L32 | 32 | 0x00001057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divu_32_cfbc0d1760e4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divu_32_cfbc0d1760e4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divu_32_cfbc0d1760e4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| divu_32_cfbc0d1760e4 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| divu_32_cfbc0d1760e4 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| divu_32_cfbc0d1760e4 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractOperation_DIVU() => ScalarOperation
begin
    return ScalarOperation_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractHandler_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsigned;
end;
pure func InstructionContractResult_DIVU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
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

- Interpret both complete XLEN sources as unsigned integers and return the unsigned quotient.
- A zero divisor returns zero.
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

- divu a0, a1, ->a2
- divu t#1, zero, ->u
