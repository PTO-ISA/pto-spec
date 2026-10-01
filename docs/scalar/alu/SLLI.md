<!-- GENERATED FROM: asl/scalar/alu/SLLI.asl -->
# SLLI

**Normative ASL source:** `asl/scalar/alu/SLLI.asl`

SLLI performs an XLEN logical left shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-slli-purpose role=purpose -->
## What SLLI does

`SLLI` shifts `SrcL` logically left by a constant `shamt` of `0` through `63` and publishes the full `PTO_XLEN` result. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and the six-bit `shamt` at `[20 +: 6]`.

The carrier matches `0x00007015` under mask `0xfc00707f`. The mask fixes bits `31:26`, the six bits directly above the shift amount, so no bit of `shamt` is reserved.

`SLLI` and `SLL` compute the same function; the difference is that the amount is part of the instruction rather than a second register.

<!-- PTO-READER-BLOCK: scalar-slli-mechanism role=mechanism -->
## How the shift is formed

Dispatch calls `ExecuteDecodedShiftImmediate` with `ScalarBinary_SLL` at `asl/scalar/model/dispatch/alu.asl:188-189`. That path reads `SrcL`, decodes the six-bit field into a word with `ScalarDecodedWord`, and calls `ScalarBinary(ScalarBinary_SLL, left, amount)`, which is `LSL(left, UInt(right[5:0]))` (`asl/scalar/model/alu/semantics.asl:456`).

```asm
slli SrcL, shamt, ->{t, u, Rd}
```

Design point: The immediate path passes the decoded `shamt` through the same six-bit mask as the register form, so a `shamt` of `64` cannot be encoded and a `shamt` of `63` is the largest shift. Every encodable amount is legal.

Design point: Bits shifted out of bit `63` are discarded and zeros enter from the right, so `SLLI` cannot preserve information that leaves the word. The published result is always a function of `SrcL` and the encoded amount alone.

<!-- PTO-READER-BLOCK: scalar-slli-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the shifted value, `shamt` is decoded from the carrier, and `RegDst` receives the result.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and the read does not consume a queue entry.
- `shamt`, instruction slice `[20 +: 6]`: every value from `0` through `63` is legal, and encoded zero performs an identity shift.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, so a zero source publishes `0` for every amount.

Design point: Because the amount is encoded, it cannot be renamed or pushed onto a queue. A program that wants to vary the amount at run time needs `SLL` and a register, while `SLLI` fixes one amount in the instruction stream.

<!-- PTO-READER-BLOCK: scalar-slli-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination is written, so an aliasing destination shifts the pre-instruction value. The result is published and `TPC` advances by `4` bytes.

`SLLI` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; the only queue movement possible is the push selected by a `30` or `31` destination.

Design point: The instruction is a pure function of one register and its own encoding, which makes it usable to build a mask of the form `1 << k` without occupying a second register for the count.

<!-- PTO-READER-BLOCK: scalar-slli-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `64` shift amounts are assigned. Beyond the fixed bits `31:26` and `14:12` the form carries no constraint.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`, which is how the reserved high bits are rejected. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SLLI` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Each check precedes the destination effect and the `TPC` advance.

Design point: An out-of-range shift amount is not an illegal instruction; it is not encodable in the first place. Fixed bits `31:26` must be zero, so the only way to express a shift by more than `63` is not available at all.

<!-- PTO-READER-BLOCK: scalar-slli-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `1`, `slli a0, 4, ->a2` publishes `16` and `slli a0, 0, ->a2` publishes `1`.

With `a0` holding `1`, `slli a0, 63, ->a2` publishes `0x8000000000000000`. With `a0` holding `0xFFFFFFFFFFFFFFFF`, `slli a0, 4, ->a2` publishes `0xFFFFFFFFFFFFFFF0`, because four one-bits leave the word at the top.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
slli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | L32 | 32 | 0x00007015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| slli_32_b43ca2454e3a | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| slli_32_b43ca2454e3a | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractOperation_SLLI()
    => ScalarOperation
begin
    return ScalarOperation_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractHandler_SLLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SLLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SLLI()
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

- Compute the XLEN logical left shift LSL(SrcL, shamt); discard bits shifted beyond bit PTO_XLEN-1 and insert zero bits at the right.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the right.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- slli a0, 1, ->a0
- slli t#1, 63, ->u
- slli zero, 0, ->zero
