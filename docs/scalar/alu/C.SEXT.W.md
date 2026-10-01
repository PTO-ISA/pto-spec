<!-- GENERATED FROM: asl/scalar/alu/C.SEXT.W.asl -->
# C.SEXT.W

**Normative ASL source:** `asl/scalar/alu/C.SEXT.W.asl`

C.SEXT.W sign-extends SrcL[31:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SEXT-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sext-w-purpose role=purpose -->
## What C.SEXT.W does

`C.SEXT.W` takes the low word of one Reg5 source, sign-extends it to `PTO_XLEN`, and pushes the result to `T` as the newest temporary value.

Design point: the word member completes the compressed extension family. It is the normalization step that makes a `32`-bit value well formed in a `64`-bit register, and it does so without needing a destination field or an immediate.

<!-- PTO-READER-BLOCK: scalar-c-sext-w-mechanism role=mechanism -->
## How the result is formed

Source bits `31..0` become result bits `31..0`, and source bit `31` is copied into bits `63..32`.

Design point: the published value always has its upper `32` bits equal to bit `31`, whatever the source upper word held. A `32`-bit sum that was computed in a `64`-bit register is therefore restored to its canonical signed form by this instruction.

Design point: the push shifts the queue, so the new value becomes `T#1`, the previous `T#1` becomes `T#2`, and the previous `T#4` is discarded.

<!-- PTO-READER-BLOCK: scalar-c-sext-w-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry. Only `SrcL[31:0]` participates.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: `c.sext.w t#1, ->t` reads the old `T#1`, pushes the normalized value as the new `T#1`, and moves the original to `T#2`; the source queue is read, not consumed.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so `c.sext.w zero, ->t` pushes `0`. There is no discard form, because the compressed encoding has no destination field to hold one.

<!-- PTO-READER-BLOCK: scalar-c-sext-w-effects role=effects -->
## Effects and ordering

The source is read before the push, so a source that names a queue entry sees the pre-instruction value.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-sext-w-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code is assigned and fixed encoding bits must match the canonical form, so `C.SEXT.W` has no reserved operand value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: word extension is total and value-independent, so `C.SEXT.W` never faults on data. It also reports nothing: sign extension is a bit copy, not a comparison, so no status flag is set.

<!-- PTO-READER-BLOCK: scalar-c-sext-w-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=4294967295`, the low word is all ones, so `c.sext.w a0, ->t` pushes `18446744073709551615`. With `a0=2147483647` the sign bit `31` is clear and the pushed value is `2147483647`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sext.w srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sext_w_16_f2bb13f0797b | C16 | 16 | 0x501c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sext_w_16_f2bb13f0797b | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sext_w_16_f2bb13f0797b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.W.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.W.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_SEXT_W(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        32,
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

- Sign-extend source bit 31 through the XLEN result.
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

- c.sext.w srcl, ->t
