// PTO-TEST: {"id":"PTO-AVS-TILE-SORT-ORDER-001","source":"asl/tile/model/ordering/sorting.asl","requirements":["PTO-INST-TILE-TSORT","PTO-INST-TILE-TMRGSORT"],"kind":"boundary","summary":"Sorting compares signed zeros as equal and places numeric values before NaNs","pass_condition":"stable zero ties and numeric-before-NaN ordering hold in both directions","related_sources":[]}
func main() => integer
begin
    let positive_zero = Zeros{PTO_XLEN};
    let negative_zero = Zeros{PTO_XLEN} + 0x80000000;
    let one = Zeros{PTO_XLEN} + 0x3f800000;
    let quiet_nan = Zeros{PTO_XLEN} + 0x7fc00000;

    assert TileSortDataTypeSupported(TileDataType_FP32);
    assert TileSortDataTypeSupported(TileDataType_FP16);
    assert !TileSortDataTypeSupported(TileDataType_U64);
    assert TileSortLeftBefore(
        positive_zero,
        negative_zero,
        FALSE,
        TileDataType_FP32);
    assert TileSortLeftBefore(
        one,
        quiet_nan,
        FALSE,
        TileDataType_FP32);
    assert TileSortLeftBefore(
        one,
        quiet_nan,
        TRUE,
        TileDataType_FP32);
    assert !TileSortLeftBefore(
        quiet_nan,
        one,
        FALSE,
        TileDataType_FP32);
    return 0;
end;
