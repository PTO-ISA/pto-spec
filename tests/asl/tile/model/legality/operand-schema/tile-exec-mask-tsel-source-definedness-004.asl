// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-TSEL-SOURCE-DEFINEDNESS-004","source":"asl/tile/model/legality/operand-schema.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Decoded PredicateCell TSEL requires both numeric inputs at every ExecutionMask-active coordinate","pass_condition":"An undefined unselected numeric input at an active coordinate rejects without destination effects, undefined numeric payload at all-inactive coordinates is ignored under ZERO, and fully ZERO-materialized inputs execute","related_sources":["asl/tile/model/legality/execution-mask-source-schema.asl","asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/execution/comparison.asl"]}
func ConfigureTSELSourceDefinednessOperands()
begin
    let predicate_ready = ConfigurePredicateCell(
        0, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let true_ready = ConfigureCubeTile(
        1, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let false_ready = ConfigureCubeTile(
        2, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        3, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_ready && true_ready && false_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
end;

func ExecuteDecodedTSEL() => TileExecutionStatus
begin
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 3;
    operands.source0 = 0;
    operands.source1 = 1;
    operands.source2 = 2;
    operands.scalar0 = Zeros{PTO_XLEN} + 31;
    let (status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, Zeros{12} + 0x01a, operands);
    return status;
end;

func AssertActiveUnselectedUndefinedRejectsAtomically()
begin
    ResetProfileState();
    ConfigureTSELSourceDefinednessOperands();
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 11);
    // The selector chooses source_true, but source_false is still an operand
    // whose active coordinate must be defined before execution.
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 77);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 88);
    let capacity_before = _Tiles[[3]].capacity_bytes;
    var execution_mask = Zeros{PTO_XLEN};
    execution_mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    ClearFault();
    let status = ExecuteDecodedTSEL();
    assert status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 77;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 88;
    assert _Tiles[[3]].capacity_bytes == capacity_before;
    assert _Tiles[[3]].contents_defined;
    assert _Tiles[[3]].defined_valid_elements == 2;
end;

func AssertAllInactiveUndefinedPayloadIsIgnored()
begin
    ResetProfileState();
    ConfigureTSELSourceDefinednessOperands();
    CaptureBundleExecutionMaskGPR(
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    ClearFault();
    let status = ExecuteDecodedTSEL();
    assert status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN};
    assert _Tiles[[3]].contents_defined;
end;

func AssertZeroMaterializedInputsExecute()
begin
    ResetProfileState();
    ConfigureTSELSourceDefinednessOperands();
    for column = 0 to 1 looplimit 2 do
        WriteTileElement(1, 0, column as integer {0..65535}, Zeros{PTO_XLEN});
        WriteTileElement(2, 0, column as integer {0..65535}, Zeros{PTO_XLEN});
    end;
    var execution_mask = Zeros{PTO_XLEN};
    execution_mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    ClearFault();
    let status = ExecuteDecodedTSEL();
    assert status == TileExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN};
    assert _Tiles[[3]].contents_defined;
end;

func main() => integer
begin
    AssertActiveUnselectedUndefinedRejectsAtomically();
    AssertAllInactiveUndefinedPayloadIsIgnored();
    AssertZeroMaterializedInputsExecute();
    return 0;
end;
