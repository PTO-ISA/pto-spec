<!-- GENERATED FROM: asl/scalar/alu/HL.REM.asl -->
# HL.REM

**Normative ASL source:** `asl/scalar/alu/HL.REM.asl`

HL.REM computes a signed XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-rem-purpose role=purpose -->
## What HL.REM does

`HL.REM` is a 48-bit scalar ALU instruction that divides two signed XLEN values and publishes both results: the remainder through `RegDst0` and the quotient through `RegDst1`.

The division is total. A zero divisor and the signed minimum divided by `-1` both have defined results, so the mnemonic has no arithmetic fault case.

<!-- PTO-READER-BLOCK: scalar-hl-rem-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractQuotient_HL_REM` and `InstructionContractRemainder_HL_REM`, which call `ScalarDivideSigned` and `ScalarRemainderSigned`. Dispatch calls `ExecuteScalarRemainderPair` with `signed_operation` true; that helper computes `quotient` and `remainder` first, then writes the remainder to `RegDst0` and the quotient to `RegDst1`.

```asm
hl.rem SrcL, SrcR, ->Dst0, Dst1
```

Design point: `ScalarDivideSigned` divides the magnitudes and negates only when the two signs differ, so the quotient truncates toward zero. `ScalarRemainderSigned` is `dividend - quotient * divisor`, which makes the remainder carry the dividend's sign rather than the divisor's.

<!-- PTO-READER-BLOCK: scalar-hl-rem-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0`, instruction slice `[23 +: 5]`, receives the remainder or discards it.
- `RegDst1`, instruction slice `[11 +: 5]`, receives the quotient or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the dividend.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the divisor.

Both sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry. An encoded-zero divisor reads the architectural zero GPR and therefore selects the defined zero-divisor results.

Design point: the two destination fields are independent, so the pair may discard one half, write one GPR and push the other, or push both to the same queue. A duplicate push is well defined because the remainder is pushed first and the quotient second.

<!-- PTO-READER-BLOCK: scalar-hl-rem-effects role=effects -->
## Effects and ordering

Both sources are snapshotted and both results are computed before either destination write, so a destination that aliases `SrcL` or `SrcR` cannot disturb the pair.

Publication order is `RegDst0` then `RegDst1`: the remainder first, the quotient second. If both fields name one GPR the quotient is the final value; if both push one queue the quotient is the newest entry and the remainder is next-newest.

`TPC` advances by `6` bytes after the destination effects. `HL.REM` reads and writes no memory and changes no numeric-status, reservation, descriptor, Tile, bundle, privilege or control-flow state apart from the selected queue pushes.

<!-- PTO-READER-BLOCK: scalar-hl-rem-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and duplicate destinations are legal, so operand legality can fail only on an unavailable temporary source. The fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination write.

Design point: no operand value can raise an arithmetic fault here. A zero divisor publishes quotient `0` and remainder equal to the dividend, and the signed minimum divided by `-1` publishes the signed minimum as quotient with remainder `0`, because the magnitude path wraps instead of trapping.

<!-- PTO-READER-BLOCK: scalar-hl-rem-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 13` and `SrcR = 5`, the quotient is `2` and the remainder is `3`, so `RegDst0` receives `3` and `RegDst1` receives `2`. With `SrcL = -7` and `SrcR = 3`, the quotient is `-2` and the remainder is `-1`, so `RegDst0` receives `0xFFFFFFFFFFFFFFFF` and `RegDst1` receives `0xFFFFFFFFFFFFFFFE`. With `SrcR` held at the architectural zero GPR and `SrcL = 13`, `RegDst0` receives `13` and `RegDst1` receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.rem SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_rem_48_3c13e08615aa | HL48 | 48 | 0x00004057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_rem_48_3c13e08615aa | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_rem_48_3c13e08615aa | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_rem_48_3c13e08615aa | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_rem_48_3c13e08615aa | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_rem_48_3c13e08615aa | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_rem_48_3c13e08615aa | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_rem_48_3c13e08615aa | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_rem_48_3c13e08615aa | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REM.asl -->
```asl
readonly func InstructionContractOperation_HL_REM() => ScalarOperation
begin
    return ScalarOperation_HL_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REM.asl -->
```asl
readonly func InstructionContractHandler_HL_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPair;
end;
pure func InstructionContractQuotient_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSigned(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REM(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REM(
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
- Publish RegDst0 remainder first, then RegDst1 quotient. If both destinations name one GPR, quotient is final; if both push one queue, quotient is newest and remainder is next-newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources and compute both results before either destination effect.
- Publish remainder to RegDst0, publish quotient to RegDst1, then advance TPC by six bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.rem a0, a1, ->a2, a3
- hl.rem t#1, zero, ->u, u
