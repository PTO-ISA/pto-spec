<!-- GENERATED FROM: asl/block/model/dispatch/timg2col-execution.asl -->
# Timg2col Execution

**Normative ASL source:** `asl/block/model/dispatch/timg2col-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-purpose role=purpose-scope -->
## Purpose and scope

This unit executes a `BSTART.TIMG2COL` bundle when it commits. It checks the complete bundle, reads the image from global memory (GM), and writes an IMG2COL matrix into either a Shared Tile or a Local CUBE Tile.

`ExecuteBundleTIMG2COLOperation` is the entry point. [Tile execution](tile-execution.md) calls it first among the specialized handlers when `BundleDescriptorSelectsTIMG2COL` is true, that is, for form identity 94 with TLSU Function 28.

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-concepts role=concepts-state -->
## Output kinds and inputs

The `B.DATR` layout selects one of three output kinds. `ND2M16` and `CUBE_M16` select Local M16, `ND2M32` and `CUBE_M32` select Local M32, and every other layout, including an absent `B.DATR`, selects Shared ND.

- Shared ND writes one Shared Tile named by one `B.IOS` and uses no `B.IOT`.
- Local M16 and Local M32 write one Local `CUBE_M16` or `CUBE_M32` Tile named by one `B.IOT` with PE mask `1111`, and use no `B.IOS`.

Two source-only `B.IOR` records carry the operands. The first holds the GM base address; the second holds three packed parameter words. The `B.DIM` values give ValidCol, ValidRow (1 to 128), and TotalCol.

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-rules role=rules-interactions -->
## Validation, build, and publication

`BundleTIMG2COLStateLegal` runs first and reads no memory. It checks the operation data type against a fixed code list, the `B.DATR` fields, the binding counts for the output kind, and that ValidRow is at most 64 for Local M16. It then checks both `B.IOR` records and requires every participating PE to hold equal GM base and parameter values. It rejects nonzero extension bits and zero sizes, and applies the crop rule from [TIMG2COL schema](timg2col-schema.md).

For Shared ND the Shared mask must be a single PE or `1111`, and it must include the current PE. A single-PE mask must not use `B.ASSEMBLE`. A `1111` mask must use it: PE 0 carries INIT, PE 3 carries LAST, and PEs 1 and 2 carry neither. The unit derives each writer's offset from its row start, in 32-byte units, and validates the generation range. For Local output the unit checks the `CUBE` descriptor shape of this PE's row share.

`BundleTIMG2COLBuildAndPublish` then works per PE. A Local PE with zero rows returns at once with no allocation or GM read. For a PE with at least one row, `BundleTIMG2COLPreflightGM` probes every GM address of all ValidRow rows before the first load.

Design point: the complete footprint is probed before any allocation, load event, or Shared generation change. A translation or permission fault therefore leaves no partial payload behind.

A Local PE then reuses a continuation destination or allocates a fresh `CUBE` Tile for its own PE bit. The unit fills each cell, reading GM only for cells that need it, and records a load event per read. Shared ND with one PE publishes through `AtomicUpdateSharedTile`. Shared ND with `1111` commits a candidate range into the open generation; the parent is published only when the gap-free LAST writer arrives.

If validation or build fails, `BundleTIMG2COLAbortFailedAttempt` aborts the Shared generation or rolls back the Local destination. A failure without a recorded fault becomes `Fault_TileLegality`; a memory fault keeps its own kind.

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-boundaries role=boundaries -->
## Architectural boundaries

Tile execution skips the generic effect-eligibility check, stage-2 preparation, Local continuation reuse, and ExecutionMask capture for this operation. It still applies the output-structure and Shared assembly-policy checks first. After success it commits Local generations, retires consumer dependencies, and finalizes the Tile attempt.

The single-argument `BundleTIMG2COLScalarCommandCanBePlaced` in this unit has no caller; command placement uses the three-argument function of the same name in [scalar schema](scalar-schema.md).

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Local M16 output with ValidRow 40 splits rows as 16, 16, 8, and 0. PE 3 has no rows, so it allocates nothing and reads nothing, but the bundle still completes.

Shared ND output with mask `1111`, FP16 data, ValidRow 64, and TotalCol 64 gives each PE 16 rows. `C0` is 16, so each writer covers 16 * 64 / 16 = 64 units. PE 1 starts at unit 64. A parent of 8192 bytes has 256 units, so the LAST writer, PE 3, starts at 192 and its coverage runs to 256.

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-related role=related-owners-navigation -->
## Related owners

- [TIMG2COL schema](timg2col-schema.md) defines the crop, row split, and cell mapping.
- [TIMG2COL parameters](../operands/timg2col-parameters.md) checks the two `B.IOR` records and unpacks the parameters.
- [TIMG2COL GM access](../memory/timg2col-gm.md) defines the GM index formulas and the preflight loop.
- [Shared generation](../operands/shared-generation.md) validates and commits cooperative ranges.
- [Tile execution](tile-execution.md) dispatches this handler and commits the result.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/timg2col-execution.asl -->
```asl
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
    if !BundleTIMG2COLDataTypeSupported(data_type) then
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
    if output != BundleTIMG2COLOutput_SharedND then
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid &&
               _BundleTileBindings[[binding]].destination_assemble.valid then
                return FALSE;
            end;
        end;
    end;
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
       (BundleSharedBindingPhysicalCount() != 1 || BundleTileBindingCount() != 0) then
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
        if BundleSharedGenerationCapacity(0) == 0 ||
           (PEMaskPopulation(shared_mask) != 1 && shared_mask != '1111') ||
           (shared_mask AND BundleTIMG2COLPEBit()) == Zeros{4} then
            return FALSE;
        end;
        let shared_capacity = TileSizeCodeBytes(
            BundleSharedGenerationCapacity(0) as integer {1..12});
        if !BundleTIMG2COLDestinationShapeLegal(output, shared_capacity,
               valid_row, valid_col, total_col, data_type) then
            return FALSE;
        end;
        let generation_metadata = BundleTIMG2COLGenerationMetadata(
            _BundleDataAttributes.data_layout, _BundleOperation.data_type,
            _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][7:0],
            _BundleDimensions[[2]][15:0],
            Zeros{4} + BundleSharedGenerationCapacity(0),
            BundleSharedBindingId(0));
        if shared_mask == '1111' then
            let assemble = _BundleSharedBindings[[0]].destination_assemble;
            let pe = BundleTIMG2COLCurrentPE();
            let expected_phase = if pe == 0 then assemble.init && !assemble.last
                else if pe == 3 then !assemble.init && assemble.last
                else !assemble.init && !assemble.last;
            if !assemble.valid || !expected_phase ||
               assemble.reg_src != 0 || assemble.uimm11 != Zeros{11} ||
               assemble.offset != Zeros{PTO_XLEN} ||
               (assemble.size_code < 1 || assemble.size_code > 12) then
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
        BundleSharedBindingSize(0) as integer {1..12}) * 4 else
        _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].parent_cell_count;
    if offset_cells > parent_cells then return (FALSE, 0); end;
    return (TRUE, (parent_cells - offset_cells) as integer {0..8192});
end;

func BundleTIMG2COLBuildAndPublish() => boolean
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
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
        TileSizeCodeBytes(BundleSharedGenerationCapacity(0)
            as integer {1..12})
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
        let binding = _BundleTileBindings[[0]];
        let expected_layout =
            if output == BundleTIMG2COLOutput_LocalM16 then
                TileLayout_CUBE_M16
            else TileLayout_CUBE_M32;
        if binding.destination_reused_by_generation then
            destination = binding.destination;
            let reused = _Tiles[[destination]];
            if !TileCubeDescriptorLegal(reused) ||
               reused.capacity_bytes != capacity ||
               reused.valid_rows != pe_valid_row ||
               reused.valid_columns != valid_col ||
               reused.data_type != data_type ||
               reused.layout != expected_layout then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        else
            let hand = UInt(binding.destination_hand);
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
                   expected_layout, BundleTIMG2COLPEBit()) then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
            _BundleTileBindings[[0]].destination = destination;
            _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
        end;
        candidate = _Tiles[[destination]];
        // The destination now carries the exact current writer descriptor.
        // Reject malformed WriterSize/common metadata/tail/finalization before
        // the first GM event, payload update, coverage change, or publication.
        if !ValidateBundleLocalGenerationWriters() then return FALSE; end;
    end;
    candidate.allocated = TRUE;
    candidate.storage_kind = TileStorage_Numeric;
    candidate.contents_defined = FALSE;
    candidate.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    candidate.packed_defined_elements = zero_packed_tile_elements;
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
                Zeros{4} + BundleSharedGenerationCapacity(0),
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
       BundleSharedBindingPhysicalCount() == 1 &&
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
```
<!-- GENERATED-ASL-END: unit -->
