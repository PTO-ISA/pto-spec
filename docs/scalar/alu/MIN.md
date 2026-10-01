<!-- GENERATED FROM: asl/scalar/alu/MIN.asl -->
# MIN

**Normative ASL source:** `asl/scalar/alu/MIN.asl`

MIN performs a signed full-XLEN comparison and publishes the complete bit pattern of the minimum operand.

## Normative identity {#PTO-INST-SCALAR-MIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-min-purpose role=purpose -->
## What MIN does

`MIN` is a 32-bit encoded scalar ALU instruction that compares two XLEN values as signed integers and publishes the smaller of the two unchanged through one Reg5 destination.

As with `MAX`, the result is one of the operand bit patterns rather than a computed value, and the comparison uses all `64` bits of each source.

<!-- PTO-READER-BLOCK: scalar-min-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MIN`, which returns `left` when `SInt(left) < SInt(right)` and `right` otherwise, and `InstructionContractUsesSignedComparison_MIN`, which returns true. Dispatch reaches the same helper through `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MIN, FALSE)`.

```asm
min SrcL, SrcR, ->{t, u, Rd}
```

Design point: the minimum is taken on the signed reading, so it is not the same as clearing the high bits. `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 0` produce `SrcL`, because `-1 < 0`, even though `SrcR` is the smaller word when both are read as unsigned.

<!-- PTO-READER-BLOCK: scalar-min-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the selected operand or discards it.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left operand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right operand.

Both sources use the common Reg5 map: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4` without consuming an entry. Encoded zero reads the architectural zero GPR.

Design point: only the two 5-bit source fields feed the comparison; the form carries no immediate, no modifier and no shift field. A `MIN` against a constant therefore needs that constant in a register, which may be a temporary read from a queue.

<!-- PTO-READER-BLOCK: scalar-min-effects role=effects -->
## Effects and ordering

The two sources are snapshotted before the destination effect. A destination push to the same queue a source was read from publishes the selected operand without disturbing the entry that was read.

The selected operand is written through `RegDst`, and `TPC` then advances by `4` bytes. The instruction has no memory effect, no numeric-status effect and no effect on reservation, descriptor, bundle, privilege or control-flow state.

<!-- PTO-READER-BLOCK: scalar-min-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and every XLEN bit pattern is legal, so only an unavailable temporary source can fail the operand checks. Instruction bits `31:25` and `14:12` are fixed by the accepted form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: the fault surface is identical to `MAX` because both mnemonics share the selection helper and differ only in the comparison operator. There is no operand pair for which one of the two faults on values and the other does not.

<!-- PTO-READER-BLOCK: scalar-min-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 0`, the signed values are `-1` and `0`, so `RegDst` receives `0xFFFFFFFFFFFFFFFF`. With `SrcL = 4` and `SrcR = 7`, `RegDst` receives `4`. With `SrcL = SrcR = 0x8000000000000000`, the strict comparison is false and `RegDst` receives the right operand, whose bit pattern is identical.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
min SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| min_32_25692b799267 | L32 | 32 | 0x0000505b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| min_32_25692b799267 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| min_32_25692b799267 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| min_32_25692b799267 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| min_32_25692b799267 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| min_32_25692b799267 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| min_32_25692b799267 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractOperation_MIN()
    => ScalarOperation
begin
    return ScalarOperation_MIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractHandler_MIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MIN(left: Word, right: Word)
    => Word
begin
    if SInt(left) < SInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MIN()
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

- Perform a signed full-XLEN comparison and return the complete bit pattern of the minimum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MIN raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- min a0, a1, ->a2
- min t#1, u#1, ->u
- min zero, zero, ->zero
