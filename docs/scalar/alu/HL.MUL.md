<!-- GENERATED FROM: asl/scalar/alu/HL.MUL.asl -->
# HL.MUL

**Normative ASL source:** `asl/scalar/alu/HL.MUL.asl`

HL.MUL computes a signed 128-bit scalar product and publishes its low half followed by its high half.

## Normative identity {#PTO-INST-SCALAR-HL-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-mul-purpose role=purpose -->
## What HL.MUL does

`HL.MUL` is a 48-bit scalar ALU instruction that forms the signed 128-bit product of its two XLEN sources and publishes it as two XLEN halves. It takes no addend and no immediate.

`RegDst0` receives the low half `product[63:0]` and `RegDst1` receives the high half `product[127:64]`, so the pair carries the exact product without rounding or saturation.

<!-- PTO-READER-BLOCK: scalar-hl-mul-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractProduct_HL_MUL`, which returns `MultiplyWideSigned(left, right)`. `InstructionContractLow_HL_MUL` slices bits `63:0` of that product and `InstructionContractHigh_HL_MUL` slices bits `127:64`. Dispatch reaches the same slices through `ExecuteScalarMultiplyPair` with `signed_operation` true.

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

Design point: the signed reading of the sources changes the high half but not the low half. Bits `63:0` of a two's-complement product depend only on the low `64` bits of the operands, so `HL.MUL` and `HL.MULU` publish the same `RegDst0` value for every input pair and can differ only in `RegDst1`.

<!-- PTO-READER-BLOCK: scalar-hl-mul-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0`, instruction slice `[23 +: 5]`, receives the low product half `product[63:0]`.
- `RegDst1`, instruction slice `[11 +: 5]`, receives the high product half `product[127:64]`.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the left multiplicand.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the right multiplicand.

Both sources are Reg5 codes: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. A temporary read does not consume the entry. The whole product is computed from the two snapshots before either destination is written.

Design point: this form encodes no right-source modifier. Some other scalar ALU forms, for example `ADD`, `SUB`, `AND`, `OR` and `XOR`, carry a `SrcRType` field that can sign-extend, zero-extend or negate `SrcR` before use, and `HL.MUL` has no such field, so the register value enters the multiply unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-mul-effects role=effects -->
## Effects and ordering

Both sources are read before the first write, so a destination that also names a source still receives a result computed from pre-instruction values.

The two writes run in encoded order: `RegDst0` with `product[63:0]`, then `RegDst1` with `product[127:64]`. When both fields name one GPR the high half is what remains; when both push one queue the high half is newest.

`TPC` advances by `6` bytes after the destination effects. `HL.MUL` performs no memory access and leaves reservation, descriptor, numeric-status, bundle, privilege and control-flow state unchanged apart from the queue pushes selected by the destinations.

<!-- PTO-READER-BLOCK: scalar-hl-mul-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding is assigned and every `32`-code destination encoding is accepted, so the only operand check that can fail is temporary source availability. Fixed encoding bits must match the canonical form; the two multiplicand fields carry no reserved value.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before any destination write. The multiplication raises no arithmetic exception at any operand value.

Design point: an unavailable selected `T` or `U` source is the only fault this instruction can take after decoding, and it is raised before either half of the product is published.

<!-- PTO-READER-BLOCK: scalar-hl-mul-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 6` and `SrcR = 7` the product is `42`, so `RegDst0` receives `42` and `RegDst1` receives `0`. With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 2`, the signed product is `-2`: `RegDst0` receives `0xFFFFFFFFFFFFFFFE` and `RegDst1` receives `0xFFFFFFFFFFFFFFFF`. Repeating the second pair under `HL.MULU` changes only `RegDst1`, which would be `0x1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | HL48 | 48 | 0x00000047000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_mul_48_0d059ff178fb | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_mul_48_0d059ff178fb | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractOperation_HL_MUL() => ScalarOperation
begin
    return ScalarOperation_HL_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractHandler_HL_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
pure func InstructionContractProduct_HL_MUL(left: Word, right: Word) => DoubleWord
begin
    return MultiplyWideSigned(left, right);
end;

pure func InstructionContractLow_HL_MUL(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MUL(left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MUL(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MUL(left, right)[127:64];
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

- Sign-extend both XLEN sources into a signed 128-bit product.
- Snapshot every source and compute the complete 128-bit result before destinations. Publish bits 63:0 to RegDst0, then bits 127:64 to RegDst1. Duplicate destinations are legal; the second high result is final/newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the low result to RegDst0, publish the high result to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.mul srcl, srcr, ->dst0, dst1
