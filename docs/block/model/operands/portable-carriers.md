<!-- GENERATED FROM: asl/block/model/operands/portable-carriers.asl -->
# Portable Carriers

**Normative ASL source:** `asl/block/model/operands/portable-carriers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-portable-carriers-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the portable carrier rules of a Local `B.ASSEMBLE` generation: consumer readiness, writer completion, publication, speculation squash, and which producer operations may take part. A generation is a Local Tile built by several writer bundles. A consumer is a later bundle that reads that Tile as a source.

<!-- PTO-READER-BLOCK: block-model-operands-portable-carriers-concepts role=concepts-state -->
## Concepts and visible state

The unit updates fields of the `_LocalGenerations` slots:

- per-writer `ready` flags and per-PE `per_pe_ready_cells` maps;
- `per_pe_published` flags and the slot's `published`, `published_destination`, `committed_destination`, and `committed_valid`;
- up to 16 consumer records. Each holds the source, participant mask, generation instance, execution-domain token, consumer instruction instance, the required CELL set, a mode (`WholeParent` or `Range`), and a state (`Waiting`, `Eligible`, `Retired`, or `Cancelled`).

An execution domain identifies one dynamic execution of a bundle. `BeginBundleAt` takes a fresh token for every dynamic bundle execution, and trap-context recovery restores the saved token.

<!-- PTO-READER-BLOCK: block-model-operands-portable-carriers-rules role=rules-interactions -->
## Rules and interactions

A consumer's source is checked by `BundlePrepareConsumerSource`. If the source is not a generation, it is ready. Otherwise the consumer requires either the CELL range selected by its `B.SUBVIEW` or, without a subview, every parent CELL. `BundleConsumerDependencyReady` is TRUE when each participating PE has every required CELL ready, and in whole-parent mode also has the generation published. The first call registers the consumer; a repeat call from the same consumer instance finds the same record.

A consumer that is not ready makes stage-2 preparation return FALSE without a fault. The NDF `PTO-B-ASSEMBLE-CONSUMER-READINESS-001` calls this a non-faulting, no-effect waiting state.

`CompleteBundleLocalGenerationWriterEvent` is the event that marks one registered writer complete. It sets that writer's ready cells, recomputes `ready_cells` from all completed writers, and updates per-PE publication. If the generation is closed, unpublished, and eligible, it publishes it: the committed mapping moves to the working destination, and the destination is published into its hand's relative queue if it is not already there. It then re-evaluates waiting consumers.

Design point: registration and completion are separate events. The ASL comment states that coverage and readiness therefore remain separate even when writers complete out of order. A consumer of the generation waits until its required CELLs are ready, not merely covered.

`SquashBundleExecutionDomain` invalidates every writer and consumer of the squashed domain, rebuilds coverage and readiness from the survivors, and aborts an open generation that has no writers left. The abort path keeps the older committed mapping, as the NDF `PTO-B-ASSEMBLE-SPECULATION-001` requires.

`BundleProducerEffectEligible` rejects, with `Fault_TileLegality`, an operation whose handler class is `NonRollbackAuxiliary` when a Local Tile binding of the bundle carries an assemble modifier. That class covers `TSTORE`, `TPREFETCH`, `TSCATTER`, `MSCATTER`, `MSCATTER_MASK`, and the GM atomic and reduction handlers.

Design point: tile execution checks eligibility, for every operation except TIMG2COL, before descriptor preparation, body execution, allocation, or auxiliary effects. A generation writer that could not be rolled back is rejected before it has done anything.

<!-- PTO-READER-BLOCK: block-model-operands-portable-carriers-boundaries role=boundaries -->
## Architectural boundaries

The completion and squash entry points are architecture events, not encoded instructions. In the current ASL they are driven by tests. `RetireBundleConsumerDependencies` retires every eligible consumer after a successful operation.

<!-- PTO-READER-BLOCK: block-model-operands-portable-carriers-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A generation has 32 CELLs, and writers for CELLs 0..15 and 16..31 are registered and closed by LAST. A consumer uses `B.SUBVIEW` for CELLs 0..3. Before any completion event it waits and has no effect. After the first writer completes, CELLs 0..15 are ready, so the consumer becomes eligible and may run. A second consumer without a subview needs the whole parent. It stays waiting until the second writer completes and the generation is published.

`TLEA` is a rollback-safe Local producer: its source persists through preflight and execution, and atomic destination publication neither consumes nor retags that source.

<!-- PTO-READER-BLOCK: block-model-operands-portable-carriers-related role=related-owners-navigation -->
## Related owners

- [Local generation](local-generation.md) registers writers and aborts generations.
- [Local generation CUBE](local-generation-cube.md) owns CUBE finalization.
- [Subview descriptor](subview-descriptor.md) calls the consumer check before copying a view.
- [Tile execution](../dispatch/tile-execution.md) calls eligibility and retirement.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/portable-carriers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","surface":"block","classification":["model","operands","portable-carriers"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE"]}

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
       (BundleLocalGenerationCubeLayout(
            _LocalGenerations[[slot]].parent_descriptor.layout) &&
        !_LocalGenerations[[slot]].descriptor_finalized) then
        return FALSE;
    end;
    for pe = 0 to 3 do
        if _LocalGenerations[[slot]].participant_mask[
               PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
           !BundleLocalGenerationPEPublicationEligible(slot, pe) then
            return FALSE; end;
    end;
    return TRUE;
end;

readonly func BundleLocalGenerationSlotForSource(source: TileIndex)
    => integer {0..64}
begin
    return BundleLocalGenerationSlotForDestination(source);
end;

readonly func BundleConsumerDependencyReady(
    slot: integer {0..63}, index: integer {0..15}) => boolean
begin
    let dependency = _LocalGenerations[[slot]].consumers[[index]];
    for pe = 0 to 3 do
        if dependency.participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            if dependency.mode == BundleConsumerDependency_WholeParent &&
               !_LocalGenerations[[slot]].per_pe_published[[pe]] then
                return FALSE;
            end;
            for cell = 0 to 2047 do
                if dependency.required_cells[cell] == '1' &&
                   _LocalGenerations[[slot]].per_pe_ready_cells[[pe]][cell] == '0' then
                    return FALSE; end;
            end;
        end;
    end;
    return TRUE;
end;

func BundleConsumerDependencyRequiredRange(
    slot: integer {0..63}, source: TileIndex, offset: Word,
    size_code: integer {0..15}, whole: boolean,
    participant_mask: bits(4), consumer_instance: Word) => boolean
begin
    let raw_offset = UInt(offset);
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let parent_cells = if _LocalGenerations[[slot]].descriptor_finalized &&
        BundleLocalGenerationCubeLayout(
            _LocalGenerations[[slot]].parent_descriptor.layout) then
        _LocalGenerations[[slot]].parent_descriptor.cube_cell_count
        else _LocalGenerations[[slot]].parent_cell_count;
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
           _LocalGenerations[[slot]].consumers[[index]].participant_mask ==
               participant_mask &&
           _LocalGenerations[[slot]].consumers[[index]].required_cells ==
               required then
            found = TRUE;
            if _LocalGenerations[[slot]].consumers[[index]].state ==
                   BundleConsumerDependency_Waiting then
                if BundleConsumerDependencyReady(
                       slot, index as integer {0..15}) then
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
        _LocalGenerations[[slot]].consumers[[index]].participant_mask =
            participant_mask;
        _LocalGenerations[[slot]].consumers[[index]].generation_instance =
            _LocalGenerations[[slot]].generation_instance;
        _LocalGenerations[[slot]].consumers[[index]].execution_domain_token =
            _BundleExecutionDomainToken;
        _LocalGenerations[[slot]].consumers[[index]].mode = if whole then
            BundleConsumerDependency_WholeParent
            else BundleConsumerDependency_Range;
        _LocalGenerations[[slot]].consumers[[index]].required_cells = required;
        _LocalGenerations[[slot]].consumers[[index]].required_cell_count =
            required_count as integer {0..2048};
        _LocalGenerations[[slot]].consumers[[index]].after_last = TRUE;
        _LocalGenerations[[slot]].consumers[[index]]
            .consumer_instruction_instance = consumer_instance;
        _LocalGenerations[[slot]].consumer_count = (index + 1)
            as integer {0..16};
        let ready = BundleConsumerDependencyReady(
            slot, index as integer {0..15});
        _LocalGenerations[[slot]].consumers[[index]].state = if ready then
            BundleConsumerDependency_Eligible
            else BundleConsumerDependency_Waiting;
        return ready;
    end;
    return FALSE;
end;

func BundlePrepareConsumerSource(
    source: TileIndex, modifier_valid: boolean, offset: Word,
    size_code: integer {0..15}, participant_mask: bits(4)) => boolean
begin
    let slot = BundleLocalGenerationSlotForSource(source);
    if slot == 64 || !_LocalGenerations[[slot]].generation_identity_valid then
        return TRUE;
    end;
    return BundleConsumerDependencyRequiredRange(
        slot as integer {0..63}, source, offset, size_code,
        !modifier_valid, participant_mask, ReadBPC());
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
                   _BundleTileBindings[[binding]].source0_subview.size_code,
                   _BundleTileBindings[[binding]].pe_mask) then
                return FALSE;
            end;
            if _BundleTileBindings[[binding]].source1_valid &&
               !BundlePrepareConsumerSource(
                   _BundleTileBindings[[binding]].source1,
                   _BundleTileBindings[[binding]].source1_subview.valid,
                   _BundleTileBindings[[binding]].source1_subview.offset,
                   _BundleTileBindings[[binding]].source1_subview.size_code,
                   _BundleTileBindings[[binding]].pe_mask) then
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
            for pe = 0 to 3 do
                if _LocalGenerations[[slot]].writers[[writer]].pe_mask[
                       PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                    var pe_ready = _LocalGenerations[[slot]].per_pe_ready_cells[[pe]];
                    for cell = 0 to 2047 do
                        if cell < _LocalGenerations[[slot]].writers[[writer]].cell_count &&
                           _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell < 2048 then
                            pe_ready[_LocalGenerations[[slot]].writers[[writer]].offset_cells + cell] = '1';
                        end;
                    end;
                    _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = pe_ready;
                end;
            end;
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
    for pe = 0 to 3 do
        if BundleLocalGenerationPEPublicationEligible(slot, pe) then
            _LocalGenerations[[slot]].per_pe_published[[pe]] = TRUE;
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
        PublishRelativeTileDestination(_LocalGenerations[[slot]].working_destination);
    end;
    // Publication is part of whole-parent readiness, so re-evaluate waiting
    // consumers only after the delayed publication transition above.
    for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
        looplimit 16 do
        if _LocalGenerations[[slot]].consumers[[index]].valid &&
           _LocalGenerations[[slot]].consumers[[index]].state ==
               BundleConsumerDependency_Waiting &&
           BundleConsumerDependencyReady(
               slot, index as integer {0..15}) then
            _LocalGenerations[[slot]].consumers[[index]].state =
                BundleConsumerDependency_Eligible;
        end;
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
        for pe = 0 to 3 do
            var pe_covered = Zeros{2048};
            var pe_ready = Zeros{2048};
            for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
                looplimit 16 do
                if _LocalGenerations[[slot]].writers[[writer]].valid &&
                   _LocalGenerations[[slot]].writers[[writer]].pe_mask[
                       PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                    for cell = 0 to 2047 do
                        if cell < _LocalGenerations[[slot]].writers[[writer]].cell_count &&
                           _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell < 2048 then
                            let index = _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell;
                            pe_covered[index] = '1';
                            if _LocalGenerations[[slot]].writers[[writer]].ready then
                                pe_ready[index] = '1';
                            end;
                        end;
                    end;
                end;
            end;
            _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = pe_covered;
            _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = pe_ready;
        end;
        if writers_left == 0 && _LocalGenerations[[slot]].open then
            AbortBundleLocalGeneration(slot);
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
        when TileHandler_ExecuteTileBinary, TileHandler_ExecuteTileExpdif,
             TileHandler_ExecuteTileCompare,
             TileHandler_ExecuteTileCompareScalar,
             TileHandler_ExecuteTileExpand,
             TileHandler_ExecuteTileFillScalar,
             TileHandler_ExecuteTileReduction,
             TileHandler_ExecuteTileScalar,
             TileHandler_ExecuteTileSelect,
             TileHandler_ExecuteTileSelectScalar,
             TileHandler_ExecuteTileUnary,
             TileHandler_GMOV,
             TileHandler_MGATHER,
             TileHandler_MGATHER_MASK,
             TileHandler_TCI, TileHandler_TLEA,
             TileHandler_TCVT,
             TileHandler_TFMA,
             TileHandler_TGATHER,
             TileHandler_TLOAD,
             TileHandler_TMOV,
             TileHandler_TPERMUTE,
             TileHandler_TSHUF,
             TileHandler_TPACK,
             TileHandler_TGPR2T,
             TileHandler_TUNPACK,
             TileHandler_TTRI =>
            return BundleProducerEffect_RollbackSafe;
        when TileHandler_GM_ATOM_CAS,
             TileHandler_GM_ATOM_VALUE, TileHandler_GM_RED_VALUE,
             TileHandler_GM_RED_POPC,
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
