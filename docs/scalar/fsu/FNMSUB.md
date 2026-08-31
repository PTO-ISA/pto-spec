<!-- GENERATED FROM: asl/scalar/fsu/FNMSUB.asl -->
# FNMSUB

**Normative ASL source:** `asl/scalar/fsu/FNMSUB.asl`

FNMSUB computes the negation of one fused SrcL multiplied by SrcR minus SrcA operation through the active numeric profile.

## Normative identity {#PTO-INST-SCALAR-FNMSUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fnmsub-purpose role=purpose -->
## What FNMSUB does

`FNMSUB` negates fused left times right minus addend through the active numeric profile.

<!-- PTO-READER-BLOCK: scalar-fnmsub-mechanism role=mechanism -->
## Numeric mechanism

`SrcType=00` selects a complete FP64 carrier; `SrcType=01` selects the zero-extended low 32-bit FP32 carrier.

The active profile receives snapshotted operands and the mnemonic-selected operation, then returns a result and exact `NV`, `DZ`, `OF`, `UF`, `NX` vector.

In the `pto-v0` reference profile, carrier multiplication minus addend is negated modulo the selected width. This deterministic reference rule is not an IEEE-754 or target-hardware claim.

<!-- PTO-READER-BLOCK: scalar-fnmsub-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the encoded destination or discard behavior.

- `SrcA` supplies the addend source.

- `SrcL` supplies the left scalar source.

- `SrcR` supplies the right scalar source.

- `SrcType` selects the source-carrier width.

- Reg5 source selectors may read GPR, T, or U state without consuming temporary entries.

- The destination selector writes a GPR, pushes T/U, or discards only the result.

<!-- PTO-READER-BLOCK: scalar-fnmsub-effects role=effects -->
## Effects and ordering

All explicit sources are snapshotted before numeric-status or destination effects.

All five profile-returned flags are ORed into sticky numeric state; the operation cannot clear an existing flag.

The result is published or discarded, then `TPC` advances by `4` bytes. The instruction has no memory or reservation effect.

<!-- PTO-READER-BLOCK: scalar-fnmsub-constraints role=constraints -->
## Type and profile boundaries

`SrcType=10` and `SrcType=11` are reserved. Reserved types and unavailable T/U sources raise `Fault_IllegalInstruction` before source, profile, flag, queue, destination, or `TPC` effects.

The portable instruction contract owns carrier selection, snapshots, flag accumulation, publication, and fault order; the active named profile owns the numeric result and produced flags.

<!-- PTO-READER-BLOCK: scalar-fnmsub-example role=example -->
## Non-normative example

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

`fnmsub.fd a0, a1, a2, ->a3` selects its carriers, snapshots its sources, invokes the active profile, accumulates returned flags, publishes the result, and then advances `TPC`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fnmsub.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fnmsub_32_6542d56665b3 | L32 | 32 | 0x0000704b / 0x0000707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fnmsub_32_6542d56665b3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fnmsub_32_6542d56665b3 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fnmsub_32_6542d56665b3 | SrcA | 5 | 0–31 | none | none | fused addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmsub_32_6542d56665b3 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmsub_32_6542d56665b3 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmsub_32_6542d56665b3 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fnmsub_32_6542d56665b3.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcA | fused addend Reg5 source |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNMSUB.asl -->
```asl
readonly func InstructionContractOperation_FNMSUB()
    => ScalarOperation
begin
    return ScalarOperation_FNMSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNMSUB.asl -->
```asl
readonly func InstructionContractHandler_FNMSUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;

pure func InstructionContractSourceTypeLegal_FNMSUB(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FNMSUB(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FNMSUB(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FNMSUB()
    => integer {1..3}
begin
    return 3;
end;

pure func InstructionContractUsesProfileFlags_FNMSUB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FNMSUB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFusedOperation_FNMSUB()
    => FloatingFusedOperation
begin
    return FloatingFused_NMSUB;
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

- FNMSUB computes the negation of one fused SrcL multiplied by SrcR minus SrcA operation through the active numeric profile.
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

- fnmsub.fd a0, a1, a2, ->a3
- fnmsub.fs t#1, u#1, a0, ->t
