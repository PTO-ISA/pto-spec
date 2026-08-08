// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLEDATAATTRIBUTES-EXECUTION-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"execution","summary":"migrated independent behavior point for TestBundleDataAttributes","pass_condition":"TestBundleDataAttributes completes without assertion failure","related_sources":[]}
func TestBundleDataAttributes()
begin
    ResetProfileState();
    assert TileDataLayoutCodeAccepted(Zeros{5});
    assert TileDataLayoutCodeAccepted(Zeros{5} + 1);
    assert TileDataLayoutCodeAccepted(Zeros{5} + 30);
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 2);
    assert TileDataLayoutCodeSupported(Zeros{5});
    assert !TileDataLayoutCodeSupported(Zeros{5} + 1);

    ClearFault();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '11',
        Zeros{3} + 1, Zeros{3} + 2, TRUE, TRUE);
    assert _LastFault == Fault_None;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    assert CurrentBundlePadValue() == TilePad_Null;
    assert CurrentBundleCanonicalize();
    let conversion_operation = DecodeTileOperation(TileDecode_TEPL, '000000011011')
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let conversion_operands = BundleTileInstructionOperands(conversion_operation);
    assert !conversion_operands.numeric_control.use_operation_default;
    assert conversion_operands.numeric_control.rounding_mode == NumericRound_RTZ;
    assert conversion_operands.numeric_control.saturating;

    // Accepted implementation-defined layouts are rejected by generic
    // indexing until the implementation advertises support.
    ClearFault();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5} + 1, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_TileLegality;
    assert CurrentBundleDataTypeCode() == Zeros{5} + 24;
    AdvertiseTileDataLayout(Zeros{5} + 1);
    ClearFault();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5} + 1, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_None;
    assert TileDataLayoutCodeSupported(Zeros{5} + 1);

    ClearFault();
    SetBundleDataAttributeState(Zeros{5} + 15, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert _LastFault == Fault_TileLegality;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleDataAttributes();
    return 0;
end;
