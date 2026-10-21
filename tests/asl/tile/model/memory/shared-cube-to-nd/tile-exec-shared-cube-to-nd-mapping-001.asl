// PTO-TEST: {"id":"PTO-AVS-TILE-SHARED-CUBE-TO-ND-MAPPING-001","source":"asl/tile/model/memory/shared-cube-to-nd.asl","requirements":["PTO-CUBE-M32-B64-DOUBLE-CELL-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"execution","summary":"CUBE-to-ND fragment normalization preserves M32 b64 and packed raw logical coordinates","pass_condition":"Every defined M32 b64 pair coordinate and odd-valid-column packed nibble is copied through independent row/column goldens into RowMajor ND; backing type and writer capacity remain exact, source padding remains undefined, and CUBE metadata is cleared","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/definedness/packed-boundary.asl"]}
func ConfigureSharedCubeSource(index: TileIndex, capacity: integer {512,4096},
    valid_columns: integer {13,31}, data_type: TileDataType)
begin
    let configured = ConfigureCubeTileForMask(index, capacity, 32,
        valid_columns, data_type, TileLayout_CUBE_M32, '1111');
    assert configured;
    var source = _Tiles[[index]];
    for row = 0 to 31 do
        for column = 0 to valid_columns - 1 do
            let element = TileStorageIndex(source, row, column);
            let value = if data_type == TileDataType_FP64 then
                Zeros{PTO_XLEN} + 0x1000000000000000 + row * 0x1000 + column * 7 + 1
                else Zeros{PTO_XLEN} + ((row * 3 + column * 5) MOD 16);
            source.payload[[element]] = value;
            source.defined_elements[element] = '1';
        end;
    end;
    source.defined_valid_elements = (32 * valid_columns) as
        integer {0..524288};
    source.contents_defined = TRUE;
    _Tiles[[index]] = source;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureSharedCubeSource(1, 4096, 13, TileDataType_FP64);
    let source_b64 = _Tiles[[1]];
    let normalized_b64 = SharedTileFromLocalCubeToND(1, 4096);
    assert normalized_b64.layout == TileLayout_RowMajor &&
           normalized_b64.capacity_bytes == 4096 &&
           normalized_b64.rows == 32 && normalized_b64.columns == 16 &&
           normalized_b64.valid_rows == 32 &&
           normalized_b64.valid_columns == 13 &&
           normalized_b64.data_type == TileDataType_FP64 &&
           normalized_b64.cube_k_repeat == 0 &&
           normalized_b64.cube_n_repeat == 0 &&
           normalized_b64.cube_cell_count == 0 &&
           normalized_b64.cube_storage_bytes == 0 &&
           _Tiles[[1]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[1]].capacity_bytes == source_b64.capacity_bytes &&
           _Tiles[[1]].contents_defined == source_b64.contents_defined;
    for row = 0 to 31 do
        for column = 0 to 12 do
            let element = TileLogicalLinearIndex(normalized_b64, row, column);
            assert TileLogicalElementDefined(normalized_b64, element) &&
                TileReadLogicalElement(normalized_b64, element) ==
                    Zeros{PTO_XLEN} + 0x1000000000000000 + row * 0x1000 + column * 7 + 1;
        end;
        for column = 13 to 15 do
            let element = TileLogicalLinearIndex(normalized_b64, row, column);
            assert !TileLogicalElementDefined(normalized_b64, element);
        end;
    end;

    ConfigureSharedCubeSource(2, 512, 31, TileDataType_U4X2);
    let normalized_packed = SharedTileFromLocalCubeToND(2, 512);
    assert normalized_packed.layout == TileLayout_RowMajor &&
           normalized_packed.capacity_bytes == 512 &&
           normalized_packed.rows == 32 && normalized_packed.columns == 32 &&
           normalized_packed.valid_columns == 31 &&
           normalized_packed.data_type == TileDataType_U4X2 &&
           normalized_packed.cube_storage_bytes == 0;
    for row = 0 to 31 do
        for column = 0 to 30 do
            let element = TileLogicalLinearIndex(normalized_packed, row, column);
            assert TileLogicalElementDefined(normalized_packed, element) &&
                TileReadLogicalElement(normalized_packed, element) ==
                    Zeros{PTO_XLEN} + ((row * 3 + column * 5) MOD 16);
        end;
        let padding = TileLogicalLinearIndex(normalized_packed, row, 31);
        assert !TileLogicalElementDefined(normalized_packed, padding);
    end;
    return 0;
end;
