<!-- GENERATED FROM: asl/scalar/fsu/SCVTF.asl -->
# SCVTF

**Normative ASL source:** `asl/scalar/fsu/SCVTF.asl`

SCVTF converts an S64, S32, S16, or S8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.

## Normative identity {#PTO-INST-SCALAR-SCVTF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-scvtf-purpose role=purpose -->
## What SCVTF does

`SCVTF` converts one scalar signed integer into a floating-point carrier and publishes that carrier. It is the scalar integer-to-floating direction; the floating-to-integer direction is owned by the separate conversion mnemonics.

<!-- PTO-READER-BLOCK: scalar-scvtf-mechanism role=mechanism -->
## How the conversion is performed

`SrcType` selects the source integer carrier: code `0` selects the 64-bit type, `1` the 32-bit type, `2` the 16-bit type and `3` the 8-bit type, which here means S64, S32, S16 and S8. Sign extension is used for the source carrier, so a narrow source is read as the signed value it names.

`DstType` selects the destination floating carrier: code `0` selects FP64, `1` selects FP32, `2` selects FP16 and `3` selects E4M3. Codes `4` through `31` are reserved.

The conversion runs through the same shared scalar and tile conversion reference that the tile conversion family uses, with saturation disabled. The rounding mode is the one encoded in `CORE_STATE[39:37]`, and the profile returns the result together with an exact `NV`, `DZ`, `OF`, `UF`, `NX` vector.

The conversion is not limited to exact values. When the integer magnitude cannot be represented exactly in the destination carrier, the destination carrier is the nearest representable value under the active rounding mode and the inexact flag `NX` is recorded; when it is out of range the result is the infinity of the matching sign and `OF` is recorded, except for the `E4M3` destination, which has no infinity encoding and publishes its canonical quiet NaN instead.

Design point: the destination carrier is chosen by an encoded field rather than by the destination register, so the same source value can be converted to FP64, FP32, FP16 or E4M3 without changing any register role. Saturation is disabled for scalar conversion, so an overflowing value is never clamped to the largest finite value.

<!-- PTO-READER-BLOCK: scalar-scvtf-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the destination selector: codes `1`..`23` write a GPR, `30` pushes `U`, `31` pushes `T`, and `0` plus `24`..`29` discard the result.
- `SrcL` is the source selector. There is no second source field.
- `SrcType` selects the source integer carrier.
- `DstType` selects the destination floating carrier.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and destination selector `0` writes nothing.
- The published word is the destination encoding zero-extended to XLEN, so the upper bits above the selected carrier width are zero.

<!-- PTO-READER-BLOCK: scalar-scvtf-effects role=effects -->
## Effects and ordering

The source is read after both encoded types have been validated, and it is read before any write. `SrcL` and `RegDst` may therefore name the same register or queue slot and the conversion still uses the pre-instruction value. A push into `T` or `U` happens only after the read.

The returned flags are ORed into `CORE_STATE[36:32]`, so the conversion can set a sticky flag but never clear one. The destination is written or discarded, and only then does `TPC` advance by `4` bytes. No memory access and no reservation is involved.

<!-- PTO-READER-BLOCK: scalar-scvtf-constraints role=constraints -->
## Reserved types and rejection

All four `SrcType` codes are assigned, so no source type is reserved for this mnemonic. `DstType` codes `4` through `31` are reserved. The handler resolves both type codes before the first read of the source register, so a reserved `DstType` raises `Fault_IllegalInstruction` with no source read, no profile call, no flag, no queue change, no destination write, and no `TPC` advance.

A source selector that names an unavailable `T` or `U` slot is rejected the same way, at the same point.

A recorded numeric flag never raises a synchronous PTO trap by itself.

<!-- PTO-READER-BLOCK: scalar-scvtf-example role=example -->
## Non-normative example

`scvtf.sd2fd a0, ->a1` reads `a0` as an S64 source and writes the FP64 encoding of the same numeric value to `a1`.

With `a0` holding the S64 value `-2`, the published FP64 value is `-2.0` and `NX` stays clear because that value is exact. With `a0` holding the S64 maximum and `DstType` selecting FP32, that magnitude is not exactly representable, so the published value is the nearest FP32 value and `NX` is recorded, while `OF` stays clear because the magnitude is still far below the FP32 range. Overflow needs a narrow destination: with `DstType` selecting E4M3, a magnitude above `448` overflows.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
scvtf.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| scvtf_32_01861bbd5ef2 | L32 | 32 | 0x0000606b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| scvtf_32_01861bbd5ef2 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| scvtf_32_01861bbd5ef2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| scvtf_32_01861bbd5ef2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| scvtf_32_01861bbd5ef2 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| scvtf_32_01861bbd5ef2 | DstType | 5 | 0–3 | none | 4–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| scvtf_32_01861bbd5ef2 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| scvtf_32_01861bbd5ef2 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| scvtf_32_01861bbd5ef2 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `scvtf_32_01861bbd5ef2.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/SCVTF.asl -->
```asl
readonly func InstructionContractOperation_SCVTF()
    => ScalarOperation
begin
    return ScalarOperation_SCVTF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/SCVTF.asl -->
```asl
readonly func InstructionContractHandler_SCVTF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_SCVTF(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_SCVTF(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_SCVTF(encoded);
    return ScalarSignedIntegerSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_SCVTF(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 3;
end;

pure func InstructionContractSourceArity_SCVTF()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_SCVTF()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_SCVTF()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType codes 0..3 select S64, S32, S16, and S8 with sign extension.
- DstType codes 0..3 select FP64, FP32, FP16, and E4M3; codes 4..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- Every SrcType code is assigned: 0, 1, 2, and 3 select S64, S32, S16, and S8.
- DstType codes 0 through 3 select FP64, FP32, FP16, and E4M3; codes 4 through 31 are reserved.

## State effects

- SCVTF converts an S64, S32, S16, or S8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- The pto-v0 reference profile uses the same deterministic conversion rule and flags as TCVT for every shared scalar type pair; scalar conversion supplies saturation disabled.
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

- scvtf.sd2fd a0, ->a1
- scvtf.sw2fs t#1, ->u
