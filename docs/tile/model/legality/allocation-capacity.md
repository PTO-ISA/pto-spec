<!-- GENERATED FROM: asl/tile/model/legality/allocation-capacity.asl -->
# Allocation Capacity

**Normative ASL source:** `asl/tile/model/legality/allocation-capacity.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-purpose role=purpose-scope -->
## Purpose and scope

Despite its name, this unit does not check allocation capacity. It defines four read-only payload predicates. Each one inspects source element values during preflight and returns FALSE when a value would make the operation illegal. Preflight is the checking phase that runs before an operation reads its snapshots or writes anything.

- `TilePayloadNonzero` checks that a divisor Tile has no zero element.
- `TileBroadcastPayloadNonzero` checks a row or column broadcast divisor.
- `TileIndexPayloadWithin` checks that element indices are below an extent.
- `TileByteOffsetPayloadWithin` checks that byte offsets are aligned and in range.

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-concepts role=concepts-state -->
## Concepts and visible state

The predicates read `_Tiles`, the element definedness state, and, for `TilePayloadNonzero`, the bundle ExecutionMask `_BundleExecutionMask`. An ExecutionMask is a per-bundle carrier that marks each coordinate of the valid region as active or inactive.

They iterate over the valid region, `valid_rows` by `valid_columns`. Elements outside the valid region are not read.

An element counts as zero when `IsZero` holds for its raw bits. The index and offset checks treat each element as an unsigned integer with `UInt`.

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-rules role=rules-interactions -->
## Rules and interactions

`TilePayloadNonzero` has two modes.

- Without an ExecutionMask, the source must satisfy `TileSourceContentsDefined`, and every valid element must be defined and nonzero. Because `TileDescriptorLegal` rejects CUBE layouts, a CUBE divisor always fails this branch.
- With an ExecutionMask, the source must pass `TileCubeDescriptorLegal` and match the mask's layout, `valid_rows`, and `valid_columns`. Only active coordinates are then checked; each must be defined and nonzero.

Design point: under an ExecutionMask the zero test skips inactive coordinates. A divisor may contain zero in a coordinate the mask disables, because that coordinate is never divided. A non-CUBE source fails the ExecutionMask branch, because `TileCubeDescriptorLegal` requires a CUBE layout.

`TileOperandsLegal_ExecuteTileBinary` calls `TilePayloadNonzero` on the right source when the operation is `TileBinary_DIV` or `TileBinary_REM` and the operation type is an integer type. `TDIV` and `TREM` reach this path. A FALSE result makes the generated dispatcher raise `Fault_TileLegality` before `ExecuteTileBinary` snapshots the sources or writes the destination; any destination the bundle already allocated is rolled back.

Design point: the integer divide helper `TileIntegerDivRemValue` asserts a nonzero divisor, so a zero divisor must be rejected by legality rather than reach execution. Floating types skip this check; a floating zero divisor is handled by the floating numeric helpers. A rejected `TDIV` leaves no new destination allocation, because the bundle rolls it back.

`TileIndexPayloadWithin` requires defined contents and every valid element to be below `extent`. `TileByteOffsetPayloadWithin` requires every offset to be a multiple of the source element size and, after division by that size, below the source's `valid_rows` x `valid_columns`. `TileBroadcastPayloadNonzero` requires both Tiles to be defined and reads the broadcast Tile at column 0 for a row broadcast, or at row 0 for a column broadcast.

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-boundaries role=boundaries -->
## Architectural boundaries

A grep of `asl/` finds no caller of `TileBroadcastPayloadNonzero`, `TileIndexPayloadWithin`, or `TileByteOffsetPayloadWithin`. They are defined here but do not currently gate any instruction.

These predicates do not raise faults themselves. The caller chooses the fault. They also do not check allocation capacity or the PE pool; that belongs to the Local capacity unit.

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-example role=example-usage -->
## Non-normative reading example

Consider `TDIV` with S32 and a divisor Tile whose valid region is 2 rows by 3 columns, with values `4 7 0` in row 0 and `1 2 3` in row 1.

- No ExecutionMask is present, so all 6 valid elements are checked.
- Row 0, column 2 holds 0, so `TilePayloadNonzero` returns FALSE.
- The bundle is rejected with `Fault_TileLegality`; the destination is never written, and its allocation is rolled back.

If an ExecutionMask on a CUBE form made that coordinate inactive, only the 5 active elements would be checked, and the check would pass.

<!-- PTO-READER-BLOCK: tile-model-legality-allocation-capacity-related role=related-owners-navigation -->
## Related owners

- [Operand schema](operand-schema.md) calls `TilePayloadNonzero` for integer `TDIV` and `TREM`.
- [Descriptor shape](descriptor-shape.md) owns `TileSourceContentsDefined` and `TileCubeDescriptorLegal`.
- [ExecutionMask state](../execution/execution-mask-state.md) owns the active-coordinate test.
- [Element definedness](../definedness/elements.md) owns `TileElementDefined` and logical indexing.
- [Local capacity](../capacity/local.md) owns the actual capacity checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/allocation-capacity.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY","surface":"tile","classification":["model","legality","allocation-capacity"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func TilePayloadNonzero(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !_BundleExecutionMask.valid then
        if !TileSourceContentsDefined(index) then return FALSE; end;
    elsif !TileCubeDescriptorLegal(tile) ||
          tile.layout != _BundleExecutionMask.layout ||
          tile.valid_rows != _BundleExecutionMask.valid_rows ||
          tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                if !TileElementDefined(index, row as integer {0..65535},
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if IsZero(TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileBroadcastPayloadNonzero(axis: TileAxis, source: TileIndex,
                                           broadcast: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(broadcast) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let element = TileLogicalLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            if IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileIndexPayloadWithin(index: TileIndex, extent: integer) => boolean
begin
    if !TileSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if UInt(TileReadLogicalElement(tile, element)) >= extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileByteOffsetPayloadWithin(offsets: TileIndex,
                                           source: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(offsets) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let offsets_tile = _Tiles[[offsets]];
    let element_bytes = TileElementBytes(_Tiles[[source]].data_type);
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    for row = 0 to offsets_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to offsets_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(offsets_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let byte_offset = UInt(TileReadLogicalElement(
                offsets_tile, element));
            if byte_offset MOD element_bytes != 0 ||
               byte_offset DIV element_bytes >= source_extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
