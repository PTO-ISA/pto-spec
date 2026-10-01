<!-- GENERATED FROM: asl/scalar/alu/ORIW.asl -->
# ORIW

**Normative ASL source:** `asl/scalar/alu/ORIW.asl`

ORIW performs word disjunction with a signed 12-bit immediate and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-ORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-oriw-purpose role=purpose -->
## What ORIW does

`ORIW` ORs the low `32` bits of `SrcL` with the low `32` bits of a sign-extended `12`-bit immediate and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `simm12` at `[20 +: 12]`.

The carrier matches `0x00003035` under mask `0x0000707f`, and the handler is `ScalarBinaryW`. The instruction therefore discards the upper word of the source before the operation and reconstructs sign bits after it.

`ORIW` and `OR` share the destination map and the `12`-bit immediate shape of `ORI`, but only `ORIW` narrows to the low word.

<!-- PTO-READER-BLOCK: scalar-oriw-mechanism role=mechanism -->
## How the word result is formed

Dispatch calls `ExecuteDecodedImmediateBinary` with `word_operation` true at `asl/scalar/model/dispatch/alu.asl:108-110`. That path lands in `ScalarBinaryW(ScalarBinary_OR, left, right)`, which binds `left32` to `left[31:0]`, `right32` to `right[31:0]`, ORs the two `32`-bit patterns, and returns `SignExtend{PTO_XLEN}(result32)`.

```asm
oriw SrcL, simm, ->{t, u, Rd}
```

Design point: The immediate is sign-extended to `PTO_XLEN` before the width narrowing, but only its low word survives. `simm12 = -1` therefore contributes `0xFFFFFFFF` to the word OR and the published word is the all-ones word.

Design point: Bit `31` of the word result is copied into bits `63..32`. A word whose bit `31` is set publishes an upper half of ones, so `oriw` never produces a zero-extended word because of narrowing alone.

<!-- PTO-READER-BLOCK: scalar-oriw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` selects a Reg5 source; the immediate is decoded from the carrier; `RegDst` selects the Reg5 destination.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `simm12`, instruction slice `[20 +: 12]`: signed, so `-2048` through `2047`; only the low `32` bits of its sign extension participate.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, and encoded zero of `simm12` supplies `0`.

Design point: Two sources that share a low word publish the same result under `ORIW`, whatever their upper halves hold. The mnemonic is a complete description of the operation, not a preview of an `PTO_XLEN` disjunction.

<!-- PTO-READER-BLOCK: scalar-oriw-effects role=effects -->
## Effects and ordering

`SrcL` is read and the word result computed before `RegDst` is written, so an aliasing destination observes the pre-instruction value. The sign-extended word is published, and then `TPC` advances by `4` bytes.

`ORIW` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; the only queue movement possible is the push selected by a `30` or `31` destination.

Design point: `ORIW` records no numeric status. The narrowing is not reported anywhere, so the published word is the only observable trace of the instruction.

<!-- PTO-READER-BLOCK: scalar-oriw-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code, every `RegDst` code and all `4096` immediate values are assigned. Beyond the fixed encoding bits `14:12` and `6:0`, the form carries no constraint.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `ORIW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. All three checks precede the destination effect and the `TPC` advance.

Design point: Neither the `32`-bit truncation nor the final sign extension can fault, so `ORIW` has no value-dependent trap path. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-oriw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `0x00F0` and `simm12 = 15`, `oriw a0, 15, ->a2` publishes `0x00FF`.

With `a0` holding `0x00000000F0000000` and `simm12 = 15`, the low word of `a0` is `0`, so the word result is `15` and `a2` receives `15`; the nonzero upper half of `a0` never reaches the disjunction.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
oriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| oriw_32_91608caf1ba6 | L32 | 32 | 0x00003035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| oriw_32_91608caf1ba6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| oriw_32_91608caf1ba6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| oriw_32_91608caf1ba6 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| oriw_32_91608caf1ba6 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| oriw_32_91608caf1ba6 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| oriw_32_91608caf1ba6 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORIW.asl -->
```asl
readonly func InstructionContractOperation_ORIW()
    => ScalarOperation
begin
    return ScalarOperation_ORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORIW.asl -->
```asl
readonly func InstructionContractHandler_ORIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ORIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal. Only the low 32 bits of SrcL and the sign-extended immediate participate.

## State effects

- Sign-extend simm12, OR its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- ORIW raises no arithmetic exception; word disjunction and final sign extension are defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- oriw a0, -1, ->a0
- oriw u#1, 2047, ->t
- oriw zero, -2048, ->zero
