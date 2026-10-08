// PTO-TEST: {"id":"PTO-AVS-TILE-TROWMIN-U8-MASK-M16-ALL-TAIL-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWMIN.asl","requirements":["PTO-INST-TILE-TROWMIN"],"kind":"execution","summary":"TROWMIN composes a 256-coordinate U8 M16 logical mask with GPR comparison and SETC for all_tail.","pass_condition":"The full-width row reduction reaches the last CELL, predicate padding is zero, numeric status is preserved and the decoded conditional setter observes the independent expected result.","related_sources":["asl/tile/model/execution/predicate-carriers.asl","asl/scalar/bru/SETC.EQ.asl"]}
func main() => integer
begin
    ResetProfileState();
    let condition_ready = ConfigureCubeTile(
        0, 256, 16, 16, TileDataType_U8, TileLayout_CUBE_M16);
    // Row reduction preserves the source physical columns even when ValidCol=1.
    let result_ready = ConfigureCubeTileForMaskWithColumns(
        1, 256, 16, 16, 1, TileDataType_U8, TileLayout_CUBE_M16, '0001');
    let domain_ready = ConfigurePredicateCell(
        2, 256, 16, 16, TileDataType_U8, TileLayout_CUBE_M16);
    let neutral_ready = ConfigureCubeTile(
        3, 256, 16, 16, TileDataType_U8, TileLayout_CUBE_M16);
    let input_ready = ConfigureCubeTile(
        4, 256, 16, 16, TileDataType_U8, TileLayout_CUBE_M16);
    assert condition_ready && result_ready && domain_ready && neutral_ready &&
           input_ready;
    for row = 0 to 15 looplimit 32 do
        for column = 0 to 15 looplimit 16 do
            let coordinate = row * 16 + column;
            let active = coordinate < 253;
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                if active then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            WriteTileElement(2, row as integer {0..65535},
                column as integer {0..65535},
                if active then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            WriteTileElement(3, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN} + 1);
        end;
    end;
    // Only the first 253 coordinates belong to the active domain.
    // select(domain, cond, true) materializes neutral ones for the tail.
    // Every active condition is true; MIN must therefore report all=true.
    ExecuteTileSelectAs(4, 2, 0, 3, TileDataType_U8);
    assert ReadTileElement(4, 15, 12) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(4, 15, 13) == Zeros{PTO_XLEN} + 1;
    RecordNumericStatusFlags(Zeros{5} + 4);
    let flags_before = NumericStatusFlags();
    ExecuteTileReduction(TileReduction_MIN, TileAxis_Row, 1, 4);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5},
        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert CurrentBundlePadValue() == TilePad_Zero;
    let word = TileCompareCUBEScalarToGPRAs(
        1, Zeros{PTO_XLEN}, TileComparison_EQ, FALSE, TileDataType_U8);
    assert word == Zeros{PTO_XLEN} + 0;
    assert NumericStatusFlags() == flags_before;

    WriteGPR(2, word);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(Zeros{PTO_XLEN} + 0x100, BundleKind_Standard,
        BundleTransfer_Conditional, Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN} + 0x120, Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let executed = ExecuteScalarInstruction(Zeros{48} + 0x10065, 32);
    assert executed == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert _BARG.taken == TRUE;
    return 0;
end;
