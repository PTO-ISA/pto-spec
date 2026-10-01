<!-- GENERATED FROM: asl/scalar/alu/MAXU.asl -->
# MAXU

**Normative ASL source:** `asl/scalar/alu/MAXU.asl`

MAXU performs an unsigned full-XLEN comparison and publishes the complete bit pattern of the maximum operand.

## Normative identity {#PTO-INST-SCALAR-MAXU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-maxu-purpose role=purpose -->
## What MAXU does

`MAXU` is a 32-bit encoded scalar ALU instruction that compares two XLEN values as unsigned integers and publishes the larger of the two unchanged through one Reg5 destination.

The comparison covers all `64` bits, so a source with bit `63` set is the largest possible operand rather than a negative one.

<!-- PTO-READER-BLOCK: scalar-maxu-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MAXU`, which returns `left` when `UInt(left) > UInt(right)` and `right` otherwise, and `InstructionContractUsesSignedComparison_MAXU`, which returns false. Dispatch reaches the same helper through `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MAXU, FALSE)`.

```asm
maxu SrcL, SrcR, ->{t, u, Rd}
```

Design point: `MAX` and `MAXU` share one helper with a comparison-mode flag rather than two separate bodies, and the choice changes the answer whenever exactly one operand has bit `63` set. With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 0`, `MAX` publishes `0` and `MAXU` publishes `SrcL`.

<!-- PTO-READER-BLOCK: scalar-maxu-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the selected operand or discards it.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left operand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right operand.

Sources use the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, all read without consuming an entry. Encoded zero reads the architectural zero GPR.

Design point: the destination codes are the usual ones: `1..23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard. Because both operands are only read, a discarded `MAXU` leaves every register and queue exactly as it found them.

<!-- PTO-READER-BLOCK: scalar-maxu-effects role=effects -->
## Effects and ordering

Both sources are read before the destination write, so a destination that aliases a source cannot change which operand is selected.

The selected operand is published through `RegDst`, and `TPC` then advances by `4` bytes. The instruction has no memory effect and sets no numeric flag; apart from `RegDst` and `TPC`, only the destination-selected `T` or `U` push can change state.

<!-- PTO-READER-BLOCK: scalar-maxu-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and every XLEN bit pattern is a legal operand, so only an unavailable temporary source can fail the operand checks. Instruction bits `31:25` and `14:12` are fixed by the accepted form, so those bits belong to the decode match rather than to the operands.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: an unsigned comparison has no sign corner and no arithmetic step, so no operand value can produce fault behavior. The complete fault surface is the decode match plus temporary source availability.

<!-- PTO-READER-BLOCK: scalar-maxu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 0`, the unsigned comparison is true, so `RegDst` receives `0xFFFFFFFFFFFFFFFF`. With `SrcL = 4` and `SrcR = 7`, `RegDst` receives `7`. With `SrcL = SrcR = 0x8000000000000000`, the comparison is false and `RegDst` receives the right operand, which holds the same bit pattern.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
maxu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| maxu_32_b8789571339d | L32 | 32 | 0x0800405b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| maxu_32_b8789571339d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| maxu_32_b8789571339d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| maxu_32_b8789571339d | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| maxu_32_b8789571339d | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| maxu_32_b8789571339d | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| maxu_32_b8789571339d | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MAXU.asl -->
```asl
readonly func InstructionContractOperation_MAXU()
    => ScalarOperation
begin
    return ScalarOperation_MAXU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MAXU.asl -->
```asl
readonly func InstructionContractHandler_MAXU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MAXU(left: Word, right: Word)
    => Word
begin
    if UInt(left) > UInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MAXU()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- The operands use an unsigned full-XLEN comparison; every XLEN bit pattern is legal.

## State effects

- Perform an unsigned full-XLEN comparison and return the complete bit pattern of the maximum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MAXU raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- maxu a0, a1, ->a2
- maxu t#1, u#1, ->u
- maxu zero, zero, ->zero
