// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-WRITER-PREFLIGHT-002","source":"asl/block/model/dispatch/destination-shape.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001"],"kind":"fault","summary":"Local CUBE writer shape and range legality are preflighted before destination allocation","pass_condition":"a 128-byte CUBE_M16 FP32 writer that cannot hold the requested 16x9 valid shape raises TileLegality while leaving Tile 0 unallocated and its destination binding unresolved","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/tile/model/state/allocation.asl"]}
pure func WriterPreflightStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        1, 128, 16, 1, TileDataType_FP32,
        TileLayout_CUBE_M16);
    assert source_ready;

    let started = ExecuteCommandInstruction(
        WriterPreflightStart(),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE,
        Zeros{5} + 31,
        Zeros{2},
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    AddBundleTileBinding(
        TRUE,
        0,
        4,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);
    _BundleTileBindings[[0]].destination_assemble.valid = TRUE;
    _BundleTileBindings[[0]].destination_assemble.init = TRUE;
    _BundleTileBindings[[0]].destination_assemble.last = TRUE;
    _BundleTileBindings[[0]].destination_assemble.size_code = 1;
    _BundleTileBindings[[0]].destination_assemble.offset =
        Zeros{PTO_XLEN};

    let (resolved, -) =
        ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, 16, 9, 9, TRUE, TileDataType_FP32);
    assert !resolved;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
