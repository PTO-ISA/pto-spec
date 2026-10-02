<!-- GENERATED FROM: asl/tile/model/memory/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/tile/model/memory/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-addressing-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the pure address arithmetic that turns a Tile element or an index value into a global-memory (GM) byte address. It performs no access, probe, or fault itself.

It defines three kinds of helper:

- Element-size helpers: `TileMemoryElementBytes` gives the access width of one element in memory.
- Scaled-index helpers: `TileMemoryElementAddress` and `TileMemoryIndexedAddress` multiply an element number by the element width.
- Byte-displacement helpers: `TileIndexByteDisplacement` and `TileMemoryByteDisplacementAddress` add an index value to a base address as raw bytes.

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-concepts role=concepts-state -->
## Concepts and visible state

A base address is an XLEN `Word`, usually read from the GPR selected by `B.IOR`. All address sums use `Word` arithmetic, so they wrap modulo 2^64.

A four-bit type is one of E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 (`TileDataTypeIsFourBit`). Two such elements share one byte. For these types `TileMemoryElementBytes` returns 1, because memory is accessed in whole bytes; `TileInfo` capacity still counts them packed.

A nibble selector says which half of that byte an element uses. `TileMemoryElementHighNibble` and `TileMemoryIndexedHighNibble` return TRUE for an odd element number or odd index, and always FALSE for types that are not four-bit.

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-rules role=rules-interactions -->
## Rules and interactions

Scaled addressing: for a type that is not four-bit, the offset is `element * TileElementBytes(data_type)`. For a four-bit type, the offset is the element number divided by 2 (rounded down), and the low bit picks the nibble. `TileMemoryIndexedAddress` uses this rule for an index word; `TPREFETCHCore` calls it with the strided element index from `TileMemoryStridedIndex`.

Byte-displacement addressing: `TileIndexByteDisplacement` reads the index at the width of its integer type. Signed types (S4X2, S8, S16, S32) sign-extend, unsigned types (U4X2, U8, U16, U32) zero-extend, and S64 and U64 are used as is. The result is added to the base with no scaling. A non-integer index type fails the assertion.

The indexed TLSU forms (`MGATHER`, `MSCATTER`, their MASK forms, `MGATHER_CAS`, and the GM atom/red family) use the byte-displacement rule. Their operand legality accepts only S32, U32, S64, and U64 index Tiles (`IndexedTLSUMemoryIndexDataTypeLegal`); the smaller cases in `TileIndexByteDisplacement` are not reachable through that legality.

Design point: NDF `PTO-INDEXED-TLSU-STRIDE-001` requires indexed TLSU to treat each index as a byte displacement and forbids scaling it, splitting it by `ValidCol`, or applying an implicit row stride. The consequence is that one index Tile can address elements of any width, and software must multiply by the element size itself. If the resulting address is not a multiple of the element width, the later probe reports an alignment fault.

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-boundaries role=boundaries -->
## Architectural boundaries

These helpers only compute addresses. Alignment, permission, and range checks happen in `ProbeTileMemoryAccess` in the load-store unit, which probes with the width from `TileMemoryElementBytes`.

Dense `TLOAD` and `TSTORE` do not use these helpers for rows; they use the byte row stride in the stride unit.

`TileMemoryElementAddress`, `TileMemoryElementHighNibble`, and `TileMemoryIndexedHighNibble` have no caller in the current ASL outside this unit.

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-example role=example-usage -->
## Non-normative reading example

Take base address `0x1000` and an index element whose low 32 bits are `0xFFFFFFF8`.

- As an S32 index, `TileIndexByteDisplacement` sign-extends it to -8, so the address is `0x1000 - 8 = 0xFF8`.
- As a U32 index, it zero-extends, so the address is `0x1000 + 0xFFFFFFF8 = 0x100000FF8`.

Now take `TileMemoryIndexedAddress` with base `0x2000` and index 5.

- For FP16 the offset is 5 x 2 = 10 bytes, so the address is `0x200A`.
- For U4X2 the offset is 5 / 2 = 2 bytes, so the address is `0x2002`, and index bit 0 is 1, so the element is the high nibble.

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-related role=related-owners-navigation -->
## Related owners

- [Stride](stride.md) owns row-strided addresses for `TLOAD`, `TSTORE`, and `TPREFETCH`.
- [Load and store](load-store.md) owns the probe and the byte-level load and store helpers.
- [Gather and scatter](gather-scatter.md) and [GM atom/red execution](gm-atom-red-execution.md) are the byte-displacement users.
- [Indexed layout legality](../legality/indexed-layout.md) owns the accepted index types.
- [Global memory access](../../../arch/memory-model/global-memory-access.md) owns the GM address space.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ADDRESSING","surface":"tile","classification":["model","memory","addressing"],"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}
// NDF-BEGIN: PTO-INDEXED-TLSU-STRIDE-001
// ndf: kind=executable level=L3 layer=tile status=accepted
// Indexed TLSU MUST interpret S32, U32, S64, and U64 IndexTile elements as
// logical element indices. Signed values MUST sign-extend and unsigned values
// MUST zero-extend before scaling by the accessed transfer element width and
// adding to BaseGPR. Indexed TLSU MUST NOT decompose the index by ValidCol or
// consume an implicit row stride.
// NDF-END: PTO-INDEXED-TLSU-STRIDE-001
pure func TileMemoryElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    // PTO-v0 TLSU exposes four-bit elements through byte-sized containing
    // accesses. Tile capacity remains packed in TileInfo.
    if TileDataTypeIsFourBit(data_type) then return 1;
    else return TileElementBytes(data_type);
    end;
end;

readonly func TileMemoryElementAddress(base_address: Word,
                                       element: ModelTileElementIndex,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let offset = (element DIVRM 2) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    else
        let element_bytes = TileElementBytes(data_type);
        let offset = (element * element_bytes) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    end;
end;

readonly func TileMemoryIndexedAddress(base_address: Word,
                                       index_value: Word,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        return base_address + ZeroExtend{PTO_XLEN}(index_value[63:1]);
    else
        let element_bytes = TileElementBytes(data_type);
        let byte_width = NaturalToWord(element_bytes as integer {0..262144});
        return base_address + MultiplyWord(index_value, byte_width);
    end;
end;

readonly func TileMemoryElementHighNibble(element: ModelTileElementIndex,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && element MOD 2 == 1;
end;

readonly func TileMemoryIndexedHighNibble(index_value: Word,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && index_value[0] == '1';
end;

pure func TileIndexByteDisplacement(index_value: Word,
                                    index_data_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(index_data_type);
    case index_data_type of
        when TileDataType_S4X2 =>
            return SignExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_S8 =>
            return SignExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_S16 =>
            return SignExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_S32 =>
            return SignExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_S64 => return index_value;
        when TileDataType_U4X2 =>
            return ZeroExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_U8 =>
            return ZeroExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_U16 =>
            return ZeroExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_U32 =>
            return ZeroExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_U64 => return index_value;
        otherwise => unreachable;
    end;
end;

pure func TileMemoryByteDisplacementAddress(
    base_address: Word, index_value: Word,
    index_data_type: TileDataType, data_type: TileDataType) => Word
begin
    let logical_index = TileIndexByteDisplacement(index_value, index_data_type);
    if TileDataTypeIsFourBit(data_type) then
        let byte_index = if TileDataTypeIsSigned(index_data_type) then
            SignExtend{PTO_XLEN}(logical_index[63:1])
        else ZeroExtend{PTO_XLEN}(logical_index[63:1]);
        return base_address + byte_index;
    end;
    let element_bytes = NaturalToWord(
        TileMemoryElementBytes(data_type) as integer {0..262144});
    return base_address + MultiplyWord(logical_index, element_bytes);
end;
```
<!-- GENERATED-ASL-END: unit -->
