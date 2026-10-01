<!-- GENERATED FROM: asl/scalar/alu/SUBI.asl -->
# SUBI

**Normative ASL source:** `asl/scalar/alu/SUBI.asl`

SUBI performs unsigned-immediate XLEN subtraction with Reg5 source and destination selection.

## Normative identity {#PTO-INST-SCALAR-SUBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-subi-purpose role=purpose -->
## What SUBI does

`SUBI` subtracts a zero-extended `12`-bit immediate from `SrcL` modulo `2^PTO_XLEN` and publishes the full `PTO_XLEN` result. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `uimm12` at `[20 +: 12]`.

The carrier matches `0x00001015` under mask `0x0000707f`.

The immediate is unsigned, so the subtrahend ranges over `0` through `4095` and never becomes a negative value. This is the opposite of the `simm12` immediate used by `ORI`.

<!-- PTO-READER-BLOCK: scalar-subi-mechanism role=mechanism -->
## How the result is formed

The immediate decoder sees an unsigned `12`-bit field and returns `ZeroExtend{PTO_XLEN}(raw)`. Dispatch then calls `ScalarBinary(ScalarBinary_SUB, left, right)` at `asl/scalar/model/dispatch/alu.asl:111-113` and writes `left - right` through `RegDst`.

```asm
subi SrcL, uimm, ->{t, u, Rd}
```

Design point: An unsigned immediate means the smallest subtrahend is `0` and the largest is `4095`, with no sign extension at all. `subi a0, 4095, ->a2` subtracts exactly `4095`, while the same raw bits in `ori` would supply a negative constant.

Design point: Because the subtraction wraps, subtracting a value larger than `SrcL` produces a borrow that shows up as a large result rather than as a fault or a saturation. `subi` with `SrcL = 0` and `uimm12 = 1` publishes the all-ones word.

<!-- PTO-READER-BLOCK: scalar-subi-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the minuend, `uimm12` is decoded from the carrier, and `RegDst` receives the difference.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and the read does not consume a queue entry.
- `uimm12`, instruction slice `[20 +: 12]`: unsigned, so every value from `0` through `4095` is assigned and none of them is sign-extended.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, and encoded zero of `uimm12` supplies subtrahend `0`, which makes the instruction an identity copy of the source.

Design point: The `0..4095` range means `SUBI` can step down by at most `4095` per instruction; a larger decrement needs a register constant.

<!-- PTO-READER-BLOCK: scalar-subi-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a destination that aliases the source uses the pre-instruction value. The wrapped difference is published and `TPC` advances by `4` bytes.

`SUBI` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; a `30` or `31` destination is the only case in which a temporary queue moves.

Design point: No borrow or carry flag is recorded, so the instruction cannot report that the immediate exceeded the source. The published word is the only architectural trace of the wrap.

<!-- PTO-READER-BLOCK: scalar-subi-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `4096` immediate values are assigned, and the form has no constraint entry. The only fixed requirement is that the carrier bits selected by mask `0x0000707f` match `0x00001015`, because `uimm12` occupies all twelve instruction bits `31:20`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SUBI` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: Every immediate pattern is assigned and the subtraction is total, so `SUBI` has no operand-selected trap path. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-subi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `10`, `subi a0, 3, ->a2` publishes `7`, and `subi a0, 10, ->a2` publishes `0`.

With `a0` holding `0`, `subi a0, 4095, ->a2` publishes `0xFFFFFFFFFFFFF001`, the wrapped difference. With `uimm12` equal to `0`, `a2` receives the source unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
subi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subi_32_a0c87f5e7ac4 | L32 | 32 | 0x00001015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subi_32_a0c87f5e7ac4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subi_32_a0c87f5e7ac4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subi_32_a0c87f5e7ac4 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subi_32_a0c87f5e7ac4 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| subi_32_a0c87f5e7ac4 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| subi_32_a0c87f5e7ac4 | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBI.asl -->
```asl
readonly func InstructionContractOperation_SUBI()
    => ScalarOperation
begin
    return ScalarOperation_SUBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBI.asl -->
```asl
readonly func InstructionContractHandler_SUBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_SUBI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_SUBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_SUBI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal.

## State effects

- Zero-extend uimm12, subtract it from the snapshotted SrcL value modulo 2^PTO_XLEN, and publish the XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- SUBI raises no arithmetic exception: subtraction wraps modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subi a0, 1, ->a0
- subi u#1, 4095, ->t
- subi zero, 0, ->zero
