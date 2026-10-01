<!-- GENERATED FROM: asl/scalar/alu/SUBIW.asl -->
# SUBIW

**Normative ASL source:** `asl/scalar/alu/SUBIW.asl`

SUBIW performs unsigned-immediate word subtraction and sign-extends the result to XLEN.

## Normative identity {#PTO-INST-SCALAR-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-subiw-purpose role=purpose -->
## What SUBIW does

`SUBIW` subtracts a zero-extended `12`-bit immediate from the low `32` bits of `SrcL` modulo `2^32` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `uimm12` at `[20 +: 12]`.

The carrier matches `0x00001035` under mask `0x0000707f` and dispatches `ScalarBinaryW`.

Two independent width decisions are visible here: the subtraction happens at `32` bits, while the published value is a `PTO_XLEN` word whose upper half repeats word bit `31`.

<!-- PTO-READER-BLOCK: scalar-subiw-mechanism role=mechanism -->
## How the word result is formed

Dispatch calls `ExecuteDecodedImmediateBinary` with `word_operation` true at `asl/scalar/model/dispatch/alu.asl:114-116`. `ScalarBinaryW` binds `left32` to `left[31:0]`, computes `left32 - right32` modulo `2^32`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:477`).

```asm
subiw SrcL, uimm, ->{t, u, Rd}
```

Design point: The immediate is zero-extended to `PTO_XLEN` first, but only its low word reaches the subtraction, and the immediate is at most `4095`, so it never sets a bit above bit `11`.

Design point: A word subtraction that goes below zero produces a word with bit `31` set, and the final extension turns that into a negative published value. `subiw` with a source word of `0` and `uimm12 = 1` publishes `0xFFFFFFFFFFFFFFFF`, which is `-1`.

<!-- PTO-READER-BLOCK: scalar-subiw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` supplies the word, `uimm12` is decoded from the carrier, and `RegDst` receives the sign-extended word.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `uimm12`, instruction slice `[20 +: 12]`: unsigned, `0` through `4095`; encoded zero supplies subtrahend `0`.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, whose low word is `0`.

Design point: The upper half of `SrcL` is discarded before the subtraction, so `subiw` with `a0 = 0x0000000100000000` and `uimm12 = 1` publishes `0xFFFFFFFFFFFFFFFF`, not `0x00000000FFFFFFFF`. The word of the source is zero and the word result is `-1`.

<!-- PTO-READER-BLOCK: scalar-subiw-effects role=effects -->
## Effects and ordering

`SrcL` is read before the write, so an aliasing destination computes from the pre-instruction value. The sign-extended word is published and `TPC` advances by `4` bytes.

`SUBIW` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state; the only queue movement is the push selected by a `30` or `31` destination.

Design point: The wrap at `32` bits and the sign extension are both silent. A caller that wants the unsigned word difference reads the low `32` bits of the destination and ignores the upper half.

<!-- PTO-READER-BLOCK: scalar-subiw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `4096` immediate values are assigned, and the form has no constraint entry. The only fixed requirement is that the carrier bits selected by mask `0x0000707f` match `0x00001035`, because `uimm12` occupies all twelve instruction bits `31:20`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SUBIW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: The word subtraction and the final sign extension are total, so `SUBIW` has no operand-selected trap. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-subiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `10`, `subiw a0, 3, ->a2` publishes `7`.

With `a0` whose low word is `3` and an immediate of `7`, the word difference is `0xFFFFFFFC`, so `a2` receives `0xFFFFFFFFFFFFFFFC`, which is `-4`. With the same source, an immediate of `3` publishes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subiw_32_51019ff77d0a | L32 | 32 | 0x00001035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subiw_32_51019ff77d0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subiw_32_51019ff77d0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subiw_32_51019ff77d0a | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subiw_32_51019ff77d0a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| subiw_32_51019ff77d0a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| subiw_32_51019ff77d0a | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractOperation_SUBIW()
    => ScalarOperation
begin
    return ScalarOperation_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractHandler_SUBIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_SUBIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_SUBIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal; source bits above bit 31 do not affect the result.

## State effects

- Subtract zero-extended uimm12 from SrcL[31:0] modulo 2^32, then sign-extend the 32-bit result to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- SUBIW raises no arithmetic exception: word subtraction wraps modulo 2^32 and is sign-extended to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subiw a0, 1, ->a0
- subiw u#1, 4095, ->t
- subiw zero, 0, ->zero
