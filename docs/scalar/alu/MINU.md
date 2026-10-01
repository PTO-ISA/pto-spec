<!-- GENERATED FROM: asl/scalar/alu/MINU.asl -->
# MINU

**Normative ASL source:** `asl/scalar/alu/MINU.asl`

MINU performs an unsigned full-XLEN comparison and publishes the complete bit pattern of the minimum operand.

## Normative identity {#PTO-INST-SCALAR-MINU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-minu-purpose role=purpose -->
## What MINU does

`MINU` is a 32-bit encoded scalar ALU instruction that compares two XLEN values as unsigned integers and publishes the smaller of the two unchanged through one Reg5 destination.

The comparison uses all `64` bits, so a source with bit `63` set is large rather than negative and can never be selected as the minimum unless the other operand is at least as large.

<!-- PTO-READER-BLOCK: scalar-minu-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_MINU`, which returns `left` when `UInt(left) < UInt(right)` and `right` otherwise, and `InstructionContractUsesSignedComparison_MINU`, which returns false. Dispatch reaches the same helper through `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MINU, FALSE)`.

```asm
minu SrcL, SrcR, ->{t, u, Rd}
```

Design point: `MIN` and `MINU` share the helper and differ only in the comparison mode, so the pair `SrcL = 0xFFFFFFFFFFFFFFFF`, `SrcR = 0` selects `SrcL` under `MIN` and `SrcR` under `MINU`. Both results are the same word `0` or the same all-ones word; nothing in between is computed.

<!-- PTO-READER-BLOCK: scalar-minu-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the selected operand or discards it.
- `SrcL`, instruction slice `[15 +: 5]`, supplies the left operand.
- `SrcR`, instruction slice `[20 +: 5]`, supplies the right operand.

Sources use the common Reg5 map, `0..23` for absolute GPRs, `24..27` for `T#1..T#4` and `28..31` for `U#1..U#4`, read without consuming an entry. Encoded zero reads the architectural zero GPR.

Design point: both operands are only read, so an encoded-zero source contributes the constant `0` with no data dependency. `minu` against a zero source therefore publishes `0` through the destination map whatever the other operand holds, including when the destination is a queue push.

<!-- PTO-READER-BLOCK: scalar-minu-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination effect, so a destination that names one of them still receives a value chosen from the pre-instruction operands.

The selected operand is published through `RegDst`, and `TPC` advances by `4` bytes afterwards. No memory is accessed, no numeric flag is set, and no reservation, descriptor, bundle, privilege or control-flow state changes; only the destination-selected queue push can alter a queue.

<!-- PTO-READER-BLOCK: scalar-minu-constraints role=constraints -->
## Legality and fault boundary

Every `32`-code source encoding and every `32`-code destination encoding is assigned, and every XLEN bit pattern is a legal operand, so only an unavailable temporary source can fail the operand checks. Instruction bits `31:25` and `14:12` are fixed by the accepted form.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise a mismatching encoding raises `Fault_IllegalInstruction` at `PC` before the bundle body is entered, and an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination write.

Design point: an unsigned comparison has no arithmetic and no sign corner, so no operand pair can move the fault from the encoding match or the source-availability check into the operation. That holds for the signed minimum input as much as for any other word.

<!-- PTO-READER-BLOCK: scalar-minu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL = 4` and `SrcR = 7`, `RegDst` receives `4`. With `SrcL = 0xFFFFFFFFFFFFFFFF` and `SrcR = 0`, the unsigned comparison is false, so `RegDst` receives `0`. With `SrcL = SrcR = 0x8000000000000000`, the comparison is false and `RegDst` receives the right operand, which carries the same bit pattern.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
minu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| minu_32_9bdb71ef7b19 | L32 | 32 | 0x0800505b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| minu_32_9bdb71ef7b19 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| minu_32_9bdb71ef7b19 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| minu_32_9bdb71ef7b19 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| minu_32_9bdb71ef7b19 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| minu_32_9bdb71ef7b19 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| minu_32_9bdb71ef7b19 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MINU.asl -->
```asl
readonly func InstructionContractOperation_MINU()
    => ScalarOperation
begin
    return ScalarOperation_MINU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MINU.asl -->
```asl
readonly func InstructionContractHandler_MINU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MINU(left: Word, right: Word)
    => Word
begin
    if UInt(left) < UInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MINU()
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

- Perform an unsigned full-XLEN comparison and return the complete bit pattern of the minimum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MINU raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- minu a0, a1, ->a2
- minu t#1, u#1, ->u
- minu zero, zero, ->zero
