<!-- GENERATED FROM: asl/scalar/fsu/FLT.asl -->
# FLT

**Normative ASL source:** `asl/scalar/fsu/FLT.asl`

FLT performs ordered quiet less-than comparison and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FLT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-flt-purpose role=purpose -->
## What FLT does

`FLT` tests whether the left selected floating-point carrier is less than the right one and writes a canonical `0` or `1` to a Reg5 destination.

It is the quiet strict less-than member of the compare group, so equality of the two encodings produces false rather than true.

<!-- PTO-READER-BLOCK: scalar-flt-mechanism role=mechanism -->
## Strict less-than over the shared order key

`SrcType` selects the carrier for both sides, encoded `00` for FP64 and encoded `01` for an FP32 carrier in the low word, and each source is normalised to that carrier before the test.

Any NaN operand makes the result false. Otherwise the model evaluates the strict order key that the group shares. A positive zero and a negative zero compare as neither less nor greater, so `FLT` writes `0` for that pair even though the two encodings differ bit for bit.

Design point: the comparison is decided by a word-order key derived from the two encodings, not by subtracting them, so no rounding, cancellation, or overflow can affect the answer: `-1.0 < 1.0` and `1.0 < 2.0` are both true, and a value compared with itself is never less.

<!-- PTO-READER-BLOCK: scalar-flt-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left Reg5 source.
- `SrcR` supplies the right Reg5 source.
- `SrcType` selects the source carrier for both sides.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 sources read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in a source reads the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-flt-effects role=effects -->
## Effects and ordering

The destination receives exactly `1` or `0`, normalised to the full XLEN word, and `TPC` advances by `4` bytes. Flags, if any were recorded, are ORed into the sticky numeric status.

There is no memory, reservation, descriptor, or predicate effect, and the instruction records no numeric flag other than a possible `NV` from a signaling NaN input.

<!-- PTO-READER-BLOCK: scalar-flt-constraints role=constraints -->
## Carrier legality and quiet-form behavior

`SrcType` codes `0` and `1` are assigned and codes `2` and `3` are reserved. The carrier check runs before the first architectural source read, so a reserved `SrcType`, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-flt-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical FP64 example is `flt.fd a0, a1, ->a2` with GPR `a0` holding `0x3ff0000000000000`, standing for `1.0`, and GPR `a1` holding `0x4000000000000000`, standing for `2.0`: GPR `a2` receives `1`.

Comparing that `1.0` against itself writes `0`, and so does comparing a positive zero against a negative zero.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
flt.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| flt_32_1c09549d8d3f | L32 | 32 | 0x0000205b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| flt_32_1c09549d8d3f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| flt_32_1c09549d8d3f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| flt_32_1c09549d8d3f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| flt_32_1c09549d8d3f | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| flt_32_1c09549d8d3f | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| flt_32_1c09549d8d3f | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| flt_32_1c09549d8d3f | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| flt_32_1c09549d8d3f | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `flt_32_1c09549d8d3f.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FLT.asl -->
```asl
readonly func InstructionContractOperation_FLT()
    => ScalarOperation
begin
    return ScalarOperation_FLT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FLT.asl -->
```asl
readonly func InstructionContractHandler_FLT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FLT(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FLT(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FLT(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FLT()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FLT()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FLT()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FLT()
    => FloatingCompareOperation
begin
    return FloatingCompare_LT;
end;

pure func InstructionContractSignalingCompare_FLT()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.

## State effects

- FLT performs ordered quiet less-than comparison and returns canonical XLEN zero or one.
- Any NaN returns false. This quiet form records sticky NV only for a signaling NaN.
- Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.
- Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Validate every encoded type before the first architectural source read or profile call.
- Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.
- Accumulate produced flags, publish or discard the destination, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.
- Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap.

## Examples

- flt.fd a0, a1, ->a2
- flt.fs t#1, u#1, ->u
