<!-- GENERATED FROM: asl/scalar/alu/SRLIW.asl -->
# SRLIW

**Normative ASL source:** `asl/scalar/alu/SRLIW.asl`

SRLIW performs a word logical right shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SRLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srliw-purpose role=purpose -->
## What SRLIW does

`SRLIW` shifts the low `32` bits of `SrcL` logically right by a constant `shamt` of `0` through `31` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and the five-bit `shamt` at `[20 +: 5]`.

The carrier matches `0x00005035` under mask `0xfe00707f`.

Zero bits enter at word bit `31`, and the final sign extension then decides the upper half from the new word bit `31`.

<!-- PTO-READER-BLOCK: scalar-srliw-mechanism role=mechanism -->
## How the word shift is formed

Dispatch calls `ExecuteDecodedShiftImmediate` with `word_operation` true (`asl/scalar/model/dispatch/alu.asl:194-195`). `ScalarBinaryW` binds `left32` to `left[31:0]`, performs `LSR(left32, UInt(right[4:0]))`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:482`).

```asm
srliw SrcL, shamt, ->{t, u, Rd}
```

Design point: Because the shift is logical but the publication is a sign extension, the same instruction can produce a negative-looking result. Shifting the word `0x80000000` right by `31` yields the word `1`, which publishes as `1`, while shifting the same word right by `1` yields `0x40000000`, which publishes as the positive word `0x0000000040000000`.

Design point: A logical shift by a nonzero amount always enters a zero at word bit `31`, so the all-ones upper half can only come from an amount whose low five bits are `0`, which leaves the word unchanged. `SRLIW` with a word of `0xFFFFFFFF` and an amount of `0` therefore publishes `0xFFFFFFFFFFFFFFFF`, while an amount of `1` gives the word `0x7FFFFFFF` and publishes `0x000000007FFFFFFF`.

<!-- PTO-READER-BLOCK: scalar-srliw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` supplies the word, `shamt` is decoded from the carrier, and `RegDst` receives the sign-extended word.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `shamt`, instruction slice `[20 +: 5]`: `0` through `31`; encoded zero performs an identity word shift.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, so every amount publishes `0`.

Design point: The upper half of the source cannot enter the result. Only the low word is shifted, so `srliw` with `a0 = 0xFFFFFFFF00000000` and an amount of `16` publishes `0`, because the word of the source is zero.

<!-- PTO-READER-BLOCK: scalar-srliw-effects role=effects -->
## Effects and ordering

`SrcL` is read before the write, so an aliasing destination shifts the pre-instruction value. The sign-extended word is published and `TPC` advances by `4` bytes.

`SRLIW` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state; a `30` or `31` destination is the only case in which a temporary queue moves.

Design point: Because the narrowing precedes the shift, the published value is fully determined by the word of the source and the constant amount. No upper-half bit of `SrcL` can change it.

<!-- PTO-READER-BLOCK: scalar-srliw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `32` shift amounts are assigned; the form has no constraint entry beyond the fixed bits `31:25` and `14:12`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRLIW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: The word shift and the final extension are total, so `SRLIW` has no operand-selected trap. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-srliw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `16`, `srliw a0, 2, ->a2` publishes `4`.

With `a0` holding `0x0000000080000000` and an amount of `1`, the word result is `0x40000000` and `a2` receives `0x0000000040000000`, a positive word. With an amount of `31`, the word result is `1` and `a2` receives `1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srliw_32_ef4aa650f46e | L32 | 32 | 0x00005035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srliw_32_ef4aa650f46e | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srliw_32_ef4aa650f46e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srliw_32_ef4aa650f46e | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srliw_32_ef4aa650f46e | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srliw_32_ef4aa650f46e | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| srliw_32_ef4aa650f46e | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractOperation_SRLIW()
    => ScalarOperation
begin
    return ScalarOperation_SRLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractHandler_SRLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRLIW()
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

- Compute the 32-bit logical right shift LSR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SRLIW raises no arithmetic exception; zero bits enter from the left and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srliw a0, 1, ->a0
- srliw u#1, 31, ->t
- srliw zero, 0, ->zero
