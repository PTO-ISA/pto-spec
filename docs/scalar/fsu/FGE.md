<!-- GENERATED FROM: asl/scalar/fsu/FGE.asl -->
# FGE

**Normative ASL source:** `asl/scalar/fsu/FGE.asl`

FGE performs ordered quiet greater-than-or-equal comparison and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FGE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fge-purpose role=purpose -->
## What FGE does

`FGE` tests whether the left selected floating-point carrier is greater than or equal to the right one and writes a canonical `0` or `1` to a Reg5 destination.

It is the quiet greater-than-or-equal member of the compare group.

<!-- PTO-READER-BLOCK: scalar-fge-mechanism role=mechanism -->
## Greater-or-equal as the negation of less-than

`SrcType` selects the carrier for both sides, encoded `00` for FP64 and encoded `01` for an FP32 carrier in the low word, and both sources are normalised to that carrier before the test.

Any NaN operand makes the result false. Otherwise the model evaluates `!less`, using an ordering derived from a fixed word-order key, so `FGE` is true for equal encodings, including a positive zero compared with a negative zero.

Design point: for ordered operands `FGE` is the negation of the strict less-than order rather than a separate greater-or-equal primitive, so `FLT` and `FGE` are never both true; when either operand is a NaN the shared compare returns false for both mnemonics.

<!-- PTO-READER-BLOCK: scalar-fge-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left Reg5 source.
- `SrcR` supplies the right Reg5 source.
- `SrcType` selects the source carrier for both sides.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 sources read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in a source reads the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-fge-effects role=effects -->
## Effects and ordering

The destination receives exactly `1` or `0`, normalised to the full XLEN word, and `TPC` advances by `4` bytes. Flags, if any were recorded, are ORed into the sticky numeric status.

No memory, reservation, descriptor, or predicate state changes, and no numeric flag other than a possible `NV` is produced.

<!-- PTO-READER-BLOCK: scalar-fge-constraints role=constraints -->
## Carrier legality and quiet-form behavior

`SrcType` codes `0` and `1` are assigned and codes `2` and `3` are reserved. The carrier check runs before the first architectural source read, so a reserved `SrcType`, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-fge-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical FP64 example is `fge.fd a0, a1, ->a2` with GPR `a0` holding `0x4000000000000000`, standing for `2.0`, and GPR `a1` holding `0x3ff0000000000000`, standing for `1.0`: GPR `a2` receives `1`.

Reversing the two operand registers writes `0`, and comparing two encodings of zero, one positive and one negative, writes `1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fge.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fge_32_b3244b2ffa89 | L32 | 32 | 0x0000305b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fge_32_b3244b2ffa89 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fge_32_b3244b2ffa89 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fge_32_b3244b2ffa89 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fge_32_b3244b2ffa89 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fge_32_b3244b2ffa89 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fge_32_b3244b2ffa89 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fge_32_b3244b2ffa89 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fge_32_b3244b2ffa89 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fge_32_b3244b2ffa89.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FGE.asl -->
```asl
readonly func InstructionContractOperation_FGE()
    => ScalarOperation
begin
    return ScalarOperation_FGE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FGE.asl -->
```asl
readonly func InstructionContractHandler_FGE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FGE(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FGE(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FGE(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FGE()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FGE()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FGE()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FGE()
    => FloatingCompareOperation
begin
    return FloatingCompare_GE;
end;

pure func InstructionContractSignalingCompare_FGE()
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

- FGE performs ordered quiet greater-than-or-equal comparison and returns canonical XLEN zero or one.
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

- fge.fd a0, a1, ->a2
- fge.fs t#1, u#1, ->u
