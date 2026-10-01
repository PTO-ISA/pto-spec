<!-- GENERATED FROM: asl/scalar/alu/REMUW.asl -->
# REMUW

**Normative ASL source:** `asl/scalar/alu/REMUW.asl`

REMUW computes the unsigned low-32-bit remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remuw-purpose role=purpose -->
## What REMUW does

`REMUW` takes the unsigned remainder of the low `32` bits of two sources and publishes that `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00007057` under mask `0xfe00707f` and routes to `ScalarRemainderUnsignedW`.

Two narrowings happen: the operands are zero-extended from `32` bits before the division, and the result is sign-extended from `32` bits after it. The second one is not an unsigned extension.

<!-- PTO-READER-BLOCK: scalar-remuw-mechanism role=mechanism -->
## How the word remainder is formed

`ScalarRemainderUnsignedW` binds `dividend32` to `ZeroExtend{PTO_XLEN}(dividend[31:0])` and `divisor32` to `ZeroExtend{PTO_XLEN}(divisor[31:0])`, calls `ScalarRemainderUnsigned(dividend32, divisor32)`, and returns `SignExtend{PTO_XLEN}(remainder[31:0])` (`asl/scalar/model/alu/semantics.asl:74-80`). Dispatch reaches it through `ScalarOperation_REMUW` at `asl/scalar/model/dispatch/alu.asl:252-257`.

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

Design point: The zero extension of the operands is what makes the word unsigned: source bit `31` contributes `2147483648` to the dividend rather than a sign. The final sign extension then reinterprets result bit `31`, so an unsigned word remainder of `0xFFFFFFFF` is published as `0xFFFFFFFFFFFFFFFF`.

Design point: Because the operands stop at `32` bits, two registers that agree in their low words publish the same remainder whatever their upper halves hold. The upper word of a source cannot change the quotient or the remainder.

<!-- PTO-READER-BLOCK: scalar-remuw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` holds the dividend, `SrcR` the divisor, and `RegDst` receives the sign-extended word remainder.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` reaches the divider.
- `SrcR`, instruction slice `[20 +: 5]`: same five-bit map. Only `SrcR[31:0]` reaches the divider.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR; its low word is `0`, which selects the zero-divisor answer.

Design point: A zero low-word divisor answers with the sign-extended low word of the dividend, not with zero. For a dividend whose low word is `0xFFFFFFFF` the published word is `0xFFFFFFFFFFFFFFFF`, so the zero-divisor case does not bound the published magnitude.

<!-- PTO-READER-BLOCK: scalar-remuw-effects role=effects -->
## Effects and ordering

Both sources are read before the write, so an aliasing destination divides the pre-instruction low words. The sign-extended remainder is published and `TPC` advances by `4` bytes.

`REMUW` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, branch-target or control-flow state. A `30` or `31` destination is the only case in which it moves a temporary queue.

Design point: The word division discards the upper half of the quotient and records nothing about it. The published word is the only architectural trace, and it is a sign-extended `32`-bit value rather than a full unsigned result.

<!-- PTO-READER-BLOCK: scalar-remuw-constraints role=constraints -->
## Legality and fault boundary

Every Reg5 source code and every Reg5 destination code is assigned, and the form has no constraint entry beyond its fixed encoding bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `REMUW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Both dividend and divisor are total inputs: a zero low-word divisor is answered with the extended dividend, and no operand pair raises an arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-remuw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `10` and `a1` whose low `32` bits are `4`, `remuw a0, a1, ->a2` publishes `2`.

With `a0` holding `0x10000000A` and `a1` holding `4`, only the low words participate, so the dividend word is `10` and `a2` receives `2`. With `a1` whose low word is `0`, the word remainder is the whole dividend word, so `a2` receives `10`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | L32 | 32 | 0x00007057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remuw_32_f10ade2f5ccb | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remuw_32_f10ade2f5ccb | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractOperation_REMUW() => ScalarOperation
begin
    return ScalarOperation_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractHandler_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsignedW;
end;
pure func InstructionContractResult_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsignedW(
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

- Interpret each source low 32 bits as unsigned, return the unsigned remainder, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns the sign-extended low 32-bit dividend.
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

- remuw a0, a1, ->a2
- remuw t#1, zero, ->u
