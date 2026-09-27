// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-SELECTOR-LEGALITY-DECODED-003","source":"asl/tile/model/legality/operand-schema.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TSELS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Decoded PredicateCell TSEL and TSELS validate only ExecutionMask-active selector values","pass_condition":"Undefined or noncanonical inactive selector coordinates are ignored, active undefined or noncanonical coordinates reject, and a wrong-shape selector rejects without an internal shape assertion","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/execution/comparison.asl"]}
func ConfigureMaskedSelectorOperands(wrong_shape: boolean)
begin
    let predicate_ready = ConfigurePredicateCell(
        0, 128, 1, if wrong_shape then 1 else 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    let true_ready = ConfigureCubeTile(
        1, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let false_ready = ConfigureCubeTile(
        2, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        3, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_ready && true_ready && false_ready && destination_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 11);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 12);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 22);
end;

func RunMaskedSelector(selector: bits(12), active_column: integer {0..2},
    active_value: integer {0..2}, inactive_noncanonical: boolean,
    wrong_shape: boolean, should_complete: boolean)
begin
    ResetProfileState();
    ConfigureMaskedSelectorOperands(wrong_shape);
    if active_value != 2 then
        WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + active_value);
    end;
    if !wrong_shape && inactive_noncanonical then
        WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    end;

    var execution_mask = Zeros{PTO_XLEN};
    if active_column == 0 then execution_mask[0] = '1';
    elsif active_column == 1 then execution_mask[16] = '1';
    end;
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;

    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 3;
    operands.source0 = 0;
    operands.source1 = 1;
    operands.source2 = 2;
    operands.scalar0 = Zeros{PTO_XLEN} + 31;
    ClearFault();
    let (status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, selector, operands);
    assert (status == TileExecution_Executed) == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
    else
        assert _LastFault == Fault_TileLegality;
    end;
end;

func RunSelectorCases(selector: bits(12))
begin
    // No active coordinate: every selector byte may remain undefined.
    RunMaskedSelector(selector, 2, 2, FALSE, FALSE, TRUE);
    // Column zero is canonical and active; a noncanonical inactive byte is ignored.
    RunMaskedSelector(selector, 0, 1, TRUE, FALSE, TRUE);
    // The same noncanonical byte becomes illegal when its coordinate is active.
    RunMaskedSelector(selector, 1, 1, TRUE, FALSE, FALSE);
    // An active undefined selector coordinate is illegal.
    RunMaskedSelector(selector, 0, 2, FALSE, FALSE, FALSE);
    // Descriptor and shape checks remain unconditional and reject safely.
    RunMaskedSelector(selector, 0, 1, FALSE, TRUE, FALSE);
end;

func AssertExecutionMaskCarrierRemainsFullyCanonical()
begin
    ResetProfileState();
    let mask_ready = ConfigurePredicateCell(
        4, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert mask_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 2);
    _Tiles[[4]].contents_defined = TRUE;
    assert !TileExecutionMaskPredicateCellShapeLegal(
        4, TileLayout_CUBE_M16, 1, 2);
end;

func main() => integer
begin
    RunSelectorCases(Zeros{12} + 0x01a);
    RunSelectorCases(Zeros{12} + 0x03a);
    AssertExecutionMaskCarrierRemainsFullyCanonical();
    return 0;
end;
