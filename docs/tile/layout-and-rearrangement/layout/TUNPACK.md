<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
# TUNPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TUNPACK.asl`

Extract selected byte fields from 8/16/32-bit and M32 64-bit Local CUBE source carriers into U8/U16/U32/U64 destination words.

## Normative identity {#PTO-INST-TILE-TUNPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tunpack-purpose role=purpose -->
## What TUNPACK does

`TUNPACK` extracts one contiguous byte field from every participating 32-bit word of a Local CUBE source and places it in the low bytes of a destination word. It rearranges raw bytes and performs no numeric conversion.

Design point: `TUNPACK` is selected by `BSTART.SFU` with TEPL Mode 3 Function 24 (selector `0x078`). The `BSTART` type, `U8`, `U16`, `U32`, or `U64`, is the destination type; the source backing type need not equal it.

<!-- PTO-READER-BLOCK: tile-tunpack-mechanism role=mechanism -->
## Extraction rule

The control word gives a byte offset in bits 7 to 0 and a byte count in bits 15 to 8. For word w of each row, destination bytes 0 to count-1 receive source bytes `4w + offset` onward, and every remaining destination byte is zero.

Design point: the span rule is checked for every word, including a partial last word, whether or not the ExecutionMask makes it active. `offset + count` must fit inside each word's valid bytes, so a field never reads past the valid data of a row.

Only selected bytes are read, and each selected byte of a participating word must belong to a defined element. Unselected valid bytes and physical padding are never read.

<!-- PTO-READER-BLOCK: tile-tunpack-inputs-outputs role=inputs-outputs -->
## Inputs and result

- `source0` is a Local numeric CUBE Tile with non-packed 8-, 16-, 32-, or M32 64-bit elements.
- `scalar0` is the unpack control word from one `B.IOR`; RegSrc1, RegSrc2, and RegDst are zero.
- `destination0` is fresh. U8/U16/U32 use 4/2/1 elements per raw word. U64 requires `CUBE_M32`, an even raw-word count, and one logical column per complete low/high pair.

Like `TPACK`, the destination shape is derived from the source descriptor rather than from `B.DIM`.

<!-- PTO-READER-BLOCK: tile-tunpack-effects role=effects -->
## Effects

Control and source validation precede publication. Each participating source word produces one complete destination word, every valid destination element becomes defined, and padding is `Null`.

Under an ExecutionMask, one mask bit at (row, word index) gates the whole destination word group; an inactive group reads no source byte and receives the mask's zero or merge value. The source persists, and the operation has no memory or numeric-status effect.

<!-- PTO-READER-BLOCK: tile-tunpack-constraints role=constraints -->
## What is rejected

The offset must be 0 to 3, the count 1 to 4, and `offset + count` at most 4; control bits `63:32` must be zero. An unsupported storage, layout, or source width, a field outside a word's valid bytes, a destination that aliases the source, or an undefined selected byte raises `Fault_TileLegality` before effects.

<!-- PTO-READER-BLOCK: tile-tunpack-example role=example -->
## Concrete example

Source word `0x44332211` with control `0x00000201` selects two bytes starting at byte offset `1`, which are `0x22` and `0x33`. The destination word is `0x00003322`.

A `U8` `CUBE_M16` source with 6 valid columns has 6 valid bytes per row: word 0 has 4 and word 1 has 2. Control `0x00000200` (offset 0, count 2) is legal, and a `U16` destination gets 2 x 2 = 4 valid columns. Control `0x00000201` is rejected, because offset 1 plus count 2 exceeds the 2 valid bytes of word 1.

```text
TUNPACK <U16>, T#1, a0, ->T<128B>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TUNPACK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TUNPACK | TEPL | 0x078 | 24 | 3 | TUNPACK |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | unpack-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
```asl
readonly func InstructionContractOperation_TUNPACK() => TileOperation
begin
    return TileOperation_TUNPACK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TUNPACK, U8/U16/U32/U64
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source, ->destination
B.IOR unpack_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
```asl
readonly func InstructionContractHandler_TUNPACK() => TileSemanticHandler
begin
    return TileHandler_TUNPACK;
end;

pure func InstructionContractDataTypeLegal_TUNPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U64;
end;

readonly func InstructionContractOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TUNPACK(destination, source, control);
end;

func InstructionContractExecute_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TUNPACK(destination, source, control);
    TUNPACK(destination, source, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TUNPACK accepts Local Numeric CUBE_M16 or CUBE_M32 source backing with non-packed 8/16/32-bit or M32 64-bit elements.
- BSTART selects U8, U16, U32, or U64 for the fresh destination. The control selects a contiguous byte field within each independent 32-bit source word.
- Only selected source bytes are read. Every selected interval is inside its word logical valid-byte span and every selected byte has a defined containing element; each participating word produces one zero-filled result word; U64 joins complete low/high pairs and rejects odd tails.

## State effects

- Extract the selected byte field independently from each participating 32-bit raw-word slot, zero-fill the remainder, and publish one complete destination word per source word.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Unsupported storage, layout, or backing width; a selected interval outside a source word logical valid-byte span; an undefined selected byte; or illegal offset/count fields reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TUNPACK, U8/U16/U32/U64; B.DATR Layout; B.DIM LB0; B.IOT source, ->destination; B.IOR a0; BSTOP
