<!-- GENERATED FROM: asl/scalar/alu/MUL.asl -->
# MUL

**Normative ASL source:** `asl/scalar/alu/MUL.asl`

MUL computes the low XLEN bits of the complete scalar product and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-mul-purpose role=purpose -->
## What MUL does

`MUL` is a 32-bit encoded scalar ALU instruction that multiplies two XLEN sources and publishes the low `PTO_XLEN` bits of the complete product through one Reg5 destination.

The `L32` class of the form is the instruction length, so the source operands still enter the multiply as complete `64`-bit values. No high product half is produced and no immediate is encoded.

<!-- PTO-READER-BLOCK: scalar-mul-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MUL`, which returns `MultiplyWord(left, right)`. That helper starts from zero and, for every set bit position of `right`, adds `LSL(left, bit_index)` to a `Word` accumulator, so each partial sum is already reduced modulo `2^PTO_XLEN`.

```asm
mul SrcL, SrcR, ->{t, u, Rd}
```

Design point: the retained half is the same under either sign interpretation, and the executable dispatch binds `MUL` and `MULU` to that one helper. `SrcL = 0xFFFFFFFFFFFFFFFF` with `SrcR = 0xFFFFFFFFFFFFFFFF` therefore publishes `1` under both mnemonics.

<!-- PTO-READER-BLOCK: scalar-mul-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the low XLEN bits of the product.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left multiplicand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right multiplicand.

Both sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reads do not consume a queue entry, and an encoded zero reads the architectural zero GPR.

Design point: this form encodes no `SrcRType` or shift field, so `SrcR` reaches the multiply unchanged. A form that carries those fields, such as `ADD`, writes them as a suffix on the right source (`.sw`, `.uw`, `.neg`, and the shift); `MUL` has three operand fields only.

<!-- PTO-READER-BLOCK: scalar-mul-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination effect, so `mul a0, a0, ->a0` multiplies the pre-instruction `a0` by itself.

Once the result is published, `TPC` advances by `4` bytes. `MUL` performs no memory access and changes no numeric-status, reservation, descriptor, bundle, privilege or control-flow state; the only possible queue change is the single `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-mul-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding is assigned and every `32`-code destination encoding is accepted, so an unavailable temporary source is the only operand condition that can fail. Fixed encoding bits must match the canonical 32-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: the discarded high product bits leave no trace and set no flag, so `MUL` cannot report overflow. Code that must detect it has to compare against a wider form or reconstruct the product, because no exception is defined for any operand pair.

<!-- PTO-READER-BLOCK: scalar-mul-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 6` and `SrcR = 7`, the accumulator holds `42` and `RegDst` receives `42`. With `SrcL = SrcR = 0xFFFFFFFFFFFFFFFF`, the exact product is `2^128 - 2^65 + 1`, whose low `PTO_XLEN` bits are `1`, so `RegDst` receives `1` under `MUL` and under `MULU` alike.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
mul SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mul_32_9f2affd8efb8 | L32 | 32 | 0x00000047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mul_32_9f2affd8efb8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mul_32_9f2affd8efb8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mul_32_9f2affd8efb8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mul_32_9f2affd8efb8 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| mul_32_9f2affd8efb8 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| mul_32_9f2affd8efb8 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractOperation_MUL() => ScalarOperation
begin
    return ScalarOperation_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractHandler_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
pure func InstructionContractResult_MUL(left: Word, right: Word) => Word
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

- Multiply both complete XLEN source bit patterns modulo 2^PTO_XLEN; signedness does not affect the retained low half.
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

- mul srcl, srcr, ->{t, u, rd}
