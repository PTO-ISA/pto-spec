<!-- GENERATED FROM: asl/tile/model/memory/stride.asl -->
# Stride

**Normative ASL source:** `asl/tile/model/memory/stride.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-STRIDE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-stride-purpose role=purpose-scope -->
## Purpose and scope

This unit owns row-strided GM addressing for Tile transfers. A row stride is the distance between the start of one Tile row in memory and the start of the next.

It defines four helpers:

- `TileMemoryStridedByteAddress` computes the byte address of `(row, column)` from a byte row stride.
- `TileMemoryStridedByteHighNibble` selects the nibble for four-bit types.
- `TileDenseRowStrideBytes` computes the dense row width in bytes.
- `TileMemoryStridedIndex` computes an element index from a row stride counted in elements.

<!-- PTO-READER-BLOCK: tile-model-memory-stride-concepts role=concepts-state -->
## Concepts and visible state

There are two stride units in this unit, and they must not be mixed.

- A byte row stride (`row_stride_bytes`) is used by `TLOAD`, `TSTORE`, and the Shared transfer helpers.
- An element row stride (`row_stride_elements`) is used by `TPREFETCH` through `TileMemoryStridedIndex`, whose result is then scaled by `TileMemoryIndexedAddress`.

A four-bit type (E2M1X2, E1M2X2, HiF4X2, S4X2, U4X2) packs two elements per byte. Its row base is still a whole byte; the column picks a byte and a nibble inside the row.

<!-- PTO-READER-BLOCK: tile-model-memory-stride-rules role=rules-interactions -->
## Rules and interactions

For a type that is not four-bit, `TileMemoryStridedByteAddress` returns `base + row * row_stride_bytes + column * TileElementBytes(data_type)`.

For a four-bit type it returns `base + row * row_stride_bytes + column / 2` (rounded down). `TileMemoryStridedByteHighNibble` is TRUE for an odd column of a four-bit type and FALSE otherwise.

`TileDenseRowStrideBytes` returns `columns * TileElementBytes(data_type)` for types that are not four-bit, and `(columns + 1) / 2` rounded down for four-bit types. The block operand resolver uses it as the `TLOAD` and `TSTORE` row stride when `B.IOR` is omitted, with the resolved physical column count.

`TileMemoryStridedIndex` returns `row * row_stride_elements + column`. All products and sums use `Word` arithmetic and wrap modulo 2^64.

Design point: the byte row stride is added as bytes and is not multiplied by the element size a second time (ADR-MEM-0008 records this decision). The consequence is that a row pitch that is not a multiple of the element size can be expressed. Whether such an address is legal is decided later by the alignment probe in the load-store unit.

Design point: a four-bit row starts on a byte boundary. For an odd physical column count, the dense stride rounds up, so the unused high nibble of the last byte in a row does not belong to the next row.

<!-- PTO-READER-BLOCK: tile-model-memory-stride-boundaries role=boundaries -->
## Architectural boundaries

These helpers compute addresses only. They do not probe, fault, or record memory events.

Omission of `B.IOR` and an encoded zero register are different: an encoded zero selector reads the zero GPR and gives a real stride of 0, so every row accesses the same memory. Only omission selects the dense default. The decoding of `B.IOR` is owned by the block operand resolver, not by this unit.

`TPREFETCH` keeps an element-count stride. When its `B.IOR` is omitted, the prefetch dispatcher supplies the physical column count as the element stride.

<!-- PTO-READER-BLOCK: tile-model-memory-stride-example role=example-usage -->
## Non-normative reading example

A `TLOAD` of FP16 with base `0x1000` and `row_stride_bytes = 64` reads element `(2, 3)` at `0x1000 + 2 x 64 + 3 x 2 = 0x1000 + 128 + 6 = 0x1086`.

A U4X2 Tile with 5 physical columns has a dense stride of `(5 + 1) / 2 = 3` bytes. Element `(1, 3)` from base `0x2000` is at `0x2000 + 1 x 3 + 3 / 2 = 0x2004`, in the high nibble because column 3 is odd.

For FP16 with 5 columns the dense stride is `5 x 2 = 10` bytes.

<!-- PTO-READER-BLOCK: tile-model-memory-stride-related role=related-owners-navigation -->
## Related owners

- [Addressing](addressing.md) owns element-scaled and byte-displacement addresses.
- [Load and store](load-store.md) owns `TLOAD` and `TSTORE`, which use the byte row stride.
- [Gather and scatter](gather-scatter.md) owns `TPREFETCHCore`, which uses the element row stride.
- [Shared movement](shared-movement.md) owns the Shared transfers that use per-PE byte strides.
- [TLOAD](../../memory-and-data-movement/regular/TLOAD.md) states the instruction-level stride defaults.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/stride.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-STRIDE","surface":"tile","classification":["model","memory","stride"],"depends_on":["PTO-TILE-MODEL-MEMORY-ADDRESSING"]}
readonly func TileMemoryStridedIndex(row: integer {0..65535},
                                     column: integer {0..65535},
                                     row_stride_elements: Word) => Word
begin
    return MultiplyWord(NaturalToWord(row as integer {0..262144}),
                        row_stride_elements) +
           NaturalToWord(column as integer {0..262144});
end;

pure func TileDenseRowStrideBytes(columns: integer {0..65535},
                                  data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let packed_bytes = ((columns + 1) DIVRM 2) as integer {0..32768};
        return NaturalToWord(packed_bytes as integer {0..262144});
    else
        return MultiplyWord(
            NaturalToWord(columns as integer {0..262144}),
            NaturalToWord(TileElementBytes(data_type) as
                integer {0..262144}));
    end;
end;

readonly func TileMemoryStridedByteAddress(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    let row_base = base_address + MultiplyWord(
        NaturalToWord(row as integer {0..262144}), row_stride_bytes);
    if TileDataTypeIsFourBit(data_type) then
        return row_base + NaturalToWord(
            (column DIVRM 2) as integer {0..262144});
    else
        return row_base + MultiplyWord(
            NaturalToWord(column as integer {0..262144}),
            NaturalToWord(TileElementBytes(data_type) as
                integer {0..262144}));
    end;
end;

pure func TileMemoryStridedByteHighNibble(
    column: integer {0..65535}, data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && column MOD 2 == 1;
end;
```
<!-- GENERATED-ASL-END: unit -->
