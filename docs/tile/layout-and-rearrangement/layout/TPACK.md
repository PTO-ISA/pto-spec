<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
# TPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TPACK.asl`

Pack selected raw byte prefixes from 8/16/32-bit and M32 64-bit Local CUBE source carriers into U8/U16/U32/U64 destination words.

## Normative identity {#PTO-INST-TILE-TPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpack-purpose role=purpose -->
## What TPACK does

`TPACK` joins low-byte fields from corresponding 32-bit words of two Local CUBE sources into one destination word. It rearranges raw bytes and performs no numeric conversion.

Design point: `TPACK` is selected by `BSTART.SFU` with TEPL Mode 3 Function 23 (selector `0x077`). The `BSTART` type, `U8`, `U16`, `U32`, or `U64`, is the destination type; it need not match the source types.

<!-- PTO-READER-BLOCK: tile-tpack-mechanism role=mechanism -->
## Packing rule

Each source row is read as raw words: the valid bytes of the row, `ValidCol x element bits / 8` rounded up, are grouped into 32-bit words, and the last word may be partial.

The control word gives n0 in bits 7 to 0 and n1 in bits 15 to 8. For word w of each row, destination bytes 0 to n0-1 receive the low n0 bytes of `source0` word w, the next n1 bytes receive the low n1 bytes of `source1` word w, and every remaining destination byte is zero.

Design point: only selected bytes are read. Each selected byte of a participating word must lie inside its word's valid bytes and belong to a defined element; unselected bytes, including physical padding, are never read, so their definedness does not matter.

<!-- PTO-READER-BLOCK: tile-tpack-inputs-outputs role=inputs-outputs -->
## Inputs and result

- `source0` and `source1` are Local numeric CUBE Tiles with non-packed 8-, 16-, 32-, or M32 64-bit elements. They share one layout, the same valid rows, and the same number of raw 32-bit words per row; their types may differ.
- `scalar0` is the pack control word from one `B.IOR`; RegSrc1, RegSrc2, and RegDst are zero.
- `destination0` is fresh. U8/U16/U32 use 4/2/1 elements per raw word. U64 requires `CUBE_M32`, an even raw-word count, and one logical column per complete low/high pair.

Design point: the destination shape is derived from the source descriptors, not from `B.DIM`. The macro form therefore has no shape fields, and a static disassembler cannot print Row or Col.

<!-- PTO-READER-BLOCK: tile-tpack-effects role=effects -->
## Effects

Control and source validation precede publication. Each paired source word produces one complete destination word, every valid destination element becomes defined, and padding is `Null`.

Under an ExecutionMask, raw words are gated independently. For U64, the low and high word bits may differ; each active half is packed independently and the two halves are joined into one coherent 64-bit publication, with an inactive half supplied by ZERO or MERGE.

<!-- PTO-READER-BLOCK: tile-tpack-constraints role=constraints -->
## What is rejected

Each field width must be from `1` through `3`, their sum must not exceed `4`, and control bits `63:32` must be zero. An unsupported storage, layout, or source width, unequal word counts, a destination that aliases a source, or an undefined selected byte also raises `Fault_TileLegality` before destination effects.

<!-- PTO-READER-BLOCK: tile-tpack-example role=example -->
## Concrete example

With corresponding source words `0x00001234` and `0x00ABCDEF`, control `0x00000202` selects two low bytes from each. The destination bytes are `0x34`, `0x12`, `0xEF`, `0xCD`, which is the word `0xCDEF1234`.

With `U32` `CUBE_M16` sources of 8 valid rows and 8 valid columns, each row holds 32 bytes, which is 8 words. A `U32` destination therefore has 8 valid rows and 8 valid columns; a `U16` destination would have 16 valid columns.

```text
TPACK <U32>, T#1, T#2, a0, ->T<2KB>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TPACK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPACK | TEPL | 0x077 | 23 | 3 | TPACK |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source0 |
| source1 | source1 |
| scalar0 | pack-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
```asl
readonly func InstructionContractOperation_TPACK() => TileOperation
begin
    return TileOperation_TPACK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPACK, U8/U16/U32/U64
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source0, source1, ->destination
B.IOR pack_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
```asl
readonly func InstructionContractHandler_TPACK() => TileSemanticHandler
begin
    return TileHandler_TPACK;
end;

pure func InstructionContractDataTypeLegal_TPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U64;
end;

readonly func InstructionContractOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TPACK(destination, source0, source1, control);
end;

func InstructionContractExecute_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TPACK(
        destination, source0, source1, control);
    TPACK(destination, source0, source1, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TPACK accepts Local Numeric CUBE_M16 or CUBE_M32 source backing with non-packed 8/16/32-bit or M32 64-bit elements; source layouts and valid rows match and RawWordSlotsPerRow is equal.
- BSTART selects U8, U16, U32, or U64 for the fresh destination. The control selects low-byte prefixes of 1..3 bytes per source word with total width at most four.
- Only selected source bytes are read. Each selected byte is logically valid and its containing element is defined; each paired 32-bit word produces one zero-filled result word; U64 joins complete low/high pairs and rejects odd tails.

## State effects

- Pair corresponding 32-bit raw-word slots independently in each row, assemble the selected low-byte prefixes, and zero every unselected destination byte.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Unsupported storage, layout, or backing width; unequal raw-word counts; an out-of-span or undefined selected byte; or illegal field widths reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TPACK, U8/U16/U32/U64; B.DATR Layout; B.IOT source0, source1, ->destination; B.IOR a0; BSTOP
