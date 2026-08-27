<!-- GENERATED FROM: asl/block/operands/B.ASSEMBLE.asl -->
# B.ASSEMBLE

**Normative ASL source:** `asl/block/operands/B.ASSEMBLE.asl`

Decodes one destination-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.

## Normative identity {#PTO-INST-BLOCK-B-ASSEMBLE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-assemble-purpose role=purpose -->
## What B.ASSEMBLE contributes

`B.ASSEMBLE` is a 32-bit block header command that attaches one assembler-range modifier to an open Local or Shared binder group. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-assemble-mechanism role=mechanism -->
## Placement and mechanism

The modifier is valid only while it remains contiguous with the `B.IOT` or `B.IOS` binder group that opened its carrier. Intervening, reversed, or duplicate modifiers are rejected before carrier state changes.

The command records its raw selector and range fields in the open binder carrier together with the derived XLEN offset. A binder whose decoded PE mask is zero keeps only a discarded syntactic group and performs no source read or role effect.

<!-- PTO-READER-BLOCK: block-b-assemble-inputs role=inputs-outputs -->
## Operands and header roles

- `INIT` marks the first assembler carrier; its exact assigned domain remains in the generated contract below.
- `LAST` marks the final assembler carrier; its exact assigned domain remains in the generated contract below.
- `RegSrc` selects the named absolute GPR role; its exact assigned domain remains in the generated contract below.
- `uimm11` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.
- `ParentSizeCode` supplies the parent range size code; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-assemble-effects role=effects -->
## Pending state and completion

An accepted header command changes only its pending record or carrier. Architectural tile, Shared, GPR, memory, and completion effects remain deferred to the completed block unless this owner's contract explicitly identifies an immediate header-state update.

<!-- PTO-READER-BLOCK: block-b-assemble-constraints role=constraints -->
## Legality and fault boundary

Reserved encodings are rejected before reads or pending-state changes. Placement, duplicate, role, or completed-schema mismatches fail before body effects.

<!-- PTO-READER-BLOCK: block-b-assemble-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOT mask=PE_MASK, <last>, ->DstTile<SizeCode>
B.ASSEMBLE INIT, LAST, RegSrc, uimm11, ParentSizeCode
```

The destination form of `B.IOT` opens the exact destination carrier group. The immediately following `B.ASSEMBLE` applies its assembler range to that destination carrier; any intervening command breaks contiguity and makes the modifier group invalid.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.ASSEMBLE INIT, LAST, RegSrc, uimm11, ParentSizeCode
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_assemble_32_122000000002 | L32 | 32 | 0x00001053 / 0x0000707f | [{"field":"INIT","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"ParentSizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_assemble_32_122000000002 | INIT | 1 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":1}] |
| b_assemble_32_122000000002 | uimm11 | 11 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":11}] |
| b_assemble_32_122000000002 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_assemble_32_122000000002 | LAST | 1 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":1}] |
| b_assemble_32_122000000002 | ParentSizeCode | 4 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_assemble_32_122000000002 | INIT | 1 | 0–1 | none | none | selects INIT versus MIDDLE/LAST form | Zero selects MIDDLE/LAST rather than INIT/INIT_LAST. |
| b_assemble_32_122000000002 | uimm11 | 11 | 0–2047 | none | none | unsigned XLEN addend | Zero is a real zero displacement. |
| b_assemble_32_122000000002 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR selector | Zero names the architectural zero GPR. |
| b_assemble_32_122000000002 | LAST | 1 | 0–1 | none | none | marks the final assembler carrier | One closes the modifier sequence at the semantic assembler. |
| b_assemble_32_122000000002 | ParentSizeCode | 4 | 0–12 | none | 13–15 | raw parent size code | Zero is the MIDDLE/LAST-only no-parent-size encoding. |

- `b_assemble_32_122000000002.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_assemble_32_122000000002.ParentSizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| INIT | selects INIT versus MIDDLE/LAST form |
| LAST | marks the final assembler carrier |
| RegSrc | absolute GPR selector |
| uimm11 | unsigned XLEN addend |
| ParentSizeCode | raw parent size code |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.ASSEMBLE.asl -->
```asl
readonly func InstructionContractMatches_B_ASSEMBLE(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_assemble_32_122000000002;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.ASSEMBLE.asl -->
```asl
pure func InstructionContractParentSizeCodeIsRawLegal_B_ASSEMBLE(code: integer {0..15}) => boolean
begin
    return code <= 12;
end;

readonly func InstructionContractHandler_B_ASSEMBLE() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleAssemble;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR. INIT=0 encodes MIDDLE/LAST; INIT=1 encodes INIT/INIT_LAST.

## Legality

- RegSrc accepts only absolute GPR selectors 0..23.
- ParentSizeCode raw values 0..12 are decoded; INIT/size combinations select INIT, MIDDLE, LAST, or INIT_LAST and contradictory combinations are BundleControl.
- Local parent sizes 1..10 are accepted; Shared parent sizes 1..12 are accepted.
- The modifier is legal only in the contiguous immediately preceding binder group and follows source roles.

## State effects

- Store raw INIT/LAST/RegSrc/uimm11/ParentSizeCode and the derived XLEN offset in the destination carrier of the open binder group.
- PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality.

## Exceptions

- Reserved funct3/opcode, RegSrc24..31, and ParentSizeCode13..15 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance.
- INIT=1 with ParentSizeCode=0 or INIT=0 with a nonzero ParentSizeCode raises Fault_BundleControl.
- Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl.

## Examples

- B.IOT T0, mask=1111, ->T1<1>; B.ASSEMBLE 1, 1, a0, 0, 10
