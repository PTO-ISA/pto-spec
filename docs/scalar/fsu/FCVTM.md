<!-- GENERATED FROM: asl/scalar/fsu/FCVTM.asl -->
# FCVTM

**Normative ASL source:** `asl/scalar/fsu/FCVTM.asl`

FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.

## Normative identity {#PTO-INST-SCALAR-FCVTM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fcvtm-purpose role=purpose -->
## What FCVTM does

`FCVTM` converts a floating-point carrier to an integer carrier and writes the result to a Reg5 destination, using the round toward negative infinity rule.

The rounding rule is fixed by the mnemonic and is not read from a register field, so a program that needs this rounding can name it directly.

<!-- PTO-READER-BLOCK: scalar-fcvtm-mechanism role=mechanism -->
## Rounding a finite source into the integer destination

`SrcType` selects the source carrier and every code `0..3` is assigned, meaning FP64, FP32, FP16, and E4M3. `DstType` is a raw five-bit field: raw codes `0..3` select the unsigned destinations `UD`, `UW`, `UH`, and `UB`, raw codes `4..7` select the corresponding signed destinations `SD`, `SW`, `SH`, and `SB`, and raw codes `8..31` are reserved.

The source is normalised to the full word before the profile runs. The result rounds an already finite value into the integer destination, so the rounding decision happens once, when the fractional part is discarded. Always round down, so `2.5` becomes `2` and `-2.5` becomes `-3`.

Design point: because the rule is a fixed part of the contract, the same source value always produces the same integer for this mnemonic, independently of the current rounding-mode field, and two programs that need different tie-break rules simply name different mnemonics.

<!-- PTO-READER-BLOCK: scalar-fcvtm-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the sole Reg5 source.
- `SrcType` selects the source carrier; every code `0..3` is assigned.
- `DstType` selects the destination integer width and signedness; codes `0..7` are assigned and codes `8..31` are reserved.
- `RegDst` selects the destination: codes `1..23` write the named absolute GPR, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and code `0` plus codes `24..29` discard the result.

Reg5 source codes read absolute GPRs, `T#1..T#4`, or `U#1..U#4` without consuming a queue entry. Encoded zero in `SrcL` reads the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-fcvtm-effects role=effects -->
## Effects and ordering

The integer result is normalised to the selected destination width and written once, and the flags the profile returns are ORed into the sticky numeric status. `TPC` then advances by `4` bytes. No memory, reservation, or descriptor state changes.

A NaN source publishes zero for the destination and an infinity source publishes the destination endpoint, and both cases record `NV` rather than raising a trap. The mnemonic does not saturate the result; saturation is disabled for scalar conversion.

<!-- PTO-READER-BLOCK: scalar-fcvtm-constraints role=constraints -->
## Type legality and the rounding field

Type legality is resolved before the first architectural source read: every `SrcType` is legal and `DstType` must be at most `7`. A reserved destination type, a fixed-bit mismatch, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any source, profile, destination, flag, queue, or `TPC` effect.

Every Reg5 destination code is assigned, so no destination encoding is illegal. The mnemonic does not consult the active rounding field, so changing that field does not change this instruction's result. Numeric status flags update sticky status and never raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-fcvtm-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

The canonical example is `fcvtm.fd2sd a0, ->a1`: GPR `a0` holds `0x4004000000000000`, standing for `2.5`, and the form whose encoded `DstType` selects `SD` writes `2` to the destination.

The companion example `fcvtm.fs2sw t#1, ->u` converts the FP32 carrier in the low word of the `T#1` entry to a signed 32-bit integer and pushes the result to the `U` queue.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fcvtm.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvtm_32_8801f1562870 | L32 | 32 | 0x0000206b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvtm_32_8801f1562870 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvtm_32_8801f1562870 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvtm_32_8801f1562870 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvtm_32_8801f1562870 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fcvtm_32_8801f1562870 | DstType | 5 | 0–7 | none | 8–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| fcvtm_32_8801f1562870 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fcvtm_32_8801f1562870 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fcvtm_32_8801f1562870 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fcvtm_32_8801f1562870.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTM.asl -->
```asl
readonly func InstructionContractOperation_FCVTM()
    => ScalarOperation
begin
    return ScalarOperation_FCVTM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTM.asl -->
```asl
readonly func InstructionContractHandler_FCVTM()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVTM(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_FCVTM(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVTM(encoded);
    return ScalarConvertFloatingTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVTM(encoded: bits(5))
    => boolean
begin
    return ScalarFPToIntegerDestinationRawLegal(encoded);
end;

pure func InstructionContractDestinationCarrier_FCVTM(encoded: bits(5))
    => bits(5)
begin
    assert InstructionContractDestinationTypeLegal_FCVTM(encoded);
    return ScalarFPToIntegerDestinationTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FCVTM()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVTM()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVTM()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractFixedRounding_FCVTM()
    => NumericRoundingMode
begin
    return NumericRound_RTM;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType codes 0..3 select FP64, FP32, FP16, and E4M3; every code is assigned.
- DstType raw codes 0..3 select UD/UW/UH/UB, raw codes 4..7 select SD/SW/SH/SB, and raw codes 8..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- Every SrcType code is assigned: 0, 1, 2, and 3 select FP64, FP32, FP16, and E4M3.
- DstType raw codes 0 through 3 map to unsigned 64-, 32-, 16-, and 8-bit results; raw codes 4 through 7 map to the corresponding signed results; raw codes 8 through 31 are reserved.

## State effects

- FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.
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

- fcvtm.fd2sd a0, ->a1
- fcvtm.fs2sw t#1, ->u
