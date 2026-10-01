<!-- GENERATED FROM: asl/scalar/alu/HL.MISUB.asl -->
# HL.MISUB

**Normative ASL source:** `asl/scalar/alu/HL.MISUB.asl`

HL.MISUB multiplies SrcR by the unsigned 19-bit immediate, subtracts the product from SrcL modulo 2^PTO_XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-HL-MISUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-misub-purpose role=purpose -->
## What HL.MISUB does

`HL.MISUB` is a 48-bit scalar ALU instruction that publishes `SrcL - SrcR * uimm19` modulo `2^PTO_XLEN` through one Reg5 destination.

`SrcL` is the minuend and the scaled product is the subtrahend, so the immediate selects how many copies of `SrcR` are removed from `SrcL`.

<!-- PTO-READER-BLOCK: scalar-hl-misub-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_HL_MISUB`, which returns `ScalarMultiplyImmediateAdd(left, right, immediate, TRUE)`. With the subtract flag set, the helper computes `MultiplyWord(right, ZeroExtend{PTO_XLEN}(immediate))` first and then returns `left - product`. Dispatch shares the `ScalarOperation_HL_MIADD, ScalarOperation_HL_MISUB` alternative and passes `operation == ScalarOperation_HL_MISUB` as that flag.

```asm
hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}
```

Design point: the subtraction is a full-width step, so a product larger than `SrcL` borrows across the whole word. `SrcL = 0`, `SrcR = 1` and `uimm19 = 1` publish `0xFFFFFFFFFFFFFFFF` rather than a clamped zero.

<!-- PTO-READER-BLOCK: scalar-hl-misub-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[23 +: 5]`, receives the XLEN result or discards it.
- `SrcL`, instruction slice `[31 +: 5]`, supplies the minuend.
- `SrcR`, instruction slice `[36 +: 5]`, supplies the multiplicand.
- `uimm19`, instruction slices `[41 +: 7]` and `[4 +: 12]`, supplies value bits `6:0` and `18:7`.

Each Reg5 code is a source code or a destination code from the common map: `0..23` name absolute GPRs, `24..27` name `T#1..T#4`, and `28..31` name `U#1..U#4` as sources. Reading a temporary leaves it in place, and the two reads both precede the destination write.

Design point: the destination shares the five-bit field with the sources, but the two roles are not symmetric: source codes `24..29` are readable temporary entries, while the same codes as a destination discard the result. `->u` and `->t` are the codes `30` and `31`.

<!-- PTO-READER-BLOCK: scalar-hl-misub-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination effect, so a destination that also names `SrcL` or `SrcR` receives a value computed from the pre-instruction registers.

The result is published through `RegDst`, and `TPC` then advances by `6` bytes. No memory is read or written, and no numeric-status, reservation, descriptor, bundle, privilege or control-flow state changes; only the destination-selected queue push can alter a temporary queue.

<!-- PTO-READER-BLOCK: scalar-hl-misub-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding, every `32`-code destination encoding and every `uimm19` value from `0` through `524287` is assigned, so only an unavailable temporary source can fail the operand checks. The fixed encoding bits must match the canonical 48-bit form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: a subtract that underflows is not an exception, so the instruction cannot report a negative intermediate result. `HL.MISUB` publishes the wrapped word, and the sign of the difference is readable only from its top bit.

<!-- PTO-READER-BLOCK: scalar-hl-misub-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 20`, `SrcR = 3` and `uimm19 = 4`, the product is `12` and `RegDst` receives `8`. With `SrcL = 0`, `SrcR = 1` and `uimm19 = 1` the subtraction wraps and `RegDst` receives `0xFFFFFFFFFFFFFFFF`. With `uimm19 = 0` the product is `0` and `RegDst` receives `SrcL`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_misub_48_e9e4c7b23479 | HL48 | 48 | 0x0000104d000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_misub_48_e9e4c7b23479 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_misub_48_e9e4c7b23479 | uimm19 | 19 | unsigned | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_misub_48_e9e4c7b23479 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_misub_48_e9e4c7b23479 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_misub_48_e9e4c7b23479 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_misub_48_e9e4c7b23479 | uimm19 | 19 | 0–524287 | none | none | unsigned 19-bit multiplier | Encoded zero selects multiplier zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |
| uimm19 | unsigned 19-bit multiplier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractOperation_HL_MISUB() => ScalarOperation
begin
    return ScalarOperation_HL_MISUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MISUB.asl -->
```asl
readonly func InstructionContractHandler_HL_MISUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
pure func InstructionContractResult_HL_MISUB(
    left: Word,
    right: Word,
    immediate: bits(19))
    => Word
begin
    return ScalarMultiplyImmediateAdd(left, right, immediate, TRUE);
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

- Zero-extend uimm19 to XLEN, multiply it by SrcR, then subtract the product from SrcL modulo 2^PTO_XLEN.
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

- hl.misub srcl, srcr, uimm, ->{t, u, rd}
