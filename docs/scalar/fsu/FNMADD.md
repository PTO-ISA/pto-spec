<!-- GENERATED FROM: asl/scalar/fsu/FNMADD.asl -->
# FNMADD

**Normative ASL source:** `asl/scalar/fsu/FNMADD.asl`

FNMADD computes the negation of one fused SrcL multiplied by SrcR plus SrcA operation through the active numeric profile.

## Normative identity {#PTO-INST-SCALAR-FNMADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fnmadd-purpose role=purpose -->
## What FNMADD does

`FNMADD` evaluates a three-operand floating-point expression of the form `-(product + addend)` and publishes one result carrier. `SrcL` is multiplied by `SrcR`; the third source `SrcA` is the addend that is added to or subtracted from that product.

The whole expression is one fused operation: the product is never rounded to a carrier of its own before the addend participates.

<!-- PTO-READER-BLOCK: scalar-fnmadd-mechanism role=mechanism -->
## How the fused operation is performed

`SrcType=00` selects a complete 64-bit FP64 carrier. `SrcType=01` selects FP32 and uses only the low 32 bits of each source word, zero-extended to XLEN.

The contract names `FloatingFused_NMADD`. The handler reads `SrcA`, `SrcL` and `SrcR`, applies the selected carrier to each, and asks the profile for one result and one exact `NV`, `DZ`, `OF`, `UF`, `NX` vector. In the `pto-v0` reference profile the addend, the left operand and the right operand become real values, `left * right` is formed exactly, `-(product + addend)` is formed from that exact product, and the final real value is encoded once with the rounding mode encoded in `CORE_STATE[39:37]`.

Special inputs are answered before the finite kernel. A NaN in any of the three sources publishes the canonical quiet NaN and records `NV` only when at least one of the three was a signaling NaN. `0` times an infinity publishes the canonical quiet NaN and records `NV`. A product infinity and an addend infinity of opposite effective sign also publish the canonical quiet NaN with `NV`; otherwise an infinite product or an infinite addend publishes the signed infinity that the effective sign selects.

Design point: for `FMSUB` and `FNMSUB` the addend sign is inverted for the sign analysis, and for `FNMADD` and `FNMSUB` the final sign is inverted after that analysis. This is what lets one shared special-value rule cover all four mnemonics without a separate rule per mnemonic.

<!-- PTO-READER-BLOCK: scalar-fnmadd-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the destination selector: codes `1`..`23` write a GPR, `30` pushes `U`, `31` pushes `T`, and `0` plus `24`..`29` discard the result.
- `SrcL` is the left multiplicand selector.
- `SrcR` is the right multiplicand selector.
- `SrcA` is the addend selector.
- `SrcType` selects the carrier that all three sources are read with.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and destination selector `0` writes nothing.

<!-- PTO-READER-BLOCK: scalar-fnmadd-effects role=effects -->
## Effects and ordering

All three sources are read before any write, so `SrcL`, `SrcR`, `SrcA` and `RegDst` may name the same register or queue slot and the operation still uses the pre-instruction values. A push into `T` or `U` happens only after all three reads, so a read-then-push of the same queue observes the entry that was already present.

All five returned flag bits are ORed into `CORE_STATE[36:32]`, so the operation can set a sticky flag but never clear one. The destination is written or discarded, and only then does `TPC` advance by `4` bytes. No memory access and no reservation is involved.

<!-- PTO-READER-BLOCK: scalar-fnmadd-constraints role=constraints -->
## Reserved types and rejection

`SrcType=10` and `SrcType=11` are reserved. The handler checks the carrier type before the first read of any source register, so a reserved type raises `Fault_IllegalInstruction` with no source read, no profile call, no flag, no queue change, no destination write, and no `TPC` advance.

A source selector that names an unavailable `T` or `U` slot is rejected the same way, at the same point.

Because the whole expression is fused, there is no intermediate carrier and therefore no intermediate rounding step that a programmer could observe or rely on. Reserved numeric flags never raise a synchronous PTO trap by themselves.

<!-- PTO-READER-BLOCK: scalar-fnmadd-example role=example -->
## Non-normative example

`fnmadd.fd a0, a1, a2, ->a3` reads `a0`, `a1` and `a2` as complete FP64 carriers, forms `-(a0 * a1 + a2)` with a single rounding, records the returned flags in `CORE_STATE[36:32]`, and writes the result to `a3`.

With `SrcL` holding FP64 `2.0`, `SrcR` holding FP64 `3.0` and `SrcA` holding FP64 `1.0`, the published value is FP64 `-7.0`, the negation of `2.0 * 3.0 + 1.0`. No memory traffic is generated and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fnmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fnmadd_32_7f45e606d299 | L32 | 32 | 0x0000604b / 0x0000707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fnmadd_32_7f45e606d299 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fnmadd_32_7f45e606d299 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fnmadd_32_7f45e606d299 | SrcA | 5 | 0–31 | none | none | fused addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmadd_32_7f45e606d299 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmadd_32_7f45e606d299 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmadd_32_7f45e606d299 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fnmadd_32_7f45e606d299.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcA | fused addend Reg5 source |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNMADD.asl -->
```asl
readonly func InstructionContractOperation_FNMADD()
    => ScalarOperation
begin
    return ScalarOperation_FNMADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNMADD.asl -->
```asl
readonly func InstructionContractHandler_FNMADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;

pure func InstructionContractSourceTypeLegal_FNMADD(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FNMADD(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FNMADD(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FNMADD()
    => integer {1..3}
begin
    return 3;
end;

pure func InstructionContractUsesProfileFlags_FNMADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FNMADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFusedOperation_FNMADD()
    => FloatingFusedOperation
begin
    return FloatingFused_NMADD;
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

- FNMADD computes the negation of one fused SrcL multiplied by SrcR plus SrcA operation through the active numeric profile.
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

- fnmadd.fd a0, a1, a2, ->a3
- fnmadd.fs t#1, u#1, a0, ->t
