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

`B.SUBVIEW` is a 32-bit block header command that attaches one source-subview modifier to an open Local or Shared binder group. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-subview-mechanism role=mechanism -->
## Placement and mechanism

The modifier is valid only while it remains contiguous with the `B.IOT` or `B.IOS` binder group that opened its carrier. Intervening, reversed, or duplicate modifiers are rejected before carrier state changes.

The command records its raw selector and range fields in the open binder carrier together with the derived XLEN offset. A binder whose decoded PE mask is zero keeps only a discarded syntactic group and performs no source read or role effect.

<!-- PTO-READER-BLOCK: block-b-subview-inputs role=inputs-outputs -->
## Operands and header roles

- `SrcSelect` selects source carrier zero or one; its exact assigned domain remains in the generated contract below.
- `RegSrc` selects the named absolute GPR role; its exact assigned domain remains in the generated contract below.
- `uimm11` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.
- `SubviewSizeCode` supplies the subview range size code; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-subview-effects role=effects -->
## Pending state and completion

An accepted header command changes only its pending record or carrier. Architectural tile, Shared, GPR, memory, and completion effects remain deferred to the completed block unless this owner's contract explicitly identifies an immediate header-state update.

<!-- PTO-READER-BLOCK: block-b-subview-constraints role=constraints -->
## Legality and fault boundary

Reserved encodings are rejected before reads or pending-state changes. Placement, duplicate, role, or completed-schema mismatches fail before body effects.

<!-- PTO-READER-BLOCK: block-b-subview-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>
B.SUBVIEW 0, RegSrc, uimm11, SubviewSizeCode
```

The source form of `B.IOT` opens a group whose source-zero carrier is exact. The immediately following `B.SUBVIEW 0` modifies that source carrier only; it cannot be separated from the binder or redirected to a destination carrier.
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
