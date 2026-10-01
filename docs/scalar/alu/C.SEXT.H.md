<!-- GENERATED FROM: asl/scalar/alu/C.SEXT.H.asl -->
# C.SEXT.H

**Normative ASL source:** `asl/scalar/alu/C.SEXT.H.asl`

C.SEXT.H sign-extends SrcL[15:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SEXT-H}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sext-h-purpose role=purpose -->
## What C.SEXT.H does

`C.SEXT.H` takes the low halfword of one Reg5 source, sign-extends it to `PTO_XLEN`, and pushes the result to `T` as the newest temporary value.

Design point: `C.SEXT.H` is the halfword member of the compressed extension family. The field layout, the fixed `T` destination and the push behaviour are identical to `C.SEXT.B`; only the sign bit moves from position `7` to position `15`.

<!-- PTO-READER-BLOCK: scalar-c-sext-h-mechanism role=mechanism -->
## How the result is formed

Source bits `15..0` become result bits `15..0`, and source bit `15` is copied into every bit from `16` upward.

Design point: the extension reads the source once and produces one value. The bits above the halfword are not tested or reported, so a value that overflowed a 16-bit computation is simply re-extended from bit `15` with no flag and no trap.

Design point: the push shifts the queue, so the new value becomes `T#1`, the previous `T#1` becomes `T#2`, and the previous `T#4` is discarded.

<!-- PTO-READER-BLOCK: scalar-c-sext-h-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: `c.sext.h t#1, ->t` reads the old `T#1`, pushes the halfword-extended value as the new `T#1`, and moves the original to `T#2`. A temporary source is read, not consumed.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, whose low halfword is `0`, so `c.sext.h zero, ->t` pushes `0`.

<!-- PTO-READER-BLOCK: scalar-c-sext-h-effects role=effects -->
## Effects and ordering

The source is read before the push, so the pushed value is computed from the pre-instruction source.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-sext-h-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code is assigned and fixed encoding bits must match the canonical form, so `C.SEXT.H` has no reserved operand value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: halfword extension is total, so `C.SEXT.H` has no value-dependent fault. All `65536` possible low halfwords produce a defined result, and the upper `48` source bits are ignored rather than checked.

<!-- PTO-READER-BLOCK: scalar-c-sext-h-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=65535`, the low halfword is all ones, so `c.sext.h a0, ->t` pushes `18446744073709551615`. With `a0=32767` the sign bit `15` is clear and the pushed value is `32767`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sext.h srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sext_h_16_90cb7ea36bd3 | C16 | 16 | 0x481c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sext_h_16_90cb7ea36bd3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sext_h_16_90cb7ea36bd3 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.H.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.H.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_H() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_SEXT_H(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        16,
        TRUE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- The compressed form has no destination field and always pushes exactly one result to T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend source bit 15 through the XLEN result.
- Push the complete XLEN result to T. The source queue is non-consuming, and no explicit destination encoding exists.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.sext.h srcl, ->t
