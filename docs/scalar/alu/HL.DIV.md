<!-- GENERATED FROM: asl/scalar/alu/HL.DIV.asl -->
# HL.DIV

**Normative ASL source:** `asl/scalar/alu/HL.DIV.asl`

HL.DIV computes a signed XLEN quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-div-purpose role=purpose -->
## What HL.DIV does

`HL.DIV` is a 48-bit HL48 form with two source fields and two destination fields. It divides two Reg5 operands as signed `PTO_XLEN` integers and publishes the quotient through `RegDst0` and the remainder through `RegDst1`.

Design point: this is the spelling that returns both halves from one pair of source reads. `DIV` publishes the same quotient and drops the remainder, and `REM` derives a remainder from its own reads; `HL.DIV` derives the two published values from the same two snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-div-mechanism role=mechanism -->
## How the quotient and remainder are formed

Execution reads `SrcL` and `SrcR`, computes both results, and only then publishes them.

- The quotient is the signed quotient of the complete operands, truncated toward zero, the same value `DIV` publishes.
- The remainder is `dividend - quotient * divisor` over those same operands, so it carries the dividend's sign and, for a nonzero divisor, its magnitude stays below the divisor's magnitude.

Publication then follows the encoded order: `RegDst0` receives the quotient and `RegDst1` receives the remainder.

Design point: because the remainder is derived from the quotient word and not from an independent division, the pair always satisfies `dividend = quotient * divisor + remainder` in `PTO_XLEN` two's-complement arithmetic. With `a0=-13` and `a1=5` that identity gives `-13 - (-2 * 5) = -3`, so the remainder is `-3` rather than `3`.

<!-- PTO-READER-BLOCK: scalar-hl-div-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the dividend and `SrcR` is the divisor. Both use the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry.
- `RegDst0` receives the quotient and `RegDst1` receives the remainder. Each uses the Reg5 destination map on its own: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard.
- All four fields are required encoded fields, so no spelling of `HL.DIV` returns only the quotient or only the remainder.

Design point: duplicate destinations are legal and the publication order decides the outcome. When `RegDst0` and `RegDst1` encode the same GPR, the remainder is the final value of that register; when both encode `30` or both encode `31`, the remainder becomes the newest entry of that queue and the quotient the next-newest.

<!-- PTO-READER-BLOCK: scalar-hl-div-effects role=effects -->
## Effects and ordering

Both sources are read and both results are computed before the first destination effect, so a destination that aliases a source still divides the pre-instruction values.

After the two publications, `TPC` advances by `6` bytes, the length of the 48-bit form. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

Design point: a discard on one side suppresses only that side. When `RegDst0` carries a discarding code the quotient is dropped while the remainder is still written to `RegDst1`, and the instruction performs the same source reads and the same arithmetic as a pair that publishes both values.

<!-- PTO-READER-BLOCK: scalar-hl-div-constraints role=constraints -->
## Legality and fault boundary

Both sources and both destinations assign every code of the Reg5 space, and the 48-bit form adds no fixed-bit constraint beyond its match and mask, so `HL.DIV` reserves no selector value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`; an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination effect and before `TPC` advances.

Design point: the source availability check runs before the sources are read, and no destination code is rejected, so nothing can fault between the two publications. The pair is all-or-nothing with respect to its destination effects: either both writes happen or neither does.

<!-- PTO-READER-BLOCK: scalar-hl-div-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=-13` and `a1=5`, `hl.div a0, a1, ->a2, a3` writes `-2` to `a2` and `-3` to `a3`, because the remainder is computed as `-13 - (-2 * 5)`. With `SrcR` encoded as zero the divisor is the architectural zero GPR, so the quotient is `0` and the remainder is the dividend `-13`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.div SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_div_48_e8ff1fc1cb98 | HL48 | 48 | 0x00000057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_div_48_e8ff1fc1cb98 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_div_48_e8ff1fc1cb98 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_div_48_e8ff1fc1cb98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_div_48_e8ff1fc1cb98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_div_48_e8ff1fc1cb98 | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_div_48_e8ff1fc1cb98 | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_div_48_e8ff1fc1cb98 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_div_48_e8ff1fc1cb98 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIV.asl -->
```asl
readonly func InstructionContractOperation_HL_DIV() => ScalarOperation
begin
    return ScalarOperation_HL_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIV.asl -->
```asl
readonly func InstructionContractHandler_HL_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
pure func InstructionContractQuotient_HL_DIV(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIV(
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

- SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form.

## State effects

- Interpret the selected operands as signed values, compute both quotient and remainder using the fixed total division rules.
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

- hl.div a0, a1, ->a2, a3
- hl.div t#1, zero, ->u, u
