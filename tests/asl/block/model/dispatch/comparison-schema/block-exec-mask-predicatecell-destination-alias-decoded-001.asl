// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXEC-MASK-PREDICATECELL-ALIAS-DECODED-001","source":"asl/block/model/dispatch/comparison-schema.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded TCMP snapshots an aliased PredicateCell ExecutionMask before publishing a comparison result","pass_condition":"a decoded B.IOT output binding seeded to the existing PredicateCell mask uses the captured active bits while the handler overwrites that tile, and an active-undefined rejection preserves the alias payload and publishes no destination","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/block/model/dispatch/comparison-schema.asl","asl/tile/model/execution/execution-mask.asl","asl/block/model/operands/tile-bindings.asl"]}
// B.ASSEMBLE cannot produce a Local PredicateCell ParentRef on this baseline.
// The setup therefore decodes legal B.IOT records and seeds only the resolved
// destination binding identity to model an already-bound PredicateCell alias.
// Capture, comparison dispatch, fault rollback, and destination finalization
// then run through their ordinary model paths.
pure func AliasCompareStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2};
    instruction[24:20] = Zeros{5} + 0x0d;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func AliasCompareAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    instruction[13] = '1';
    return instruction;
end;

pure func AliasCompareInputs(left: bits(6), right: bits(6))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = right;
    instruction[25:20] = left;
    instruction[11:9] = '100';
    return instruction;
end;

pure func AliasMaskDestination(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '100';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

func BeginAliasComparison()
begin
    let started = ExecuteCommandInstruction(AliasCompareStart(), 32);
    let attributes = ExecuteCommandInstruction(AliasCompareAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
end;

func InstallAliasInputs(active_undefined: boolean)
begin
    let left_ready = ConfigureCubeTile(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let predicate_ready = ConfigurePredicateCell(
        12, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && predicate_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 1);
    if !active_undefined then
        WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 1);
        WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 2);
    end;
    _Tiles[[12]].contents_defined = TRUE;
    MarkTileValidRegionDefined(10);
    if !active_undefined then MarkTileValidRegionDefined(8); end;
end;

func DecodeAliasedPredicateOutput()
begin
    let input_record = ExecuteCommandInstruction(
        AliasCompareInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let output_record = ExecuteCommandInstruction(
        AliasMaskDestination(Zeros{6} + 12), 32);
    assert input_record == CommandExecution_Executed;
    assert output_record == CommandExecution_Executed;
    assert BundleTileBindingCount() == 2;
    assert _BundleTileBindings[[0]].source0_relative &&
           _BundleTileBindings[[0]].source1_relative;
    assert _BundleTileBindings[[1]].source0_relative &&
           _BundleTileBindings[[1]].destination_valid;

    // This models an already-bound PredicateCell destination alias. There is
    // no claim that a B.ASSEMBLE ParentRef producer can create this binding.
    _BundleTileBindings[[1]].destination = 12;
    _BundleTileBindings[[1]].destination_reused_by_generation = TRUE;
    let resolved = ResolveBundleRelativeTileSources();
    assert resolved;
    assert _BundleTileBindings[[0]].source0 == 8 &&
           _BundleTileBindings[[0]].source1 == 10 &&
           _BundleTileBindings[[1]].source0 == 12;
    RemoveRelativeTileMapping(12);
end;

func RunPredicateMaskDestinationAlias(should_complete: boolean)
begin
    ResetProfileState();
    InstallAliasInputs(!should_complete);
    BeginAliasComparison();
    DecodeAliasedPredicateOutput();
    assert !RelativeTileDestinationPublished(12);
    let prior_inactive = ReadTileElement(12, 0, 0);
    let prior_active = ReadTileElement(12, 0, 1);
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        assert _BundleExecutionMask.valid &&
               _BundleExecutionMask.predicate_tile == 12;
        assert _BundleExecutionMask.predicate_tile_snapshot[1] == '1';
        // The aliased tile now contains the comparison result (false), while
        // ActiveAt still observes the pre-operation captured true mask bit.
        assert ReadTileElement(12, 0, 1) == Zeros{PTO_XLEN};
        assert BundleExecutionMaskActiveAt(
            TileLayout_CUBE_M16, 0, 1);
        assert ReadTileElement(12, 0, 0) == prior_inactive;
        assert RelativeTileDestinationPublished(12) == FALSE;

        // The reused alias correctly skipped publication in ExecuteBundleTileOperation.
        // Exercise the same real finalizer's successful newly allocated destination
        // branch explicitly after the alias result has committed.
        _BundleTileBindings[[1]].destination_reused_by_generation = FALSE;
        _BundleTileBindings[[1]].destination_allocated_by_bundle = TRUE;
        FinalizeBundleTileAttempt(TileExecution_Executed);
        assert RelativeTileDestinationPublished(12);
        assert ResolveRelativeTileSource(0) == 12;
    else
        assert _LastFault == Fault_TileLegality;
        assert _BundleExecutionMask.valid &&
               _BundleExecutionMask.predicate_tile == 12;
        assert ReadTileElement(12, 0, 0) == prior_inactive;
        assert ReadTileElement(12, 0, 1) == prior_active;
        assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
        assert !RelativeTileDestinationPublished(12);
    end;
end;

func main() => integer
begin
    RunPredicateMaskDestinationAlias(TRUE);
    RunPredicateMaskDestinationAlias(FALSE);
    return 0;
end;
