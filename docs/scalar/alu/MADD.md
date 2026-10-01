<!-- GENERATED FROM: asl/scalar/alu/MADD.asl -->
# MADD

**Normative ASL source:** `asl/scalar/alu/MADD.asl`

MADD adds a snapshotted XLEN addend to the low XLEN scalar product modulo 2^PTO_XLEN and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-madd-purpose role=purpose -->
## What MADD does

`MADD` is a 32-bit encoded scalar ALU instruction that publishes `SrcD + SrcL * SrcR` modulo `2^PTO_XLEN` through one Reg5 destination. It is the single-destination member of the multiply-add group: no high product half is produced.

The `L32` encoding class fixes the instruction length, not the operand width. Both multiplicands are used at full XLEN width, unlike `MADDW`, which reads only their low words.

<!-- PTO-READER-BLOCK: scalar-madd-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MADD`, which returns `ScalarMultiplyAdd(addend, left, right)`. That helper is `addend + MultiplyWord(left, right)`, and `MultiplyWord` accumulates `left` shifted left by each set bit position of `right`, keeping the low `PTO_XLEN` bits of every partial sum.

```asm
madd SrcL, SrcR, SrcD, ->{t, u, Rd}
```

Design point: the product never leaves XLEN width. `SrcL = 2^63` with `SrcR = 2` produces a partial sum of `2^64`, which is discarded, so the published value is `SrcD`; a wide form such as `HL.MADD` would instead keep that bit in its high half.

<!-- PTO-READER-BLOCK: scalar-madd-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the XLEN result.
- `SrcD`, instruction slice `[27 +: 5]`, supplies the addend.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left multiplicand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right multiplicand.

All three sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reads are non-consuming, and an encoded zero reads the architectural zero GPR rather than an uninitialized value.

Design point: the destination map is not the mirror image of the source map. Codes `1..23` write GPRs and codes `30` and `31` push `U` and `T`, while code `0` and codes `24..29` discard the result. A destination code of `24` therefore names a readable `T#1` source but writes nothing.

<!-- PTO-READER-BLOCK: scalar-madd-effects role=effects -->
## Effects and ordering

The three sources are snapshotted before the destination effect, so `madd a0, a1, a0, ->a0` uses the pre-instruction `a0` as both addend and destination.

After the result is published or discarded, `TPC` advances by `4` bytes. `MADD` accesses no memory and changes no reservation, descriptor, numeric-status, bundle, privilege or control-flow state; the single possible queue change is the `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-madd-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding is assigned and every `32`-code destination encoding is accepted, so operand legality can fail only on an unavailable temporary source. The fixed encoding bits must match the canonical 32-bit form; no operand value is reserved.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. Multiplication and addition raise no arithmetic exception at any value.

Design point: the multiply, the add and the wrap are all fixed-width steps with no flag output, so the instruction has no operand pair that reports overflow. A caller that needs the discarded high bits must use a wider form instead.

<!-- PTO-READER-BLOCK: scalar-madd-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 6`, `SrcR = 7` and `SrcD = 1`, `MultiplyWord` returns `42`, the addend adds `1`, and `RegDst` receives `43`. With `SrcL = 2^63`, `SrcR = 2` and `SrcD = 0` the product is `2^64`, which wraps to `0` modulo `2^PTO_XLEN`, so `RegDst` receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
madd SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| madd_32_6208e8e59303 | L32 | 32 | 0x00006047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| madd_32_6208e8e59303 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| madd_32_6208e8e59303 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| madd_32_6208e8e59303 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| madd_32_6208e8e59303 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| madd_32_6208e8e59303 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractOperation_MADD() => ScalarOperation
begin
    return ScalarOperation_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractHandler_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAdd;
end;
pure func InstructionContractResult_MADD(addend: Word, left: Word, right: Word) => Word
begin
    return ScalarMultiplyAdd(addend, left, right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Multiply SrcL and SrcR modulo 2^PTO_XLEN, add SrcD modulo 2^PTO_XLEN, and retain the low XLEN bits.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- madd srcl, srcr, srcd, ->{t, u, rd}
