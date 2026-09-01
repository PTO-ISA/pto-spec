<!-- GENERATED FROM: asl/scalar/fsu/UCVTF.asl -->
# UCVTF

**Normative ASL source:** `asl/scalar/fsu/UCVTF.asl`

UCVTF converts a U64, U32, U16, or U8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.

## Normative identity {#PTO-INST-SCALAR-UCVTF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ucvtf-purpose role=purpose -->
## What UCVTF does

`UCVTF` converts U64, U32, U16, or U8 input to FP64, FP32, FP16, or E4M3 through the active numeric profile.

<!-- PTO-READER-BLOCK: scalar-ucvtf-mechanism role=mechanism -->
## Numeric mechanism

`SrcType=00`, `01`, `10`, and `11` select U64, U32, U16, and U8 with source-width zero extension.

The active profile receives snapshotted operands and the mnemonic-selected operation, then returns a result and exact `NV`, `DZ`, `OF`, `UF`, `NX` vector.

The `pto-v0` reference profile uses the same deterministic value, rounding, range, special-value, saturation, and flag rules as `TCVT` for every shared type pair; scalar conversion supplies saturation disabled.

<!-- PTO-READER-BLOCK: scalar-ucvtf-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `DstType` selects the destination-carrier code.

- `RegDst` selects the encoded destination or discard behavior.

- `SrcL` supplies the left scalar source.

- `SrcType` selects the source-carrier width.

- Reg5 source selectors may read GPR, T, or U state without consuming temporary entries.

- The destination selector writes a GPR, pushes T/U, or discards only the result.

<!-- PTO-READER-BLOCK: scalar-ucvtf-effects role=effects -->
## Effects and ordering

All explicit sources are snapshotted before numeric-status or destination effects.

All five profile-returned flags are ORed into sticky numeric state; the operation cannot clear an existing flag.

The result is published or discarded, then `TPC` advances by `4` bytes. The instruction has no memory or reservation effect.

<!-- PTO-READER-BLOCK: scalar-ucvtf-constraints role=constraints -->
## Type and profile boundaries

All four `SrcType` values are assigned. Unavailable T/U sources raise `Fault_IllegalInstruction` before source, profile, flag, queue, destination, or `TPC` effects.

Raw `DstType=0..3` select FP64, FP32, FP16, and E4M3; `4..31` are reserved and reject before effects.

The portable instruction contract owns carrier selection, snapshots, flag accumulation, publication, and fault order; the active named profile owns the numeric result and produced flags.

<!-- PTO-READER-BLOCK: scalar-ucvtf-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

`ucvtf.ud2fd a0, ->a1` selects its carriers, snapshots its sources, invokes the active profile, accumulates returned flags, publishes the result, and then advances `TPC`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ucvtf_32_987f4e019c32 | L32 | 32 | 0x0000706b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ucvtf_32_987f4e019c32 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| ucvtf_32_987f4e019c32 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ucvtf_32_987f4e019c32 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ucvtf_32_987f4e019c32 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ucvtf_32_987f4e019c32 | DstType | 5 | 0–3 | none | 4–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| ucvtf_32_987f4e019c32 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| ucvtf_32_987f4e019c32 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| ucvtf_32_987f4e019c32 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `ucvtf_32_987f4e019c32.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/UCVTF.asl -->
```asl
readonly func InstructionContractOperation_UCVTF()
    => ScalarOperation
begin
    return ScalarOperation_UCVTF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/UCVTF.asl -->
```asl
readonly func InstructionContractHandler_UCVTF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_UCVTF(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_UCVTF(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_UCVTF(encoded);
    return ScalarUnsignedIntegerSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_UCVTF(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 3;
end;

pure func InstructionContractSourceArity_UCVTF()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_UCVTF()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_UCVTF()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType codes 0..3 select U64, U32, U16, and U8 with zero extension.
- DstType codes 0..3 select FP64, FP32, FP16, and E4M3; codes 4..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- Every SrcType code is assigned: 0, 1, 2, and 3 select U64, U32, U16, and U8.
- DstType codes 0 through 3 select FP64, FP32, FP16, and E4M3; codes 4 through 31 are reserved.

## State effects

- UCVTF converts a U64, U32, U16, or U8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.
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

- ucvtf.ud2fd a0, ->a1
- ucvtf.uw2fs t#1, ->u
