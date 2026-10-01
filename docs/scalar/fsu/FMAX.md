<!-- GENERATED FROM: asl/scalar/fsu/FMAX.asl -->
# FMAX

**Normative ASL source:** `asl/scalar/fsu/FMAX.asl`

FMAX applies the architecture-owned ordered maximum, NaN, and signed-zero rules to selected FP64 or FP32 carriers.

## Normative identity {#PTO-INST-SCALAR-FMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fmax-purpose role=purpose -->
## What FMAX does

`FMAX` selects one of two floating-point scalars and publishes it unchanged. It is an architecture-owned ordered maximum: floating-point `fmax` never traps and never rounds, and it returns one of the two input encodings it was given except when both operands are NaNs, where it publishes the carrier's canonical quiet NaN instead.

Because the winner is copied rather than recomputed, no rounding happens on the selected value and no inexact flag can come from the selection itself.

<!-- PTO-READER-BLOCK: scalar-fmax-mechanism role=mechanism -->
## How the selection is decided

`SrcType=00` selects a complete 64-bit FP64 carrier. `SrcType=01` selects FP32 and uses only the low 32 bits of each source word, zero-extended to XLEN.

The contract names `FloatingBinary_MAX` and reports that this form does not use profile flags and does not use the active rounding mode. The handler therefore does not call the numeric profile at all; it calls the architecture-owned NaN and signed-zero selection rule and forms its own flag vector.

The NaN rule is asymmetric by design: if exactly one operand is a NaN the other operand is returned, and the returned value is an input encoding, never a fresh computation. If both operands are NaNs the canonical quiet NaN for the selected carrier is returned instead. Only a signaling NaN input sets sticky `NV`; a quiet NaN is silent.

Signed zero is ordered explicitly rather than left to the host: `+0` and `-0` compare equal by value, so maximum prefers `+0` and minimum prefers `-0`, while two `-0` inputs under maximum stay `-0`. For two non-zero operands the ordering uses the same encoding order key as the compare family, so the greater value wins.

Design point: returning the numeric operand when the other one is a NaN keeps a NaN from silently eating a valid value, and copying the winner instead of recomputing it keeps the payload and the sign of zero intact.

<!-- PTO-READER-BLOCK: scalar-fmax-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the destination selector: codes `1`..`23` write a GPR, `30` pushes `U`, `31` pushes `T`, and `0` plus `24`..`29` discard the result.
- `SrcL` is the left source selector.
- `SrcR` is the right source selector.
- `SrcType` selects the carrier that both sources are read with.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and destination selector `0` writes nothing.

<!-- PTO-READER-BLOCK: scalar-fmax-effects role=effects -->
## Effects and ordering

Both sources are read before any write, so `SrcL`, `SrcR` and `RegDst` may name the same register or queue slot and the selection still uses the pre-instruction values. A push into `T` or `U` happens only after both reads, so a read-then-push of the same queue observes the entry that was already present.

At most one flag bit is ever produced here: `NV`, when a signaling NaN is an input. It is ORed into `CORE_STATE[36:32]`, so an earlier flag is never cleared. The selected value is written or discarded, and only then does `TPC` advance by `4` bytes. No memory access and no reservation is involved.

<!-- PTO-READER-BLOCK: scalar-fmax-constraints role=constraints -->
## Reserved types and rejection

`SrcType=10` and `SrcType=11` are reserved. The handler checks the carrier type before the first read of either source register, so a reserved type raises `Fault_IllegalInstruction` with no source read, no flag, no queue change, no destination write, and no `TPC` advance.

A source selector that names an unavailable `T` or `U` slot is rejected the same way, at the same point.

Because this form never consults the profile, the active rounding mode cannot change its result, and no `DZ`, `OF`, `UF` or `NX` bit can be produced by it.

<!-- PTO-READER-BLOCK: scalar-fmax-example role=example -->
## Non-normative example

`fmax.fs a0, a1, ->a2` reads the low 32 bits of `a0` and `a1` as FP32 carriers and writes the selected encoding to `a2`.

With `a0` holding FP32 `-0.0` and `a1` holding FP32 `+0.0`, the two are equal by value; `FMAX` returns `+0.0`, with no flag recorded. With `a0` holding a signaling NaN and `a1` holding FP32 `3.0`, the instruction writes the FP32 encoding of `3.0` and sets sticky `NV`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fmax.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fmax_32_eaf3880d7739 | L32 | 32 | 0x0000605b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fmax_32_eaf3880d7739 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fmax_32_eaf3880d7739 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fmax_32_eaf3880d7739 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fmax_32_eaf3880d7739 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fmax_32_eaf3880d7739 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fmax_32_eaf3880d7739 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmax_32_eaf3880d7739 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmax_32_eaf3880d7739 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fmax_32_eaf3880d7739.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMAX.asl -->
```asl
readonly func InstructionContractOperation_FMAX()
    => ScalarOperation
begin
    return ScalarOperation_FMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMAX.asl -->
```asl
readonly func InstructionContractHandler_FMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FMAX(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FMAX(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FMAX(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FMAX()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FMAX()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FMAX()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractBinaryOperation_FMAX()
    => FloatingBinaryOperation
begin
    return FloatingBinary_MAX;
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

- FMAX applies the architecture-owned ordered maximum, NaN, and signed-zero rules to selected FP64 or FP32 carriers.
- One NaN returns the numeric input; two NaNs return the canonical quiet NaN; a signaling NaN records sticky NV; signed-zero ordering is architecture-owned.
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

- fmax.fd a0, a1, ->a2
- fmax.fs t#1, u#1, ->u
