// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-CUBE-TRANSPORT-LAYOUT-005","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"boundary","summary":"ExecutionMask coordinate layout maps every CUBE transport conversion without using the ordinary Tile layout decoder.","pass_condition":"ND2M32/M322ND and ND2M16/M162ND select their M layouts for TLOAD/TSTORE GPR masks, while ND2N8/N82ND remain valid unpredicated transport layouts but reject predication without an internal assertion.","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/block/model/state/control-state.asl"]}
func SelectCubeTransportLayout(layout_code: bits(5), function: bits(5))
begin
    ResetProfileState();
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMemory;
    _BundleOperation.selector_valid = TRUE;
    _BundleOperation.selector = Zeros{10} + UInt(function);
    _BundleOperation.data_type_valid = TRUE;
    _BundleOperation.data_type = TileDataTypeToEncoding(TileDataType_U16);
    _BundleDataAttributesPresent = TRUE;
    _BundleDataAttributes.data_layout = layout_code;
    _BundleDataAttributes.data_type = DTYPE_NONE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
end;

func AssertCubeTransportMaskLayout(layout_code: bits(5),
    function: bits(5), expected: TileLayout, predication_legal: boolean)
begin
    SelectCubeTransportLayout(layout_code, function);
    let operation = DecodeTileOperation(
        TileDecode_TLSU, Zeros{12} + UInt(function))
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleCubeTransportSelected();
    assert BundleExecutionMaskCoordinateLayout(operation) == expected;
    assert BundleExecutionMaskGPRCarrierShapeLegal(operation) ==
        predication_legal;
end;

func main() => integer
begin
    AssertCubeTransportMaskLayout(
        Zeros{5} + 21, Zeros{5}, TileLayout_CUBE_M32, TRUE);
    AssertCubeTransportMaskLayout(
        Zeros{5} + 22, Zeros{5}, TileLayout_CUBE_M16, TRUE);
    AssertCubeTransportMaskLayout(
        Zeros{5} + 23, Zeros{5}, TileLayout_CUBE_N8, FALSE);
    AssertCubeTransportMaskLayout(
        Zeros{5} + 24, Zeros{5} + 1, TileLayout_CUBE_M32, TRUE);
    AssertCubeTransportMaskLayout(
        Zeros{5} + 25, Zeros{5} + 1, TileLayout_CUBE_M16, TRUE);
    AssertCubeTransportMaskLayout(
        Zeros{5} + 26, Zeros{5} + 1, TileLayout_CUBE_N8, FALSE);
    return 0;
end;
