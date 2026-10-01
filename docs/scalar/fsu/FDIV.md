<!-- GENERATED FROM: asl/scalar/fsu/FDIV.asl -->
# FDIV

**Normative ASL source:** `asl/scalar/fsu/FDIV.asl`

FDIV divides the left selected carrier by the right through the active numeric profile and publishes its sticky flags.

## Normative identity {#PTO-INST-SCALAR-FDIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fdiv-purpose role=purpose -->
## What FDIV does

`FDIV` divides the left selected floating-point carrier by the right one and publishes the rounded quotient to a Reg5 destination.

It is the division member of the binary `FSU` forms, so it shares the operand shape and the destination rules of `FADD`, `FMUL`, `FMIN`, and `FMAX`.

<!-- PTO-READER-BLOCK: scalar-fdiv-mechanism role=mechanism -->
## How the quotient is produced

`SrcType` selects the carrier for both sides: encoded `00` selects FP64 and encoded `01` selects an FP32 carrier in the low word. The two sources are normalised first, then the binary division runs with the active rounding mode read from `core_state[39:37]`.

Division by zero is a defined result, not a trap. A finite nonzero dividend over a zero divisor produces an infinity whose sign is the exclusive-or of the operand signs, and the model reports `DZ` for that case. Zero divided by zero and infinity divided by infinity produce a quiet NaN and report `NV`.

Design point: because the result of a zero divisor is an infinity rather than a trap, a program can test the quotient for infinity after the fact; the `DZ` flag tells it that the infinity came from a zero divisor rather than from an overflowed finite division.

<!-- PTO-READER-BLOCK: scalar-fdiv-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the dividend as the left Reg5 source.
- `SrcR` supplies the divisor as the right Reg5 source.
- `SrcType` selects the source carrier for both sides.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 source codes read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in a source reads the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-fdiv-effects role=effects -->
## Effects and ordering

The quotient is normalised to the selected carrier width and written once, the produced flags are ORed into the sticky numeric status, and `TPC` advances by `4` bytes. No memory, reservation, or descriptor state changes.

An infinity operand over a finite nonzero divisor yields an infinity with the exclusive-or sign, and a finite value over an infinity yields a signed zero. Both cases report no flag, because the input was already infinite and no new exception condition was created.

<!-- PTO-READER-BLOCK: scalar-fdiv-constraints role=constraints -->
## Carrier legality and flag reporting

`SrcType` codes `0` and `1` are assigned and codes `2` and `3` are reserved. The carrier check runs before the first architectural source read, so a reserved `SrcType`, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-fdiv-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical FP64 example is `fdiv.fd a0, a1, ->a2` with GPR `a0` holding `0x3ff0000000000000`, standing for `1.0`, and GPR `a1` holding `0x4000000000000000`, standing for `2.0`: GPR `a2` receives `0x3fe0000000000000`, standing for `0.5`, and no numeric flag is reported, because the quotient `0.5` is exact in FP64.

Dividing `1.0` by `0.0` instead produces an infinity and sets `DZ`; the quotient `1.0 / 3.0` is not exact and reports `NX`. The destination is written in every case.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fdiv.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fdiv_32_04a5bb6ab56f | L32 | 32 | 0x0000304b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fdiv_32_04a5bb6ab56f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fdiv_32_04a5bb6ab56f | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fdiv_32_04a5bb6ab56f | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fdiv_32_04a5bb6ab56f | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fdiv_32_04a5bb6ab56f | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fdiv_32_04a5bb6ab56f.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractOperation_FDIV()
    => ScalarOperation
begin
    return ScalarOperation_FDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractHandler_FDIV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FDIV(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FDIV(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FDIV(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FDIV()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FDIV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FDIV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FDIV()
    => FloatingBinaryOperation
begin
    return FloatingBinary_DIV;
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

- FDIV divides the left selected carrier by the right through the active numeric profile and publishes its sticky flags.
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

- fdiv.fd a0, a1, ->a2
- fdiv.fs t#1, u#1, ->u
