<!-- GENERATED FROM: asl/scalar/alu/MAX.asl -->
# MAX

**Normative ASL source:** `asl/scalar/alu/MAX.asl`

MAX performs a signed full-XLEN comparison and publishes the complete bit pattern of the maximum operand.

## Normative identity {#PTO-INST-SCALAR-MAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-max-purpose role=purpose -->
## What MAX does

`MAX` is a 32-bit encoded scalar ALU instruction that compares two XLEN values as signed integers and publishes the larger of the two unchanged through one Reg5 destination.

The published word is one of the two operand bit patterns, not a newly computed value. Both sources are compared at full XLEN width, so the `L32` class describes the instruction length rather than the operand width.

<!-- PTO-READER-BLOCK: scalar-max-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MAX`, which returns `left` when `SInt(left) > SInt(right)` and `right` otherwise, and `InstructionContractUsesSignedComparison_MAX`, which returns true. Dispatch reaches the same helper through `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MAX, FALSE)`, which reads `SrcL` and `SrcR` and writes the selected operand.

```asm
max SrcL, SrcR, ->{t, u, Rd}
```

Design point: the comparison is strict, so equal operands fall through to the `right` branch. That choice is invisible because two's-complement values that compare equal have identical bit patterns; there is no separate tie case to define.

<!-- PTO-READER-BLOCK: scalar-max-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the selected operand or discards it.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left operand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right operand.

Both sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry. Encoded zero reads the architectural zero GPR for either source.

Design point: this form has no right-source modifier, so `SrcR` is compared exactly as read. Some other scalar ALU forms, for example `ADD`, `SUB`, `AND`, `OR` and `XOR`, carry a `SrcRType` field that can sign-extend, zero-extend or negate the right source before use; `MAX` has no such field and compares the complete register contents.

<!-- PTO-READER-BLOCK: scalar-max-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination effect, so `max a0, a0, ->a0` and a destination that aliases one source both operate on pre-instruction values.

The selected operand is published through `RegDst`, and `TPC` then advances by `4` bytes. `MAX` reads and writes no memory, sets no numeric flag, and changes no reservation, descriptor, bundle, privilege or control-flow state; the only possible queue change is the `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-max-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and every XLEN bit pattern is a legal operand, so only an unavailable temporary source can fail the operand checks. Instruction bits `31:25` and `14:12` are fixed by the accepted form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write. The comparison itself raises no arithmetic exception.

Design point: selecting between two operands cannot overflow, so no operand pair has a fault. A maximum of two registers is exact at every value, including the signed minimum and maximum, because no arithmetic is performed on them.

<!-- PTO-READER-BLOCK: scalar-max-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 0`, the signed reading makes `SrcL` equal to `-1`, which is not greater than `0`, so `RegDst` receives `SrcR`, the word `0`. With `SrcL = 5` and `SrcR = 5` the comparison is false and `RegDst` receives `5`. With `SrcL = 4` and `SrcR = 7`, `RegDst` receives `7`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
max SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| max_32_9166468a1db7 | L32 | 32 | 0x0000405b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| max_32_9166468a1db7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| max_32_9166468a1db7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| max_32_9166468a1db7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| max_32_9166468a1db7 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| max_32_9166468a1db7 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| max_32_9166468a1db7 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MAX.asl -->
```asl
readonly func InstructionContractOperation_MAX()
    => ScalarOperation
begin
    return ScalarOperation_MAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MAX.asl -->
```asl
readonly func InstructionContractHandler_MAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MAX(left: Word, right: Word)
    => Word
begin
    if SInt(left) > SInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MAX()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- The operands use a signed full-XLEN comparison; every XLEN bit pattern is legal.

## State effects

- Perform a signed full-XLEN comparison and return the complete bit pattern of the maximum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MAX raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- max a0, a1, ->a2
- max t#1, u#1, ->u
- max zero, zero, ->zero
