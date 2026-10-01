<!-- GENERATED FROM: asl/scalar/alu/REMW.asl -->
# REMW

**Normative ASL source:** `asl/scalar/alu/REMW.asl`

REMW computes the signed low-32-bit remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remw-purpose role=purpose -->
## What REMW does

`REMW` divides the signed low words of two sources and publishes the signed remainder sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00006057` under mask `0xfe00707f` and routes to `ScalarRemainderSignedW`.

The word form narrows the operands first and widens the result afterwards, so a remainder that fits in `32` bits is published as the sign-extended `64`-bit value of that word.

<!-- PTO-READER-BLOCK: scalar-remw-mechanism role=mechanism -->
## How the word remainder is formed

`ScalarRemainderSignedW` binds `dividend32` to `SignExtend{PTO_XLEN}(dividend[31:0])` and `divisor32` to `SignExtend{PTO_XLEN}(divisor[31:0])`, calls `ScalarRemainderSigned(dividend32, divisor32)`, and returns `SignExtend{PTO_XLEN}(remainder[31:0])` (`asl/scalar/model/alu/semantics.asl:90-96`). Dispatch selects it for `ScalarOperation_REMW` at `asl/scalar/model/dispatch/alu.asl:246-251`.

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

Design point: The operand sign extension is what makes a word such as `0xFFFFFFFF` a dividend of `-1`. The final sign extension is applied to a `32`-bit remainder that already followed the dividend's sign, so the published word is the `64`-bit extension of a value that `32`-bit truncating division can produce.

Design point: Signed 32-bit minimum divided by negative one returns `0` in this helper, exactly as the full-width `REM` does. The case has a defined answer and does not fault.

<!-- PTO-READER-BLOCK: scalar-remw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` supplies the dividend word, `SrcR` the divisor word, and `RegDst` receives the sign-extended remainder.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `SrcR`, instruction slice `[20 +: 5]`: same five-bit map; only `SrcR[31:0]` participates.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, whose low word is the zero divisor; the answer is the sign-extended low word of the dividend.

Design point: A dividend whose low word is negative is extended before the division, so `remw` with low word `0xFFFFFFFF` and divisor `2` publishes `-1`, while the unsigned mnemonic publishes `1` for the same bits. The pair `remw`/`remuw` differs only in this interpretation.

<!-- PTO-READER-BLOCK: scalar-remw-effects role=effects -->
## Effects and ordering

The two low words are read before `RegDst` is written, so a destination aliasing a source divides pre-instruction values. The sign-extended remainder is published and `TPC` advances by `4` bytes.

`REMW` accesses no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, branch-target or control-flow state; the only queue movement is the push selected by a `30` or `31` destination.

Design point: The quotient is computed and dropped. Because `REMW` has no quotient destination, a signed word division needs a second instruction when both results are wanted.

<!-- PTO-READER-BLOCK: scalar-remw-constraints role=constraints -->
## Legality and fault boundary

All `32` source codes and all `32` destination codes are assigned, and the form has no constraint entry beyond its fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `REMW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Every check precedes the destination effect and the `TPC` advance.

Design point: No operand pair selects a trap: a zero divisor returns the extended dividend, and the signed minimum divided by negative one returns `0`. `REMW` therefore has no value-dependent fault path.

<!-- PTO-READER-BLOCK: scalar-remw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0 = -7` and `a1 = 3`, `remw a0, a1, ->a2` publishes `-1`, because the extended dividend is `-7` and the word quotient truncates to `-2`.

With `a0 = 0x100000007` and `a1 = 2`, only the low words take part: the dividend word is `7` and `a2` receives `1`. With `a1` whose low word is `0`, `a2` receives the sign-extended dividend word `7`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | L32 | 32 | 0x00006057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remw_32_22659af46ec0 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remw_32_22659af46ec0 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractOperation_REMW() => ScalarOperation
begin
    return ScalarOperation_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractHandler_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSignedW;
end;
pure func InstructionContractResult_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSignedW(
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

- Interpret each source low 32 bits as signed, return the signed remainder, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns the sign-extended low 32-bit dividend. Signed 32-bit minimum divided by negative one returns zero.
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

- remw a0, a1, ->a2
- remw t#1, zero, ->u
