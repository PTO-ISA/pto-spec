<!-- GENERATED FROM: asl/scalar/alu/C.MOVR.asl -->
# C.MOVR

**Normative ASL source:** `asl/scalar/alu/C.MOVR.asl`

C.MOVR snapshots a Reg5 source and publishes the complete XLEN value unchanged through RegDst.

## Normative identity {#PTO-INST-SCALAR-C-MOVR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-movr-purpose role=purpose -->
## What C.MOVR does

`C.MOVR` reads one Reg5 source and publishes the complete XLEN value unchanged through the Reg5 destination.

Design point: the source field accepts `T#1..T#4`, so `c.movr t#1, ->a0` is the compressed way to move a pushed temporary result into a GPR. The compressed arithmetic forms all push to `T` and cannot write a register themselves, so this instruction is what closes that gap.

<!-- PTO-READER-BLOCK: scalar-c-movr-mechanism role=mechanism -->
## How the result is formed

The source code is resolved and its value is published with no transformation: no extension, no truncation and no arithmetic. Bits `63..0` of the destination, when there is one, become exactly the bits that were read.

Design point: the move is a pure copy rather than a conversion. A program that wants a 32-bit normalization must ask for it, for example with `c.sext.w` or `addiw`.

<!-- PTO-READER-BLOCK: scalar-c-movr-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- `RegDst` publishes the value: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so `c.movr zero, ->a0` is a compressed constant-zero materialization. Encoded zero of `RegDst` discards the value rather than writing the zero GPR, even though the source is still read and checked.

Design point: `c.movr t#1, ->t` is legal. It reads the old `T#1`, pushes a copy as the new `T#1`, and shifts the original to `T#2`, which is a way to duplicate a temporary value.

<!-- PTO-READER-BLOCK: scalar-c-movr-effects role=effects -->
## Effects and ordering

The source is read before the destination is written, so a destination that aliases the source still publishes the pre-instruction value. Nothing else changes.

After publication or discard, `TPC` advances by `2` bytes. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no queue moves except the single `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-c-movr-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code and every `RegDst` code is assigned, so `C.MOVR` has no reserved operand value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: a copy has no arithmetic to fault on, so the whole value-dependent boundary of `C.MOVR` is source availability. Reading an uninitialized temporary is therefore a defined trap rather than a silent copy of stale data.

<!-- PTO-READER-BLOCK: scalar-c-movr-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `5`, `c.movr t#1, ->a0` writes `5` into `a0` and leaves `T#1` equal to `5`. `c.movr zero, ->a1` writes `0` into `a1` without reading any GPR value that could change the result.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.movr SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_movr_16_80d2b5f3580b | C16 | 16 | 0x0006 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_movr_16_80d2b5f3580b | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| c_movr_16_80d2b5f3580b | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_movr_16_80d2b5f3580b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| c_movr_16_80d2b5f3580b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.MOVR.asl -->
```asl
readonly func InstructionContractOperation_C_MOVR() => ScalarOperation
begin
    return ScalarOperation_C_MOVR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.MOVR.asl -->
```asl
readonly func InstructionContractHandler_C_MOVR() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVR(value: Word)
    => Word
begin
    return MoveScalarValue(value);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Return the complete snapshotted SrcL value without conversion.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.movr srcl, ->{t, u, rd}
