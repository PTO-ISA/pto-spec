<!-- GENERATED FROM: asl/tile/model/execution/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/execution/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","execution","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT"]}

func TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert TileOperandsLegal_TGATHER(destination, source, indices);
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    var result = _Tiles[[destination]];
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let index_element = TileLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let source_row = TileIndexedRowValue(
                index_payload[[index_element]],
                index_tile.data_type);
            let source_element = TileLinearIndex(
                source_tile,
                source_row as integer {0..65535},
                column as integer {0..65535});
            let destination_element = TileLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result.payload[[destination_element]] =
                source_payload[[source_element]];
            result.defined_elements[destination_element] = '1';
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..16384};
    result.contents_defined = TRUE;
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert TileOperandsLegal_TSCATTER(destination, source, indices);
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    var result = _Tiles[[destination]];
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result.payload[[destination_element]] = Zeros{PTO_XLEN};
            result.defined_elements[destination_element] = '1';
        end;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let index_element = TileLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let destination_row = TileIndexedRowValue(
                index_payload[[index_element]],
                index_tile.data_type);
            let destination_element = TileLinearIndex(
                result,
                destination_row as integer {0..65535},
                column as integer {0..65535});
            result.payload[[destination_element]] =
                source_payload[[source_element]];
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..16384};
    result.contents_defined = TRUE;
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
