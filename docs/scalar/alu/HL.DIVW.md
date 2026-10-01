<!-- GENERATED FROM: asl/scalar/alu/HL.DIVW.asl -->
# HL.DIVW

**Normative ASL source:** `asl/scalar/alu/HL.DIVW.asl`

HL.DIVW computes a signed low-32-bit quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divw-purpose role=purpose -->
## What HL.DIVW does

`HL.DIVW` is the 48-bit HL48 word form of the signed pair. It divides the low word of two Reg5 sources as signed integers and publishes a sign-extended quotient to `RegDst0` and a sign-extended remainder to `RegDst1`.

Design point: both results pass through the same extension rule, but only the quotient can leave the signed 32-bit range. For a nonzero divisor the remainder's magnitude stays below the divisor's magnitude, so its low word extends back to the exact signed remainder. The quotient is different: dividing the signed minimum low word by `-1` would give `2147483648`, and the final extension publishes `-2147483648` instead.

<!-- PTO-READER-BLOCK: scalar-hl-divw-mechanism role=mechanism -->
## How both results are formed

Execution sign-extends `SrcL[31:0]` and `SrcR[31:0]` to `PTO_XLEN` and derives the pair from those two words.

- The quotient is the signed quotient over the extended operands, truncated toward zero.
- The remainder is `dividend - quotient * divisor` over the same extended operands.
- Each result is then reduced to its low `32` bits and sign-extended to `PTO_XLEN`, the quotient published first and the remainder second.

Computing on the extended operands is what makes the pair the signed 32-bit division widened to `PTO_XLEN` rather than a `32`-bit wraparound.

Design point: with `a0` whose low `32` bits are `-7` and `a1` whose low `32` bits are `2`, the pair is `-3` and `-1`, and the upper words of either source never change it.

<!-- PTO-READER-BLOCK: scalar-hl-divw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the dividend and `SrcR` is the divisor. Only bits `31` through `0` of each source are used, and both are read through the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `RegDst0` publishes the quotient and `RegDst1` the remainder; each uses the common map, `1..23` writing that GPR, `30` pushing `U`, `31` pushing `T`, and `0` with `24..29` discarding.
- The upper words are read as part of the complete source values and are then dropped by the word arithmetic.

Design point: the field layout matches `HL.DIV`, so the same five-bit codes name the same registers and queue slots in both mnemonics. Only the operand width and the signedness of the interpretation separate `hl.divw` from `hl.div`.

<!-- PTO-READER-BLOCK: scalar-hl-divw-effects role=effects -->
## Effects and ordering

Both results are computed before either destination effect, and the publications follow the encoded order `RegDst0` then `RegDst1`. `TPC` then advances by `6` bytes.

No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no queue entry moves except through a destination code of `30` or `31`.

Design point: when `RegDst0` and `RegDst1` name one GPR, the ordered second write leaves the remainder in that register and the quotient is lost, so the quotient survives only in a different destination. The same holds for a single queue: the later push makes the remainder the newest entry.

<!-- PTO-READER-BLOCK: scalar-hl-divw-constraints role=constraints -->
## Legality and fault boundary

`SrcL`, `SrcR`, `RegDst0` and `RegDst1` assign every code, and the 48-bit form carries no fixed bits beyond its match and mask.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`; an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination effect and before `TPC` advances.

Design point: the word form keeps the total divisor rules of the signed family. A zero low-word divisor gives quotient `0` and the effective dividend as the remainder, and the signed minimum low word divided by `-1` gives that same low word with remainder `0`; no divisor value reaches the restoring-division assertion, which requires a nonzero divisor.

<!-- PTO-READER-BLOCK: scalar-hl-divw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `-7` and `a1` whose low `32` bits are `2`, `hl.divw a0, a1, ->a2, a3` writes `-3` to `a2` and `-1` to `a3`, because `-7 - (-3 * 2)` is `-1`. With `a1` holding `0` in its low word the quotient is `0` and the remainder is the sign-extended low word of `a0`. With `a0=-8` and `a1=2` the pair is `-4` and `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | HL48 | 48 | 0x00002057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
pure func InstructionContractQuotient_HL_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVW(
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

- SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form.

## State effects

- Interpret the selected operands as signed values, compute both quotient and remainder using the fixed total division rules. For W forms, use the low 32 bits and sign-extend each 32-bit result to XLEN.
- A zero divisor returns quotient zero and the effective dividend as remainder. Signed minimum divided by negative one returns signed minimum quotient and zero remainder.
- Publish RegDst0 quotient first, then RegDst1 remainder. If both destinations name one GPR, remainder is final; if both push one queue, remainder is newest and quotient is next-newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources and compute both results before either destination effect.
- Publish quotient to RegDst0, publish remainder to RegDst1, then advance TPC by six bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.divw a0, a1, ->a2, a3
- hl.divw t#1, zero, ->u, u
