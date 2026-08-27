<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl -->
# TPERMUTE

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl`

Permute raw bytes from two Local CUBE sources by a Local U8 index Tile.

## Normative identity {#PTO-INST-TILE-TPERMUTE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpermute-purpose role=purpose -->
**Why use it.** `TPERMUTE` provides a two-source byte table within each CUBE CELL so every valid destination byte can be chosen independently without interpreting the payload numerically.

<!-- PTO-READER-BLOCK: tile-tpermute-mechanism role=mechanism -->
**How it works.** The lookup resets at every CUBE CELL: its per-source table width is `4` bytes for `CUBE_M32` and `8` bytes for `CUBE_M16`; indices below that width select the same CELL in `source0`, and the following equal-sized range selects the same CELL in `source1`.

<!-- PTO-READER-BLOCK: tile-tpermute-inputs-outputs role=inputs-outputs -->
**Inputs and result.** The two Local data sources have the same supported non-64-bit dtype, CUBE layout, and geometry, while the matching Local `U8` index Tile supplies one index for every valid destination byte and the destination is fresh.

<!-- PTO-READER-BLOCK: tile-tpermute-effects role=effects -->
**Effects.** All indices and selected source bytes are validated and read before the complete valid destination region is published; the sources and index Tile persist, padding is `Null`, and there is no memory effect.

<!-- PTO-READER-BLOCK: tile-tpermute-constraints role=constraints -->
**What is rejected.** Each index must be below the combined per-CELL bound—`8` for `CUBE_M32` or `16` for `CUBE_M16`; an out-of-range index, an undefined selected byte, mismatched layout, dtype, or geometry, aliasing between the index Tile and either source, or destination aliasing rejects before any destination effect.

<!-- PTO-READER-BLOCK: tile-tpermute-example role=example -->
**Concrete example.** For one `CUBE_M32` row with source words `0x04030201` and `0x08070605`, byte indices `[0, 4, 1, 5]` produce destination word `0x06020501`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TPERMUTE <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPERMUTE | TEPL | 0x075 | 21 | 3 | TPERMUTE |

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
| source2 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl -->
```asl
readonly func InstructionContractOperation_TPERMUTE() => TileOperation
begin
    return TileOperation_TPERMUTE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPERMUTE, DataType
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source0, source1
B.IOT indices, ->destination
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl -->
```asl
readonly func InstructionContractHandler_TPERMUTE() => TileSemanticHandler
begin
    return TileHandler_TPERMUTE;
end;

pure func InstructionContractDataTypeLegal_TPERMUTE(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           TileElementBits(data_type) != 64;
end;

readonly func InstructionContractOperandsLegal_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TPERMUTE(destination, source0, source1, indices);
end;

func InstructionContractExecute_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TPERMUTE(
        destination, source0, source1, indices);
    TPERMUTE(destination, source0, source1, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.DATR has no effect other than selecting CUBE_M16 or CUBE_M32; padding and numeric fields remain zero.
- A nonzero PE mask requires two ordered B.IOT bindings and no B.IOR.

## Legality

- TPERMUTE accepts only Local CUBE_M16 or CUBE_M32 data Tiles with matching dtype and geometry.
- indices is Local U8 with the same CUBE layout and supplies one byte index for every valid destination byte.
- The destination is fresh; source0 and source1 may alias, while indices is distinct from both sources.
- Raw bytes are rearranged without numerical conversion.

## State effects

- Perform per-row two-source raw-byte table lookup and publish only the destination valid region.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All index legality and source reads precede destination publication.

## Exceptions

- Illegal raw indices reject before any destination effect with Fault_TileLegality.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TPERMUTE, U32; B.DATR Layout; B.IOT source0, source1; B.IOT indices, ->destination; BSTOP
