<!-- GENERATED FROM: asl/scalar/alu/ORI.asl -->
# ORI

**Normative ASL source:** `asl/scalar/alu/ORI.asl`

ORI performs XLEN disjunction with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ori-purpose role=purpose -->
## What ORI does

`ORI` ORs `SrcL` with a sign-extended `12`-bit immediate and publishes the full `PTO_XLEN` result. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `simm12` at `[20 +: 12]`.

The carrier matches `0x00003015` under mask `0x0000707f`. Because the immediate is part of the encoding, the instruction carries no right-source register and no `shamt` field: `ORI` cannot shift or transform its right operand.

`simm12` is signed, so the constant that reaches the disjunction ranges over `-2048` through `2047` after sign extension to `PTO_XLEN`.

<!-- PTO-READER-BLOCK: scalar-ori-mechanism role=mechanism -->
## How the result is formed

The immediate decoder reads `simm12` and, because its signedness is `signed` and its width is `12`, returns `SignExtend{PTO_XLEN}(raw[11:0])`. Dispatch then calls `ScalarBinary(ScalarBinary_OR, left, right)` at `asl/scalar/model/dispatch/alu.asl:105-107` and writes the `64`-bit disjunction through `RegDst`.

```asm
ori SrcL, simm, ->{t, u, Rd}
```

Design point: Sign extension of a `12`-bit immediate is what makes `ori` usable as a negative-constant mask builder: `-1` is encoded as `0xFFF` and reaches the OR as `0xFFFFFFFFFFFFFFFF`, so `ori a0, -1, ->a2` publishes the all-ones word.

Design point: No shift stage exists here, so the only way to place an immediate pattern in the upper bits is to encode a negative value. A program that wants bit `63` set uses `simm12 = -1`, not a shift.

<!-- PTO-READER-BLOCK: scalar-ori-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` uses the Reg5 source map and `RegDst` the Reg5 destination map. The immediate is decoded from the instruction rather than selected from a register.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and the read never consumes a queue entry.
- `simm12`, instruction slice `[20 +: 12]`: every value from `-2048` through `2047` is assigned and is sign-extended to `PTO_XLEN` before the disjunction.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, and an encoded zero immediate supplies the numeric value `0`.

Design point: Encoded zero of `simm12` is a value, not an omission marker: it supplies `0`, and `ori a0, 0, ->a2` is a legal way to copy the low `PTO_XLEN` bits of `a0` into `a2` through the OR identity.

<!-- PTO-READER-BLOCK: scalar-ori-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination is written, so a destination that aliases the source uses the pre-instruction value. The result is then published, and `TPC` advances by `4` bytes.

`ORI` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege or control-flow state; a `30` or `31` destination is the only case in which it moves a temporary queue.

Design point: The immediate has no register, so it cannot be renamed or queued. The published value is always a function of one snapshotted GPR or queue slot and the encoding itself, which makes `ORI` usable to materialise a constant mask without a second source register.

<!-- PTO-READER-BLOCK: scalar-ori-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `4096` immediate values are assigned, and the form has no constraint entry. The only fixed requirement is that the carrier bits selected by mask `0x0000707f` match `0x00003015`, because `simm12` occupies all twelve instruction bits `31:20`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, which for `ORI` requires a pending system-block terminal request; an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Every check precedes the destination effect and the `TPC` advance.

Design point: The immediate cannot be out of range. `simm12` is a full `12`-bit field with every pattern assigned, so there is no reserved immediate encoding and no operand value that selects a trap.

<!-- PTO-READER-BLOCK: scalar-ori-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `0x00F0`, `ori a0, 15, ->a2` publishes `0x00FF`, because `15` sign-extends to the same value.

With `a0` holding `0` and `simm12` encoded as `-2048`, the sign-extended immediate is `0xFFFFFFFFFFFFF800`, so `a2` receives `0xFFFFFFFFFFFFF800`. Encoding `simm12` as `-1` publishes the all-ones word instead.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ori_32_413a6cc76e9a | L32 | 32 | 0x00003015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ori_32_413a6cc76e9a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ori_32_413a6cc76e9a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ori_32_413a6cc76e9a | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ori_32_413a6cc76e9a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| ori_32_413a6cc76e9a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| ori_32_413a6cc76e9a | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORI.asl -->
```asl
readonly func InstructionContractOperation_ORI()
    => ScalarOperation
begin
    return ScalarOperation_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORI.asl -->
```asl
readonly func InstructionContractHandler_ORI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ORI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the disjunction.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise disjunction with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ORI raises no arithmetic exception; bitwise disjunction is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- ori a0, -1, ->a0
- ori t#1, 2047, ->u
- ori zero, -2048, ->zero
