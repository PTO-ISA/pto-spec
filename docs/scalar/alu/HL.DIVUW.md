<!-- GENERATED FROM: asl/scalar/alu/HL.DIVUW.asl -->
# HL.DIVUW

**Normative ASL source:** `asl/scalar/alu/HL.DIVUW.asl`

HL.DIVUW computes a unsigned low-32-bit quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divuw-purpose role=purpose -->
## What HL.DIVUW does

`HL.DIVUW` is the 48-bit HL48 pair form that divides the low word of two Reg5 sources as unsigned integers. It publishes a sign-extended quotient to `RegDst0` and a sign-extended remainder to `RegDst1`.

Design point: the operands are unsigned while the published words are sign-extended, so either half of the pair can look negative in `PTO_XLEN`. A low-word dividend of `4294967295` with a divisor of `1` gives the quotient `-1`, and only a consumer that reads the low `32` bits recovers the unsigned value.

<!-- PTO-READER-BLOCK: scalar-hl-divuw-mechanism role=mechanism -->
## How both results are formed

Execution zero-extends `SrcL[31:0]` and `SrcR[31:0]` to `PTO_XLEN` and computes both results from those two words.

- The quotient is the unsigned quotient of the zero-extended operands.
- The remainder is `dividend - quotient * divisor`, so it stays below the divisor whenever the divisor is nonzero.

Each result is then reduced to its low `32` bits and sign-extended to `PTO_XLEN`: the quotient to `RegDst0` first, the remainder to `RegDst1` second.

Design point: the extension applies to the remainder too, and the remainder can carry bit `31` when the divisor is larger than the dividend, because the quotient is then `0` and the remainder is the dividend's low word. With a low-word dividend of `4000000000` and a divisor of `4294967295`, `hl.divuw a0, a1, ->a2, a3` publishes quotient `0` and remainder `-294967296`.

<!-- PTO-READER-BLOCK: scalar-hl-divuw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the dividend and `SrcR` is the divisor. Both are read through the Reg5 source map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, and only the low `32` bits of each source reach the divider.
- `RegDst0` takes the quotient and `RegDst1` the remainder. Each destination uses the common map: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Reading a source never consumes a `T` or `U` entry; only a destination code of `30` or `31` changes a queue.

Design point: a source read never removes a `T` or `U` entry, while a destination code of `30` or `31` appends one. Each destination is applied on its own, and a destination that reuses a source selector writes that register only after both snapshots have been taken.

<!-- PTO-READER-BLOCK: scalar-hl-divuw-effects role=effects -->
## Effects and ordering

The sources are read and both results are computed before the first destination effect. The quotient is published to `RegDst0`, then the remainder to `RegDst1`, and then `TPC` advances by `6` bytes.

No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes. Nothing records the truncation, and the remainder exists only at `RegDst1`.

Design point: the publication order is observable only through aliasing. When `RegDst0` and `RegDst1` encode the same GPR the remainder is the final content of that register, and when both encode one queue the remainder is the newest entry; with two distinct destinations the order has no visible effect.

<!-- PTO-READER-BLOCK: scalar-hl-divuw-constraints role=constraints -->
## Legality and fault boundary

The four selectors assign every code, duplicate destinations are legal, and the 48-bit encoding adds no fixed-bit constraint, so no selector value is reserved for this mnemonic.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`; an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination effect and before `TPC` advances.

Design point: the divisor value is total. A low-word divisor of `0` gives quotient `0` and the sign-extended low word of the dividend as the remainder, which can itself be negative, and no divisor value raises a fault.

<!-- PTO-READER-BLOCK: scalar-hl-divuw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `10` and `a1` whose low `32` bits are `4`, `hl.divuw a0, a1, ->a2, a3` writes `2` to `a2` and `2` to `a3`. With a low-word dividend of `4294967295` and a divisor of `2` the pair is `2147483647` and `1`, and with a low-word dividend of `4000000000` and a divisor of `4294967295` the pair is `0` and `-294967296`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divuw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divuw_48_9ebe516091b8 | HL48 | 48 | 0x00003057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divuw_48_9ebe516091b8 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divuw_48_9ebe516091b8 | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divuw_48_9ebe516091b8 | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divuw_48_9ebe516091b8 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divuw_48_9ebe516091b8 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVUW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVUW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVUW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
pure func InstructionContractQuotient_HL_DIVUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVUW(
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

- SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form.

## State effects

- Interpret the selected operands as unsigned values, compute both quotient and remainder using the fixed total division rules. For W forms, use the low 32 bits and sign-extend each 32-bit result to XLEN.
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

- hl.divuw a0, a1, ->a2, a3
- hl.divuw t#1, zero, ->u, u
