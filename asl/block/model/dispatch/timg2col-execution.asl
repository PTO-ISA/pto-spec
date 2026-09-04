// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION","surface":"block","classification":["model","dispatch","timg2col-execution"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS","PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM"]}
readonly func BundleTIMG2COLDataTypeSupported(data_type: TileDataType)
    => boolean
begin
    let code = UInt(TileDataTypeToEncoding(data_type));
    return code == 1 || code == 2 || code == 3 || code == 4 || code == 5 ||
           code == 6 || code == 7 || code == 8 || code == 13 ||
           code == 17 || code == 18 || code == 19 || code == 25 ||
           code == 26 || code == 27;
end;

readonly func BundleTIMG2COLCurrentPE() => integer {0..3}
begin
    return _CurrentMemoryAgent as integer {0..3};
end;

readonly func BundleTIMG2COLPEValidRow(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128})
    => integer {0..32}
begin
    return BundleTIMG2COLValidRowForOutput(
        output, valid_row, BundleTIMG2COLCurrentPE());
end;

readonly func BundleTIMG2COLPERowStart(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128},
    row_start: integer)
    => integer
begin
    return BundleTIMG2COLRowStartForOutput(output, valid_row, row_start,
        BundleTIMG2COLCurrentPE());
end;

readonly func BundleTIMG2COLPEBit() => bits(4)
begin
    var result = Zeros{4};
    result[PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] = '1';
    return result;
end;

readonly func BundleTIMG2COLStateOutput() => BundleTIMG2COLOutputKind
begin
    let layout = TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
    if layout == TileDataLayout_ND2M16 || layout == TileDataLayout_CUBE_M16 then
        return BundleTIMG2COLOutput_LocalM16;
    elsif layout == TileDataLayout_ND2M32 || layout == TileDataLayout_CUBE_M32 then
        return BundleTIMG2COLOutput_LocalM32;
    end;
    return BundleTIMG2COLOutput_SharedND;
end;

readonly func BundleTIMG2COLScalarCommandCanBePlaced(
    binding_index: integer {0..1}) => boolean
begin
    if !_BundleActive || _BundleBodyActive ||
       _BundleScalarBindings[[binding_index]].valid then
        return FALSE;
    end;
    if binding_index == 0 then return TRUE; end;
    return _BundleScalarBindings[[0]].valid &&
           BundleTIMG2COLIORSecondExpected();
end;

func BundleTIMG2COLStateLegal() => boolean
begin
    if !BundleTIMG2COLSelected() ||
       !_BundleOperation.data_type_valid ||
       !BundleDataTypeConcrete(_BundleOperation.data_type) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    if !BundleTIMG2COLDataTypeSupported(data_type) ||
       !BundleTIMG2COLDimensionRolesComplete(
           _BundleDimensionPresent[[0]], _BundleDimensionPresent[[1]],
           _BundleDimensionPresent[[2]]) then
        return FALSE;
    end;
    if _BundleDataAttributesPresent &&
       !InstructionContractB_DATR_TIMG2COLFieldsLegal(
           TileDataLayoutOfCode(_BundleDataAttributes.data_layout),
           _BundleDataAttributes.data_type,
           _BundleDataAttributes.pad_value,
           _BundleDataAttributes.comparison_mode,
           _BundleDataAttributes.rounding_mode,
           _BundleDataAttributes.saturating,
           _BundleDataAttributes.canonicalize) then
        return FALSE;
    end;
    let output = BundleTIMG2COLStateOutput();
    let valid_col_raw = UInt(_BundleDimensions[[0]]);
    let valid_row_raw = UInt(_BundleDimensions[[1]]);
    let total_col_raw = UInt(_BundleDimensions[[2]]);
    if valid_col_raw == 0 || valid_col_raw > 65535 || valid_row_raw == 0 ||
       valid_row_raw > 128 || total_col_raw == 0 || total_col_raw > 65535 then
        return FALSE;
    end;
    let valid_col = valid_col_raw as integer {1..65535};
    let valid_row = valid_row_raw as integer {1..128};
    let total_col = total_col_raw as integer {1..65535};
    if output == BundleTIMG2COLOutput_LocalM16 && valid_row > 64 then
        return FALSE;
    end;
    if output == BundleTIMG2COLOutput_SharedND &&
       (BundleSharedBindingCount() != 1 || BundleTileBindingCount() != 0) then
        return FALSE;
    end;
    if output != BundleTIMG2COLOutput_SharedND &&
       (BundleSharedBindingCount() != 0 || BundleTileBindingCount() != 1) then
        return FALSE;
    end;
    if !_BundleScalarBindings[[0]].valid ||
       !_BundleScalarBindings[[1]].valid ||
       _BundleScalarBindings[[0]].source_count != 3 ||
       _BundleScalarBindings[[1]].source_count != 3 ||
       _BundleScalarBindings[[0]].destination != 0 ||
       _BundleScalarBindings[[1]].destination != 0 then
        return FALSE;
    end;
    let participant_mask = if output == BundleTIMG2COLOutput_SharedND then
        BundleSharedBindingMask(0) else '1111';
    if !BundleTIMG2COLIORBindingsPreflight(participant_mask) then
        return FALSE;
    end;
    let param0 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source0);
    let param1 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source1);
    let param2 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source2);
    let gm_base = ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0);
    if !BundleTIMG2COLBaseParameterExtensionLegal(param1) then return FALSE; end;
    let parameters = BundleTIMG2COLParametersFromWords(param0, param1, param2);
    if !BundleTIMG2COLParametersLegal(parameters) then return FALSE; end;
    let shape = BundleTIMG2COLShape {
        valid_col = valid_col, valid_row = valid_row,
        total_col = total_col, data_type = data_type,
        input_h = parameters.input_h as integer {1..65535},
        input_w = parameters.input_w as integer {1..65535},
        cin = parameters.cin as integer {1..65535},
        kernel_h = parameters.kernel_h as integer {1..255},
        kernel_w = parameters.kernel_w as integer {1..255},
        pad_top = parameters.pad_top, pad_left = parameters.pad_left,
        pad_bottom = parameters.pad_bottom, pad_right = parameters.pad_right,
        dilation_h = parameters.dilation_h as integer {1..31},
        dilation_w = parameters.dilation_w as integer {1..31},
        conv_stride_h = parameters.conv_stride_h as integer {1..63},
        conv_stride_w = parameters.conv_stride_w as integer {1..63},
        row_start = parameters.row_start, col_start = parameters.col_start
    };
    if !BundleTIMG2COLShapeLegal(shape) then return FALSE; end;
    if output == BundleTIMG2COLOutput_SharedND then
        let shared_mask = BundleSharedBindingMask(0);
        if BundleSharedBindingSize(0) == 0 ||
           (PEMaskPopulation(shared_mask) != 1 && shared_mask != '1111') ||
           (shared_mask AND BundleTIMG2COLPEBit()) == Zeros{4} then
            return FALSE;
        end;
        let shared_capacity = TileSizeCodeBytes(
            BundleSharedBindingSize(0) as integer {1..12});
        if !BundleTIMG2COLDestinationShapeLegal(output, shared_capacity,
               valid_row, valid_col, total_col, data_type) then
            return FALSE;
        end;
        let generation_metadata = BundleTIMG2COLGenerationMetadata(
            _BundleDataAttributes.data_layout, _BundleOperation.data_type,
            _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][7:0],
            _BundleDimensions[[2]][15:0],
            Zeros{4} + BundleSharedBindingSize(0), BundleSharedBindingId(0));
        if shared_mask == '1111' then
            let assemble = _BundleSharedBindings[[0]].destination_assemble;
            let pe = BundleTIMG2COLCurrentPE();
            let expected_phase = if pe == 0 then assemble.init && !assemble.last
                else if pe == 3 then !assemble.init && assemble.last
                else !assemble.init && !assemble.last;
            if !assemble.valid || !expected_phase ||
               assemble.reg_src != 0 || assemble.uimm11 != Zeros{11} ||
               assemble.offset != Zeros{PTO_XLEN} ||
               (assemble.init && assemble.size_code == 0) ||
               (!assemble.init && assemble.size_code != 0) then
                return FALSE;
            end;
            let c0 = BundleTIMG2COLC0Elements(data_type);
            let writer_cells =
                (BundleTIMG2COLPEValidRow(output, valid_row) *
                    (total_col DIVRM c0)) as integer {0..8192};
            let derived_offset =
                (BundleTIMG2COLPERowStart(output,
                    valid_row, 0) *
                    total_col) DIVRM c0;
            if derived_offset > 8192 then return FALSE; end;
            let (coverage_legal, coverage_cells) =
                BundleTIMG2COLGenerationCoverage(
                    derived_offset as integer {0..8192}, writer_cells);
            if !coverage_legal then return FALSE; end;
            _BundleSharedBindings[[0]].destination_assemble.offset =
                Zeros{PTO_XLEN} + derived_offset;
            if !ValidateBundleSharedGenerationRange(0,
                   derived_offset as integer {0..8192}, coverage_cells,
                   BundleTIMG2COLPEBit(), TRUE, gm_base,
                   param0, param1, param2, generation_metadata) then
                return FALSE;
            end;
        elsif _BundleSharedBindings[[0]].destination_assemble.valid then
            return FALSE;
        end;
    else
        let binding = _BundleTileBindings[[0]];
        let expected_layout = if output == BundleTIMG2COLOutput_LocalM16 then
            TileLayout_CUBE_M16 else TileLayout_CUBE_M32;
        if !binding.valid || !binding.destination_valid ||
           binding.source0_valid || binding.source1_valid || !binding.last ||
           binding.pe_mask != '1111' ||
           (BundleTIMG2COLPEValidRow(output, valid_row) != 0 &&
            !TileCubeDescriptorShapeLegal(
               BundleTileDestinationSizeBytes(0),
               BundleTIMG2COLPEValidRow(output, valid_row), valid_col,
               data_type, expected_layout)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleTIMG2COLGenerationCoverage(
    offset_cells: integer {0..8192}, writer_cells: integer {0..8192})
    => (boolean, integer {0..8192})
begin
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    if !assemble.last then return (TRUE, writer_cells); end;
    let shared_tile_id = BundleSharedBindingId(0);
    let parent_cells = if assemble.init then BundleLocalGenerationCellCount(
        assemble.size_code as integer {1..12}) * 4 else
        _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].parent_cell_count;
    if offset_cells > parent_cells then return (FALSE, 0); end;
    return (TRUE, (parent_cells - offset_cells) as integer {0..8192});
end;

func BundleTIMG2COLBuildAndPublish() => boolean
begin
    let output = BundleTIMG2COLStateOutput();
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    let valid_col = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_row = UInt(_BundleDimensions[[1]]) as integer {1..128};
    let total_col = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    var cooperative = TRUE;
    if output == BundleTIMG2COLOutput_SharedND then
        cooperative = BundleSharedBindingMask(0) == '1111';
    end;
    let pe_valid_row = if cooperative then
        BundleTIMG2COLPEValidRow(output, valid_row) else valid_row;
    let encoded_row_start = UInt(ReadScalarRegisterOperand(
        _BundleScalarBindings[[1]].source2)[31:0]);
    let pe_row_start = if cooperative then
        BundleTIMG2COLPERowStart(output, valid_row, encoded_row_start)
        else encoded_row_start;
    let param0 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source0);
    let param1 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source1);
    let param2 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source2);
    let base_parameters = BundleTIMG2COLParametersFromWords(
        param0, param1, param2);
    var parameters = base_parameters;
    parameters.row_start = pe_row_start as integer {0..4294967295};
    let layout = TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
    let gm_base = ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0);
    let element_bytes = TileMemoryElementBytes(data_type);
    // Zero-row cooperative PEs complete the collective protocol but have no
    // Local allocation, GM read, payload write, or definedness effect.
    if pe_valid_row == 0 && output != BundleTIMG2COLOutput_SharedND then
        return TRUE;
    end;
    if pe_valid_row != 0 &&
       !BundleTIMG2COLPreflightGM(layout, data_type, base_parameters,
           valid_row, valid_col, gm_base, element_bytes) then
        return FALSE;
    end;
    let capacity = if output == BundleTIMG2COLOutput_SharedND then
        TileSizeCodeBytes(BundleSharedBindingSize(0) as integer {1..12})
        else BundleTileDestinationSizeBytes(0);
    let rows_to_write = if output == BundleTIMG2COLOutput_SharedND &&
        BundleSharedBindingMask(0) != '1111' then valid_row else pe_valid_row;
    let rows = DerivedTileRows(capacity, total_col, data_type);
    var destination: TileIndex = 0;
    var candidate: TileInfo;
    var mask = '1111';
    if output == BundleTIMG2COLOutput_SharedND then
        destination = 0;
        candidate = SharedTileRecord(BundleSharedBindingId(0)).tile;
        mask = BundleSharedBindingMask(0);
    else
        let hand = UInt(_BundleTileBindings[[0]].destination_hand);
        var found = FALSE;
        for offset = 0 to 15 do
            let raw_index = hand * 16 + offset;
            if !found && !_Tiles[[raw_index]].allocated then
                destination = raw_index as TileIndex;
                found = TRUE;
            end;
        end;
        if !found || !ConfigureCubeTileForMask(
               destination, capacity, pe_valid_row, valid_col, data_type,
               if output == BundleTIMG2COLOutput_LocalM16 then
                   TileLayout_CUBE_M16 else TileLayout_CUBE_M32,
               TileLocation_Matrix, BundleTIMG2COLPEBit()) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
        _BundleTileBindings[[0]].destination = destination;
        _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
        candidate = _Tiles[[destination]];
    end;
    candidate.allocated = TRUE;
    candidate.storage_kind = TileStorage_Numeric;
    candidate.contents_defined = FALSE;
    candidate.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    candidate.packed_defined_elements = ZeroPackedTileDefinedElements();
    candidate.defined_valid_elements = 0;
    if output == BundleTIMG2COLOutput_SharedND then
        candidate.capacity_bytes = capacity;
        candidate.rows = rows;
        candidate.columns = total_col;
        candidate.valid_rows = if mask == '1111' then pe_valid_row else valid_row;
        candidate.valid_columns = valid_col;
        candidate.data_type = data_type;
        candidate.predicate_basis_type = data_type;
        candidate.layout = TileLayout_RowMajor;
        candidate.location = TileLocation_Any;
    end;
    for row = 0 to rows_to_write - 1 looplimit 128 do
        for col = 0 to valid_col - 1 looplimit 65535 do
            let cell = BundleTIMG2COLCell(layout, data_type, parameters,
                row as integer {0..127}, col as integer {0..65534});
            var value = Zeros{PTO_XLEN};
            if cell.gm_access then
                let byte_offset: integer = cell.gm_index * element_bytes;
                let address = gm_base + byte_offset;
                if UInt(address) < UInt(gm_base) then
                    SetFault(Fault_DataPage, address);
                    return FALSE;
                end;
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return FALSE; end;
                let raw = LoadTranslatedUnsigned(probe.translated_address,
                    element_bytes);
                RecordLoadEvent(probe.translated_address, element_bytes, raw,
                    CurrentBundleMemoryOrder());
                value = DecodeTileMemoryElementRaw(raw, data_type,
                    TileMemoryStridedByteHighNibble(col, data_type));
            end;
            let element = TileLogicalLinearIndex(candidate,
                row as integer {0..65535}, col as integer {0..65535});
            candidate = TileInfoWithLogicalElement(candidate, element, value);
        end;
    end;
    candidate.contents_defined = TRUE;
    candidate.defined_valid_elements =
        (rows_to_write * valid_col) as integer {0..524288};
    if output == BundleTIMG2COLOutput_SharedND then
        if mask == '1111' then
            let c0 = BundleTIMG2COLC0Elements(data_type);
            let destination_row_start = BundleTIMG2COLPERowStart(
                output, valid_row, 0);
            let derived_offset = (destination_row_start * total_col) DIVRM c0;
            let writer_cells = (pe_valid_row * (total_col DIVRM c0))
                as integer {0..8192};
            let generation_metadata = BundleTIMG2COLGenerationMetadata(
                _BundleDataAttributes.data_layout, _BundleOperation.data_type,
                _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][7:0],
                _BundleDimensions[[2]][15:0],
                Zeros{4} + BundleSharedBindingSize(0),
                BundleSharedBindingId(0));
            if derived_offset > 8192 then return FALSE; end;
            let (coverage_legal, coverage_cells) =
                BundleTIMG2COLGenerationCoverage(
                    derived_offset as integer {0..8192}, writer_cells);
            if !coverage_legal then return FALSE; end;
            _BundleSharedBindings[[0]].destination_assemble.offset =
                Zeros{PTO_XLEN} + derived_offset;
            if !CommitBundleSharedGenerationCandidateRange(
                   0, SharedTileInfo {
                       descriptor_valid = TRUE,
                       allocation_mask = mask,
                       initialized_mask = BundleTIMG2COLPEBit(),
                       whole_parent_ready = FALSE,
                       published = FALSE,
                       tile = candidate },
                   derived_offset as integer {0..8192}, coverage_cells,
                   writer_cells, BundleTIMG2COLPEBit(), TRUE, gm_base,
                   param0, param1, param2, generation_metadata) then
                AbortBundleSharedGeneration(
                    BundleSharedBindingId(0));
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        elsif !AtomicUpdateSharedTile(
               BundleSharedBindingId(0), candidate, mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    else
        _Tiles[[destination]] = candidate;
    end;
    return TRUE;
end;

func BundleTIMG2COLAbortFailedAttempt()
begin
    if BundleTIMG2COLSelected() &&
       BundleSharedBindingCount() == 1 &&
       _BundleSharedBindings[[0]].destination_assemble.valid then
        AbortBundleSharedGeneration(BundleSharedBindingId(0));
    elsif BundleTIMG2COLSelected() && BundleTileBindingCount() == 1 then
        RollBackBundleTileDestinations();
    end;
end;

func ExecuteBundleTIMG2COLOperation() => boolean
begin
    if !BundleTIMG2COLStateLegal() then
        BundleTIMG2COLAbortFailedAttempt();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleTIMG2COLBuildAndPublish() then
        BundleTIMG2COLAbortFailedAttempt();
        if _LastFault == Fault_None then SetFault(Fault_TileLegality, ReadTPC()); end;
        return FALSE;
    end;
    return TRUE;
end;
