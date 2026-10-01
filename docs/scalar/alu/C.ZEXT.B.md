<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.B.asl -->
# C.ZEXT.B

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.B.asl`

C.ZEXT.B zero-extends SrcL[7:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-zext-b-purpose role=purpose -->
## What C.ZEXT.B does

`C.ZEXT.B` takes the low byte of one Reg5 source, fills every result bit above bit `7` with zero, and pushes the XLEN result to `T`.

Design point: the width is part of the mnemonic, not of an encoded field, so `C.ZEXT.B`, `C.ZEXT.H` and `C.ZEXT.W` are three separate 16-bit forms whose fixed bits differ. A program that changes width changes the opcode.

<!-- PTO-READER-BLOCK: scalar-c-zext-b-mechanism role=mechanism -->
## How the result is formed

The shared extension helper selects `value[7:0]` and zero-extends it to `PTO_XLEN`. Bits `8` and above of the source are discarded rather than tested, so the published value is always in `0..255`.

Design point: the same helper serves the signed counterpart `C.SEXT.B`; the only difference in the call is the extension flag, which is `FALSE` here. The observable difference is that `C.ZEXT.B` cannot publish a value above `255`, while a sign-extending form of the same byte can publish an all-ones high half.

<!-- PTO-READER-BLOCK: scalar-c-zext-b-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, read without consuming a queue entry.
- The immediate and destination fields do not exist in this form: the compressed encoding fixes the destination to `T`.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so `c.zext.b zero, ->t` pushes `0` with no register dependency, and the byte selection makes that the only zero-source result.

<!-- PTO-READER-BLOCK: scalar-c-zext-b-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a source that names `T#1` is read at its pre-instruction value. The push then moves the queue toward older indices, the new value becomes `T#1`, and the previous `T#4` is discarded.

After the push, `TPC` advances by `2` bytes. No GPR is written, and no `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, branch-target or other control state changes.

<!-- PTO-READER-BLOCK: scalar-c-zext-b-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code from `0` through `31` is assigned, and the fixed encoding bits must match the canonical form. Extension is a total fixed-width operation and raises no arithmetic exception for any source value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`.

Design point: there is no illegal operand value to reject, because the source selector map is total and the byte truncation is defined for every XLEN input. The only source-related fault is asking for a queue entry the queue does not hold.

<!-- PTO-READER-BLOCK: scalar-c-zext-b-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `0x1234` and `T#1` holding `0x7F`, `c.zext.b a0, ->t` pushes `0x34` and moves the old `0x7F` to `T#2`. With an all-ones source the pushed value is `255`, never `-1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.zext.b srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | C16 | 16 | 0x581c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_ZEXT_B(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        8,
        FALSE);
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

- Zero-fill every result bit above source bit 7.
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

- c.zext.b srcl, ->t
