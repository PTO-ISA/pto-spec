<!-- GENERATED FROM: asl/scalar/fsu/FNES.asl -->
# FNES

**Normative ASL source:** `asl/scalar/fsu/FNES.asl`

FNES performs ordered signaling inequality and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FNES}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fnes-purpose role=purpose -->
## What FNES does

`FNES` compares two floating-point scalars and writes an integer verdict. It is the ordered signaling inequality: the destination receives canonical XLEN `1` when the two operands differ and canonical XLEN `0` when they are equal or when either one is a NaN.

The integer result is a plain word in a Reg5 destination, so a deciding compare can feed later integer control flow without any conversion step.

<!-- PTO-READER-BLOCK: scalar-fnes-mechanism role=mechanism -->
## How the comparison is decided

`SrcType=00` selects a complete 64-bit FP64 carrier. `SrcType=01` selects FP32 and uses only the low 32 bits of each source word, zero-extended to XLEN.

The instruction contract names `FloatingCompare_NE` and reports itself as a signaling compare. The handler records `NV` whenever any input is a NaN, quiet or signaling, because this form is signaling.

Equality is decided on the value, not on the raw encoding: `-0` and `+0` compare equal even though their encodings differ, so the published verdict is `0` for that pair. Only the inequality test is needed, so the result is the negation of the equality test.

Design point: comparing a NaN against anything is unordered, and this form is declared signaling, so the unordered case is reported on the status side as well as the result side. A quiet NaN that reaches a signaling compare is therefore visible in `CORE_STATE[32]`, which is what tells a program that a NaN took part in the comparison.

<!-- PTO-READER-BLOCK: scalar-fnes-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the destination selector: codes `1`..`23` write a GPR, `30` pushes `U`, `31` pushes `T`, and `0` plus `24`..`29` discard the result.
- `SrcL` is the left source selector.
- `SrcR` is the right source selector.
- `SrcType` selects the carrier that both sources are read with.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and destination selector `0` writes nothing.

<!-- PTO-READER-BLOCK: scalar-fnes-effects role=effects -->
## Effects and ordering

Both source reads complete before anything else is written, so `SrcL`, `SrcR` and `RegDst` may name the same register or queue slot and the comparison still sees the pre-instruction values. A push into `T` or `U` happens only after both reads, so a selector that reads and is pushed in the same instruction observes the entry that was already present.

The sticky flag update writes `CORE_STATE[36:32]` through an OR, so an earlier flag is never cleared. The destination is then written or discarded, and only then does `TPC` advance by `4` bytes. The instruction performs no memory access and leaves no reservation.

<!-- PTO-READER-BLOCK: scalar-fnes-constraints role=constraints -->
## Reserved types and rejection

`SrcType=10` and `SrcType=11` are reserved. The handler checks the carrier type before the first read of either source register, so a reserved type raises `Fault_IllegalInstruction` with no source read, no flag, no queue change, no destination write, and no `TPC` advance.

A source selector that names an unavailable `T` or `U` slot is rejected the same way, at the same point.

This form does not use the active rounding mode, because comparing two carriers is not a rounding operation. Numeric flags are status only: a recorded `NV` never raises a synchronous PTO trap by itself.

<!-- PTO-READER-BLOCK: scalar-fnes-example role=example -->
## Non-normative example

`fnes.fd a0, a1, ->a2` reads `a0` and `a1` as complete FP64 carriers and writes the verdict to `a2`.

With `a0` holding FP64 `+0.0` and `a1` holding FP64 `-0.0`, the two are equal by value, so `0` is written and no flag is recorded. With `a0` holding a quiet NaN and `a1` holding FP64 `1.0`, `0` is written, and sticky `NV` is set in `CORE_STATE[32]` because this form is signaling.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fnes.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fnes_32_9b4b5a493783 | L32 | 32 | 0x0800105b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fnes_32_9b4b5a493783 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fnes_32_9b4b5a493783 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fnes_32_9b4b5a493783 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fnes_32_9b4b5a493783 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fnes_32_9b4b5a493783 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fnes_32_9b4b5a493783 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnes_32_9b4b5a493783 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnes_32_9b4b5a493783 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fnes_32_9b4b5a493783.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNES.asl -->
```asl
readonly func InstructionContractOperation_FNES()
    => ScalarOperation
begin
    return ScalarOperation_FNES;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNES.asl -->
```asl
readonly func InstructionContractHandler_FNES()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FNES(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FNES(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FNES(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FNES()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FNES()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FNES()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FNES()
    => FloatingCompareOperation
begin
    return FloatingCompare_NE;
end;

pure func InstructionContractSignalingCompare_FNES()
    => boolean
begin
    return TRUE;
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

- FNES performs ordered signaling inequality and returns canonical XLEN zero or one.
- Any NaN returns false. This signaling form records sticky NV for any NaN.
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

- fnes.fd a0, a1, ->a2
- fnes.fs t#1, u#1, ->u
