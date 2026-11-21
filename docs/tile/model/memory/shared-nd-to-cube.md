<!-- GENERATED FROM: asl/tile/model/memory/shared-nd-to-cube.asl -->
# Shared Nd To CUBE

**Normative ASL source:** `asl/tile/model/memory/shared-nd-to-cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-ND-TO-CUBE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-purpose role=purpose-scope -->
## Purpose and scope

This unit materializes one selected row-major Shared ND fragment as a detached Local CUBE value.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-concepts role=concepts-state -->
## Concepts and state

`SharedNDToCubeFragment` records the origin row, valid region, physical shape, capacity, data type, and target CUBE layout. An empty fragment is explicitly invalid.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-rules role=rules-interactions -->
## Rules and interactions

`TMOVSharedNDToCubeToValue` first clears the destination physical region to undefined zero, then copies each defined source coordinate from the fragment window and marks the valid result defined.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-boundaries role=boundaries -->
## Architectural boundaries

The caller supplies a valid fragment and matching destination descriptor. This helper does not choose the fragment, publish Shared state, or make padding elements defined.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-example role=example-usage -->
## Non-normative reading example

A fragment starting at source row 8 with four valid rows copies rows 8 through 11 into destination rows 0 through 3 while leaving destination padding undefined.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-nd-to-cube-related role=related-owners-navigation -->
## Related owners

- [Related owner](shared-movement-values.md) defines related Shared-to-Local value-copy conventions and definedness handling.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-nd-to-cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-ND-TO-CUBE","surface":"tile","classification":["model","memory","shared-nd-to-cube"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-STATE-TYPES"]}

type SharedNDToCubeFragment of record {
    valid: boolean,
    origin_row: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    capacity_bytes: integer {0..262144},
    data_type: TileDataType,
    layout: TileLayout
};

pure func EmptySharedNDToCubeFragment() => SharedNDToCubeFragment
begin
    return SharedNDToCubeFragment {
        valid = FALSE,
        origin_row = 0,
        valid_rows = 0,
        valid_columns = 0,
        physical_rows = 0,
        physical_columns = 0,
        capacity_bytes = 0,
        data_type = TileDataType_U8,
        layout = TileLayout_CUBE_M32
    };
end;

// Read only selected valid coordinates from a published Shared ND source.
// Destination padding is deterministic raw zero and remains undefined.
func TMOVSharedNDToCubeToValue(
    destination: TileInfo,
    shared_tile_id: SharedTileID,
    source_parent: TileInfo,
    fragment: SharedNDToCubeFragment) => TileInfo
begin
    assert fragment.valid && fragment.valid_rows > 0 &&
           fragment.valid_columns > 0 &&
           destination.layout == fragment.layout &&
           destination.data_type == fragment.data_type &&
           destination.capacity_bytes == fragment.capacity_bytes &&
           destination.rows == fragment.physical_rows &&
           destination.columns == fragment.physical_columns &&
           destination.valid_rows == fragment.valid_rows &&
           destination.valid_columns == fragment.valid_columns;
    var result = destination;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result, element,
                Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    for row = 0 to fragment.valid_rows - 1 looplimit 65536 do
        for column = 0 to fragment.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_parent,
                (fragment.origin_row + row) as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(source_parent, source_element);
            let value = ReadSharedTileWord(shared_tile_id, source_element);
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result,
                destination_element, value, TRUE);
        end;
    end;
    result.defined_valid_elements =
        (fragment.valid_rows * fragment.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
