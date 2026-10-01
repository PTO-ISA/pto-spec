<!-- GENERATED FROM: asl/scalar/alu/HL.DIVU.asl -->
# HL.DIVU

**Normative ASL source:** `asl/scalar/alu/HL.DIVU.asl`

HL.DIVU computes a unsigned XLEN quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divu-purpose role=purpose -->
## What HL.DIVU does

`HL.DIVU` is the unsigned 48-bit HL48 pair form. It reads two Reg5 operands as unsigned `PTO_XLEN` integers and publishes the quotient through `RegDst0` and the remainder through `RegDst1`, in that order.

Design point: `HL.DIVU` and `HL.DIV` share one field layout and differ only in the mnemonic and the fixed match bits of the 48-bit encoding, so the unsigned interpretation belongs to the executed instruction word rather than to an operand value or a mode field.

<!-- PTO-READER-BLOCK: scalar-hl-divu-mechanism role=mechanism -->
## How the pair is formed

Execution reads both sources, computes both results, and then publishes them in encoded order.

- For a zero divisor the quotient is `0` and the remainder is the dividend itself, so the pair still satisfies `dividend = quotient * divisor + remainder`.
- For a nonzero divisor the quotient is the unsigned quotient of the two complete operands and the remainder is `dividend - quotient * divisor`, which stays strictly below the divisor.

The quotient goes to `RegDst0` first and the remainder to `RegDst1` second.

Design point: the remainder is the difference the quotient leaves over, not a separately rounded value. `13` divided by `5` gives the pair `2` and `3`, and `7` divided by `7` gives `1` and `0`; the identity between the two results holds for every operand pair the encoding can express.

<!-- PTO-READER-BLOCK: scalar-hl-divu-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the dividend and `SrcR` is the divisor, read through the Reg5 source map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry.
- `RegDst0` publishes the quotient and `RegDst1` publishes the remainder. Each destination uses the common map independently: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard.
- `SrcL`, `SrcR`, `RegDst0` and `RegDst1` are all required encoded fields, so no operand and no destination can be omitted.

Design point: the two destinations are independent, so one instruction can mix a GPR write with a queue push, and a code that discards on one side leaves the other side untouched. A destination code that names a source selector is a legal alias: both sources are snapshotted first, so that register or queue slot is overwritten only after the two source reads have happened.

<!-- PTO-READER-BLOCK: scalar-hl-divu-effects role=effects -->
## Effects and ordering

Both results are computed from the same two source snapshots and both are published only after the arithmetic is complete. `TPC` then advances by `6` bytes.

No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no queue entry moves unless a destination encodes `30` or `31`.

Design point: when both destinations push one queue, the pushes follow the encoded order, so the remainder pushed by `RegDst1` is the newest entry and the quotient pushed by `RegDst0` is next-newest. While `T#1` is available, `hl.divu t#1, zero, ->u, u` therefore leaves the remainder in `U#1` and the quotient in `U#2`.

<!-- PTO-READER-BLOCK: scalar-hl-divu-constraints role=constraints -->
## Legality and fault boundary

Both sources and both destinations assign every code, and duplicate destination codes are legal, so `HL.DIVU` reserves no selector value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`; an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination effect and before `TPC` advances.

Design point: no divisor value can fault. A zero divisor has defined outputs, `0` for the quotient and the dividend for the remainder, and a nonzero divisor goes through the same guarded loop the single-result `DIVU` uses, so the pair form adds no trap path.

<!-- PTO-READER-BLOCK: scalar-hl-divu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=13` and `a1=5`, `hl.divu a0, a1, ->a2, a3` writes `2` to `a2` and `3` to `a3`. With `SrcR` encoded as zero the divisor is the architectural zero GPR, so the quotient is `0` and the remainder is `13`. With `a0=7` and `a1=7` the pair is `1` and `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divu_48_597acda29e08 | HL48 | 48 | 0x00001057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divu_48_597acda29e08 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divu_48_597acda29e08 | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divu_48_597acda29e08 | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divu_48_597acda29e08 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divu_48_597acda29e08 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVU.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVU() => ScalarOperation
begin
    return ScalarOperation_HL_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVU.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
pure func InstructionContractQuotient_HL_DIVU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsigned(
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

- hl.divu a0, a1, ->a2, a3
- hl.divu t#1, zero, ->u, u
