<!-- GENERATED FROM: asl/scalar/fsu/FSQRT.asl -->
# FSQRT

**Normative ASL source:** `asl/scalar/fsu/FSQRT.asl`

FSQRT applies the active numeric profile square-root operation to the selected FP64 or FP32 carrier.

## Normative identity {#PTO-INST-SCALAR-FSQRT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fsqrt-purpose role=purpose -->
## What FSQRT does

`FSQRT` computes the square root of one floating-point scalar and publishes the result carrier. It takes a single source and produces a single destination. It applies one named operation from the numeric profile; it is not a bit-manipulation instruction, so it does not preserve the source encoding.

<!-- PTO-READER-BLOCK: scalar-fsqrt-mechanism role=mechanism -->
## How the operation is performed

`SrcType=00` selects a complete 64-bit FP64 carrier. `SrcType=01` selects FP32 and uses only the low 32 bits of the source word, zero-extended to XLEN.

The contract names `FloatingUnary_SQRT`, which the profile evaluates through a rounded square-root reference: the model normalizes the input to a significand times an even power of two, builds that significand's root bit by bit to `100` fractional bits with a final round-to-odd step, and scales the result back.

The selected numeric profile returns both the result and an exact `NV`, `DZ`, `OF`, `UF`, `NX` vector. In the `pto-v0` reference profile the operation is evaluated on real values and encoded once with the rounding mode encoded in `CORE_STATE[39:37]`.

A zero input publishes a signed zero with the sign of the input and records no flag. A positive infinity input publishes positive infinity and records no flag. A negative input publishes the canonical quiet NaN for the carrier and records `NV`. A NaN input also publishes the canonical quiet NaN, and records `NV` only when the input was a signaling NaN.

Design point: every special input is answered by an explicit architecture rule before the finite kernel is entered. That is why a negative input still retires normally with a sticky `NV` instead of raising a trap.

<!-- PTO-READER-BLOCK: scalar-fsqrt-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the destination selector: codes `1`..`23` write a GPR, `30` pushes `U`, `31` pushes `T`, and `0` plus `24`..`29` discard the result.
- `SrcL` is the source selector. There is no second source field.
- `SrcType` selects the carrier that the source is read with.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and destination selector `0` writes nothing.

<!-- PTO-READER-BLOCK: scalar-fsqrt-effects role=effects -->
## Effects and ordering

The single source is read before any write, so `SrcL` and `RegDst` may name the same register or queue slot and the operation still uses the pre-instruction value. A push into `T` or `U` happens only after the read, so a read-then-push of the same queue observes the entry that was already present.

All five returned flag bits are ORed into `CORE_STATE[36:32]`, so the operation can set a sticky flag but never clear one. The destination is written or discarded, and only then does `TPC` advance by `4` bytes. No memory access and no reservation is involved.

<!-- PTO-READER-BLOCK: scalar-fsqrt-constraints role=constraints -->
## Reserved types and rejection

`SrcType=10` and `SrcType=11` are reserved. The handler checks the carrier type before the first read of the source register, so a reserved type raises `Fault_IllegalInstruction` with no source read, no profile call, no flag, no queue change, no destination write, and no `TPC` advance.

A source selector that names an unavailable `T` or `U` slot is rejected the same way, at the same point.

The active rounding mode comes from `CORE_STATE[39:37]`; there is no per-instruction rounding field. A recorded flag never raises a synchronous PTO trap by itself.

<!-- PTO-READER-BLOCK: scalar-fsqrt-example role=example -->
## Non-normative example

`fsqrt.fs a0, ->a1` reads the low 32 bits of `a0` as an FP32 carrier, computes its square root, records the returned flags, and writes the result to `a1`.

With `a0` holding FP32 `-4.0`, the instruction writes the FP32 canonical quiet NaN to `a1` and sets sticky `NV` in `CORE_STATE[32]`. No memory traffic is generated and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fsqrt.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fsqrt_32_84b3495cc6c7 | L32 | 32 | 0x0000107b / 0xf9f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fsqrt_32_84b3495cc6c7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fsqrt_32_84b3495cc6c7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fsqrt_32_84b3495cc6c7 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fsqrt_32_84b3495cc6c7 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fsqrt_32_84b3495cc6c7 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fsqrt_32_84b3495cc6c7 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fsqrt_32_84b3495cc6c7.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FSQRT.asl -->
```asl
readonly func InstructionContractOperation_FSQRT()
    => ScalarOperation
begin
    return ScalarOperation_FSQRT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FSQRT.asl -->
```asl
readonly func InstructionContractHandler_FSQRT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FSQRT(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FSQRT(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FSQRT(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FSQRT()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FSQRT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FSQRT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUnaryOperation_FSQRT()
    => FloatingUnaryOperation
begin
    return FloatingUnary_SQRT;
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

- FSQRT applies the active numeric profile square-root operation to the selected FP64 or FP32 carrier.
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

- fsqrt.fd a0, ->a1
- fsqrt.fs t#1, ->t
