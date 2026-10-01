<!-- GENERATED FROM: asl/scalar/fsu/FEQS.asl -->
# FEQS

**Normative ASL source:** `asl/scalar/fsu/FEQS.asl`

FEQS performs ordered signaling equality and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FEQS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-feqs-purpose role=purpose -->
## What FEQS does

`FEQS` tests two selected floating-point carriers for equality and writes a canonical `0` or `1` to a Reg5 destination, recording the invalid-operation flag whenever a NaN participates.

The trailing `s` suffix marks the signaling comparison. The result value is computed exactly as in the quiet form; what differs is the flag the instruction reports.

<!-- PTO-READER-BLOCK: scalar-feqs-mechanism role=mechanism -->
## Ordered equality with a reported NaN

`SrcType` selects the carrier for both sides, encoded `00` for FP64 and encoded `01` for an FP32 carrier in the low word, and each source is normalised to that carrier first.

Any NaN operand makes the comparison return false. In addition, this form records `NV` when either operand is a NaN, whereas the quiet form records `NV` only for a signaling NaN. The ordered cases still come from the signed-zero-aware equality rule and the fixed word-order key.

Design point: the extra flag is the only difference from `FEQ`. Two valid encodings of the same comparison therefore exist, and a program picks the signaling one when it wants an unexpected NaN to become visible in the sticky status without a separate test.

<!-- PTO-READER-BLOCK: scalar-feqs-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left Reg5 source.
- `SrcR` supplies the right Reg5 source.
- `SrcType` selects the source carrier for both sides.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 sources read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in a source reads the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-feqs-effects role=effects -->
## Effects and ordering

The destination receives exactly `1` or `0`, normalised to the full XLEN word. Any recorded `NV` is ORed into the sticky numeric status, so it survives until software clears it, and `TPC` advances by `4` bytes.

There is no memory, reservation, or descriptor effect, and no other numeric status flag is produced by this instruction.

<!-- PTO-READER-BLOCK: scalar-feqs-constraints role=constraints -->
## Carrier legality and signaling-form behavior

`SrcType` codes `0` and `1` are assigned and codes `2` and `3` are reserved. The carrier check runs before the first architectural source read, so a reserved `SrcType`, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-feqs-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical FP64 example is `feqs.fd a0, a1, ->a2` with GPR `a0` holding `0x3ff0000000000000` and GPR `a1` holding `0x3ff0000000000000`, both standing for `1.0`: GPR `a2` receives `1` and no flag is recorded.

Setting GPR `a1` to a NaN encoding still writes `0` to the destination, and this time the instruction records `NV`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
feqs.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| feqs_32_1d3011890fa8 | L32 | 32 | 0x0800005b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| feqs_32_1d3011890fa8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| feqs_32_1d3011890fa8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| feqs_32_1d3011890fa8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| feqs_32_1d3011890fa8 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| feqs_32_1d3011890fa8 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| feqs_32_1d3011890fa8 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| feqs_32_1d3011890fa8 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| feqs_32_1d3011890fa8 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `feqs_32_1d3011890fa8.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEQS.asl -->
```asl
readonly func InstructionContractOperation_FEQS()
    => ScalarOperation
begin
    return ScalarOperation_FEQS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEQS.asl -->
```asl
readonly func InstructionContractHandler_FEQS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FEQS(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FEQS(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FEQS(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FEQS()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FEQS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FEQS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FEQS()
    => FloatingCompareOperation
begin
    return FloatingCompare_EQ;
end;

pure func InstructionContractSignalingCompare_FEQS()
    => boolean
begin
    return TRUE;
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

- FEQS performs ordered signaling equality and returns canonical XLEN zero or one.
- Any NaN returns false. This signaling form records sticky NV for any NaN.
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

- feqs.fd a0, a1, ->a2
- feqs.fs t#1, u#1, ->u
