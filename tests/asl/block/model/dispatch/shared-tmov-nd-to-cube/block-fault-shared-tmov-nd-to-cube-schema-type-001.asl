// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-SCHEMA-TYPE-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"reverse TMOV closes the frozen Shared ND roles, CUBE selectors, type relation, and conversion mask guards","pass_condition":"decoded Function-2 Shared-to-Local bundles reject wrong-direction Layout 24, invalid selectors 23 and 26 with an ExecutionMask, CUBE Shared source, RCPE6M2 backing, incompatible carrier width, M16 b64, unsupported Sat control, and Shared-source B.ASSEMBLE before destination allocation; selector 23/26 mask faults also preserve the source descriptor state","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/dispatch/tile-schema.asl","asl/tile/model/legality/dtype-layout.asl"]}

pure func SharedNDToCubeSchemaStart(carrier: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(carrier);
    return instruction;
end;

pure func SharedNDToCubeSchemaDATR(selector: integer {21,22,23,24,25,26},
    invalid_control: integer {0..7}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + selector;
    if invalid_control == 1 then instruction[26] = '1'; end;
    if invalid_control == 2 then instruction[28:27] = '01'; end;
    if invalid_control == 3 then instruction[31:29] = '001'; end;
    if invalid_control == 4 then instruction[17:15] = '001'; end;
    if invalid_control == 5 then instruction[25] = '1'; end;
    if invalid_control == 6 then instruction[14] = '1'; end;
    if invalid_control == 7 then instruction[13] = '1'; end;
    return instruction;
end;

pure func SharedNDToCubeSchemaFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func SharedNDToCubeSchemaExecMaskIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[26] = '1';
    return instruction;
end;

pure func SharedNDToCubeSchemaShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeSchemaDestination(size_code: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeSchemaAssemble(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = size_code;
    return instruction;
end;

pure func SharedNDToCubeSchemaValue(data_type: TileDataType,
    row: integer {0..31}, column: integer {0..127}) => Word
begin
    let value = Zeros{PTO_XLEN} + 0x81234567 + row * 131 + column * 17;
    if TileElementBits(data_type) == 8 then
        return Zeros{PTO_XLEN} + (UInt(value) MOD 256);
    elsif TileElementBits(data_type) == 32 then
        return Zeros{PTO_XLEN} + (UInt(value) MOD 0x100000000);
    end;
    return value;
end;

func SharedNDToCubeSchemaRejects(source_type: TileDataType,
    carrier_type: TileDataType, selector: integer {21,22,23,24,25,26},
    source_layout: TileLayout,
    rows: integer {16,32}, columns: integer {2,128},
    source_capacity: integer {256,4096}, destination_size: bits(4),
    invalid_control: integer {0..7}, with_assemble: boolean,
    with_fpatr: boolean, with_exec_mask: boolean) => boolean
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x700);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    let setup_type = if source_type == TileDataType_RCPE6M2 then
        TileDataType_U8 else source_type;
    ConfigureTileForMask(10, source_capacity, rows, columns, rows,
        columns, setup_type, TileLayout_RowMajor, '1000');
    for row = 0 to rows - 1 looplimit 32 do
        for column = 0 to columns - 1 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeSchemaValue(setup_type,
                    row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 35) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let shared_index = SharedTileArrayIndex(shared_id);
    if source_layout != TileLayout_RowMajor then
        _SharedTiles[[shared_index]].tile.layout = source_layout;
    end;
    if source_type == TileDataType_RCPE6M2 then
        _SharedTiles[[shared_index]].tile.data_type = source_type;
        _SharedTiles[[shared_index]].tile.predicate_basis_type = source_type;
    end;
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeSchemaStart(carrier_type), 32);
    assert start_status == CommandExecution_Executed &&
           BundleTMOVSelected();
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeSchemaDATR(selector, invalid_control), 32);
    if datr_status != CommandExecution_Executed then
        assert _LastFault != Fault_None &&
               !_BundleTileBindings[[0]].destination_allocated_by_bundle;
        return TRUE;
    end;
    let output_columns = if rows == 16 then columns else columns;
    SetBundleDimension(0, Zeros{PTO_XLEN} + output_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + rows);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeSchemaShared(shared_id as bits(6)), 32);
    var fpatr_status = CommandExecution_Executed;
    if with_fpatr then
        fpatr_status = ExecuteCommandInstruction(
            SharedNDToCubeSchemaFPATR(), 32);
        if fpatr_status != CommandExecution_Executed then
            assert _LastFault != Fault_None &&
                   !_BundleTileBindings[[0]].destination_allocated_by_bundle;
            return TRUE;
        end;
    end;
    var ior_status = CommandExecution_Executed;
    if with_exec_mask then
        ior_status = ExecuteCommandInstruction(
            SharedNDToCubeSchemaExecMaskIOR(), 32);
        if ior_status != CommandExecution_Executed then
            let source_after_mask_rejection = SharedTileRecord(shared_id);
            assert _LastFault != Fault_None &&
                   !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
                   source_after_mask_rejection.payload_generation ==
                       source_before.payload_generation &&
                   source_after_mask_rejection.payload_live ==
                       source_before.payload_live &&
                   source_after_mask_rejection.published ==
                       source_before.published;
            return TRUE;
        end;
    end;
    if with_assemble then
        let assemble_status = ExecuteCommandInstruction(
            SharedNDToCubeSchemaAssemble(destination_size), 32);
        if assemble_status != CommandExecution_Executed then
            assert _LastFault != Fault_None &&
                   !_BundleTileBindings[[0]].destination_allocated_by_bundle;
            return TRUE;
        end;
    end;
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeSchemaDestination(destination_size), 32);
    assert shared_status == CommandExecution_Executed &&
           fpatr_status == CommandExecution_Executed &&
           ior_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    let source_after = SharedTileRecord(shared_id);
    return stop_status == CommandExecution_Rejected &&
           _LastFault != Fault_None &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published;
end;

func main() => integer
begin
    // Shared ND-to-CUBE does not admit the existing reverse-direction code.
    let wrong_direction = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 24, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, FALSE);
    assert wrong_direction;
    // A published CUBE Shared descriptor is not a RowMajor ND source.
    let cube_source = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 21, TileLayout_CUBE_M32,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, FALSE);
    assert cube_source;
    // The source-only carrier interpretation cannot become persistent backing.
    let rcpe_backing = SharedNDToCubeSchemaRejects(
        TileDataType_RCPE6M2, TileDataType_RCPE6M2, 21,
        TileLayout_RowMajor, 32, 128, 4096, Zeros{4} + 6,
        0, FALSE, FALSE, FALSE);
    assert rcpe_backing;
    // Carrier width must match source backing under the existing relation.
    let incompatible_carrier = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U16, 21, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, FALSE);
    assert incompatible_carrier;
    // Existing CUBE legality keeps M16 b64 unavailable.
    let m16_b64 = SharedNDToCubeSchemaRejects(
        TileDataType_FP64, TileDataType_FP64, 22, TileLayout_RowMajor,
        16, 2, 256, Zeros{4} + 2, 0, FALSE, FALSE, FALSE);
    assert m16_b64;
    // DATR Sat is not part of either new conversion schema.
    let unsupported_sat = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 21, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 1, FALSE, FALSE, FALSE);
    assert unsupported_sat;
    // Every other B.DATR control is closed to this conversion as well.
    var other_controls_rejected = TRUE;
    for control = 2 to 7 looplimit 6 do
        let control_rejected = SharedNDToCubeSchemaRejects(
            TileDataType_U8, TileDataType_U8, 21, TileLayout_RowMajor,
            32, 128, 4096, Zeros{4} + 6,
            control as integer {0..7}, FALSE, FALSE, FALSE);
        other_controls_rejected = other_controls_rejected && control_rejected;
    end;
    assert other_controls_rejected;
    // Layout 23 (ND2N8) and 25/26 (the other reverse-direction layouts) do
    // not define a Shared ND-to-Local CUBE Function-2 conversion.
    let invalid_nd2n8 = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 23, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, FALSE);
    assert invalid_nd2n8;
    let invalid_m16_to_nd = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 25, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, FALSE);
    assert invalid_m16_to_nd;
    let invalid_nd_to_n8 = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 26, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, FALSE);
    assert invalid_nd_to_n8;
    // Unsupported conversion selectors with an ExecutionMask carrier fault
    // before generic layout inference, destination allocation, or source mutation.
    let invalid_nd2n8_mask = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 23, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, TRUE);
    assert invalid_nd2n8_mask;
    let invalid_nd_to_n8_mask = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 26, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, TRUE);
    assert invalid_nd_to_n8_mask;
    // Function-2 conversion rejects matrix post-processing descriptors and
    // execution-mask carriers before destination allocation.
    let fpatr_rejected = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 21, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, TRUE, FALSE);
    assert fpatr_rejected;
    let execution_mask_rejected = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 21, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, FALSE, FALSE, TRUE);
    assert execution_mask_rejected;
    // A reverse Shared source cannot carry destination-generation assembly.
    let reverse_assemble = SharedNDToCubeSchemaRejects(
        TileDataType_U8, TileDataType_U8, 21, TileLayout_RowMajor,
        32, 128, 4096, Zeros{4} + 6, 0, TRUE, FALSE, FALSE);
    assert reverse_assemble;
    return 0;
end;
