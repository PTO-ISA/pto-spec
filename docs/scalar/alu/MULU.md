<!-- GENERATED FROM: asl/scalar/alu/MULU.asl -->
# MULU

**Normative ASL source:** `asl/scalar/alu/MULU.asl`

MULU computes the low XLEN bits of the complete unsigned scalar product and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MULU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-mulu-purpose role=purpose -->
## What MULU does

`MULU` is a 32-bit encoded scalar ALU instruction that multiplies two XLEN sources and publishes the low `PTO_XLEN` bits of the product through one Reg5 destination. It has no immediate and no high-half destination.

The mnemonic names the unsigned reading of the operands, and the executable dispatch binds it to the same `MultiplyWord` helper as `MUL`.

<!-- PTO-READER-BLOCK: scalar-mulu-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MULU`, which returns `MultiplyWord(left, right)`. The helper reduces every partial sum modulo `2^PTO_XLEN` while it accumulates, so the value it returns is the low XLEN bits of the exact product of the two source bit patterns.

```asm
mulu SrcL, SrcR, ->{t, u, Rd}
```

Design point: `MUL` and `MULU` differ in name, not in executable behavior. `asl/scalar/model/dispatch/alu.asl` handles `ScalarOperation_MUL` and `ScalarOperation_MULU` in one alternative that calls `MultiplyWord`, so no input pair can make the two mnemonics publish different words.

<!-- PTO-READER-BLOCK: scalar-mulu-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the low XLEN bits of the product.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left multiplicand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right multiplicand.

Both sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. A temporary read leaves the entry in place, and an encoded zero reads the architectural zero GPR.

Design point: every bit of both operands can reach the retained product, so `MULU` is not a word operation. Its only truncation is the discard of product bits above bit `PTO_XLEN - 1`, which is the same truncation `MUL` applies.

<!-- PTO-READER-BLOCK: scalar-mulu-effects role=effects -->
## Effects and ordering

Both sources are read before the destination write, so a destination that aliases a source still receives a value computed from the pre-instruction register contents.

After publication, `TPC` advances by `4` bytes. `MULU` reads and writes no memory and touches no numeric-status, reservation, descriptor, bundle, privilege or control-flow state; only the `T` or `U` push selected by `RegDst` can change a queue.

<!-- PTO-READER-BLOCK: scalar-mulu-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding is assigned and every `32`-code destination encoding is accepted, so an unavailable selected temporary is the only operand condition that can fail. Fixed encoding bits must match the canonical 32-bit form; there is no reserved operand value and no encoded mode.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. No arithmetic exception exists for any operand pair.

Design point: the unsigned reading removes the negative corner entirely. `0xFFFFFFFFFFFFFFFF` is the largest operand rather than `-1`, so a caller that wants the signed low half does not need a separate rule for it, and no overflow fault is defined either way.

<!-- PTO-READER-BLOCK: scalar-mulu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = SrcR = 0xFFFFFFFFFFFFFFFF`, `MultiplyWord` accumulates only the partial sums that fit in `PTO_XLEN` bits and returns `1`, so `RegDst` receives `1`. With `SrcL = 6` and `SrcR = 7` the destination receives `42`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
mulu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mulu_32_10b9d1936631 | L32 | 32 | 0x00001047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mulu_32_10b9d1936631 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mulu_32_10b9d1936631 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mulu_32_10b9d1936631 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mulu_32_10b9d1936631 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| mulu_32_10b9d1936631 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| mulu_32_10b9d1936631 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractOperation_MULU() => ScalarOperation
begin
    return ScalarOperation_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractHandler_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
pure func InstructionContractResult_MULU(left: Word, right: Word) => Word
begin
    return MultiplyWord(left, right);
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

- Multiply both complete XLEN source bit patterns modulo 2^PTO_XLEN; the result is identical to MUL for the same source bits.
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

- mulu srcl, srcr, ->{t, u, rd}
