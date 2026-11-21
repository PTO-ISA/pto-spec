<!-- GENERATED FROM: asl/block/model/dispatch/indexed-tlsu-range-schema.asl -->
# Indexed TLSU Range Schema

**Normative ASL source:** `asl/block/model/dispatch/indexed-tlsu-range-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit recognizes indexed TLSU operations and interprets their optional signed range descriptor. The range lets a participating PE reject out-of-order minimum and maximum bounds before memory effects.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-concepts role=concepts-state -->
## Descriptor state

The first scalar binding supplies two GPR selectors when it is valid and is not an execution-mask binding. Tile bindings determine whether the current PE participates.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-rules role=rules-interactions -->
## Range rule

For a participating PE, the selected GPRs are read as signed minimum and maximum values and must satisfy minimum less than or equal to maximum. A nonparticipating PE does not impose this comparison.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-boundaries role=boundaries -->
## Boundaries

The operation set is limited to MGATHER and MSCATTER forms, including their mask, atomic, and reduction variants. An absent descriptor imposes no range ordering check.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-example role=example-usage -->
## Example

If a participating PE supplies minimum -8 and maximum 15, the ordering check passes. Minimum 16 with maximum 15 fails the range contract.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-related role=related-owners-navigation -->
## Related owners

- [Range command stream](indexed-tlsu-range-command-stream.md) enforces adjacency of the two bindings.
- [Predicate carriers](../../../tile/model/execution/predicate-carriers.md) owns execution-mask carriers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/indexed-tlsu-range-schema.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","indexed-tlsu-range-schema"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-TYPES","PTO-SCALAR-MODEL-TYPES-OPERANDS","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"],"id":"PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","surface":"block"}
readonly func BundleOperationUsesIndexedTLSU(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    case TileOperationOfIndex(operation) of
        when TileOperation_MGATHER, TileOperation_MSCATTER,
             TileOperation_MGATHER_MASK, TileOperation_MSCATTER_MASK,
             TileOperation_MGATHER_CAS, TileOperation_MGATHER_EXCH,
             TileOperation_MGATHER_MAX, TileOperation_MGATHER_MIN,
             TileOperation_MGATHER_ADD, TileOperation_MGATHER_INC,
             TileOperation_MGATHER_DEC, TileOperation_MGATHER_AND,
             TileOperation_MGATHER_OR, TileOperation_MGATHER_XOR,
             TileOperation_MSCATTER_MAX, TileOperation_MSCATTER_MIN,
             TileOperation_MSCATTER_ADD, TileOperation_MSCATTER_INC,
             TileOperation_MSCATTER_DEC, TileOperation_MSCATTER_AND,
             TileOperation_MSCATTER_OR, TileOperation_MSCATTER_XOR,
             TileOperation_MSCATTER_POPC => return TRUE;
        otherwise => return FALSE;
    end;
end;

readonly func BundleIndexedTLSURangeDescriptorPresent(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return BundleOperationUsesIndexedTLSU(operation) &&
           _BundleScalarBindings[[0]].valid &&
           !_BundleScalarBindings[[0]].execution_mask_present &&
           (_BundleScalarBindings[[0]].source1 != 0 ||
            _BundleScalarBindings[[0]].source2 != 0);
end;

readonly func BundleIndexedTLSUCurrentPEParticipates() => boolean
begin
    let current_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    var seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            seen = TRUE;
            if _BundleTileBindings[[binding]].pe_mask[current_bit] != '1' then
                return FALSE;
            end;
        end;
    end;
    return seen;
end;

readonly func BundleIndexedTLSUCurrentPEBoundsOrdered(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleIndexedTLSURangeDescriptorPresent(operation) ||
       !BundleIndexedTLSUCurrentPEParticipates() then
        return TRUE;
    end;
    let minimum = SInt(ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source1));
    let maximum = SInt(ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source2));
    return minimum <= maximum;
end;

readonly func BundleIndexedTLSURangeMaskSecondPending() => boolean
begin
    if !_BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous ||
       !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       !_BundleOperation.valid then
        return FALSE;
    end;
    let operation = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    return operation != PTO_TILE_OPERATION_COUNT &&
           BundleOperationUsesIndexedTLSU(operation as
               integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
           BundleIndexedTLSURangeDescriptorPresent(operation as
               integer {0..PTO_TILE_OPERATION_COUNT-1});
end;
```
<!-- GENERATED-ASL-END: unit -->
