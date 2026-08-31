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

`FADD` adds two selected FP64 or FP32 carriers through the active numeric profile, publishes the profile result, and accumulates the returned five-bit status vector into sticky numeric state.

<!-- PTO-READER-BLOCK: scalar-fadd-mechanism role=mechanism -->
## Profile-mediated mechanism

`SrcType=00` selects complete FP64 carriers, while `SrcType=01` selects FP32 carriers from the zero-extended low 32 bits. The instruction calls the active profile's binary-add operation using active rounding.

The selected profile returns a result plus `NV`, `DZ`, `OF`, `UF`, and `NX`; `FADD` ORs those bits into the existing sticky `CORE_STATE[36:32]` field.

In the `pto-v0` reference profile, addition is deterministic raw-carrier modular arithmetic and returns zero flags. That reference behavior is not an IEEE-754 or target-hardware conformance claim.

<!-- PTO-READER-BLOCK: scalar-fadd-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` and `SrcR` accept every Reg5 source selector, including non-consuming T/U sources.
- `RegDst` values `1..23` write GPRs, `30` pushes U, `31` pushes T, and `0` plus `24..29` discard only the result.

All displayed operand fields are encoded. Encoded zero is a value: source selector `0` reads the zero GPR, destination `0` discards, and `SrcType=00` selects FP64.

<!-- PTO-READER-BLOCK: scalar-fadd-effects role=effects -->
## Effects and ordering

Type legality is checked before the first source read or profile call. Both sources are then snapshotted before flag accumulation or destination publication.

Produced flags are ORed into sticky numeric status, the result is published or discarded, and `TPC` advances by `4` bytes. Numeric flags do not themselves raise a synchronous PTO trap.

`FADD` has no memory or reservation effect.

<!-- PTO-READER-BLOCK: scalar-fadd-constraints role=constraints -->
## Type and profile boundaries

`SrcType=10` and `SrcType=11` are reserved and raise `Fault_IllegalInstruction` before source, profile, destination, flag, queue, or `TPC` effects. An unavailable selected T/U source has the same pre-effect fault boundary.

The portable contract owns carrier selection, snapshotting, flag accumulation, destination publication, and rejection ordering. The active named numeric profile owns the arithmetic result and produced status vector.

<!-- PTO-READER-BLOCK: scalar-fadd-example role=example -->
## Non-normative usage example

This example illustrates selection and publication; it does not define floating-point arithmetic independently of the active profile.

`fadd.fd a0, a1, ->a2` selects the FP64 carrier path, snapshots both sources, invokes profile addition with active rounding, accumulates returned flags, writes the returned carrier to `a2`, and then advances `TPC` by `4` bytes.
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
