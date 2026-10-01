<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.W.asl -->
# C.ZEXT.W

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.W.asl`

C.ZEXT.W zero-extends SrcL[31:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-zext-w-purpose role=purpose -->
## What C.ZEXT.W does

`C.ZEXT.W` keeps the low 32 bits of one Reg5 source unchanged, clears every result bit above bit `31`, and pushes the XLEN result to `T`.

Design point: the cleared region is everything between bit `32` and the top of `PTO_XLEN`, so on a 64-bit `PTO_XLEN` the instruction converts a two's-complement word into an unsigned word value. The low word itself is copied, not interpreted.

<!-- PTO-READER-BLOCK: scalar-c-zext-w-mechanism role=mechanism -->
## How the result is formed

The shared extension helper selects `value[31:0]` and zero-extends it to `PTO_XLEN`. Unlike `C.ZEXT.B` and `C.ZEXT.H`, the selected field is exactly the word boundary, so the published value always has bits `63:32` at zero when `PTO_XLEN` is `64`.

Design point: because bits `31:0` survive unchanged, `C.ZEXT.W` is not a no-op on a value whose low word is already the whole value. It is only an identity when the source already has a zero upper half; otherwise it removes that upper half.

<!-- PTO-READER-BLOCK: scalar-c-zext-w-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the only encoded operand: Reg5 codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, read without consuming a queue entry.
- The destination is fixed to `T`; no destination field exists in the compressed form.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so `c.zext.w zero, ->t` pushes `0`. A source that names `T#1` is read before the push, so `c.zext.w t#1, ->t` clears the upper half of the old `T#1` instead of reading the value it is about to push.

<!-- PTO-READER-BLOCK: scalar-c-zext-w-effects role=effects -->
## Effects and ordering

The source snapshot happens before the destination effect. The push then moves the queue toward older indices: the zero-extended value becomes `T#1` and the previous `T#4` is discarded.

After the push, `TPC` advances by `2` bytes. No GPR is written, and no `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, branch-target or other control state changes.

<!-- PTO-READER-BLOCK: scalar-c-zext-w-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code from `0` through `31` is assigned and the fixed encoding bits must match the canonical form. Extension is total and raises no arithmetic exception, whatever the source value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`.

Design point: this is a width-changing mnemonic with no width operand and no illegal source range, so the guide's fault boundary has no arithmetic case at all. Every reachable fault is decided before any destination effect.

<!-- PTO-READER-BLOCK: scalar-c-zext-w-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `-1`, which is an all-ones XLEN value, `c.zext.w t#1, ->t` pushes `4294967295` and moves the old all-ones value to `T#2`. With `a0` holding `0x00000000FFFFFFFF`, the pushed value is `0xFFFFFFFF` again, because the upper half was already zero.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.zext.w srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_w_16_e8bc051c7e8c | C16 | 16 | 0x681c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_w_16_e8bc051c7e8c | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_zext_w_16_e8bc051c7e8c | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.W.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.W.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_ZEXT_W(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        32,
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

- Zero-fill every result bit above source bit 31.
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

- c.zext.w srcl, ->t
