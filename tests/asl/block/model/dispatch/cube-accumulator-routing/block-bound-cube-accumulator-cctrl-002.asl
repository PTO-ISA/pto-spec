// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-ACCUMULATOR-CCTRL-002","source":"asl/block/model/dispatch/cube-accumulator-routing.asl","requirements":["PTO-B-DATR-MATRIX-ACC-CONTROL-001","PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"boundary","summary":"Matrix CCTRL assigns raw-partial output and transparent-cache hints without replacing explicit C or D.","pass_condition":"all four ACC controls are legal, init forms accept only 00 and 01, bit meanings are exact, and raw-partial forms reject final-output post-processing.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/internal-accumulator.asl"]}
func CheckAccumulatorFunction(function: integer {0..31})
begin
    for control = 0 to 3 do
        assert BundleTMATMULAccumulatorControlLegal(
            function, (Zeros{2} + control) as bits(2));
    end;
end;

func CheckInitFunction(function: integer {0..31})
begin
    assert BundleTMATMULAccumulatorControlLegal(function, '00');
    assert BundleTMATMULAccumulatorControlLegal(function, '01');
    assert !BundleTMATMULAccumulatorControlLegal(function, '10');
    assert !BundleTMATMULAccumulatorControlLegal(function, '11');
end;

func main() => integer
begin
    assert !BundleTMATMULRawPartialOutput('00');
    assert BundleTMATMULRawPartialOutput('01');
    assert !BundleTMATMULRawPartialOutput('10');
    assert BundleTMATMULRawPartialOutput('11');
    assert !BundleTMATMULAccumulatorPrefetchHint('00');
    assert !BundleTMATMULAccumulatorPrefetchHint('01');
    assert BundleTMATMULAccumulatorPrefetchHint('10');
    assert BundleTMATMULAccumulatorPrefetchHint('11');

    CheckAccumulatorFunction(2);
    CheckAccumulatorFunction(6);
    CheckAccumulatorFunction(18);
    CheckAccumulatorFunction(22);
    CheckInitFunction(0);
    CheckInitFunction(1);
    CheckInitFunction(4);
    CheckInitFunction(5);
    CheckInitFunction(16);
    CheckInitFunction(17);
    CheckInitFunction(20);
    CheckInitFunction(21);

    ResetProfileState();
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    assert BundleTMATMULPartialPostProcessLegal('00');
    assert BundleTMATMULPartialPostProcessLegal('01');
    assert BundleTMATMULPartialPostProcessLegal('10');
    assert BundleTMATMULPartialPostProcessLegal('11');

    ResetProfileState();
    SetBundleFixedPointAttributeState(
        Zeros{6} + 1, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    assert BundleTMATMULPartialPostProcessLegal('00');
    assert !BundleTMATMULPartialPostProcessLegal('01');
    assert BundleTMATMULPartialPostProcessLegal('10');
    assert !BundleTMATMULPartialPostProcessLegal('11');
    return 0;
end;
