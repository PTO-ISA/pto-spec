// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"state-transition","summary":"TSEL applies operation-typed numeric padding across source backings","pass_condition":"Min writes the TF32 operation type's numeric minimum for S32/U32 source backings while omitted Null leaves the same physical coordinate undefined","related_sources":["asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedSelection()
begin
    ConfigurePredicateTile(0, 128, 16, 2, 1, 1);
    ConfigureTile(1, 128, 8, 2, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 8, 2, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(3, 128, 8, 2, 1, 1, TileDataType_TF32,
        TileLayout_RowMajor);
    WriteTilePredicateBit(0, 0, 0, TRUE);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 9);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePaddedSelection();
    SetBundleDataAttributeState(
        Zeros{5} + 2,
        Zeros{5},
        '10',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[3]].data_type);
    assert operation_type_valid && operation_type == TileDataType_TF32;
    assert TileSelectDataTypeSupported(operation_type);
    assert TileRowMajorNumericCarrierLegal(1, operation_type);
    assert TileRowMajorNumericCarrierLegal(2, operation_type);
    assert TileLogicalShapeMatch(1, 2);
    assert TileElementwiseSourceContentsDefined(1);
    assert TileElementwiseSourceContentsDefined(2);
    assert TilePredicateValuesLegal(0);
    assert TileLogicalShapeMatch(0, 1);
    assert TileLogicalShapeMatch(3, 1);
    assert _Tiles[[3]].storage_kind == TileStorage_Numeric;
    assert _Tiles[[3]].data_type == operation_type;
    ExecuteTileSelect(3, 0, 1, 2);
    assert TileElementDefined(3, 0, 1);
    assert ReadTileElement(3, 0, 1) ==
        TilePadValueForDataType(TilePad_Min, TileDataType_TF32);

    ResetProfileState();
    ConfigurePaddedSelection();
    ExecuteTileSelect(3, 0, 1, 2);
    assert !TileElementDefined(3, 0, 1);
    return 0;
end;
