// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGPR2T-DECODED-001","source":"asl/block/model/dispatch/tile-schema.asl","requirements":["PTO-INST-TILE-TGPR2T","PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001"],"kind":"execution","summary":"Decoded TGPR2T binds the exact 3+1 source-only B.IOR stream and publishes ordinary numeric CUBE output for M32 and M16 shapes.","pass_condition":"Real decoded BSTART/B.DATR/B.IOR/B.IOT commands accept legal M32 and M16 bundles with Zero or Max whole-tile padding, while malformed binding streams fault before destination allocation.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/descriptor-legality.asl","asl/tile/model/execution/predicate-carriers.asl"]}

pure func TGPR2TStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2} + 3;
    instruction[24:20] = Zeros{5} + 30;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TGPR2TDataAttributes(layout: bits(5),
                               pad: bits(2), rmode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = layout;
    instruction[28:27] = pad;
    instruction[17:15] = rmode;
    return instruction;
end;

pure func TGPR2TSourceBinding(source0: bits(5), source1: bits(5),
                              source2: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

pure func TGPR2TLastSourceBinding(source0: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    return instruction;
end;

pure func TGPR2TDestination(size_code: bits(4)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func SeedTGPR2TGPRs()
begin
    // Each source contributes one bit to every first-row plane.  The first
    // output row therefore packs to 0xff; later rows remain zero.
    WriteGPR(2, Zeros{64} + 0x0000000100000001);
    WriteGPR(3, Zeros{64} + 0x0000000100000001);
    WriteGPR(4, Zeros{64} + 0x0000000100000001);
    WriteGPR(5, Zeros{64} + 0x0000000100000001);
end;

func SeedTGPR2TM16GPRs()
begin
    // Put one observable bit in each distinct M16 quarter position: source
    // GPRs carry bits 0, 16, 32, and 48 respectively.
    WriteGPR(2, Zeros{64} + 0x0000000000000001);
    WriteGPR(3, Zeros{64} + 0x0000000000010000);
    WriteGPR(4, Zeros{64} + 0x0000000100000000);
    WriteGPR(5, Zeros{64} + 0x0001000000000000);
end;

func StartTGPR2T(layout: bits(5), pad: bits(2), rmode: bits(3),
                 rows: integer, columns: integer)
begin
    let started = ExecuteCommandInstruction(TGPR2TStart(), 32);
    let attributes = ExecuteCommandInstruction(
        TGPR2TDataAttributes(layout, pad, rmode), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + rows);
    SeedTGPR2TGPRs();
end;

func BindTGPR2T3Plus1()
begin
    let first = ExecuteCommandInstruction(TGPR2TSourceBinding(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    let second = ExecuteCommandInstruction(TGPR2TLastSourceBinding(
        Zeros{5} + 5), 32);
    let destination = ExecuteCommandInstruction(TGPR2TDestination('0001'), 32);
    assert first == CommandExecution_Executed;
    assert second == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
end;

func TestTGPR2TM32()
begin
    ResetProfileState();
    StartTGPR2T(Zeros{5}, '00', '011', 32, 4);
    BindTGPR2T3Plus1();
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x07e) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert _BundleScalarBindings[[0]].source0 == 2;
    assert _BundleScalarBindings[[0]].source1 == 3;
    assert _BundleScalarBindings[[0]].source2 == 4;
    assert _BundleScalarBindings[[1]].source0 == 5;
    assert _BundleScalarBindings[[0]].source_count == 3;
    assert _BundleScalarBindings[[1]].source_count == 1;
    assert BundleOperationGPRBindingValuesLegal(operation);
    assert SelectedBundleClosedSchemasLegal(operation);
    let data_legal = SelectedBundleTileDataAttributesLegal(operation);
    assert data_legal;
    assert !SelectedBundleTileMaskIsZero();
    assert SelectedBundleTileMasksLegal();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    let tile = _Tiles[[destination]];
    assert tile.layout == TileLayout_CUBE_M32;
    assert tile.data_type == TileDataType_U8;
    assert tile.valid_rows == 32 && tile.valid_columns == 4;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 3) == Zeros{PTO_XLEN};
    assert tile.contents_defined;
end;

func TestTGPR2TM16()
begin
    ResetProfileState();
    StartTGPR2T(Zeros{5}, '01', '001', 16, 8);
    SeedTGPR2TM16GPRs();
    BindTGPR2T3Plus1();
    let operation = DecodeTileOperation(TileDecode_TEPL,
        Zeros{12} + 0x07e) as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert BundleOperationGPRBindingValuesLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    let tile = _Tiles[[destination]];
    assert tile.layout == TileLayout_CUBE_M16;
    assert tile.valid_rows == 16 && tile.valid_columns == 8;
    // ByteOffset=1 places the two packed M16 halves at columns 2 and 3.
    // The four distinct quarter bits produce 0x21 in the low half and
    // 0x84 in the high half; a 32-bit-half mapping cannot produce this.
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 0x21;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 0x84;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 0, 4) == Zeros{PTO_XLEN} + 0xff;
    assert tile.contents_defined;
end;

func TestTGPR2TMalformedStreams()
begin
    // A third B.IOR is rejected at the command boundary and cannot create a
    // third owner slot or partially allocate the destination.
    ResetProfileState();
    StartTGPR2T(Zeros{5}, '00', '000', 32, 4);
    let first = ExecuteCommandInstruction(TGPR2TSourceBinding(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    let second = ExecuteCommandInstruction(TGPR2TLastSourceBinding(
        Zeros{5} + 5), 32);
    let third = ExecuteCommandInstruction(TGPR2TLastSourceBinding(
        Zeros{5} + 6), 32);
    assert first == CommandExecution_Executed;
    assert second == CommandExecution_Executed;
    assert third == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert BundleTileBindingCount() == 0;

    // A destination-bearing B.IOR is not a source-only record.
    ResetProfileState();
    StartTGPR2T(Zeros{5}, '00', '000', 32, 4);
    var destination_ior = TGPR2TSourceBinding(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4);
    destination_ior[11:7] = Zeros{5} + 1;
    let rejected = ExecuteCommandInstruction(destination_ior, 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
end;

func main() => integer
begin
    TestTGPR2TM32();
    TestTGPR2TM16();
    TestTGPR2TMalformedStreams();
    return 0;
end;
