<!-- GENERATED FROM: asl/block/model/operands/portable-carriers.asl -->
# Portable Carriers

**Normative ASL source:** `asl/block/model/operands/portable-carriers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/portable-carriers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","surface":"block","classification":["model","operands","portable-carriers"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}

// NDF-BEGIN: PTO-B-ASSEMBLE-CONSUMER-READINESS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A decoded Local consumer binds either a selected CELL range or the complete
// descriptor-required CELL set after LAST. Waiting is a non-faulting,
// no-effect state; a consumer reads only after its required set is ready.
// NDF-END: PTO-B-ASSEMBLE-CONSUMER-READINESS-001

// NDF-BEGIN: PTO-B-ASSEMBLE-SPECULATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Dynamic writers carry an opaque instruction-instance plus execution-domain
// identity. A squash cancels every unretired contribution in that domain and
// preserves the older committed mapping.
// NDF-END: PTO-B-ASSEMBLE-SPECULATION-001

// NDF-BEGIN: PTO-B-ASSEMBLE-PRODUCER-EFFECT-ELIGIBILITY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Each accepted Tile semantic-handler group has exactly one generated effect
// class. Nonrollback auxiliary effects are rejected before B.ASSEMBLE body or
// auxiliary effects; rollback-safe and atomic-auxiliary effects participate in
// the same transaction.
// NDF-END: PTO-B-ASSEMBLE-PRODUCER-EFFECT-ELIGIBILITY-001

readonly func BundleLocalGenerationReplay(
    slot: integer {0..63}, offset_cells: integer {0..2047},
    writer_cells: integer {1..2048}, instance: Word,
    execution_domain_token: integer) => boolean
begin
    for prior = 0 to _LocalGenerations[[slot]].writer_count - 1
        looplimit 16 do
        if _LocalGenerations[[slot]].writers[[prior]].valid &&
           _LocalGenerations[[slot]].writers[[prior]].offset_cells == offset_cells &&
           _LocalGenerations[[slot]].writers[[prior]].cell_count == writer_cells then
            return _LocalGenerations[[slot]].writers[[prior]].identity
                .instruction_instance == instance &&
                _LocalGenerations[[slot]].writers[[prior]].identity
                    .execution_domain_token == execution_domain_token;
        end;
    end;
    return FALSE;
end;

readonly func BundleLocalGenerationPublicationEligible(
    slot: integer {0..63}) => boolean
begin
    if !_LocalGenerations[[slot]].last_seen ||
       !_LocalGenerations[[slot]].parent_descriptor.valid then
        return FALSE;
    end;
    let required = _LocalGenerations[[slot]].parent_cell_count;
    if required == 0 || required > 2048 then return FALSE; end;
    for cell = 0 to 2047 do
        if cell < required &&
           (_LocalGenerations[[slot]].covered_cells[cell] == '0' ||
            _LocalGenerations[[slot]].ready_cells[cell] == '0') then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleLocalGenerationSlotForSource(source: TileIndex)
    => integer {0..64}
begin
    for slot = 0 to 63 do
        // A post-LAST consumer binds by the architectural generation hand,
        // including a closed-pending working destination.  It must not wait
        // for publication merely to discover the generation it depends on.
        if (_LocalGenerations[[slot]].committed_valid &&
            _LocalGenerations[[slot]].committed_destination == source) ||
           (_LocalGenerations[[slot]].closed &&
            _LocalGenerations[[slot]].working_destination == source) then
            return slot;
        end;
    end;
    return 64;
end;

func BundleConsumerDependencyRequiredRange(
    slot: integer {0..63}, source: TileIndex, offset: Word,
    size_code: integer {0..12}, whole: boolean,
    consumer_instance: Word) => boolean
begin
    let raw_offset = UInt(offset);
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let parent_cells = _LocalGenerations[[slot]].parent_cell_count;
    if parent_cells == 0 || parent_cells > 2048 then return FALSE; end;
    var required: bits(2048) = Zeros{2048};
    var required_count: integer = 0;
    if whole then
        for cell = 0 to 2047 do
            if cell < parent_cells then
                required[cell] = '1';
                required_count = required_count + 1;
            end;
        end;
    else
        if size_code == 0 then return FALSE; end;
        let selected = BundleLocalGenerationCellCount(
            size_code as integer {1..12});
        var end_cell: integer = 2048;
        if offset_cells + selected < parent_cells then
            end_cell = offset_cells + selected;
        elsif parent_cells < 2048 then
            end_cell = parent_cells;
        end;
        for cell = 0 to 2047 do
            if cell >= offset_cells && cell < end_cell then
                required[cell] = '1';
                required_count = required_count + 1;
            end;
        end;
    end;
    var found = FALSE;
    for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
        looplimit 16 do
        if _LocalGenerations[[slot]].consumers[[index]].valid &&
           _LocalGenerations[[slot]].consumers[[index]]
               .consumer_instruction_instance == consumer_instance &&
           _LocalGenerations[[slot]].consumers[[index]]
               .generation_instance ==
               _LocalGenerations[[slot]].generation_instance &&
           _LocalGenerations[[slot]].consumers[[index]]
               .execution_domain_token == _BundleExecutionDomainToken &&
           _LocalGenerations[[slot]].consumers[[index]].source == source &&
           _LocalGenerations[[slot]].consumers[[index]].required_cells ==
               required then
            found = TRUE;
            if _LocalGenerations[[slot]].consumers[[index]].state ==
                   BundleConsumerDependency_Waiting then
                var ready = TRUE;
                for cell = 0 to 2047 do
                    if required[cell] == '1' &&
                       _LocalGenerations[[slot]].ready_cells[cell] == '0' then
                        ready = FALSE;
                    end;
                end;
                if ready then
                    _LocalGenerations[[slot]].consumers[[index]].state =
                        BundleConsumerDependency_Eligible;
                end;
            end;
            return _LocalGenerations[[slot]].consumers[[index]].state !=
                BundleConsumerDependency_Waiting;
        end;
    end;
    if !found && _LocalGenerations[[slot]].consumer_count < 16 then
        let index = _LocalGenerations[[slot]].consumer_count;
        _LocalGenerations[[slot]].consumers[[index]].valid = TRUE;
        _LocalGenerations[[slot]].consumers[[index]].source = source;
        _LocalGenerations[[slot]].consumers[[index]].generation_instance =
            _LocalGenerations[[slot]].generation_instance;
        _LocalGenerations[[slot]].consumers[[index]].execution_domain_token =
            _BundleExecutionDomainToken;
        _LocalGenerations[[slot]].consumers[[index]].mode = if whole then
            BundleConsumerDependency_WholeParent
            else BundleConsumerDependency_Range;
        _LocalGenerations[[slot]].consumers[[index]].required_cells = required;
        _LocalGenerations[[slot]].consumers[[index]].required_cell_count =
            required_count as integer {0..16};
        _LocalGenerations[[slot]].consumers[[index]].after_last = TRUE;
        _LocalGenerations[[slot]].consumers[[index]]
            .consumer_instruction_instance = consumer_instance;
        _LocalGenerations[[slot]].consumer_count = (index + 1)
            as integer {0..16};
        var ready = TRUE;
        for cell = 0 to 2047 do
            if required[cell] == '1' &&
               _LocalGenerations[[slot]].ready_cells[cell] == '0' then
                ready = FALSE;
            end;
        end;
        _LocalGenerations[[slot]].consumers[[index]].state = if ready then
            BundleConsumerDependency_Eligible
            else BundleConsumerDependency_Waiting;
        return ready;
    end;
    return FALSE;
end;

func BundlePrepareConsumerSource(
    source: TileIndex, modifier_valid: boolean, offset: Word,
    size_code: integer {0..12}) => boolean
begin
    let slot = BundleLocalGenerationSlotForSource(source);
    if slot == 64 || !_LocalGenerations[[slot]].last_seen then return TRUE; end;
    // An open generation still exposes the prior committed source. Only a
    // closed LAST generation binds a post-LAST consumer dependency.
    if !_LocalGenerations[[slot]].closed then return TRUE; end;
    return BundleConsumerDependencyRequiredRange(
        slot as integer {0..63}, source, offset, size_code,
        !modifier_valid, ReadBPC());
end;

func PrepareBundleConsumerDependencies() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid &&
               !BundlePrepareConsumerSource(
                   _BundleTileBindings[[binding]].source0,
                   _BundleTileBindings[[binding]].source0_subview.valid,
                   _BundleTileBindings[[binding]].source0_subview.offset,
                   _BundleTileBindings[[binding]].source0_subview.size_code) then
                return FALSE;
            end;
            if _BundleTileBindings[[binding]].source1_valid &&
               !BundlePrepareConsumerSource(
                   _BundleTileBindings[[binding]].source1,
                   _BundleTileBindings[[binding]].source1_subview.valid,
                   _BundleTileBindings[[binding]].source1_subview.offset,
                   _BundleTileBindings[[binding]].source1_subview.size_code) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func RetireBundleConsumerDependencies()
begin
    for slot = 0 to 63 do
        if _LocalGenerations[[slot]].consumer_count > 0 then
            for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
                looplimit 16 do
                if _LocalGenerations[[slot]].consumers[[index]].valid &&
               _LocalGenerations[[slot]].consumers[[index]].state ==
                   BundleConsumerDependency_Eligible then
                    _LocalGenerations[[slot]].consumers[[index]].state =
                        BundleConsumerDependency_Retired;
                    _LocalGenerations[[slot]].consumers[[index]].valid = FALSE;
                end;
            end;
        end;
    end;
end;

// PTO-NDF: PTO-B-ASSEMBLE-CONSUMER-READINESS-001
// Architecture event entry point for completion of one registered writer.
// Registration contributes coverage only.  This event contributes readiness
// and, when LAST has closed the writer set, performs the one atomic mapping
// publication transition.  The event is not instruction encoded.
func CompleteBundleLocalGenerationWriterEvent(
    slot: integer {0..63}, execution_domain_token: integer,
    offset_cells: integer {0..2047}, cell_count: integer {1..2048})
    => boolean
begin
    var matched = FALSE;
    for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
        looplimit 16 do
        if _LocalGenerations[[slot]].writers[[writer]].valid &&
           _LocalGenerations[[slot]].writers[[writer]].identity
               .execution_domain_token == execution_domain_token &&
           _LocalGenerations[[slot]].writers[[writer]].offset_cells ==
               offset_cells &&
           _LocalGenerations[[slot]].writers[[writer]].cell_count ==
               cell_count then
            _LocalGenerations[[slot]].writers[[writer]].ready = TRUE;
            matched = TRUE;
        end;
    end;
    if !matched then return FALSE; end;

    // Recompute readiness from writer completion records.  Coverage and
    // readiness therefore remain separate even when completion is OoO.
    var ready = Zeros{2048};
    for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
        looplimit 16 do
        if _LocalGenerations[[slot]].writers[[writer]].valid &&
           _LocalGenerations[[slot]].writers[[writer]].ready then
            for cell = 0 to 2047 do
                if cell < _LocalGenerations[[slot]].writers[[writer]].cell_count &&
                   _LocalGenerations[[slot]].writers[[writer]].offset_cells +
                       cell < 2048 then
                    ready[_LocalGenerations[[slot]].writers[[writer]].offset_cells +
                        cell] = '1';
                end;
            end;
        end;
    end;
    _LocalGenerations[[slot]].ready_cells = ready;
    for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
        looplimit 16 do
        if _LocalGenerations[[slot]].consumers[[index]].valid &&
           _LocalGenerations[[slot]].consumers[[index]].state ==
               BundleConsumerDependency_Waiting then
            var complete = TRUE;
            for cell = 0 to 2047 do
                if _LocalGenerations[[slot]].consumers[[index]]
                       .required_cells[cell] == '1' && ready[cell] == '0' then
                    complete = FALSE;
                end;
            end;
            if complete then
                _LocalGenerations[[slot]].consumers[[index]].state =
                    BundleConsumerDependency_Eligible;
            end;
        end;
    end;
    if _LocalGenerations[[slot]].closed &&
       !_LocalGenerations[[slot]].published &&
       BundleLocalGenerationPublicationEligible(slot) then
        // The mapping, destination hand, and publication bit become visible
        // together only after precise LAST retirement and complete readiness.
        _LocalGenerations[[slot]].open = FALSE;
        _LocalGenerations[[slot]].published = TRUE;
        _LocalGenerations[[slot]].published_destination =
            _LocalGenerations[[slot]].working_destination;
        _LocalGenerations[[slot]].committed_destination =
            _LocalGenerations[[slot]].working_destination;
        _LocalGenerations[[slot]].committed_valid = TRUE;
    end;
    return TRUE;
end;

func SquashBundleExecutionDomain(domain: integer)
begin
    for slot = 0 to 63 do
        var covered: bits(2048) = Zeros{2048};
        var ready: bits(2048) = Zeros{2048};
        var writers_left: integer {0..16} = 0;
        for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].writers[[writer]].valid &&
               _LocalGenerations[[slot]].writers[[writer]].identity
                   .execution_domain_token == domain then
                _LocalGenerations[[slot]].writers[[writer]].valid = FALSE;
                _LocalGenerations[[slot]].writers[[writer]].ready = FALSE;
            end;
        end;
        for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].writers[[writer]].valid then
                writers_left = (writers_left + 1) as integer {0..16};
                for cell = 0 to 2047 do
                    if cell < _LocalGenerations[[slot]].writers[[writer]]
                        .cell_count then
                        let index = _LocalGenerations[[slot]].writers[[writer]]
                            .offset_cells + cell;
                        if index < 2048 then
                            covered[index] = '1';
                            if _LocalGenerations[[slot]].writers[[writer]].ready then
                                ready[index] = '1';
                            end;
                        end;
                    end;
                end;
            end;
        end;
        _LocalGenerations[[slot]].covered_cells = covered;
        _LocalGenerations[[slot]].ready_cells = ready;
        _LocalGenerations[[slot]].writer_count = writers_left as integer {0..16};
        for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].consumers[[index]].valid &&
               _LocalGenerations[[slot]].consumers[[index]]
                   .execution_domain_token == domain then
                _LocalGenerations[[slot]].consumers[[index]].state =
                    BundleConsumerDependency_Cancelled;
                _LocalGenerations[[slot]].consumers[[index]].valid = FALSE;
            end;
        end;
        if writers_left == 0 && _LocalGenerations[[slot]].open then
            AbortBundleLocalGeneration(
                _LocalGenerations[[slot]].destination_hand,
                _LocalGenerations[[slot]].participant_mask);
        end;
    end;
end;

// PTO-NDF: PTO-B-ASSEMBLE-SPECULATION-001
// Architecture event entry point for an execution-domain squash.  The event
// is not instruction-encoded; a control-flow, fault, or interrupt mechanism
// invokes this procedure after the decoded writer path has registered its
// portable identity.
func EnterBundleExecutionDomainSquashEvent(domain: integer)
begin
    SquashBundleExecutionDomain(domain);
end;

func BundleHasAssembleModifier() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            return TRUE;
        end;
    end;
    return FALSE;
end;

pure func BundleProducerEffectClassOfHandler(
    handler: TileSemanticHandler) => BundleProducerEffectClass
begin
    case handler of
        when TileHandler_ExecuteTileBinary,
             TileHandler_ExecuteTileCompare,
             TileHandler_ExecuteTileCompareScalar,
             TileHandler_ExecuteTileExpand,
             TileHandler_ExecuteTileFillScalar,
             TileHandler_ExecuteTilePartial,
             TileHandler_ExecuteTileReduction,
             TileHandler_ExecuteTileScalar,
             TileHandler_ExecuteTileSelect,
             TileHandler_ExecuteTileSelectScalar,
             TileHandler_ExecuteTileUnary,
             TileHandler_GMOV,
             TileHandler_MGATHER,
             TileHandler_MGATHER_MASK,
             TileHandler_TCI,
             TileHandler_TCONCAT,
             TileHandler_TCVT,
             TileHandler_TDEQUANT,
             TileHandler_TEXTRACT,
             TileHandler_TFILLPAD,
             TileHandler_TFMA,
             TileHandler_TGATHER,
             TileHandler_THISTOGRAM,
             TileHandler_TIMG2COL,
             TileHandler_TINSERT,
             TileHandler_TLOAD,
             TileHandler_TMOV,
             TileHandler_TMRGSORT,
             TileHandler_TQUANT,
             TileHandler_TSORT,
             TileHandler_TTRANS,
             TileHandler_TTRI =>
            return BundleProducerEffect_RollbackSafe;
        when TileHandler_MGATHER_CAS,
             TileHandler_MSCATTER,
             TileHandler_MSCATTER_MASK,
             TileHandler_TPREFETCH,
             TileHandler_TSCATTER,
             TileHandler_TSTORE =>
            return BundleProducerEffect_NonRollbackAuxiliary;
        when TileHandler_TGEMV, TileHandler_TGEMV_ACC,
             TileHandler_TGEMV_BIAS, TileHandler_TGEMV_MX,
             TileHandler_TGEMV_MX_ACC, TileHandler_TGEMV_MX_BIAS,
             TileHandler_TMATMUL, TileHandler_TMATMUL_ACC,
             TileHandler_TMATMUL_BIAS, TileHandler_TMATMUL_MX,
             TileHandler_TMATMUL_MX_ACC, TileHandler_TMATMUL_MX_BIAS =>
            return BundleProducerEffect_AtomicAuxiliary;
    end;
end;

pure func BundleProducerEffectClassOfOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => BundleProducerEffectClass
begin
    return BundleProducerEffectClassOfHandler(TileHandlerOfIndex(operation));
end;

func BundleProducerEffectEligible(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleHasAssembleModifier() then return TRUE; end;
    if BundleProducerEffectClassOfOperation(operation) ==
           BundleProducerEffect_NonRollbackAuxiliary then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
