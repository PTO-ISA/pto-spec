<!-- GENERATED FROM: asl/scalar/fsu/FADD.asl -->
# FADD

**Normative ASL source:** `asl/scalar/fsu/FADD.asl`

FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.

## Normative identity {#PTO-INST-SCALAR-FADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fadd-purpose role=purpose -->
## What FADD does

`FADD` adds two selected floating-point carriers and publishes the rounded sum to a Reg5 destination.

The addition is performed by the active numeric profile, so the sum is the profile's rounded result rather than an unbounded real value.

<!-- PTO-READER-BLOCK: scalar-fadd-mechanism role=mechanism -->
## How the sum is produced

`SrcType` selects the carrier: encoded `00` selects FP64 and encoded `01` selects an FP32 carrier in the low word of each source. Both sources are normalised to that carrier before anything else happens, then the model computes the binary addition with the active rounding mode, which it reads from `core_state[39:37]`.

The special-value rules decide the result before any finite arithmetic runs. If either input is a NaN the result is a quiet NaN. If both inputs are infinities of opposite sign the result is a quiet NaN. If exactly one input is an infinity the result is that infinity with its sign. Two finite inputs whose exact sum is beyond the destination format also produce an infinity, and that overflow records `OF` and `NX`.

Design point: a NaN input produces a NaN result, never an infinity and never a finite number, so a NaN detected here stays visible at the destination instead of being absorbed silently.

<!-- PTO-READER-BLOCK: scalar-fadd-inputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left Reg5 source.
- `SrcR` supplies the right Reg5 source.
- `SrcType` selects the source carrier for both sides; one width applies to the whole operation.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 source codes read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in a source reads the architectural zero GPR, and encoded zero in `RegDst` discards.

<!-- PTO-READER-BLOCK: scalar-fadd-effects role=effects -->
## Effects and ordering

The result is normalised to the selected carrier width and written once, the produced flags are ORed into the sticky numeric status, and `TPC` then advances by `4` bytes. There is no memory, reservation, or descriptor effect.

The profile returns an exact `NV`, `DZ`, `OF`, `UF`, `NX` vector. The model ORs that vector into the existing sticky status, so a flag set by an earlier instruction survives an `FADD` that reports no flag of its own.

<!-- PTO-READER-BLOCK: scalar-fadd-constraints role=constraints -->
## Carrier legality and sticky-flag behavior

`SrcType` codes `0` and `1` are assigned and codes `2` and `3` are reserved. The carrier check runs before the first architectural source read, so a reserved `SrcType`, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned, so no destination encoding is illegal. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-fadd-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical FP64 example is `fadd.fd a0, a1, ->a2` with GPR `a0` holding `0x3ff0000000000000`, standing for `1.0`, and GPR `a1` holding `0x3ff0000000000000`: GPR `a2` receives `0x4000000000000000`, standing for `2.0`.

Because both operands select one carrier width, an `FADD` on two FP32 values in `T` and `U` queues uses the same instruction with the FP32 encoding of `SrcType`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fadd.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fadd_32_b78b658e6740 | L32 | 32 | 0x0000004b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fadd_32_b78b658e6740 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fadd_32_b78b658e6740 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fadd_32_b78b658e6740 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fadd_32_b78b658e6740 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fadd_32_b78b658e6740 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fadd_32_b78b658e6740 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fadd_32_b78b658e6740 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fadd_32_b78b658e6740 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fadd_32_b78b658e6740.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FADD.asl -->
```asl
readonly func InstructionContractOperation_FADD()
    => ScalarOperation
begin
    return ScalarOperation_FADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FADD.asl -->
```asl
readonly func InstructionContractHandler_FADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FADD(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FADD(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FADD(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FADD()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FADD()
    => FloatingBinaryOperation
begin
    return FloatingBinary_ADD;
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

- FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.
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

- fadd.fd a0, a1, ->a2
- fadd.fs t#1, u#1, ->u
