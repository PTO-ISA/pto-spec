<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gmov.asl -->
# TLSU Gmov

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gmov.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `GMOV`, the peer move between Local Tiles of the four PEs in one core. A bundle is the group of header commands that starts at `BSTART` and executes when it commits at `BSTOP` or the next `BSTART`.

`BundleGMOVSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `13`. `ExecuteBundleGMOVOperation` then validates the complete bundle, resolves one Local destination, and calls the Tile-level `GMOV` effect.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-concepts role=concepts-state -->
## Concepts and visible state

The handler reads the collected bundle state and writes only the destination Tile.

- Exactly one `B.IOT` binding, with a destination, `source0`, no `source1`, and the `last` flag. No `B.IOS` Shared binding is allowed.
- Every `B.DIM` dimension must have value `1`. Omitted dimensions default to `1`, so the usual form encodes none.
- The optional `B.IOR` `source0` names a GPR that holds the peer identifier. Each PE reads that selector from its own register file with `ReadPEAbsoluteGPROperand`. With no `B.IOR` the peer value is zero.
- The operation data type and the `B.DATR` layout must match the source Tile, and the data type must pass `TileCarrierOrPackedBaselineDataTypeSupported`.
- The destination size must equal the source Tile capacity in bytes.

The destination copies the source valid rows, valid columns, physical columns, and data type. `GMOV` copies payload and definedness from the source.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-rules role=rules-interactions -->
## Rules and interactions

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Every schema failure raises `Fault_TileLegality`, and all these checks happen before the destination is resolved.

The handler checks, in order: no Shared bindings and complete, legal `B.IOR` values; a uniform PE mask across bindings; exactly one Tile binding; data attributes; the binding shape and source readiness; the byte size, type, and layout matches; dimensions equal `1`; and each PE's peer identifier below `4`.

Design point: `BundleGMOVCore4SourceReady` requires the source contents to be defined and its allocation mask to be `1111`. The ASL comment explains that the one-level model represents the four peer source fragments as one Core4 snapshot, so full allocation plus complete definedness is the formal readiness witness.

Design point: the peer range check loops over all four PEs even when the PE mask would suppress a PE's write. The ASL comment states that every PE takes part in peer selection and readiness preflight. Repeated peer identifiers are legal; only the range `0..3` is constrained.

After the checks, the handler resolves the destination with the source shape and type, validates Local generation writers, and checks `TileOperandsLegal_GMOV`. A failure at either of the last two steps calls `RollBackBundleTileDestinations`, which releases a destination this bundle allocated. On success it runs `GMOV` and `FinalizeBundleTileAttempt`, which publishes a bundle-allocated destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decide that the bundle is a GMOV bundle at commit. `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` tests the specialized selectors in a fixed order and calls this handler only when the TIMG2COL, weight-load, matrix, and CUBE layout-conversion selectors did not match first. That caller also commits or aborts Local generations after this handler returns.

The unit does not itself test for a zero PE mask. A `B.IOT` with PE mode giving mask `0000` never creates a binding, and the caller returns early for a bundle that saw only zero participation.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose source Tile `t3` is allocated on all four PEs (mask `1111`), holds a defined FP16 RowMajor payload of 16 valid rows by 64 columns, and has a capacity of 2048 bytes. The bundle has one `B.IOT` with destination size code for 2048 bytes and source `t3`, no `B.DIM`, and one `B.IOR` whose `source0` is `a0`. If PE 0 through PE 3 hold `a0` values `1`, `2`, `3`, and `0`, all are below `4`, so the check passes. The destination receives 16 valid rows, 64 columns, and FP16.

If PE 2 instead held `a0` equal to `4`, the bundle raises `Fault_TileLegality` before any destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) orders the specialized selectors and commits Local generations.
- [Shared movement](../../../tile/model/memory/shared-movement.md) defines the Tile-level `GMOV` effect.
- [Rollback](../faults/rollback.md) defines how a bundle-allocated destination is released.
- [BSTART.GMOV](../../execution/BSTART.GMOV.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gmov.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","surface":"block","classification":["model","dispatch","tlsu-gmov"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}

readonly func BundleGMOVSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 13;
end;

readonly func BundleGMOVCore4SourceReady(source: TileIndex) => boolean
begin
    // The one-level PTO model represents the four peer-resolved Local source
    // fragments as one Core4 snapshot.  Full allocation and complete payload
    // definedness are therefore the formal rendezvous/readiness witness.
    return TileElementwiseSourceContentsDefined(source) &&
           _TileAllocationMasks[[source]] == '1111';
end;

func ExecuteBundleGMOVOperation() => boolean
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       BundleTileBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid || !binding.source0_valid ||
       binding.source1_valid || !binding.last ||
       !BundleGMOVCore4SourceReady(binding.source0) ||
       BundleTileDestinationSizeBytes(0) !=
           _Tiles[[binding.source0]].capacity_bytes ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding)) ||
       _Tiles[[binding.source0]].data_type != TileDataTypeFromEncoding(
           CurrentBundleTileOperationDataTypeCode()
               as TileDataTypeEncoding) ||
       _Tiles[[binding.source0]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) != 1 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    // Every PE participates in peer selection and readiness preflight even
    // when PE_MASK suppresses that PE's destination request/write.  Repeated
    // peer identifiers are legal; only the absolute 0..3 range is constrained.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        let peer_tid = if _BundleScalarBindings[[0]].valid then
            ReadPEAbsoluteGPROperand(agent,
                _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        if UInt(peer_tid) >= PTO_MODEL_MEMORY_AGENTS then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    // GMOV has no dimensions that describe a new shape: the destination
    // carries the resolved peer source shape while B.DATR.Layout selects its
    // physical representation.
    if !ResolveBundleTileDestinationsWithShapeAndType(
           TRUE, _Tiles[[binding.source0]].valid_rows,
           _Tiles[[binding.source0]].valid_columns,
           _Tiles[[binding.source0]].columns, TRUE,
           _Tiles[[binding.source0]].data_type) then return FALSE; end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations(); return FALSE;
    end;
    let destination = _BundleTileBindings[[0]].destination;
    let source = binding.source0;
    if !TileOperandsLegal_GMOV(destination, source, Zeros{PTO_XLEN}) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    GMOV(destination, source, Zeros{PTO_XLEN});
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
