<!-- GENERATED FROM: asl/scalar/alu/SRAIW.asl -->
# SRAIW

**Normative ASL source:** `asl/scalar/alu/SRAIW.asl`

SRAIW performs a word arithmetic right shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SRAIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sraiw-purpose role=purpose -->
## What SRAIW does

`SRAIW` shifts the low `32` bits of `SrcL` arithmetically right by a constant `shamt` of `0` through `31` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and the five-bit `shamt` at `[20 +: 5]`.

The carrier matches `0x00006035` under mask `0xfe00707f`, so bits `31:25` are fixed and the amount is five bits.

The sign that is copied is bit `31` of the word, because the shift happens at `32`-bit width before the final extension.

<!-- PTO-READER-BLOCK: scalar-sraiw-mechanism role=mechanism -->
## How the word shift is formed

Dispatch calls `ExecuteDecodedShiftImmediate` with `word_operation` true (`asl/scalar/model/dispatch/alu.asl:198-199`). `ScalarBinaryW` binds `left32` to `left[31:0]`, performs `ASR(left32, UInt(right[4:0]))`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:483`).

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

Design point: The narrowing happens before the shift, so bit `31` of the word is the sign source even when bit `63` of `SrcL` differs. A source whose low word is `0x80000000` shifts to a negative word, while the same source with a clear word bit `31` shifts to a non-negative one.

Design point: The final sign extension restores the negative value to full width. `SRAIW` with a word of `0xFFFFFFF0` and an amount of `1` publishes `0xFFFFFFFFFFFFFFF8`, not `0x00000000FFFFFFF8`.

<!-- PTO-READER-BLOCK: scalar-sraiw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` supplies the word, `shamt` is decoded from the carrier, and `RegDst` receives the sign-extended word.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `shamt`, instruction slice `[20 +: 5]`: `0` through `31`; encoded zero performs an identity word shift.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, whose word sign bit is clear, so every amount publishes `0`.

Design point: The word form reaches the same result as a full-width `SRAI` only when the shifted value is already the sign extension of its low word. For a value such as `0x00000000FFFFFFFF` the two forms disagree, because `SRAIW` treats the value as `-1` while `SRAI` treats it as a large positive number.

<!-- PTO-READER-BLOCK: scalar-sraiw-effects role=effects -->
## Effects and ordering

`SrcL` is read before the write, so an aliasing destination shifts the pre-instruction value. The sign-extended word is published and `TPC` advances by `4` bytes.

`SRAIW` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state; a `30` or `31` destination is the only case in which a temporary queue moves.

Design point: The instruction writes exactly one `PTO_XLEN` word and records nothing else. Because the word shift cannot produce a value outside the signed word range, the published upper half is always a copy of word bit `31`.

<!-- PTO-READER-BLOCK: scalar-sraiw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `32` shift amounts are assigned; the form has no constraint entry beyond the fixed bits `31:25` and `14:12`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRAIW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: Every encodable amount has a defined word result and the final extension cannot fault, so `SRAIW` has no value-dependent trap path.

<!-- PTO-READER-BLOCK: scalar-sraiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `-16`, `sraiw a0, 2, ->a2` publishes `-4`.

With `a0` holding `0x00000000FFFFFFF0` and an amount of `1`, the word is negative, so `a2` receives `0xFFFFFFFFFFFFFFF8`. With `a0` holding `0x00000000FFFFFFFF` and an amount of `0`, `a2` receives `0xFFFFFFFFFFFFFFFF`, because the final extension copies word bit `31`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | L32 | 32 | 0x00006035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sraiw_32_db04a6299504 | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| sraiw_32_db04a6299504 | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractOperation_SRAIW()
    => ScalarOperation
begin
    return ScalarOperation_SRAIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractHandler_SRAIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRAIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRAIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate.

## State effects

- Compute the 32-bit arithmetic right shift ASR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SRAIW raises no arithmetic exception; copies of SrcL[31] enter from the left and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- sraiw a0, 1, ->a0
- sraiw u#1, 31, ->t
- sraiw zero, 0, ->zero
