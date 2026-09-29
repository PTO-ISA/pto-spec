<!-- GENERATED FROM: asl/block/model/dispatch/weight-to-shared-execution.asl -->
# Weight To Shared Execution

**Normative ASL source:** `asl/block/model/dispatch/weight-to-shared-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-purpose role=purpose-scope -->
## Purpose and scope

This unit executes a weight-mode `TLOAD` bundle when it commits. It validates the complete bundle, reads the weight crop from global memory (GM), and writes it into one Shared Tile as a row-major N by K matrix. One PE may write the whole Tile, or several PEs may each write a contiguous band of rows.

`ExecuteBundleWeightTLOADOperation` is the entry point. [Tile execution](tile-execution.md) calls it when `BundleWeightTLOADSelected` is true and the bundle is not a TIMG2COL bundle.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-concepts role=concepts-state -->
## Inputs and state

- One `B.IOS` names the Shared destination. It either carries a size code (a new destination) or is a reused assembly destination with size code 0. There is no `B.IOT`.
- One `B.IOR` record with three sources and a zero destination carries GMBase, ShapeGPR, and StartGPR. ShapeGPR packs `Cin`, `Cout`, `KernelH`, and `KernelW`; StartGPR packs NStart and KStart.
- `B.DIM` gives ValidCol, ValidRow, and TotalCol.
- The data type comes from the `BSTART` descriptor. `B.DATR` supplies only the layout; its own DataType field must be none.

The unit writes the Shared Tile record for a single writer, or the open Shared generation for cooperative writers. It also records a load event for each GM element it reads.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-rules role=rules-interactions -->
## Validation, build, and publication

A strict no-op comes first. If a zero-participation binder was seen and no Tile or Shared binding exists, the unit returns success without checking anything else.

`BundleWeightTLOADStateLegal` then checks the descriptor type, the `B.DATR` fields, the binding shape, and the `B.IOR` record. A zero Shared mask is legal and does nothing. Otherwise the mask must include the current PE, and every selected PE must hold equal GMBase, ShapeGPR, and StartGPR values. Dimensions must lie in 1 to 65535, ShapeGPR bits 48 to 63 must be zero, and the four sizes must be nonzero. The [schema](weight-to-shared-schema.md) shape rule must hold, and ValidRow rows of TotalCol columns must fit the parent capacity.

A single selected PE must not use `B.ASSEMBLE`. With more PEs, `B.ASSEMBLE` is required: the first selected PE carries INIT, the last carries LAST, and the others carry neither. The encoded register, immediate, and offset must be zero. The unit derives each writer's offset from its row start, in 32-byte units, and, for a nonempty band, requires the writer size code to equal the exact bytes of its row band. It then validates the generation range, including GMBase, the two parameter words, and a metadata word.

Design point: the writer's offset is derived, not encoded, and its size must match its row span exactly. Every participant's destination range is therefore fixed by ValidRow, TotalCol, the selected mask, and PE order; NStart moves only the GM source rows. The NDF clause `PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001` rejects a size code that disagrees.

`BundleWeightTLOADBuildAndPublish` calls `BundleWeightTLOADPreflightGM` over all ValidRow rows, not only this PE's band, before its first load.

Design point: each participant proves the complete selected-PE footprint before any participant issues a GM read. A fault in any band therefore stops every writer before a load event is recorded.

The unit then fills its rows. Cin padding lanes become raw zero without a GM access. A single writer publishes through `AtomicUpdateSharedTile`; if that update fails, the fault is `Fault_TileAllocation`. A cooperative writer commits its range into the open generation, which publishes the parent only after a gap-free LAST writer arrives.

On any failure, `BundleWeightTLOADAbortFailedAttempt` aborts an open assembly generation. A failure without a recorded fault becomes `Fault_TileLegality`.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-boundaries role=boundaries -->
## Architectural boundaries

Tile execution routes this operation before generic stage-2 preparation and Local continuation reuse. It still applies the output-structure and Shared assembly-policy checks first, and it aborts all Local and Shared generations of the bundle if this unit fails.

The GM index of each cell, in OHWI or OIHW order, belongs to [weight-to-shared GM access](../memory/weight-to-shared-gm.md). The row split and shape rule belong to the [schema](weight-to-shared-schema.md) unit.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Four PEs load FP16 weights with ValidRow 64, ValidCol 64, and TotalCol 64 into a Shared parent with size code 7, which is 8192 bytes. Each PE writes 16 rows of 64 elements, which is 2048 bytes, so every writer size code must be 5.

`C0` is 16, so the offsets are 0, 64, 128, and 192 units of 32 bytes. The parent has 256 units. PE 0 carries INIT, PE 3 carries LAST, and the parent is published after PE 3 covers units 192 to 256.

If only PE 2 is selected, the bundle must omit `B.ASSEMBLE`, and PE 2 writes all 64 rows and publishes directly.

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-related role=related-owners-navigation -->
## Related owners

- [Weight-to-shared schema](weight-to-shared-schema.md) defines selection, the shape rule, and the row split.
- [Weight-to-shared parameters](../operands/weight-to-shared-parameters.md) unpacks the words and checks equal participant values.
- [Weight-to-shared GM access](../memory/weight-to-shared-gm.md) defines the cell mapping and GM preflight.
- [Shared generation](../operands/shared-generation.md) validates and commits cooperative ranges.
- [Tile execution](tile-execution.md) dispatches this handler.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/weight-to-shared-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC","surface":"block","classification":["model","dispatch","weight-to-shared-execution"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-FAULTS-ROLLBACK"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001
// ndf: kind=contract level=L1 layer=concurrency status=accepted
// A singleton nonzero Shared mask publishes without B.ASSEMBLE. Any
// multi-participant mask uses the existing Shared B.ASSEMBLE protocol, assigns
// contiguous physical N-row ranges in PE order, requires each nonempty encoded
// writer SizeCode to equal its complete-row span, and publishes only after a
// complete selected-PE GM preflight and matching gap-free LAST generation.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001
readonly func BundleWeightTLOADGenerationCoverage(
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

pure func BundleWeightTLOADWriterCells(size_code: integer {1..12})
    => integer {4..8192}
begin
    return (BundleLocalGenerationCellCount(size_code) * 4)
        as integer {4..8192};
end;

readonly func BundleWeightTLOADParentSizeCode(mask: bits(4)) => integer
begin
    if PEMaskPopulation(mask) == 1 then
        return BundleSharedBindingSize(0);
    end;
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    if assemble.init then return BundleSharedBindingSize(0); end;
    return BundleSharedGenerationCapacity(0);
end;

readonly func BundleWeightTLOADStateLegal() => boolean
begin
    if !BundleWeightTLOADSelected() ||
       !_BundleOperation.data_type_valid ||
       !BundleDataTypeConcrete(_BundleOperation.data_type) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    if !BundleWeightTLOADDataTypeSupported(data_type) ||
       !InstructionContractB_DATR_TLOADWeightFieldsLegal(
           TileDataLayoutOfCode(_BundleDataAttributes.data_layout),
           _BundleDataAttributes.data_type,
           _BundleDataAttributes.pad_value,
           _BundleDataAttributes.comparison_mode,
           _BundleDataAttributes.rounding_mode,
           _BundleDataAttributes.saturating,
           _BundleDataAttributes.canonicalize) then
        return FALSE;
    end;
    if BundleSharedBindingPhysicalCount() != 1 || BundleTileBindingCount() != 0 ||
       ((!BundleSharedBindingIsReusedDestination(0) &&
         !BundleSharedBindingIsDestination(0)) ||
        (BundleSharedBindingIsReusedDestination(0) &&
         _BundleSharedBindings[[0]].size_code != 0)) ||
       (!BundleSharedBindingIsReusedDestination(0) &&
        !TileSizeCodeIsLegal(BundleSharedBindingSize(0))) ||
       !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid ||
       _BundleScalarBindings[[0]].source_count != 3 ||
       _BundleScalarBindings[[0]].destination != 0 then
        return FALSE;
    end;
    let mask = BundleSharedBindingMask(0);
    if mask == Zeros{4} then return TRUE; end;
    if (mask AND BundleWeightTLOADPEBit()) == Zeros{4} ||
       !BundleWeightTLOADParticipantValuesEqual(mask) then
        return FALSE;
    end;
    let valid_col_raw = UInt(_BundleDimensions[[0]]);
    let valid_row_raw = UInt(_BundleDimensions[[1]]);
    let total_col_raw = UInt(_BundleDimensions[[2]]);
    if valid_col_raw == 0 || valid_col_raw > 65535 ||
       valid_row_raw == 0 || valid_row_raw > 65535 ||
       total_col_raw == 0 || total_col_raw > 65535 then
        return FALSE;
    end;
    let shape_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source1);
    let start_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source2);
    if !BundleWeightTLOADShapeReservedBitsLegal(shape_word) then return FALSE; end;
    let parameters = BundleWeightTLOADParametersFromWords(
        shape_word, start_word);
    if parameters.cin == 0 || parameters.cout == 0 ||
       parameters.kernel_h == 0 || parameters.kernel_w == 0 then
        return FALSE;
    end;
    let shape = BundleWeightTLOADShape {
        valid_col = valid_col_raw as integer {1..65535},
        valid_row = valid_row_raw as integer {1..65535},
        total_col = total_col_raw as integer {1..65535},
        data_type = data_type,
        cin = parameters.cin as integer {1..65535},
        cout = parameters.cout as integer {1..65535},
        kernel_h = parameters.kernel_h as integer {1..255},
        kernel_w = parameters.kernel_w as integer {1..255},
        n_start = parameters.n_start,
        k_start = parameters.k_start
    };
    if !BundleWeightTLOADShapeLegal(shape) then return FALSE; end;
    let population = PEMaskPopulation(mask);
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    let parent_size_code = BundleWeightTLOADParentSizeCode(mask);
    if parent_size_code < 1 || parent_size_code > 12 then return FALSE; end;
    let capacity = TileSizeCodeBytes(
        parent_size_code as integer {1..12});
    let rows = DerivedTileRows(capacity, shape.total_col, data_type);
    if rows == 0 || shape.valid_row > rows ||
       shape.valid_row * shape.total_col >
           TileLogicalElementCapacity(capacity, data_type) then
        return FALSE;
    end;
    if population == 1 then return !assemble.valid; end;
    let current_pe = _CurrentMemoryAgent as integer {0..3};
    let first_pe = BundleWeightTLOADFirstPE(mask);
    let last_pe = BundleWeightTLOADLastPE(mask);
    let expected_phase = if current_pe == first_pe then
        assemble.init && !assemble.last
        else if current_pe == last_pe then !assemble.init && assemble.last
        else !assemble.init && !assemble.last;
    if !assemble.valid || !expected_phase || assemble.reg_src != 0 ||
       assemble.uimm11 != Zeros{11} || assemble.offset != Zeros{PTO_XLEN} ||
       (assemble.size_code < 1 || assemble.size_code > 12) then
        return FALSE;
    end;
    let rank = BundleWeightTLOADCurrentPERank(mask);
    let destination_row_start = BundleWeightTLOADRowStartForRank(
        0, shape.valid_row, mask, rank);
    let rows_to_write = BundleWeightTLOADRowsForRank(
        shape.valid_row, mask, rank);
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let derived_offset_numerator = destination_row_start * shape.total_col;
    if (derived_offset_numerator MOD c0) != 0 then return FALSE; end;
    let derived_offset = derived_offset_numerator DIVRM c0;
    let intended_writer_bytes: integer = rows_to_write * shape.total_col *
        TileMemoryElementBytes(data_type);
    let encoded_writer_bytes = TileSizeCodeBytes(
        assemble.size_code as integer {1..12});
    if rows_to_write != 0 && intended_writer_bytes != encoded_writer_bytes then
        return FALSE;
    end;
    let encoded_writer_cells = BundleWeightTLOADWriterCells(
        assemble.size_code as integer {1..12});
    let payload_cells = if rows_to_write == 0 then 0 else encoded_writer_cells;
    if derived_offset > 8192 then return FALSE; end;
    let (coverage_legal, coverage_cells) = BundleWeightTLOADGenerationCoverage(
        derived_offset as integer {0..8192}, payload_cells);
    if !coverage_legal then return FALSE; end;
    let gm_base = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source0);
    let generation_metadata = BundleWeightTLOADGenerationMetadata(
        _BundleDataAttributes.data_layout, _BundleOperation.data_type,
        _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][15:0],
        _BundleDimensions[[2]][15:0],
        Zeros{4} + (parent_size_code as integer {1..12}));
    return ValidateBundleSharedGenerationRange(0,
        derived_offset as integer {0..8192}, coverage_cells,
        BundleWeightTLOADPEBit(), TRUE, gm_base, shape_word, start_word,
        generation_metadata, Zeros{PTO_XLEN});
end;

func BundleWeightTLOADBuildAndPublish() => boolean
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    let layout = TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
    let valid_col = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_row = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let total_col = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    let mask = BundleSharedBindingMask(0);
    if mask == Zeros{4} then return TRUE; end;
    let shape_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source1);
    let start_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source2);
    let base_parameters = BundleWeightTLOADParametersFromWords(
        shape_word, start_word);
    let cooperative = PEMaskPopulation(mask) > 1;
    let rank = if cooperative then BundleWeightTLOADCurrentPERank(mask) else 0;
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    let rows_to_write = if cooperative then BundleWeightTLOADRowsForRank(
        valid_row, mask, rank) else valid_row;
    let destination_row_start = if cooperative then
        BundleWeightTLOADRowStartForRank(0, valid_row, mask, rank) else 0;
    var parameters = base_parameters;
    parameters.n_start = (base_parameters.n_start + destination_row_start)
        as integer {0..4294967295};
    let gm_base = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source0);
    let element_bytes = TileMemoryElementBytes(data_type);
    // Every participant proves the complete selected-PE footprint before any
    // participant may issue the first architectural GM read.
    if !BundleWeightTLOADPreflightGM(layout, data_type, base_parameters,
           valid_row, valid_col, gm_base, element_bytes) then
        return FALSE;
    end;
    let parent_size_code = BundleWeightTLOADParentSizeCode(mask);
    let capacity = TileSizeCodeBytes(
        parent_size_code as integer {1..12});
    let rows = DerivedTileRows(capacity, total_col, data_type);
    var candidate = SharedTileRecord(BundleSharedBindingId(0)).tile;
    candidate.allocated = TRUE;
    candidate.storage_kind = TileStorage_Numeric;
    candidate.capacity_bytes = capacity;
    candidate.rows = rows;
    candidate.columns = total_col;
    candidate.valid_rows = rows_to_write;
    candidate.valid_columns = valid_col;
    candidate.data_type = data_type;
    candidate.predicate_basis_type = data_type;
    candidate.layout = TileLayout_RowMajor;
    candidate.contents_defined = FALSE;
    candidate.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    candidate.packed_defined_elements = zero_packed_tile_elements;
    candidate.defined_valid_elements = 0;
    for row = 0 to rows_to_write - 1 looplimit 65535 do
        for col = 0 to valid_col - 1 looplimit 65535 do
            let cell = BundleWeightTLOADCell(layout, data_type, parameters,
                row as integer {0..65534}, col as integer {0..65534});
            var value = Zeros{PTO_XLEN};
            if cell.gm_access then
                let byte_offset = (cell.gm_index * element_bytes)
                    as integer {0..18446744073709551615};
                let address = gm_base + byte_offset;
                if UInt(address) < UInt(gm_base) then
                    SetFault(Fault_DataPage, address);
                    return FALSE;
                end;
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return FALSE; end;
                let raw = LoadTranslatedUnsigned(
                    probe.translated_address, element_bytes);
                RecordLoadEvent(probe.translated_address, element_bytes, raw,
                    CurrentBundleMemoryOrder());
                value = DecodeTileMemoryElementRaw(raw, data_type, FALSE);
            end;
            let element = TileLogicalLinearIndex(candidate,
                row as integer {0..65535}, col as integer {0..65535});
            candidate = TileInfoWithLogicalElement(candidate, element, value);
        end;
    end;
    candidate.contents_defined = TRUE;
    candidate.defined_valid_elements =
        (rows_to_write * valid_col) as integer {0..524288};
    if !cooperative then
        candidate.valid_rows = valid_row;
        if !AtomicUpdateSharedTile(BundleSharedBindingId(0), candidate, mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let derived_offset = (destination_row_start * total_col) DIVRM c0;
    let encoded_writer_cells = BundleWeightTLOADWriterCells(
        assemble.size_code as integer {1..12});
    let payload_cells = if rows_to_write == 0 then 0 else encoded_writer_cells;
    let (coverage_legal, coverage_cells) = BundleWeightTLOADGenerationCoverage(
        derived_offset as integer {0..8192}, payload_cells);
    if !coverage_legal then return FALSE; end;
    _BundleSharedBindings[[0]].destination_assemble.offset =
        Zeros{PTO_XLEN} + derived_offset;
    let generation_metadata = BundleWeightTLOADGenerationMetadata(
        _BundleDataAttributes.data_layout, _BundleOperation.data_type,
        _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][15:0],
        _BundleDimensions[[2]][15:0],
        Zeros{4} + (parent_size_code as integer {1..12}));
    if !CommitBundleSharedGenerationCandidateRange(0,
           SharedTileInfo {
               descriptor_valid = TRUE,
               allocation_mask = mask,
               initialized_mask = BundleWeightTLOADPEBit(),
               whole_parent_ready = FALSE,
               published = FALSE,
               tile = candidate },
           derived_offset as integer {0..8192}, coverage_cells,
           payload_cells, BundleWeightTLOADPEBit(), TRUE,
           gm_base, shape_word, start_word, generation_metadata,
           Zeros{PTO_XLEN}) then
        AbortBundleSharedGeneration(BundleSharedBindingId(0));
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

func BundleWeightTLOADAbortFailedAttempt()
begin
    if BundleWeightTLOADSelected() && BundleSharedBindingPhysicalCount() == 1 &&
       _BundleSharedBindings[[0]].destination_assemble.valid then
        AbortBundleSharedGeneration(BundleSharedBindingId(0));
    end;
end;

func ExecuteBundleWeightTLOADOperation() => boolean
begin
    // A zero-participation binder is discarded before it can create a Shared
    // binding. Preserve the ordinary strict no-op even for a selected weight
    // layout, before dimensions, scalar bindings, GPRs, or DATR fields matter.
    if _BundleZeroParticipationSeen && BundleTileBindingCount() == 0 &&
       BundleSharedBindingPhysicalCount() == 0 then
        return TRUE;
    end;
    if !BundleWeightTLOADStateLegal() then
        BundleWeightTLOADAbortFailedAttempt();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleWeightTLOADBuildAndPublish() then
        BundleWeightTLOADAbortFailedAttempt();
        if _LastFault == Fault_None then
            SetFault(Fault_TileLegality, ReadTPC());
        end;
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
