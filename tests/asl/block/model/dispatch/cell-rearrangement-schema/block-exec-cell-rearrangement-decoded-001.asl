// PTO-TEST: {"id":"PTO-AVS-BLOCK-CELL-REARRANGE-DECODED-001","source":"asl/block/model/dispatch/cell-rearrangement-schema.asl","requirements":["PTO-INST-TILE-TPERMUTE","PTO-INST-TILE-TSHUF"],"kind":"execution","summary":"Decoded cell-rearrangement bundles exercise normal control, mandatory and surplus B.IOR, raw control faults, zero-mask no-op, and removed selectors.","pass_condition":"The selected bundle either publishes the decoded result or reports the specified architectural fault before effects.","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/tile/model/legality/layout-rearrangement.asl"]}

pure func CellRearrangementTEPLStart(selector: bits(10),
                                     data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func CellRearrangementScalarBinding(destination: bits(5),
                                         source0: bits(5),
                                         source1: bits(5),
                                         source2: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

func PrepareDecodedTshufBundle()
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_3 = ConfigureCubeTile(3, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(
        CellRearrangementTEPLStart(Zeros{10} + 0x076,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    AddBundleTileBinding(TRUE, 3, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    assert started == CommandExecution_Executed;
end;

func TestDecodedTpermuteNormalAndFault()
begin
    ResetProfileState();
    let configured_5 = ConfigureCubeTile(1, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_6 = ConfigureCubeTile(2, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_7 = ConfigureCubeTile(3, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_8 = ConfigureCubeTile(4, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x04030201);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x08070605);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(4, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 3, Zeros{PTO_XLEN} + 5);
    let started = ExecuteCommandInstruction(
        CellRearrangementTEPLStart(Zeros{10} + 0x075,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    AddBundleTileBinding(FALSE, 0, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(TRUE, 3, 1, '1111', TRUE, FALSE, 4, 0, TRUE);
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x075)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert started == CommandExecution_Executed;
    assert TileOperationOfIndex(operation) == TileOperation_TPERMUTE;
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleCellRearrangementSchemaLegal(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();
    assert BundleSharedDestinationAssemblyPolicyLegal();
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let decoded_destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[decoded_destination]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(decoded_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x06020501;

    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_3 = ConfigureCubeTile(3, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_4 = ConfigureCubeTile(4, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x04030201);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x08070605);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0xaaaaaaaa);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 3, Zeros{PTO_XLEN} + 5);
    let invalid_start = ExecuteCommandInstruction(
        CellRearrangementTEPLStart(Zeros{10} + 0x075,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    AddBundleTileBinding(FALSE, 0, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(TRUE, 3, 1, '1111', TRUE, FALSE, 4, 0, TRUE);
    let invalid_completed = ExecuteBundleTileOperation();
    assert invalid_start == CommandExecution_Executed;
    assert !invalid_completed;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xaaaaaaaa;
end;

func TestDecodedTshufControls()
begin
    // B.IOR is mandatory for TSHUF; omission is a bundle-control fault.
    PrepareDecodedTshufBundle();
    let omitted = ExecuteBundleTileOperation();
    assert !omitted && _LastFault == Fault_BundleControl;

    // A decoded scalar control runs the normal path.
    PrepareDecodedTshufBundle();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000302);
    let scalar = ExecuteCommandInstruction(
        CellRearrangementScalarBinding(Zeros{5}, Zeros{5} + 2,
            Zeros{5}, Zeros{5}), 32);
    let completed = ExecuteBundleTileOperation();
    assert scalar == CommandExecution_Executed;
    assert completed && _LastFault == Fault_None;
    let tshuf_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(tshuf_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(tshuf_destination, 1, 0) ==
        Zeros{PTO_XLEN} + 1;

    // Nonzero surplus B.IOR fields are rejected by the selected schema.
    PrepareDecodedTshufBundle();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000302);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    let surplus = ExecuteCommandInstruction(
        CellRearrangementScalarBinding(Zeros{5}, Zeros{5} + 2,
            Zeros{5} + 3, Zeros{5}), 32);
    let surplus_completed = ExecuteBundleTileOperation();
    assert surplus == CommandExecution_Executed;
    assert !surplus_completed && _LastFault == Fault_BundleControl;

    // The private control is an XLEN word with a reserved upper half.
    PrepareDecodedTshufBundle();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000100000302);
    let reserved = ExecuteCommandInstruction(
        CellRearrangementScalarBinding(Zeros{5}, Zeros{5} + 2,
            Zeros{5}, Zeros{5}), 32);
    let reserved_completed = ExecuteBundleTileOperation();
    assert reserved == CommandExecution_Executed;
    assert !reserved_completed && _LastFault == Fault_TileLegality;
end;

func AssertRetiredCellRearrangementSelector(selector: bits(10))
begin
    ResetProfileState();
    let retired = ExecuteCommandInstruction(
        CellRearrangementTEPLStart(selector,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    assert retired == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
end;

func TestDecodedCellRearrangementNoopAndRemovedSelectors()
begin
    // PE_MASK=0000 returns before descriptor, control, or source validation.
    ResetProfileState();
    let no_op_start = ExecuteCommandInstruction(
        CellRearrangementTEPLStart(Zeros{10} + 0x076,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    AddBundleTileBinding(TRUE, 3, 1, '0000', TRUE, TRUE, 60, 61, TRUE);
    let no_op = ExecuteBundleTileOperation();
    assert no_op_start == CommandExecution_Executed;
    assert no_op && _LastFault == Fault_None;
    assert !_Tiles[[3]].allocated;

    // The six retired selectors are holes, not compatibility aliases.
    AssertRetiredCellRearrangementSelector(Zeros{10} + 0x065);
    AssertRetiredCellRearrangementSelector(Zeros{10} + 0x06E);
    AssertRetiredCellRearrangementSelector(Zeros{10} + 0x071);
    AssertRetiredCellRearrangementSelector(Zeros{10} + 0x072);
    AssertRetiredCellRearrangementSelector(Zeros{10} + 0x073);
    AssertRetiredCellRearrangementSelector(Zeros{10} + 0x074);
end;

func main() => integer
begin
    TestDecodedTpermuteNormalAndFault();
    TestDecodedTshufControls();
    TestDecodedCellRearrangementNoopAndRemovedSelectors();
    return 0;
end;
