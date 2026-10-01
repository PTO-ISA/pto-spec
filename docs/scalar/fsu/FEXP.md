<!-- GENERATED FROM: asl/scalar/fsu/FEXP.asl -->
# FEXP

**Normative ASL source:** `asl/scalar/fsu/FEXP.asl`

FEXP applies the active numeric profile exponential operation to the selected FP64 or FP32 carrier.

## Normative identity {#PTO-INST-SCALAR-FEXP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fexp-purpose role=purpose -->
## What FEXP does

`FEXP` applies the exponential operation to the selected floating-point carrier and writes the rounded result to a Reg5 destination.

It is a unary arithmetic form, so it reads one source, consults the numeric profile, and can raise the same exception flags that the profile reports for the other floating operations.

<!-- PTO-READER-BLOCK: scalar-fexp-mechanism role=mechanism -->
## How the exponential is computed

`SrcType` selects the carrier, encoded `00` for FP64 and encoded `01` for an FP32 carrier in the low word, and the source is normalised to that carrier before the operation runs.

The operation is evaluated through the profile with the active rounding mode from `core_state[39:37]`. The special-value rules decide three cases before any finite evaluation: a NaN input produces a quiet NaN and records `NV` only if the input was signaling, an input of positive infinity produces positive infinity with no flag, and an input of negative infinity produces a positive zero with no flag.

Design point: the mnemonic names the operation, not an algorithm. The portable model evaluates the exponential through its reference profile, so an implementation is bound to the published result and flags rather than to any particular evaluation order.

<!-- PTO-READER-BLOCK: scalar-fexp-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the sole Reg5 source.
- `SrcType` selects the source carrier.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 source codes read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in `SrcL` reads the architectural zero GPR, and encoded zero in `RegDst` discards.

<!-- PTO-READER-BLOCK: scalar-fexp-effects role=effects -->
## Effects and ordering

The result is normalised to the selected carrier width and written once, the flags the profile returns are ORed into the sticky numeric status, and `TPC` advances by `4` bytes. There is no memory, reservation, or descriptor effect.

Because the flags are ORed rather than assigned, a flag recorded by an earlier operation is still visible after an `FEXP` that reports nothing.

<!-- PTO-READER-BLOCK: scalar-fexp-constraints role=constraints -->
## Carrier legality and flag reporting

`SrcType` codes `0` and `1` are assigned and codes `2` and `3` are reserved. The carrier check runs before the first architectural source read, so a reserved `SrcType`, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-fexp-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical FP64 example is `fexp.fd a0, ->a1`: GPR `a0` holds `0x0000000000000000`, standing for `0.0`, and GPR `a1` receives `0x3ff0000000000000`, standing for `1.0`, with no flag recorded.

The companion example `fexp.fs t#1, ->t` applies the same operation to the FP32 carrier in the low word of the `T#1` entry and pushes the result to the `T` queue.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fexp.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fexp_32_592ef5288c7d | L32 | 32 | 0x0000307b / 0xf9f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fexp_32_592ef5288c7d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fexp_32_592ef5288c7d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fexp_32_592ef5288c7d | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fexp_32_592ef5288c7d | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fexp_32_592ef5288c7d | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fexp_32_592ef5288c7d | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fexp_32_592ef5288c7d.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEXP.asl -->
```asl
readonly func InstructionContractOperation_FEXP()
    => ScalarOperation
begin
    return ScalarOperation_FEXP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEXP.asl -->
```asl
readonly func InstructionContractHandler_FEXP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FEXP(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FEXP(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FEXP(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FEXP()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FEXP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FEXP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUnaryOperation_FEXP()
    => FloatingUnaryOperation
begin
    return FloatingUnary_EXP;
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

- FEXP applies the active numeric profile exponential operation to the selected FP64 or FP32 carrier.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- For pto-v0 finite FP32 and FP64 carriers, execute the declared operation through the reference finite floating profile using the selected rounding mode and publish the returned NV, DZ, OF, UF, and NX flags.
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

- fexp.fd a0, ->a1
- fexp.fs t#1, ->t
