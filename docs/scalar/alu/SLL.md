<!-- GENERATED FROM: asl/scalar/alu/SLL.asl -->
# SLL

**Normative ASL source:** `asl/scalar/alu/SLL.asl`

SLL performs a logical left shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SLL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sll-purpose role=purpose -->
## What SLL does

`SLL` shifts `SrcL` logically left by an amount taken from the low six bits of `SrcR` and publishes the full `PTO_XLEN` result. It has exactly three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00007005` under mask `0xfe00707f`. There is no `shamt` field and no modifier field, so the shift amount is a register value rather than a constant.

Bits `5:0` of `SrcR` carry the amount; bits above them are ignored by the shift but still belong to the source operand.

<!-- PTO-READER-BLOCK: scalar-sll-mechanism role=mechanism -->
## How the shift is formed

Dispatch calls `ExecuteDecodedSimpleBinary` with `ScalarBinary_SLL` and `word_operation` false (`asl/scalar/model/dispatch/alu.asl:176-177`). `ScalarBinary` returns `LSL(left, UInt(right[5:0]))` (`asl/scalar/model/alu/semantics.asl:456`), so the amount is the low six bits of the snapshotted right source and the left operand is shifted at full width.

```asm
sll SrcL, SrcR, ->{t, u, Rd}
```

Design point: Masking the amount to six bits means every raw `SrcR` value is legal and no amount is rejected. A right source whose low six bits are `0` performs an identity shift even when its upper bits are nonzero.

Design point: Bits shifted beyond bit `PTO_XLEN-1` are dropped and zero bits enter from the right. The helper reports nothing about the dropped bits, so `SLL` cannot signal that information was lost.

<!-- PTO-READER-BLOCK: scalar-sll-inputs role=inputs-outputs -->
## Inputs and destination

Both operands use the Reg5 source map and the result leaves through the Reg5 destination map.

- `SrcL`, instruction slice `[15 +: 5]`: the value shifted; `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming.
- `SrcR`, instruction slice `[20 +: 5]`: the shift-count source, same five-bit map. Every value is legal; only bits `5:0` are used.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which supplies amount `0` and therefore an identity shift.

Design point: A `SrcR` selected from a `T` or `U` queue slot is read without consuming it, so the same count can drive several shifts. Only a `30` or `31` destination pushes a new queue entry.

<!-- PTO-READER-BLOCK: scalar-sll-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination is written, so a destination that aliases `SrcL` or `SrcR` shifts the pre-instruction values. The result is published and `TPC` advances by `4` bytes.

`SLL` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state. The only queue movement is the push selected by a `30` or `31` destination.

Design point: The shift amount comes from a register, so it can be computed at run time, but it is also renamed with the rest of `SrcR`: a `31` destination writes the shift result, not the amount, to the `T` queue.

<!-- PTO-READER-BLOCK: scalar-sll-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL`, `SrcR` and `RegDst` code is assigned, and there is no constraint entry beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SLL` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: The shift count is total: masking to six bits covers `0` through `63`, and the shift itself cannot fault. No operand value selects a trap in `SLL`.

<!-- PTO-READER-BLOCK: scalar-sll-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `1` and `a1` holding `4`, `sll a0, a1, ->a2` publishes `16`.

With `a0` holding `1` and `a1` holding `64`, the low six bits of the amount are `0`, so `a2` receives `1` unchanged; a `SrcR` of `63` publishes `0x8000000000000000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sll SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sll_32_a100b8961e21 | L32 | 32 | 0x00007005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sll_32_a100b8961e21 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sll_32_a100b8961e21 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sll_32_a100b8961e21 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sll_32_a100b8961e21 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sll_32_a100b8961e21 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sll_32_a100b8961e21 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLL.asl -->
```asl
readonly func InstructionContractOperation_SLL()
    => ScalarOperation
begin
    return ScalarOperation_SLL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLL.asl -->
```asl
readonly func InstructionContractHandler_SLL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SLL(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SLL(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SLL(right);
    let shifted = LSL(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SLL()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low six bits of the snapshotted SrcR select the shift amount 0 through 63; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low six bits contribute to the shift amount.

## State effects

- Compute the logical left shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLL raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sll a0, a1, ->a2
- sll t#1, u#1, ->u
- sll zero, zero, ->zero
