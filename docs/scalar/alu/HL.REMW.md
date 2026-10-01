<!-- GENERATED FROM: asl/scalar/alu/HL.REMW.asl -->
# HL.REMW

**Normative ASL source:** `asl/scalar/alu/HL.REMW.asl`

HL.REMW computes a signed low-32-bit remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-remw-purpose role=purpose -->
## What HL.REMW does

`HL.REMW` is a 48-bit scalar ALU instruction that divides the signed low words of its two sources and publishes the remainder through `RegDst0` and the quotient through `RegDst1`, each re-extended to XLEN.

`SrcL[31:0]` and `SrcR[31:0]` are sign-extended before the division, and each `32`-bit result is sign-extended again before publication.

<!-- PTO-READER-BLOCK: scalar-hl-remw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractQuotient_HL_REMW` and `InstructionContractRemainder_HL_REMW`, which call `ScalarDivideSignedW` and `ScalarRemainderSignedW`. Those helpers sign-extend the low words, divide, and return `SignExtend{PTO_XLEN}` of the `32`-bit result. Dispatch calls `ExecuteScalarRemainderPairW` with `signed_operation` true, which writes the remainder first and the quotient second.

```asm
hl.remw SrcL, SrcR, ->Dst0, Dst1
```

Design point: the widening happens on both sides of the division, and the second widening is a sign extension. A quotient of `0xFFFFFFFF` in the word form is therefore published as `0xFFFFFFFFFFFFFFFF`, not as `0x00000000FFFFFFFF`.

<!-- PTO-READER-BLOCK: scalar-hl-remw-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0`, instruction slice `[23 +: 5]`, receives the sign-extended remainder or discards it.
- `RegDst1`, instruction slice `[11 +: 5]`, receives the sign-extended quotient or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the dividend; only bits `31:0` participate.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the divisor; only bits `31:0` participate.

Both sources use the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, read without consuming an entry. Encoded zero reads the architectural zero GPR.

Design point: because the sources are truncated first, two registers that agree in their low words publish the same pair under `HL.REMW` whatever their upper halves hold. The narrow form is a complete description of the operation, not a preview of an XLEN division.

<!-- PTO-READER-BLOCK: scalar-hl-remw-effects role=effects -->
## Effects and ordering

Both low words are snapshotted and both results are computed before either write, so duplicate destinations and source aliases observe pre-instruction values.

`RegDst0` is written first with the remainder and `RegDst1` second with the quotient, which fixes what a duplicate GPR or a duplicate queue push publishes: quotient newest, remainder next-newest.

`TPC` advances by `6` bytes after the destination effects. No memory is accessed and no numeric-status, reservation, descriptor, Tile, bundle, privilege or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-hl-remw-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and duplicate destinations are legal, so operand legality can fail only on an unavailable temporary source. Fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination write.

Design point: the zero-divisor rule survives the narrowing. A zero word divisor publishes quotient `0` and a remainder equal to `SignExtend(dividend[31:0])`, so the effective dividend of the word form is the extended low word rather than the whole register.

<!-- PTO-READER-BLOCK: scalar-hl-remw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = -7` and `SrcR = 3`, the word division gives quotient `-2` and remainder `-1`, so `RegDst0` receives `SignExtend(0xFFFFFFFF)` = `0xFFFFFFFFFFFFFFFF` and `RegDst1` receives `SignExtend(0xFFFFFFFE)` = `0xFFFFFFFFFFFFFFFE`. With `SrcL = 0x100000007` and `SrcR = 2`, only the low words participate: the dividend word is `7`, the quotient word is `3`, and `RegDst0` receives `1` while `RegDst1` receives `3`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.remw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remw_48_3acb485d39a7 | HL48 | 48 | 0x00006057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remw_48_3acb485d39a7 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remw_48_3acb485d39a7 | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remw_48_3acb485d39a7 | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remw_48_3acb485d39a7 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remw_48_3acb485d39a7 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMW() => ScalarOperation
begin
    return ScalarOperation_HL_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPairW;
end;
pure func InstructionContractQuotient_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMW(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMW(
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

- hl.remw a0, a1, ->a2, a3
- hl.remw t#1, zero, ->u, u
