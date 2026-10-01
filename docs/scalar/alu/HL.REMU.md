<!-- GENERATED FROM: asl/scalar/alu/HL.REMU.asl -->
# HL.REMU

**Normative ASL source:** `asl/scalar/alu/HL.REMU.asl`

HL.REMU computes an unsigned XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-remu-purpose role=purpose -->
## What HL.REMU does

`HL.REMU` is a 48-bit scalar ALU instruction that divides two unsigned XLEN values and publishes the remainder through `RegDst0` and the quotient through `RegDst1`.

Both operands are read as unsigned magnitudes, so a source with bit `63` set contributes its large positive value rather than a negative one.

<!-- PTO-READER-BLOCK: scalar-hl-remu-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractQuotient_HL_REMU` and `InstructionContractRemainder_HL_REMU`, which call `ScalarDivideUnsigned` and `ScalarRemainderUnsigned`. Dispatch calls `ExecuteScalarRemainderPair` with `signed_operation` false; the helper computes both values and then writes the remainder first and the quotient second.

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

Design point: `ScalarRemainderUnsigned` is defined as `dividend - MultiplyWord(quotient, divisor)`, so for a nonzero divisor the published remainder satisfies `dividend = quotient * divisor + remainder` with a remainder smaller than the divisor. No nonzero divisor can break that identity.

<!-- PTO-READER-BLOCK: scalar-hl-remu-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0`, instruction slice `[23 +: 5]`, receives the remainder or discards it.
- `RegDst1`, instruction slice `[11 +: 5]`, receives the quotient or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the dividend.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the divisor.

The two sources use the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, all read without consumption. Encoded zero reads the architectural zero GPR.

Design point: the operand roles are fixed by the encoding. `SrcL` is always the dividend and `SrcR` always the divisor, so a caller that wants `a / b` and `b / a` needs two instructions; there is no encoded swap bit and no implicit operand.

<!-- PTO-READER-BLOCK: scalar-hl-remu-effects role=effects -->
## Effects and ordering

Both sources are snapshotted and both results are computed before the first destination write, so duplicate destination names and source aliases all see pre-instruction values.

`RegDst0` receives the remainder first and `RegDst1` the quotient second. On one GPR the quotient is final; on one queue the quotient is newest and the remainder next-newest. `TPC` then advances by `6` bytes, and no memory or other architectural state is touched beyond the selected queue pushes.

<!-- PTO-READER-BLOCK: scalar-hl-remu-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and duplicate destinations are legal, so only an unavailable temporary source can fail the operand checks. Fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination write.

Design point: the unsigned reading removes the signed-overflow corner that the signed form has to define. A zero divisor is still total: it publishes quotient `0` and remainder equal to the dividend, so `hl.remu` never faults on operand values.

<!-- PTO-READER-BLOCK: scalar-hl-remu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 13` and `SrcR = 5`, the quotient is `2` and the remainder is `3`, so `RegDst0` receives `3` and `RegDst1` receives `2`. With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 2`, the quotient is `0x7FFFFFFFFFFFFFFF` and the remainder is `1`. With `SrcR` held at the architectural zero GPR, the quotient is `0` and the remainder is the dividend.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | HL48 | 48 | 0x00005057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractOperation_HL_REMU() => ScalarOperation
begin
    return ScalarOperation_HL_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractHandler_HL_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPair;
end;
pure func InstructionContractQuotient_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMU(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMU(
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

- Interpret the selected operands as unsigned values, compute both quotient and remainder using the fixed total division rules.
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

- hl.remu a0, a1, ->a2, a3
- hl.remu t#1, zero, ->u, u
