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
## What TPERMUTE does

`TPERMUTE` builds each destination byte from one byte of two data sources, chosen by a `U8` index Tile. It works on raw bytes of Local `CUBE_M16` or `CUBE_M32` Tiles and performs no numeric conversion.

Design point: `TPERMUTE` is selected by `BSTART.SFU` with TEPL Mode 3 Function 21 (selector `0x075`) and has no standalone opcode.

<!-- PTO-READER-BLOCK: tile-tpermute-mechanism role=mechanism -->
## Byte selection rule

The row bytes of a cell are 8 for `CUBE_M16` and 4 for `CUBE_M32`. Each row's valid bytes are split into segments of that size, and each destination byte reads one index byte at the same row and byte position.

An index v below the row bytes selects byte `segment base + v` of `source0`. An index from the row bytes to twice the row bytes selects byte `segment base + v - row bytes` of `source1`.

Design point: a byte can move only within its own row and its own segment. An index of twice the row bytes or more is illegal rather than wrapped, so every accepted index names exactly one source byte.

Design point: every active destination byte is checked before any effect: its index byte must be defined and in range, and the selected source byte must be defined. A bad index rejects with `Fault_TileLegality` and leaves no partial destination. [Layout rearrangement legality](../../model/legality/layout-rearrangement.md) owns these checks.

<!-- PTO-READER-BLOCK: tile-tpermute-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

- `source0` and `source1` are the data sources. They share one type, valid shape, and layout with the destination, and they may be the same Tile.
- `source2` is the index Tile: `U8`, the same layout and valid rows, one valid column per valid destination byte, and the same cell count. It must differ from both data sources.
- `destination0` is fresh and keeps the source type, valid shape, and layout. It must differ from every source.

The data type may be any supported CUBE carrier; 64-bit carriers require `CUBE_M32` double-CELL descriptors. The first `B.IOT` carries `source0` and `source1`; the second carries the index Tile and the destination.

<!-- PTO-READER-BLOCK: tile-tpermute-effects role=effects -->
## Effects

All index checks and source reads come before publication. Every valid destination element becomes defined, and physical elements outside the valid region receive `Null` padding, which stays undefined.

Under an ExecutionMask, an inactive destination element reads no index or source byte and receives the mask's zero or merge value. The sources persist, and the operation has no memory or numeric-status effect.

<!-- PTO-READER-BLOCK: tile-tpermute-constraints role=constraints -->
## What is rejected

A non-CUBE_M16/M32 layout, a 64-bit `CUBE_M16` carrier, a mismatched type, shape, layout, or cell count, an invalid index Tile, an aliasing destination, or an undefined selected byte raises `Fault_TileLegality` before any destination effect.

A malformed binding structure raises `Fault_BundleControl`; [cell rearrangement schema](../../../block/model/dispatch/cell-rearrangement-schema.md) owns that check.

<!-- PTO-READER-BLOCK: tile-tpermute-example role=example -->
## Concrete example

Take one `U8` `CUBE_M32` row with 4 valid bytes, so the row bytes are 4 and legal indices are 0 to 7. `source0` holds bytes `0x01`, `0x02`, `0x03`, `0x04` (word `0x04030201`) and `source1` holds `0x05` to `0x08` (word `0x08070605`).

Index bytes `[0, 4, 1, 5]` select `source0` byte 0, `source1` byte 0, `source0` byte 1, and `source1` byte 1. The destination bytes are `0x01`, `0x05`, `0x02`, `0x06`, which is the word `0x06020501`. An index of 8 would reject the bundle.

In macro form, `T#1` and `T#2` are the data sources and `T#3` is the index Tile:

```text
TPERMUTE <U8>, T#1, T#2, T#3, ->T<128B>
```
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
    return TileCubeDataTypeSupported(data_type);
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

- TPERMUTE accepts Local CUBE_M16 data Tiles and Local CUBE_M32 data Tiles, including FP64/S64/U64 with matching dtype and geometry.
- indices is Local U8 with the same CUBE layout and supplies one byte index for every valid destination byte.
- The destination is fresh; source0 and source1 may alias, while indices is distinct from both sources.
- Raw bytes are rearranged without numerical conversion, preserving each M32 64-bit element as two 32-bit CELL groups.

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
