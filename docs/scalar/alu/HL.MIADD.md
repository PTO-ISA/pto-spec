<!-- GENERATED FROM: asl/scalar/alu/HL.MIADD.asl -->
# HL.MIADD

**Normative ASL source:** `asl/scalar/alu/HL.MIADD.asl`

HL.MIADD multiplies SrcR by the unsigned 19-bit immediate, adds SrcL modulo 2^PTO_XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-HL-MIADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-miadd-purpose role=purpose -->
## What HL.MIADD does

`HL.MIADD` is a 48-bit scalar ALU instruction that publishes `SrcL + SrcR * uimm19` modulo `2^PTO_XLEN` through one Reg5 destination.

The 19-bit field is the multiplier. It is zero-extended to XLEN and multiplied by `SrcR`; the product is then added to `SrcL` in full XLEN width.

<!-- PTO-READER-BLOCK: scalar-hl-miadd-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_MIADD`, which returns `ScalarMultiplyImmediateAdd(left, right, immediate, FALSE)`. That helper computes `MultiplyWord(right, ZeroExtend{PTO_XLEN}(immediate))` and adds `left` to the product. Dispatch reaches it from the `ScalarOperation_HL_MIADD, ScalarOperation_HL_MISUB` alternative with `ScalarDecodedBits19(instruction, form, ScalarField_uimm19)`.

```asm
hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}
```

Design point: the immediate scales `SrcR`; it is not an operand of its own. Setting `uimm19 = 0` therefore makes the product zero and the instruction publishes `SrcL` unchanged, which is the only immediate value that does not depend on `SrcR`.

<!-- PTO-READER-BLOCK: scalar-hl-miadd-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the XLEN result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the additive operand.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the multiplicand.
- `uimm19`, instruction slices `[41 +: 7]` and `[4 +: 12]`, supplies value bits `6:0` and `18:7`.

All three Reg5 codes use the common map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry. An encoded zero in `SrcL` or `SrcR` reads the architectural zero GPR.

Design point: the two immediate pieces are not adjacent. Value bits `6:0` sit at the top of the 48-bit word and value bits `18:7` sit below the destination field, so a decoder has to place both pieces before it can multiply.

<!-- PTO-READER-BLOCK: scalar-hl-miadd-effects role=effects -->
## Effects and ordering

`SrcL` and `SrcR` are snapshotted before the destination effect, so `hl.miadd a0, a1, 3, ->a0` still uses the pre-instruction `a0` as the additive operand.

The single result is published through `RegDst`, and `TPC` then advances by `6` bytes. `HL.MIADD` has no memory effect and no numeric-status effect; apart from `RegDst` and `TPC`, only the `T` or `U` push selected by the destination code can change state.

<!-- PTO-READER-BLOCK: scalar-hl-miadd-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and every `uimm19` value from `0` through `524287` is legal, so the operand pass can fail only on an unavailable temporary source. The fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. Multiplication and addition raise no arithmetic exception at any value.

Design point: the multiplier is unsigned and capped at `524287`, so the multiply can never be asked for a negative scale. A negative contribution comes from `SrcR` itself: `MultiplyWord` works on the XLEN bit pattern, so a two's-complement negative multiplicand produces the wrapped product.

<!-- PTO-READER-BLOCK: scalar-hl-miadd-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 20`, `SrcR = 3` and `uimm19 = 4`, the product is `12` and `RegDst` receives `32`. With `SrcR = 3` and `uimm19 = 0` the product is `0`, so `RegDst` receives `SrcL` whatever `SrcR` holds. With `SrcL = 0`, `SrcR = 0xFFFFFFFFFFFFFFFF` and `uimm19 = 2`, the product is `0xFFFFFFFFFFFFFFFE`, which is the published value.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_miadd_48_ec5127b6dfd6 | HL48 | 48 | 0x0000004d000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_miadd_48_ec5127b6dfd6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_miadd_48_ec5127b6dfd6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_miadd_48_ec5127b6dfd6 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_miadd_48_ec5127b6dfd6 | uimm19 | 19 | unsigned | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_miadd_48_ec5127b6dfd6 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_miadd_48_ec5127b6dfd6 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_miadd_48_ec5127b6dfd6 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_miadd_48_ec5127b6dfd6 | uimm19 | 19 | 0–524287 | none | none | unsigned 19-bit multiplier | Encoded zero selects multiplier zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |
| uimm19 | unsigned 19-bit multiplier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MIADD.asl -->
```asl
readonly func InstructionContractOperation_HL_MIADD() => ScalarOperation
begin
    return ScalarOperation_HL_MIADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MIADD.asl -->
```asl
readonly func InstructionContractHandler_HL_MIADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
pure func InstructionContractResult_HL_MIADD(
    left: Word,
    right: Word,
    immediate: bits(19))
    => Word
begin
    return ScalarMultiplyImmediateAdd(left, right, immediate, FALSE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.
- uimm19 is an unsigned value from 0 through 524287; encoded zero contributes a zero product.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Zero-extend uimm19 to XLEN, multiply it by SrcR, then add SrcL modulo 2^PTO_XLEN.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.miadd srcl, srcr, uimm, ->{t, u, rd}
