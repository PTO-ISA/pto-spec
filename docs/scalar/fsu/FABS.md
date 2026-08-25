<!-- GENERATED FROM: asl/scalar/fsu/FABS.asl -->
# FABS

**Normative ASL source:** `asl/scalar/fsu/FABS.asl`

FABS clears the sign bit of the selected FP64 or FP32 carrier, preserves every other carrier bit, and publishes no numeric flags.

## Normative identity {#PTO-INST-SCALAR-FABS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fabs-purpose role=purpose -->
## What FABS does

`FABS` clears the sign bit of the selected FP64 or FP32 carrier while preserving every other carrier bit.

<!-- PTO-READER-BLOCK: scalar-fabs-mechanism role=mechanism -->
## Numeric mechanism

`SrcType=00` selects a complete FP64 carrier; `SrcType=01` selects the zero-extended low 32-bit FP32 carrier.

The operation clears only the selected sign bit and produces no new numeric flags.

<!-- PTO-READER-BLOCK: scalar-fabs-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the encoded destination or discard behavior.

- `SrcL` supplies the left scalar source.

- `SrcType` selects the source-carrier width.

- Reg5 source selectors may read GPR, T, or U state without consuming temporary entries.

- The destination selector writes a GPR, pushes T/U, or discards only the result.

<!-- PTO-READER-BLOCK: scalar-fabs-effects role=effects -->
## Effects and ordering

All explicit sources are snapshotted before numeric-status or destination effects.

Existing numeric flags remain unchanged.

The result is published or discarded, then `TPC` advances by `4` bytes. The instruction has no memory or reservation effect.

<!-- PTO-READER-BLOCK: scalar-fabs-constraints role=constraints -->
## Type and profile boundaries

`SrcType=10` and `SrcType=11` are reserved. Reserved types and unavailable T/U sources raise `Fault_IllegalInstruction` before source, profile, flag, queue, destination, or `TPC` effects.

Numeric flag updates do not themselves raise a synchronous PTO trap.

<!-- PTO-READER-BLOCK: scalar-fabs-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

`fabs.fd a0, ->a1` clears only the selected sign bit, publishes the carrier, and leaves numeric flags unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fabs.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fabs_32_9515e008bf17 | L32 | 32 | 0x0000007b / 0xf9f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fabs_32_9515e008bf17 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fabs_32_9515e008bf17 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fabs_32_9515e008bf17 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fabs_32_9515e008bf17 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fabs_32_9515e008bf17 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fabs_32_9515e008bf17 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fabs_32_9515e008bf17.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FABS.asl -->
```asl
readonly func InstructionContractOperation_FABS()
    => ScalarOperation
begin
    return ScalarOperation_FABS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FABS.asl -->
```asl
readonly func InstructionContractHandler_FABS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FABS(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FABS(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FABS(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FABS()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FABS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FABS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUnaryOperation_FABS()
    => FloatingUnaryOperation
begin
    return FloatingUnary_ABS;
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

- FABS clears the sign bit of the selected FP64 or FP32 carrier, preserves every other carrier bit, and publishes no numeric flags.
- Existing NV, DZ, OF, UF, and NX state is unchanged.
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

- fabs.fd a0, ->a1
- fabs.fs t#1, ->t
