<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-prefetch.asl -->
# TLSU Prefetch

**Normative ASL source:** `asl/block/model/dispatch/tlsu-prefetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `TPREFETCH`. A prefetch reads a rectangle of global memory on each of the four PEs and records load events, but writes no Tile and no register.

`BundleTPREFETCHSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `3`. `ExecuteBundleTPREFETCHOperation` validates the complete bundle and then calls `TPREFETCHCore`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-concepts role=concepts-state -->
## Concepts and visible state

A prefetch bundle has no Tile operand at all.

- No `B.IOT` Local binding and no `B.IOS` Shared binding are allowed. The ASL comment states that `TPREFETCH` has implicit PE participation `1111`.
- `B.DIM` supplies valid columns (`LB0`), valid rows (`LB1`), and physical columns (`LB2`).
- The optional `B.IOR` supplies the base address in `source0` and the row stride in `source1`. Each PE reads these selectors from its own GPR file with `ReadPEAbsoluteGPROperand`.
- With no `B.IOR`, the base address is zero and the row stride is the physical column count. `TPREFETCHCore` treats this stride as a count of elements, not bytes.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-rules role=rules-interactions -->
## Rules and interactions

An unknown TLSU operation code raises `Fault_IllegalInstruction`. The remaining checks raise `Fault_TileLegality`, in this order: the operation data type passes `TileCarrierOrPackedBaselineDataTypeSupported`; no Tile or Shared binding exists; the `B.IOR` binding is complete with legal values; and the dimensions pass `BundleTPREFETCHDimensionsLegal`. Data attributes are checked last by `SelectedBundleTileDataAttributesLegal`, which raises its own fault.

`BundleTPREFETCHDimensionsLegal` requires every dimension in `1..65535`, valid columns not above physical columns, physical columns a nonzero power of two, and valid rows times valid columns not above `PTO_MODEL_TILE_ELEMENTS`.

Design point: an omitted `B.DIM` has effective value one, but an explicitly encoded zero stays a value and is illegal. The ASL comment states this distinction. A program that sets `LB0` to zero with `B.DIM` therefore faults instead of prefetching one column.

Design point: `TPREFETCHCore` probes every typed element of every PE before it records the first load event. Its comment states the reason: a fault cannot expose a partial request or an event prefix from an earlier PE. A translation fault on PE 3 therefore leaves no load event from PE 0.

On success the handler calls `FinalizeBundleTileAttempt`. With no Tile binding, that call publishes nothing.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decide that the bundle is a prefetch at commit. `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` tests the specialized selectors in a fixed order and reaches `BundleTPREFETCHSelected` only after every earlier selector, through `MSCATTER.MASK`, did not match; only the Shared TLSU selector is tested after it.

The address calculation, probing, and load-event recording belong to `TPREFETCHCore` in the Tile gather and scatter owner. The wrapper `TPREFETCHAllPEs`, used by the generated direct-operation dispatcher, applies one base and stride to all four PEs; complete bundles use this unit so each PE reads its own GPRs.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a FP32 prefetch bundle sets `LB0` to 48, `LB1` to 8, and `LB2` to 64, and binds `B.IOR` sources `a0` and `a1`. Valid columns 48 do not exceed 64, 64 is a power of two, and 8 times 48 is 384 elements, so the dimensions are legal. If PE 1 holds `a0` equal to `0x10000` and `a1` equal to 64, its row 2, column 5 element is at element index 2 times 64 plus 5, which is 133, from base `0x10000`.

If `LB2` were 48 instead, the bundle raises `Fault_TileLegality` because 48 is not a power of two.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-prefetch-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) orders the specialized selectors.
- [Gather and scatter memory](../../../tile/model/memory/gather-scatter.md) defines `TPREFETCHCore`.
- [Stride helpers](../../../tile/model/memory/stride.md) define the element-strided index.
- [BSTART.TPREFETCH](../../execution/BSTART.TPREFETCH.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-prefetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","surface":"block","classification":["model","dispatch","tlsu-prefetch"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleTPREFETCHSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 3;
end;

readonly func BundleTPREFETCHDimensionsLegal() => boolean
begin
    // Omitted dimensions have effective value one. An explicitly encoded
    // zero or out-of-range value remains a value and is therefore illegal.
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) == 0 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

func ExecuteBundleTPREFETCHOperation() => boolean
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileCarrierOrPackedBaselineDataTypeSupported(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile
    // operand.  Any B.IOT or B.IOS is a malformed complete-bundle schema.
    if BundleTileBindingCount() != 0 || BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !BundleTPREFETCHDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;

    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    var base_addresses: CorePEWords;
    var row_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        base_addresses[[agent]] =
            if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        row_strides[[agent]] =
            if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source1)
            else NaturalToWord(columns);
    end;
    TPREFETCHCore(base_addresses, row_strides,
        valid_columns as integer {1..65535},
        valid_rows as integer {1..65535},
        columns as integer {1..65535},
        data_type);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
