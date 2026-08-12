// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-OPERAND-ROUTING-EXECUTION-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"B.FPATR dense scalar/vector parameter and maximum B.IOT routing","pass_condition":"LReLU-only uses RegSrc0, scalar quant/LReLU pack densely, and eight sources/three destinations remain ordered","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMatrix;
    let operation = DecodeTileOperation(TileDecode_CUBE, Zeros{12})
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    // LReLU-only consumes RegSrc0; scalar quant then LReLU consumes RegSrc0/1.
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = Zeros{6};
    _BundleFixedPointAttributes.relu_mode = '010';
    SetBundleScalarBinding(0, 0, 7, 8, 0, 1);
    WriteGPR(7, Zeros{PTO_XLEN} + 17);
    assert ReadScalarRegisterOperand(7) == Zeros{PTO_XLEN} + 17;
    assert BundleOperationGPRInputSelector(0) == 7;
    let lrelu = BundleTileInstructionOperands(operation);
    assert lrelu.post_lrelu_param == Zeros{PTO_XLEN} + 17;
    _BundleFixedPointAttributes.pre_quant_mode = '000011';
    _BundleScalarBindings[[0]].source_count = 2;
    WriteGPR(8, Zeros{PTO_XLEN} + 19);
    let scalar_pair = BundleTileInstructionOperands(operation);
    assert scalar_pair.post_quant_param == Zeros{PTO_XLEN} + 17;
    assert scalar_pair.post_lrelu_param == Zeros{PTO_XLEN} + 19;

    // Worst-case ordered local stream: eight sources and three destinations.
    ResetProfileState();
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileMatrix;
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = Zeros{6};
    _BundleFixedPointAttributes.relu_mode = Zeros{3};
    for index = 0 to 3 looplimit 4 do
        let base = index * 2;
        _BundleTileBindings[[index]].valid = TRUE;
        _BundleTileBindings[[index]].source0_valid = TRUE;
        _BundleTileBindings[[index]].source0 = base as TileIndex;
        _BundleTileBindings[[index]].source1_valid = TRUE;
        _BundleTileBindings[[index]].source1 = (base + 1) as TileIndex;
    end;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 20;
    _BundleTileBindings[[1]].destination_valid = TRUE;
    _BundleTileBindings[[1]].destination = 21;
    _BundleTileBindings[[2]].destination_valid = TRUE;
    _BundleTileBindings[[2]].destination = 22;
    let ordered = BundleTileInstructionOperands(operation);
    assert ordered.source0 == 0;
    assert ordered.source1 == 1;
    assert ordered.source2 == 2;
    assert ordered.source3 == 3;
    assert ordered.source4 == 4;
    assert ordered.source5 == 5;
    assert ordered.source6 == 6;
    assert ordered.source7 == 7;
    assert ordered.destination0 == 20;
    assert ordered.destination1 == 21;
    assert ordered.destination2 == 22;

    // Complete-bundle destination aliases are illegal even when the
    // mathematical source count is otherwise exact.
    for index = 0 to 3 looplimit 4 do
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
    end;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 1;
    _BundleFixedPointAttributes.row_max_en = TRUE;
    _BundleFixedPointAttributes.group_max_en = TRUE;
    _BundleFixedPointAttributes.group_n_code = '0001';
    _BundleFixedPointAttributes.row_max_init = FALSE;
    _BundleTileBindings[[2]].destination = 21;
    assert !BundleOperationBindingsComplete(operation);
    return 0;
end;
