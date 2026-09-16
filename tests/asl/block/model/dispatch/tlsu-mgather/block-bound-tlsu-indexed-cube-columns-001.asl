// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLSU-INDEXED-CUBE-COLUMNS-001","source":"asl/block/model/dispatch/tlsu-mgather.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-MGATHER-MASK-PREDICATE-001","PTO-MGATHER-CAS-ATOMIC-001","PTO-ATOM-RED-TYPE-LEGALITY-001"],"kind":"boundary","summary":"Indexed TLSU bundle paths accept aligned non-power-of-two CUBE columns.","pass_condition":"MGATHER, masked, CAS, atomic, and reduction selectors share a legal CUBE_M16 LB2 of six for a three-column U32 rectangle, while the same RowMajor dimensions reject.","related_sources":["asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/block/model/dispatch/tlsu-mgather-cas.asl","asl/block/model/dispatch/tlsu-gm-atom-red.asl","asl/tile/model/legality/indexed-layout.asl"]}

func SelectIndexedFunction(function: integer {0..31})
begin
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMemory;
    _BundleOperation.selector_valid = TRUE;
    _BundleOperation.selector = Zeros{10} + function;
end;

func AssertCommonDimensionsLegal()
begin
    assert BundleMGATHERDimensionsLegal();
    assert IndexedTLSUPhysicalShapeLegal(TileLayout_CUBE_M16,
        TileDataType_U32, 1, 3, 6);
end;

func main() => integer
begin
    ResetProfileState();
    SetBundleDataAttributeState(Zeros{5} + 25, Zeros{5} + 31,
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 6);
    assert CurrentBundleTileLayout() == TileLayout_CUBE_M16;

    SelectIndexedFunction(4);
    assert BundleMGATHERSelected();
    AssertCommonDimensionsLegal();
    SelectIndexedFunction(6);
    assert BundleMGATHERMASKSelected();
    AssertCommonDimensionsLegal();
    SelectIndexedFunction(8);
    assert BundleMGATHERCASSelected();
    AssertCommonDimensionsLegal();
    SelectIndexedFunction(9);
    assert BundleGMAtomRedSelected();
    AssertCommonDimensionsLegal();
    SelectIndexedFunction(19);
    assert BundleGMAtomRedSelected();
    AssertCommonDimensionsLegal();

    SetBundleDataAttributeState(Zeros{5} + 25, Zeros{5},
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert CurrentBundleTileLayout() == TileLayout_RowMajor;
    assert !BundleMGATHERDimensionsLegal();
    return 0;
end;
