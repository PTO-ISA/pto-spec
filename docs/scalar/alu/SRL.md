<!-- GENERATED FROM: asl/scalar/alu/SRL.asl -->
# SRL

**Normative ASL source:** `asl/scalar/alu/SRL.asl`

SRL performs a logical right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SRL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srl-purpose role=purpose -->
## What SRL does

`SRL` shifts `SrcL` logically right by the amount in the low six bits of `SrcR`, inserting zero bits at the left, and publishes the full `PTO_XLEN` result. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00005005` under mask `0xfe00707f`.

The logical right shift is the value-preserving shift for unsigned patterns: no sign bit is involved, and every vacated position is filled with zero.

<!-- PTO-READER-BLOCK: scalar-srl-mechanism role=mechanism -->
## How the shift is formed

Dispatch calls `ScalarBinary(ScalarBinary_SRL, left, right)` through `ExecuteDecodedSimpleBinary` (`asl/scalar/model/dispatch/alu.asl:180-181`). The helper returns `LSR(left, UInt(right[5:0]))` (`asl/scalar/model/alu/semantics.asl:457`).

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

Design point: A logical right shift moves bit `63` of a negative value into the low positions, so `SRL` on a negative source behaves like a shift of a large unsigned number. `SRL` with `SrcL` holding `-1` and a count of `1` publishes `0x7FFFFFFFFFFFFFFF`.

Design point: The count mask keeps the shift inside the `PTO_XLEN` word. A count of `64` supplies zero and returns the source unchanged, so a program cannot use `SRL` to clear a full word.

<!-- PTO-READER-BLOCK: scalar-srl-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the shifted value, `SrcR` supplies the count, and `RegDst` receives the result.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming.
- `SrcR`, instruction slice `[20 +: 5]`: count source, same map; every value is legal and only bits `5:0` are used.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which supplies amount `0` and therefore an identity shift.

Design point: The result's upper bits can become zero, and `SRL` records no numeric status for that. A consumer that needs to know whether the source was small enough has to compare the source or the result itself.

<!-- PTO-READER-BLOCK: scalar-srl-effects role=effects -->
## Effects and ordering

Both sources are read before the destination write, so aliasing destinations observe pre-instruction values. The result is published and `TPC` advances by `4` bytes.

`SRL` reads no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged. A `30` or `31` destination is the only case in which it moves a temporary queue.

Design point: `SRL` shifts the whole `PTO_XLEN` value, not a word, and publishes it without any sign extension. A count whose low six bits are nonzero clears bit `63`, so such a result is never negative. A count whose low six bits are `0` leaves the source unchanged, so a negative source can also be published unchanged: `srl` with `SrcL` holding `-1` and a count of `1` publishes `0x7FFFFFFFFFFFFFFF`.

<!-- PTO-READER-BLOCK: scalar-srl-constraints role=constraints -->
## Legality and fault boundary

Every source code and every destination code of the Reg5 domain is assigned, and the form carries no constraint entry beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRL` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: The count field and the shift are total, so `SRL` has no operand-selected trap. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-srl-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `16` and `a1` holding `2`, `srl a0, a1, ->a2` publishes `4`.

With `a0` holding `-1` and `a1` holding `1`, `a2` receives `0x7FFFFFFFFFFFFFFF`. With `a1` holding `64`, the low six bits of the count are `0`, so `a2` receives `-1` unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | L32 | 32 | 0x00005005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srl_32_5cfca42c59f3 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| srl_32_5cfca42c59f3 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractOperation_SRL()
    => ScalarOperation
begin
    return ScalarOperation_SRL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractHandler_SRL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SRL(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SRL(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRL(right);
    let shifted = LSR(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SRL()
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

- Compute the logical right shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRL raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- srl a0, a1, ->a2
- srl t#1, u#1, ->u
- srl zero, zero, ->zero
