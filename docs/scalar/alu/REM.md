<!-- GENERATED FROM: asl/scalar/alu/REM.asl -->
# REM

**Normative ASL source:** `asl/scalar/alu/REM.asl`

REM computes the signed XLEN remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-rem-purpose role=purpose -->
## What REM does

`REM` treats both complete `PTO_XLEN` sources as signed two's-complement integers and publishes the remainder of the signed division. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00004057` under mask `0xfe00707f`. There is no quotient destination and no encoded mode: the mnemonic fixes signedness, operand width and the remainder result.

`REM` and `DIV` compute from the same signed division; `REM` publishes the difference `dividend - quotient * divisor` (`asl/scalar/model/alu/semantics.asl:59-64`).

<!-- PTO-READER-BLOCK: scalar-rem-mechanism role=mechanism -->
## How the remainder is formed

Dispatch calls `ScalarRemainderSigned(left, right)` with both complete `PTO_XLEN` sources read through the Reg5 map (`asl/scalar/model/dispatch/alu.asl:234-239`). The helper answers a zero divisor with the unchanged dividend; otherwise it computes the truncated-toward-zero quotient with `ScalarDivideSigned` and returns `dividend - quotient * divisor`.

```asm
rem SrcL, SrcR, ->{t, u, Rd}
```

Design point: Because the quotient truncates toward zero, the remainder takes the sign of the dividend, not of the divisor. `-7` divided by `3` publishes `-1`, while `7` divided by `-3` publishes `1`.

Design point: The two special cases are total answers, not faults. A zero divisor returns the whole dividend. Signed minimum divided by negative one also returns `0`: the helper compares magnitudes, the minimum magnitude is its own pattern, so the quotient wraps back to the minimum and the product `quotient * divisor` cancels the dividend.

`REM` computes no wide intermediate product that survives: only the remainder is published, and the quotient is discarded with the helper's local binding.

<!-- PTO-READER-BLOCK: scalar-rem-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` supplies the dividend, `SrcR` the divisor, and `RegDst` receives the remainder. All three are five-bit Reg5 fields.

- `SrcL`, instruction slice `[15 +: 5]`: dividend; `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming.
- `SrcR`, instruction slice `[20 +: 5]`: divisor, same five-bit map. A zero divisor is answered by the helper, not by a fault.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which is the zero divisor whose defined answer is the unchanged dividend.

Design point: Encoded zero of `RegDst` discards the remainder but still performs the division and still advances `TPC`. The zero-divisor rule is therefore observable only through the destination, so a discarded destination hides it completely.

<!-- PTO-READER-BLOCK: scalar-rem-effects role=effects -->
## Effects and ordering

Both sources are read before `RegDst` is written, so a destination aliasing either source uses the pre-instruction values. The remainder is published and `TPC` advances by `4` bytes.

`REM` reads no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, branch-target and control-flow state unchanged. The only queue movement is the push selected by a `30` or `31` destination.

Design point: The signed division is a restoring-division loop over `PTO_XLEN` steps, and `REM` records nothing about it. There is no sticky divide-by-zero flag that a later instruction could inspect.

<!-- PTO-READER-BLOCK: scalar-rem-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL`, `SrcR` and `RegDst` code is assigned, so no selector value is reserved. The fixed encoding bits must match the canonical `32`-bit carrier.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `REM` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: Both special dividend/divisor pairs have defined results, so `REM` has no operand-selected trap. Its fault boundary is encoding validity and source availability alone.

<!-- PTO-READER-BLOCK: scalar-rem-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `-7` and `a1` holding `3`, `rem a0, a1, ->a2` publishes `-1`, because the truncated quotient is `-2` and `-7 - (-2 * 3)` is `-1`.

With `a0` holding `-7` and `a1` holding `-3`, the truncated quotient is `2`, so `a2` receives `-1` as well; the remainder follows the dividend's sign. With `a1` holding `0`, `a2` receives `-7` itself.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
rem SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rem_32_0abbd6a3b865 | L32 | 32 | 0x00004057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rem_32_0abbd6a3b865 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rem_32_0abbd6a3b865 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rem_32_0abbd6a3b865 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| rem_32_0abbd6a3b865 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| rem_32_0abbd6a3b865 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| rem_32_0abbd6a3b865 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractOperation_REM() => ScalarOperation
begin
    return ScalarOperation_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractHandler_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSigned;
end;
pure func InstructionContractResult_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSigned(
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

- Interpret both complete XLEN sources as signed two-complement integers and return dividend minus the quotient-truncated-toward-zero times divisor.
- A zero divisor returns the unchanged dividend. Signed minimum divided by negative one returns zero.
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

- rem a0, a1, ->a2
- rem t#1, zero, ->u
