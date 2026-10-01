<!-- GENERATED FROM: asl/scalar/alu/SRLI.asl -->
# SRLI

**Normative ASL source:** `asl/scalar/alu/SRLI.asl`

SRLI performs an XLEN logical right shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SRLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srli-purpose role=purpose -->
## What SRLI does

`SRLI` shifts `SrcL` logically right by a constant `shamt` of `0` through `63`, inserting zeros at the left. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and the six-bit `shamt` at `[20 +: 6]`.

The carrier matches `0x00005015` under mask `0xfc00707f`, so bits `31:26` are fixed and the amount uses all six remaining bits.

A fixed amount makes the instruction a shift by a known distance, which is what a program needs to extract the field that starts at a constant bit position.

<!-- PTO-READER-BLOCK: scalar-srli-mechanism role=mechanism -->
## How the shift is formed

Dispatch calls `ExecuteDecodedShiftImmediate` with `ScalarBinary_SRL` at `asl/scalar/model/dispatch/alu.asl:192-193`. The decoded `shamt` becomes the right operand and `ScalarBinary` returns `LSR(left, UInt(right[5:0]))` (`asl/scalar/model/alu/semantics.asl:457`).

```asm
srli SrcL, shamt, ->{t, u, Rd}
```

Design point: With a constant amount, the shift never reads a count register, so an encoding of `srli a0, 8, ->a2` is a complete description of the operation with no second source. The published value depends on `a0` and the encoding only.

Design point: A `shamt` of `63` moves the source sign bit into bit `0` and clears every other bit. That is the smallest nonzero logical shift result of a `64`-bit value, and no amount can produce a wider clear because `64` is not encodable.

<!-- PTO-READER-BLOCK: scalar-srli-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the value shifted, `shamt` is decoded from the carrier, and `RegDst` receives the result.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and the read never consumes an entry.
- `shamt`, instruction slice `[20 +: 6]`: `0` through `63`; encoded zero performs an identity shift.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, so every amount publishes `0`.

Design point: The amount is fixed at assembly time and cannot be renamed, while the value is read from the Reg5 map and can come from a queue slot. The instruction therefore needs only one register operand but still takes part in the one-level source/destination model.

<!-- PTO-READER-BLOCK: scalar-srli-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the write, so an aliasing destination shifts the pre-instruction value. The result is published and `TPC` advances by `4` bytes.

`SRLI` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; the only queue movement possible is the push selected by a `30` or `31` destination.

Design point: The instruction clears the top `shamt` bits of the source and keeps the rest. Because it has no mask operand, a program that needs to keep only a middle field uses a pair of shifts rather than one masked shift.

<!-- PTO-READER-BLOCK: scalar-srli-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `64` shift amounts are assigned; the form has no constraint entry beyond the fixed bits `31:26` and `14:12`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRLI` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: Every encodable amount has a defined result and the logical shift cannot fault, so `SRLI` has no value-dependent trap path. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-srli-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `16`, `srli a0, 2, ->a2` publishes `4`.

With `a0` holding `-1`, `srli a0, 63, ->a2` publishes `1`, because the source sign bit moves into bit `0` while every other bit is cleared.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srli_32_dd29ca058cfe | L32 | 32 | 0x00005015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srli_32_dd29ca058cfe | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srli_32_dd29ca058cfe | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srli_32_dd29ca058cfe | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srli_32_dd29ca058cfe | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srli_32_dd29ca058cfe | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| srli_32_dd29ca058cfe | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractOperation_SRLI()
    => ScalarOperation
begin
    return ScalarOperation_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractHandler_SRLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SRLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SRLI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 6-bit shift amount from 0 through 63 is legal.

## State effects

- Compute the XLEN logical right shift LSR(SrcL, shamt); discard low shifted-out bits and insert zero bits at the left.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the left.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srli a0, 1, ->a0
- srli t#1, 63, ->u
- srli zero, 0, ->zero
