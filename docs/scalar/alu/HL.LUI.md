<!-- GENERATED FROM: asl/scalar/alu/HL.LUI.asl -->
# HL.LUI

**Normative ASL source:** `asl/scalar/alu/HL.LUI.asl`

HL.LUI places its split 32-bit immediate in result bits 63:32 and clears result bits 31:0.

## Normative identity {#PTO-INST-SCALAR-HL-LUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lui-purpose role=purpose -->
## What HL.LUI does

`HL.LUI` materializes a constant in the upper half of the destination word. It encodes no source register. Decode reassembles the `imm` immediate, zero-extends it to `PTO_XLEN`, shifts it left by `32`, and publishes the result through `RegDst`. Successful execution advances `TPC` by `6` bytes.

Design point: bits `31:0` of the result are always zero, and the constant the encoding carries appears only from bit `32` upward. `hl.lui 1, ->a0` writes `4294967296` and not `1`, so a value that needs a nonzero low half has to get it from another instruction.

<!-- PTO-READER-BLOCK: scalar-hl-lui-mechanism role=mechanism -->
## How the upper half is formed

The immediate arrives in two pieces; one carries value bits `19:0` and the other carries bits `31:20`. The reassembled `32`-bit pattern is zero-extended to a full `PTO_XLEN` word and then shifted left by `32`.

Design point: the shift moves a zero-extended value, so all `32` encoded bits land in positions `63:32` and positions `31:0` stay zero for every encoding, including the all-ones immediate. The immediate's own bit `31` becomes result bit `63`, so a constant starting with a one produces a word whose highest bit is set: `hl.lui 4294967295, ->a0` writes `18446744069414584320`.

<!-- PTO-READER-BLOCK: scalar-hl-lui-inputs role=inputs-outputs -->
## Inputs and destinations

- `imm` carries the `32`-bit pattern that will occupy result bits `63:32`.
- `RegDst` publishes the shifted word: codes `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: `imm=0` materializes the numeric value `0`, so this encoding is a defined zero publication rather than an omitted operand. `hl.lui 0, ->a0` writes `0` and still advances `TPC` by `6` bytes, exactly like any other encoding of the form.

<!-- PTO-READER-BLOCK: scalar-hl-lui-effects role=effects -->
## Effects and ordering

The immediate is reassembled before the destination effect, and no register or queue entry is read on the way. A `U` or `T` destination push makes the shifted word index `1` of that queue and discards the entry that was at index `4`; a GPR destination overwrites that one register.

Publication is followed by the `TPC` advance of `6` bytes. `HL.LUI` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-lui-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `RegDst` codes and all `4294967296` patterns of the `32`-bit immediate field.

Two rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. Both precede the destination effect and the `TPC` advance.

Design point: no source selector is encoded, so the unavailable-source rejection of the register forms cannot occur for this mnemonic, and every destination code is assigned. An `HL.LUI` encoding is therefore rejected only for its fixed bits or for the bundle state that the applicability test reads.

`HL.LUI` adds no arithmetic exception: shifting a zero-extended `32`-bit value by `32` can neither lose a bit nor overflow.

<!-- PTO-READER-BLOCK: scalar-hl-lui-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

`hl.lui 1, ->a0` writes `4294967296`, placing a one at result bit `32` and leaving the low word zero. `hl.lui 4294967295, ->t` pushes `18446744069414584320`, whose low half is zero and whose highest bit is set.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lui imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lui_48_255991889818 | HL48 | 48 | 0x00000017000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lui_48_255991889818 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lui_48_255991889818 | imm | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lui_48_255991889818 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_lui_48_255991889818 | imm | 32 | 0–4294967295 | none | none | split 32-bit immediate placed in result bits 63:32 | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| imm | split 32-bit immediate placed in result bits 63:32 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LUI() => ScalarOperation
begin
    return ScalarOperation_HL_LUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUpper;
end;

pure func InstructionContractResult_HL_LUI(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUpper(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes unsigned immediate placement in result bits 63:32 and the common explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble imm from its two encoded pieces, zero-extend it to XLEN, shift it left by 32, and clear result bits 31:0.
- Publish the complete XLEN result through the common Reg5 destination map. Only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Reassemble the complete encoded immediate before the destination effect.
- Publish the upper-half result, then advance TPC by six bytes.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.lui imm, ->{t, u, rd}
