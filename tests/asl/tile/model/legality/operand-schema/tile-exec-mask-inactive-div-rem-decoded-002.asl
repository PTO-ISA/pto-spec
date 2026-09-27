// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-INACTIVE-DIV-REM-DECODED-002","source":"asl/tile/model/legality/operand-schema.asl","requirements":["PTO-TDIVS-CONTRACT-001","PTO-TREMS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Decoded integer TDIVS and TREMS ignore a zero scalar when ExecutionMask disables every coordinate","pass_condition":"An all-zero ExecutionMask admits zero-scalar TDIVS and TREMS without arithmetic effects, while either decoded operation rejects the same scalar when one coordinate is active","related_sources":["asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/execution/elementwise.asl"]}
func RunMaskedZeroScalar(selector: bits(12), active: boolean)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        1, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 9);

    var execution_mask = Zeros{PTO_XLEN};
    if active then execution_mask[0] = '1'; end;
    CaptureBundleExecutionMaskGPR(
        execution_mask, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;

    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 1;
    operands.source0 = 0;
    operands.scalar0 = Zeros{PTO_XLEN};
    ClearFault();
    let (status, -) = ExecuteTileInstruction(
        TileDecode_TEPL, selector, operands);
    if active then
        assert status == TileExecution_Rejected;
        assert _LastFault == Fault_TileLegality;
    else
        assert status == TileExecution_Executed;
        assert _LastFault == Fault_None;
        assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
        assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};
    end;
end;

func main() => integer
begin
    RunMaskedZeroScalar(Zeros{12} + 0x023, FALSE);
    RunMaskedZeroScalar(Zeros{12} + 0x023, TRUE);
    RunMaskedZeroScalar(Zeros{12} + 0x024, FALSE);
    RunMaskedZeroScalar(Zeros{12} + 0x024, TRUE);
    return 0;
end;
