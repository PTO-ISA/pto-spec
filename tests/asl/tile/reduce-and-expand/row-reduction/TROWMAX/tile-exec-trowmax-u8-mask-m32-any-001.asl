// PTO-TEST: {"id":"PTO-AVS-TILE-TROWMAX-U8-MASK-M32-ANY-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl","requirements":["PTO-INST-TILE-TROWMAX"],"kind":"execution","summary":"TROWMAX composes a 256-coordinate U8 M32 logical mask with GPR comparison and SETC for any.","pass_condition":"The full-width row reduction reaches the last CELL, predicate padding is zero, numeric status is preserved and the decoded conditional setter observes the independent expected result.","related_sources":["asl/tile/model/execution/predicate-carriers.asl","asl/scalar/bru/SETC.NE.asl"]}
func main() => integer
begin
    ResetProfileState();
    let input_ready = ConfigureCubeTile(
        0, 256, 32, 8, TileDataType_U8, TileLayout_CUBE_M32);
    // Row reduction preserves the source physical columns even when ValidCol=1.
    let result_ready = ConfigureCubeTileForMaskWithColumns(
        1, 256, 32, 8, 1, TileDataType_U8, TileLayout_CUBE_M32, '0001');
    assert input_ready && result_ready;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 7 looplimit 16 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN});
        end;
    end;
    WriteTileElement(0, 31, 7, Zeros{PTO_XLEN} + 1);
    RecordNumericStatusFlags(Zeros{5} + 4);
    let flags_before = NumericStatusFlags();
    ExecuteTileReduction(TileReduction_MAX, TileAxis_Row, 1, 0);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5},
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert CurrentBundlePadValue() == TilePad_Zero;
    let word = TileCompareCUBEScalarToGPRAs(
        1, Zeros{PTO_XLEN}, TileComparison_NE, FALSE, TileDataType_U8);
    assert word == Zeros{PTO_XLEN} + 2147483648;
    assert NumericStatusFlags() == flags_before;

    WriteGPR(2, word);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(Zeros{PTO_XLEN} + 0x100, BundleKind_Standard,
        BundleTransfer_Conditional, Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN} + 0x120, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let executed = ExecuteScalarInstruction(Zeros{48} + 0x11065, 32);
    assert executed == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BARG.taken == TRUE;
    return 0;
end;
