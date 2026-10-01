<!-- GENERATED FROM: asl/scalar/alu/MULUW.asl -->
# MULUW

**Normative ASL source:** `asl/scalar/alu/MULUW.asl`

MULUW multiplies the source low 32-bit values, retains the low 32 product bits, sign-extends them to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MULUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-muluw-purpose role=purpose -->
## What MULUW does

`MULUW` is a 32-bit encoded scalar ALU instruction that multiplies the low words of its two sources, keeps the low `32` bits of that product, and sign-extends bit `31` to XLEN before publishing through one Reg5 destination.

Bits `63:32` of either source are outside the operation, so a source that differs only above bit `31` produces the same published word.

<!-- PTO-READER-BLOCK: scalar-muluw-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MULUW`, which returns `ScalarMultiplyW(left, right)`. That helper zero-extends `left[31:0]` and `right[31:0]`, multiplies them with `MultiplyWord`, and applies `SignExtend{PTO_XLEN}` to `product[31:0]`.

```asm
muluw SrcL, SrcR, ->{t, u, Rd}
```

Design point: the sources are zero-extended but the result is sign-extended, and the two extensions are not symmetric. A product whose bit `31` is set is published as a negative XLEN word: `SrcL = SrcR = 0xFFFFFFFF` gives the 32-bit product `1`, so the destination receives `1`, while the same source values under `MULU` produce `0xFFFFFFFE00000001`.

<!-- PTO-READER-BLOCK: scalar-muluw-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives `SignExtend(product[31:0])`.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left multiplicand word.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right multiplicand word.

Sources use the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, read without consuming an entry. An encoded zero reads the architectural zero GPR, so an encoded-zero multiplicand makes the whole product zero.

Design point: the destination map is the usual one, so codes `1..23` write GPRs, `30` and `31` push `U` and `T`, and `0` with `24..29` discard. The source reads still happen before the discard, so the queue state after a discarded `muluw` is unchanged.

<!-- PTO-READER-BLOCK: scalar-muluw-effects role=effects -->
## Effects and ordering

Both source snapshots are taken before the destination effect, so source-destination aliasing cannot change which values enter the multiply.

The destination receives the sign-extended low word and `TPC` then advances by `4` bytes. The instruction has no memory effect and no numeric-status effect; apart from `RegDst` and `TPC`, only the `T` or `U` push selected by the destination code can change state.

<!-- PTO-READER-BLOCK: scalar-muluw-constraints role=constraints -->
## Legality and fault boundary

Every source code and every destination code is assigned, and the destination selector check accepts all `32` codes, so an unavailable temporary source is the only operand condition that can fail. Fixed encoding bits must match the canonical 32-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise an encoding that does not match the form raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. The multiply itself is total and raises nothing.

Design point: the zero-extension of the sources and the sign-extension of the result are separate steps, so no operand value can produce an exception and no operand value is reserved. The only surprising case is a high result bit `31`, which turns an apparently small 32-bit product into a negative XLEN word.

<!-- PTO-READER-BLOCK: scalar-muluw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0xFFFFFFFF` and `SrcR = 0xFFFFFFFF`, the low words multiply to `0xFFFFFFFE00000001`, whose low `32` bits are `1`, so `RegDst` receives `1`. With `SrcL = 0x0000000180000000` and `SrcR = 2`, only the low words are used: the product `0x80000000 * 2` is `0x100000000`, whose low `32` bits are `0x00000000`, so the destination receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
muluw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| muluw_32_8f52b3d45e53 | L32 | 32 | 0x00003047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| muluw_32_8f52b3d45e53 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| muluw_32_8f52b3d45e53 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| muluw_32_8f52b3d45e53 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| muluw_32_8f52b3d45e53 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| muluw_32_8f52b3d45e53 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| muluw_32_8f52b3d45e53 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULUW.asl -->
```asl
readonly func InstructionContractOperation_MULUW() => ScalarOperation
begin
    return ScalarOperation_MULUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULUW.asl -->
```asl
readonly func InstructionContractHandler_MULUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
pure func InstructionContractResult_MULUW(left: Word, right: Word) => Word
begin
    return ScalarMultiplyW(left, right);
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

- Multiply the source low 32-bit patterns modulo 2^32, then sign-extend result bit 31 through XLEN; current MULUW and MULW results are identical for the same source bits.
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

- muluw srcl, srcr, ->{t, u, rd}
