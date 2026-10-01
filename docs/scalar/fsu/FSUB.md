<!-- GENERATED FROM: asl/scalar/fsu/FSUB.asl -->
# FSUB

**Normative ASL source:** `asl/scalar/fsu/FSUB.asl`

FSUB subtracts the right selected carrier from the left through the active numeric profile and publishes its sticky flags.

## Normative identity {#PTO-INST-SCALAR-FSUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fsub-purpose role=purpose -->
## What FSUB does

`FSUB` subtracts the right floating-point scalar from the left one and publishes the difference. The result is a floating-point carrier in a Reg5 destination, so it can feed another scalar floating-point operation or be pushed onto the `T` or `U` queue for a later consumer.

<!-- PTO-READER-BLOCK: scalar-fsub-mechanism role=mechanism -->
## How the arithmetic is performed

`SrcType=00` selects a complete 64-bit FP64 carrier. `SrcType=01` selects FP32: only the low 32 bits of each source word are used and zero-extended to XLEN.

The contract names `FloatingBinary_SUB`, so `left - right` is the declared arithmetic operation, with `SrcL` as the minuend.

The selected numeric profile returns both the result and an exact `NV`, `DZ`, `OF`, `UF`, `NX` vector. For the `pto-v0` reference profile, finite FP32 and FP64 carriers are converted to real values, subtracted with real arithmetic, and encoded once with the requested rounding mode. Rounding happens at the end, so the single published carrier is the only rounding step of the operation.

Design point: the profile returns flags instead of trapping, and the instruction ORs them into sticky state. That is why an overflowed result is still published normally as an infinity while `OF` becomes visible afterwards in `CORE_STATE[34]`.

<!-- PTO-READER-BLOCK: scalar-fsub-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the destination selector: codes `1`..`23` write a GPR, `30` pushes `U`, `31` pushes `T`, and `0` plus `24`..`29` discard the result.
- `SrcL` is the left source selector.
- `SrcR` is the right source selector.
- `SrcType` selects the carrier that both sources are read with.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and destination selector `0` writes nothing.

<!-- PTO-READER-BLOCK: scalar-fsub-effects role=effects -->
## Effects and ordering

Both sources are read before any write, so `SrcL`, `SrcR` and `RegDst` may name the same register or queue slot and the operation still uses the pre-instruction values. A push into `T` or `U` happens only after both reads, so a read-then-push of the same queue observes the entry that was already present.

All five returned flag bits are ORed into `CORE_STATE[36:32]`, so the operation can set a sticky flag but never clear one. The destination is written or discarded, and only then does `TPC` advance by `4` bytes. No memory access and no reservation is involved.

<!-- PTO-READER-BLOCK: scalar-fsub-constraints role=constraints -->
## Reserved types and rejection

`SrcType=10` and `SrcType=11` are reserved. The handler checks the carrier type before the first read of either source register, so a reserved type raises `Fault_IllegalInstruction` with no source read, no profile call, no flag, no queue change, no destination write, and no `TPC` advance.

A source selector that names an unavailable `T` or `U` slot is rejected the same way, at the same point.

The active rounding mode is taken from `CORE_STATE[39:37]`; the instruction has no per-instruction rounding field. Reserved numeric flags never raise a synchronous PTO trap by themselves.

<!-- PTO-READER-BLOCK: scalar-fsub-example role=example -->
## Non-normative example

`fsub.fd a0, a1, ->a2` reads `a0` as the left operand and `a1` as the right operand, subtracts the right from the left, records the returned flags, and writes the difference to `a2`. No memory traffic is generated and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fsub.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fsub_32_a4479d0d4276 | L32 | 32 | 0x0000104b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fsub_32_a4479d0d4276 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fsub_32_a4479d0d4276 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fsub_32_a4479d0d4276 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fsub_32_a4479d0d4276 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fsub_32_a4479d0d4276 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fsub_32_a4479d0d4276 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fsub_32_a4479d0d4276 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fsub_32_a4479d0d4276 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fsub_32_a4479d0d4276.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FSUB.asl -->
```asl
readonly func InstructionContractOperation_FSUB()
    => ScalarOperation
begin
    return ScalarOperation_FSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FSUB.asl -->
```asl
readonly func InstructionContractHandler_FSUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FSUB(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FSUB(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FSUB(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FSUB()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FSUB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FSUB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FSUB()
    => FloatingBinaryOperation
begin
    return FloatingBinary_SUB;
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

- FSUB subtracts the right selected carrier from the left through the active numeric profile and publishes its sticky flags.
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

- fsub.fd a0, a1, ->a2
- fsub.fs t#1, u#1, ->u
