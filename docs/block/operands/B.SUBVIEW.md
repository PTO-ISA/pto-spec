<!-- GENERATED FROM: asl/block/operands/B.SUBVIEW.asl -->
# B.SUBVIEW

**Normative ASL source:** `asl/block/operands/B.SUBVIEW.asl`

Decodes one source-range subview modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.

## Normative identity {#PTO-INST-BLOCK-B-SUBVIEW}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-subview-purpose role=purpose -->
## What B.SUBVIEW contributes

`B.SUBVIEW` is a 32-bit header command that narrows one source of the binder command just before it to a contiguous range. The binder is a `B.IOT` or `B.IOS`. The command is a range modifier: it attaches to that binder, allocates nothing, and does not consult the operation schema when it executes. See [Range modifiers](../model/operands/range-modifiers.md).

<!-- PTO-READER-BLOCK: block-b-subview-mechanism role=mechanism -->
## Placement and mechanism

A `B.SUBVIEW` must immediately follow its binder, or another range modifier of the same binder. Every header command that is not a range modifier closes the open range group, so a modifier cannot reach past an intervening `B.DIM` or `B.DATR`.

The handler first checks the raw fields. It then checks that a group is open, that the chosen source role exists on the binder, and that roles appear in the order source 0, source 1, destination, each at most once. Only then does it read `GPR[RegSrc]`, add the zero-extended `uimm11` modulo 2^XLEN, and store the raw fields and the derived offset in the source's range record.

Design point: a zero-participation binder (`PEMode = 000`) opens a zero-mode group. In that group each `B.SUBVIEW` passes only the open-group check, reads no GPR, and records nothing. A binder with no participating PE therefore keeps its following modifiers syntactically legal without producing any effect.

<!-- PTO-READER-BLOCK: block-b-subview-inputs role=inputs-outputs -->
## Fields and encoded values

- `SrcSelect` (bit 31) chooses source 0 when 0 and source 1 when 1. A Shared group has no source 1.
- `uimm11` (bits 30:20) is an unsigned addend, zero-extended. Zero is a real zero addend.
- `RegSrc` (bits 19:15) names an absolute GPR 0 to 23. Code zero names the zero GPR, which reads 0.
- `SubviewSizeCode` (bits 10:7) is the requested range size, 1 to 12, for 128 B up to 256 KiB. Code 0 is reserved.
- Bits 14:11 are fixed; the form matches `0x53` in its low bits under mask `0x0000787f`.

Design point: the offset is computed once, when the modifier executes, and the result is stored in the range record. A later body instruction that writes `RegSrc` does not change the recorded offset. For a Local CUBE source the derived offset counts 128-byte CELLs of the parent.

<!-- PTO-READER-BLOCK: block-b-subview-effects role=effects -->
## Recorded state and later use

An accepted `B.SUBVIEW` changes only the source's range record on the binding. It reads no Tile payload.

At stage-2 preparation, a Local subview becomes a descriptor over `min(requested, remaining)` CELLs of a CUBE-layout parent, starting at the offset. The selected CELLs are copied into a temporary Tile with the parent's layout, data type, and PE mask, and the operation reads that copy. The copy is released after the operation on both the success and the failure path. See [Subview descriptor](../model/operands/subview-descriptor.md).

Design point: the parent is unchanged, and undefined parent elements stay undefined in the view. A subview selects a range of the same object; it is not a relayout and it cannot make undefined data readable.

<!-- PTO-READER-BLOCK: block-b-subview-constraints role=constraints -->
## Legality and fault boundary

- A `RegSrc` code 24 to 31, a `SubviewSizeCode` of 0 or 13 to 15, or a nonzero fixed bit raises `Fault_IllegalInstruction` before any GPR read.
- `SubviewSizeCode` 11 or 12 attached to a participating Local group raises `Fault_TileLegality`, because Local size codes stop at 10, which is 64 KiB per PE. A Shared group accepts 1 to 12.
- No open group, a source role the binder does not have, a repeated role, or a role out of order raises `Fault_BundleControl`.
- At stage-2 preparation, a Local subview whose parent is not an allocated CUBE Tile, or whose offset is not below the parent's CELL count, raises `Fault_TileLegality` before the operation.

<!-- PTO-READER-BLOCK: block-b-subview-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOT T#1, mask=1111, <last>, ->T<2KB>
B.SUBVIEW 0, a0, 2, 2
```

Assume `T#1` is a `CUBE_M16` `FP16` Tile with a 16 x 32 valid shape, which is 8 CELLs of 16 rows by 4 columns, and `a0` holds 0. The derived offset is 0 + 2 = 2 CELLs, and size code 2 requests 256 B, which is 2 CELLs. Four CELLs remain, so the view covers the requested 2 CELLs: parent columns 8 to 15, a 16 x 8 view. The modifier encodes as `0x00210153`. A second `B.SUBVIEW 0` after it would raise `Fault_BundleControl`, because source 0 has already been modified.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.SUBVIEW SrcSelect, RegSrc, uimm11, SubviewSizeCode
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_subview_32_122000000001 | L32 | 32 | 0x00000053 / 0x0000787f | [{"field":"SrcSelect","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SubviewSizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10,11,12]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_subview_32_122000000001 | SrcSelect | 1 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":1}] |
| b_subview_32_122000000001 | uimm11 | 11 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":11}] |
| b_subview_32_122000000001 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_subview_32_122000000001 | SubviewSizeCode | 4 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_subview_32_122000000001 | SrcSelect | 1 | 0–1 | none | none | selects source0 or source1 carrier | Zero selects source role zero. |
| b_subview_32_122000000001 | uimm11 | 11 | 0–2047 | none | none | unsigned XLEN addend | Zero is a real zero displacement. |
| b_subview_32_122000000001 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR selector | Zero names the architectural zero GPR. |
| b_subview_32_122000000001 | SubviewSizeCode | 4 | 1–12 | none | 0, 13–15 | decoded source tile range size | Zero is reserved. |

- `b_subview_32_122000000001.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_subview_32_122000000001.SubviewSizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcSelect | selects source0 or source1 carrier |
| RegSrc | absolute GPR selector |
| uimm11 | unsigned XLEN addend |
| SubviewSizeCode | decoded source tile range size |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.SUBVIEW.asl -->
```asl
readonly func InstructionContractMatches_B_SUBVIEW(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_subview_32_122000000001;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.SUBVIEW.asl -->
```asl
pure func InstructionContractSubviewSizeCodeIsAssigned_B_SUBVIEW(code: integer {0..15}) => boolean
begin
    return 1 <= code && code <= 12;
end;

readonly func InstructionContractHandler_B_SUBVIEW() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleSubview;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR.

## Legality

- RegSrc accepts only absolute GPR selectors 0..23.
- SubviewSizeCode raw values 1..12 are decoded; Local-associated groups require 1..10 and Shared-associated groups accept 1..12.
- A modifier is legal only in the contiguous immediately preceding B.IOT/B.IOS group and follows source0, source1, destination role order.

## State effects

- Store raw RegSrc/uimm11/size and the derived XLEN offset in the source carrier of the open binder group.
- PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality.

## Exceptions

- Reserved funct3/bit11/opcode, RegSrc24..31, and SubviewSizeCode0/13..15 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance.
- Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl before carrier updates.

## Examples

- B.IOT T0, mask=1111; B.SUBVIEW 0, a0, 0, 1
