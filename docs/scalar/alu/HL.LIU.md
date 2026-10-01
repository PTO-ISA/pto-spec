<!-- GENERATED FROM: asl/scalar/alu/HL.LIU.asl -->
# HL.LIU

**Normative ASL source:** `asl/scalar/alu/HL.LIU.asl`

HL.LIU zero-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-HL-LIU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-liu-purpose role=purpose -->
## What HL.LIU does

`HL.LIU` materializes an unsigned constant. It encodes no source register. Decode reassembles the `uimm32` immediate from two pieces, zero-fills every result bit above bit `31`, and publishes the value through `RegDst`. Successful execution advances `TPC` by `6` bytes.

Design point: the zero fill is unconditional, so no result of this mnemonic has a bit set above bit `31` and every published value lies in `0` through `4294967295`. `hl.liu 4294967295, ->a0` writes `4294967295`, while the same `32` encoded bits through `hl.lis -1, ->a0` write `18446744073709551615`.

<!-- PTO-READER-BLOCK: scalar-hl-liu-mechanism role=mechanism -->
## How the constant is formed

One immediate piece carries value bits `19:0` and the other carries bits `31:20`; the reassembled pattern is exact. That `32`-bit pattern is then placed in the low half of a `PTO_XLEN` word, with zeros above it.

Design point: the encoded field is `32` bits wide and the destination word is `64` bits wide, so bits `63:32` are not encoded at all and are always zero. A constant that needs one of those bits set has to come from another form, because no `uimm32` pattern can supply it.

<!-- PTO-READER-BLOCK: scalar-hl-liu-inputs role=inputs-outputs -->
## Inputs and destinations

- `uimm32` carries the unsigned `32`-bit value.
- `RegDst` publishes it: codes `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: `uimm32=0` materializes the numeric value `0`, so `hl.liu 0, ->t` pushes a zero `T` entry instead of performing nothing. The pushed entry is valid, so a later relative read of `T#1` finds the `0`.

<!-- PTO-READER-BLOCK: scalar-hl-liu-effects role=effects -->
## Effects and ordering

Nothing is read before publication, because the form selects no source. The materialized value goes to the selected destination: a GPR write, a `U` or `T` push that makes the new value index `1` and discards whatever was at index `4`, or a discard that leaves register and queue state alone.

Publication is followed by the `TPC` advance of `6` bytes. `HL.LIU` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-liu-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `RegDst` codes and all `4294967296` patterns of the `32`-bit immediate field.

Two rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. Both precede the destination effect and the `TPC` advance.

Design point: the source-availability rejection of the register forms is absent here, because there is no source selector for the model to test. The destination side is equally open: every one of the `32` destination codes is assigned, and codes `24..29` are discard values of the destination map rather than reserved encodings.

`HL.LIU` adds no arithmetic exception: zero extension of a `32`-bit value cannot overflow.

<!-- PTO-READER-BLOCK: scalar-hl-liu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

`hl.liu 4294967295, ->u` pushes `4294967295` as the newest `U` entry, with bits `63:32` left zero. `hl.liu 1, ->a0` writes `1`, which is also what `hl.lis 1, ->a0` would write, because the two forms differ only once bit `31` of the immediate is set.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.liu uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_liu_48_9dd207ce3aea | HL48 | 48 | 0x0000001d000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_liu_48_9dd207ce3aea | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_liu_48_9dd207ce3aea | uimm32 | 32 | unsigned | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_liu_48_9dd207ce3aea | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_liu_48_9dd207ce3aea | uimm32 | 32 | 0–4294967295 | none | none | unsigned split 32-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| uimm32 | unsigned split 32-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIU.asl -->
```asl
readonly func InstructionContractOperation_HL_LIU() => ScalarOperation
begin
    return ScalarOperation_HL_LIU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIU.asl -->
```asl
readonly func InstructionContractHandler_HL_LIU() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUnsigned;
end;

pure func InstructionContractResult_HL_LIU(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUnsigned(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble uimm32 from its two encoded pieces and zero-fill result bits 63:32.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.liu uimm, ->{t, u, rd}
