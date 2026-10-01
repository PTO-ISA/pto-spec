<!-- GENERATED FROM: asl/scalar/alu/MADDW.asl -->
# MADDW

**Normative ASL source:** `asl/scalar/alu/MADDW.asl`

MADDW adds low 32-bit source values modulo 2^32, sign-extends the accumulated result to XLEN, and publishes it.

## Normative identity {#PTO-INST-SCALAR-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-maddw-purpose role=purpose -->
## What MADDW does

`MADDW` is a 32-bit encoded scalar ALU instruction that adds `SrcL[31:0] * SrcR[31:0]` and `SrcD[31:0]` modulo `2^32`, sign-extends bit `31` of that 32-bit sum, and publishes the result through one Reg5 destination.

Only the low word of each source participates. Bits `63:32` of `SrcL`, `SrcR` and `SrcD` cannot influence the published value.

<!-- PTO-READER-BLOCK: scalar-maddw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MADDW`, which returns `ScalarMultiplyAddW(addend, left, right)`. That helper multiplies with `MultiplyWord(left, right)`, takes `product[31:0]`, adds `addend[31:0]` into a 32-bit value, and applies `SignExtend{PTO_XLEN}` to the 32-bit sum.

```asm
maddw SrcL, SrcR, SrcD, ->{t, u, Rd}
```

Design point: the addition is performed in `32` bits and only the finished value is widened. The carry out of bit `31` is therefore dropped instead of being propagated into the upper word: `SrcL = 70000`, `SrcR = 70000` and `SrcD = 0` publish `605032704`, not `4900000000`.

<!-- PTO-READER-BLOCK: scalar-maddw-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the sign-extended 32-bit result.
- `SrcD`, instruction slice `[27 +: 5]`, supplies the addend word.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left multiplicand word.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right multiplicand word.

Sources use the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, all read without consuming an entry. An encoded zero reads the architectural zero GPR.

Design point: the sign extension happens after the accumulate, so the published word is not the zero-extended sum. A sum whose bit `31` is set arrives at the destination as an XLEN value with all upper bits set, which is why `maddw` can publish a negative result from two positive inputs.

<!-- PTO-READER-BLOCK: scalar-maddw-effects role=effects -->
## Effects and ordering

All three sources are snapshotted before the destination effect, so a destination that also names `SrcD`, `SrcL` or `SrcR` observes the pre-instruction value of that register.

The result is published through `RegDst` and `TPC` then advances by `4` bytes. `MADDW` has no memory effect and no numeric-status effect; the only state it can change besides `RegDst` and `TPC` is the single `T` or `U` queue push selected by the destination code.

<!-- PTO-READER-BLOCK: scalar-maddw-constraints role=constraints -->
## Legality and fault boundary

Every source code and every destination code of the 5-bit fields is assigned, and `ScalarDestinationSelectorLegal` accepts all `32` destination codes, so only an unavailable temporary source can fail the operand checks. Fixed encoding bits must match the canonical 32-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise the first fault in the ordered check sequence is `Fault_IllegalInstruction` at `PC` for an encoding that does not match the form, raised before the bundle body is entered, and the second is `Fault_IllegalInstruction` at `PC` for an unavailable selected `T` or `U` source, raised before the destination write.

Design point: because the discarded bits are dropped before the add, `MADDW` needs no overflow rule and defines no exception for any operand triple. The whole fixed-width contract is the modulo `2^32` sum plus the final sign extension.

<!-- PTO-READER-BLOCK: scalar-maddw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = -3`, `SrcR = 5` and `SrcD = 1`, the low words give `-15 + 1 = -14`; `SignExtend(0xFFFFFFF2)` is `0xFFFFFFFFFFFFFFF2`, so the destination receives a negative XLEN word. With `SrcL = 0x100000000`, `SrcR = 5` and `SrcD = 7`, `SrcL[31:0]` is `0`, and the destination receives `7`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
maddw SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | L32 | 32 | 0x00007047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| maddw_32_9f922b15e674 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| maddw_32_9f922b15e674 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| maddw_32_9f922b15e674 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractOperation_MADDW() => ScalarOperation
begin
    return ScalarOperation_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractHandler_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAddW;
end;
pure func InstructionContractResult_MADDW(addend: Word, left: Word, right: Word) => Word
begin
    return ScalarMultiplyAddW(addend, left, right);
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

- Multiply SrcL[31:0] and SrcR[31:0], add SrcD[31:0] modulo 2^32, then sign-extend the final low 32-bit result.
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

- maddw srcl, srcr, srcd, ->{t, u, rd}
