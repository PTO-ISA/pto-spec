<!-- GENERATED FROM: asl/scalar/alu/HL.MADD.asl -->
# HL.MADD

**Normative ASL source:** `asl/scalar/alu/HL.MADD.asl`

HL.MADD computes a signed 128-bit product plus a sign-extended XLEN addend and publishes low then high halves.

## Normative identity {#PTO-INST-SCALAR-HL-MADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-madd-purpose role=purpose -->
## What HL.MADD does

`HL.MADD` is a 48-bit scalar ALU instruction that computes `SrcL * SrcR + SrcD` at 128-bit width. Both multiplicands are read as signed XLEN values, the addend is sign-extended to 128 bits, and the sum is published as two XLEN halves.

There is no rounding, saturation, or flag output. The low half goes to `RegDst0` and the high half to `RegDst1`. That pair result shape is what separates this mnemonic from `MADD`, which adds the same addend to the product modulo `2^PTO_XLEN` and publishes one destination.

<!-- PTO-READER-BLOCK: scalar-hl-madd-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractAccumulator_HL_MADD`: `MultiplyWideSigned(left, right)` produces the 128-bit product, `SignExtend{PTO_XLEN * 2}(addend)` widens `SrcD` to the same width, and one 128-bit addition combines them. Dispatch reaches the same accumulator through `ExecuteScalarMultiplyAddPair` with `word_operation` false.

```asm
hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1
```

Design point: the addend is sign-extended to `128` bits, not zero-extended and not truncated to `64`. Adding `SrcD = -1` therefore subtracts one from the complete 128-bit product, and the borrow can reach the high half that `RegDst1` receives.

<!-- PTO-READER-BLOCK: scalar-hl-madd-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0`, instruction slice `[23 +: 5]`, receives `accumulator[63:0]`.
- `RegDst1`, instruction slice `[11 +: 5]`, receives `accumulator[127:64]`.
- `SrcD`, instruction slice `[43 +: 5]`, supplies the addend.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the left multiplicand.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the right multiplicand.

Each source is a Reg5 code: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary does not remove it from its queue, and all three sources are read before either destination is written.

Design point: both destination fields are written independently, so `->Dst0, Dst1` holding codes `30` and `31` pushes the low half to `U` and then the high half to `T`. Duplicate destinations are legal because the two writes simply happen in `RegDst0` then `RegDst1` order.

<!-- PTO-READER-BLOCK: scalar-hl-madd-effects role=effects -->
## Effects and ordering

All three sources are read before any write, so a source that also names a destination still contributes its pre-instruction value. The 128-bit accumulator is complete before the first write.

The writes then run in encoded order: `RegDst0` first with `accumulator[63:0]`, `RegDst1` second with `accumulator[127:64]`. When both names resolve to one GPR the high half is the final value; when both are queue pushes the high half is the newest entry.

After the destination effects, `TPC` advances by `6` bytes. `HL.MADD` reads and writes no memory and changes no other architectural state; the only queue change it can make is the one or two pushes selected by `RegDst0` and `RegDst1`.

<!-- PTO-READER-BLOCK: scalar-hl-madd-constraints role=constraints -->
## Legality and fault boundary

All `32` source codes are assigned: `0..23` select GPRs and `24..31` select temporary queue entries that must be valid. All `32` destination codes are accepted, so `ScalarDestinationSelectorLegal` cannot fail. The fixed bits of the form are a match-and-mask test over the whole 48-bit encoding, and no operand value is reserved.

The checks run in a fixed order. Applicability fails only while a system-block terminal request is pending, which raises `Fault_BundleControl` at `TPC`. Otherwise an encoding that does not match the form raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before any destination write. The arithmetic itself raises nothing: the 128-bit sum wraps modulo `2^128`.

Design point: an unavailable temporary is rejected by the legality pass instead of being read, so the accumulator is never built from an undefined queue entry. That is why `hl.madd t#1, t#1, zero, ->a0, a1` faults on an empty `T` queue rather than publishing a value.

<!-- PTO-READER-BLOCK: scalar-hl-madd-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 6`, `SrcR = 7`, and `SrcD = 1`, `MultiplyWideSigned` produces `42`, the sign-extended addend is `1`, and the accumulator is `43`, so `RegDst0` receives `43` and `RegDst1` receives `0`. With negative inputs `SrcL = -3`, `SrcR = 5`, and `SrcD = 1`, the accumulator is `-14`: the low half is `0xFFFFFFFFFFFFFFF2` and the high half is `0xFFFFFFFFFFFFFFFF`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_madd_48_b062d741fd99 | HL48 | 48 | 0x00006047000e / 0x0600707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_madd_48_b062d741fd99 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_madd_48_b062d741fd99 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_madd_48_b062d741fd99 | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_madd_48_b062d741fd99 | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_madd_48_b062d741fd99 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_madd_48_b062d741fd99 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_madd_48_b062d741fd99 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADD.asl -->
```asl
readonly func InstructionContractOperation_HL_MADD() => ScalarOperation
begin
    return ScalarOperation_HL_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADD.asl -->
```asl
readonly func InstructionContractHandler_HL_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
pure func InstructionContractAccumulator_HL_MADD(
    addend: Word,
    left: Word,
    right: Word)
    => DoubleWord
begin
    let product = MultiplyWideSigned(left, right);
    return product + SignExtend{PTO_XLEN * 2}(addend);
end;

pure func InstructionContractLow_HL_MADD(addend: Word, left: Word, right: Word) => Word
begin
    return InstructionContractAccumulator_HL_MADD(addend, left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MADD(addend: Word, left: Word, right: Word) => Word
begin
    return InstructionContractAccumulator_HL_MADD(addend, left, right)[127:64];
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

- Compute the signed 128-bit product of SrcL and SrcR, sign-extend SrcD to 128 bits, and add modulo 2^128.
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

- hl.madd srcl, srcr, srcd, ->dst0, dst1
