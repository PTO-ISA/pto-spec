<!-- GENERATED FROM: asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl -->
# Indexed TLSU Range Command Stream

**Normative ASL source:** `asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-COMMAND-STREAM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-purpose role=purpose-scope -->
## Purpose and scope

This unit enforces the command-stream adjacency required by a two-GPR indexed TLSU range descriptor. It prevents an unrelated command from being mistaken for the descriptor's second bound.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-concepts role=concepts-state -->
## Pending second bound

After the first eligible B.IOR record, the second scalar-binding slot records whether another B.IOR may complete the contiguous range pair. The marker applies only to an indexed TLSU operation with a present range descriptor.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-rules role=rules-interactions -->
## Stream rule

A contiguous second scalar binding at index one is allowed. If an unrelated command intervenes, the marker is cleared; a later second B.IOR then raises Fault_BundleControl before binding or operation effects.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-boundaries role=boundaries -->
## Boundaries

A lone first descriptor remains legal. Operations without an indexed range, and commands outside the relevant second-binding position, keep their existing stream behavior.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-example role=example-usage -->
## Example

For an indexed gather range, two adjacent B.IOR records form minimum and maximum. Inserting another command between them makes the later B.IOR invalid as the second bound.

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-related role=related-owners-navigation -->
## Related owners

- [Indexed TLSU range schema](indexed-tlsu-range-schema.md) identifies eligible operations and descriptors.
- [Scalar schema](scalar-schema.md) owns B.IOR binding indices.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-COMMAND-STREAM","surface":"block","classification":["model","dispatch","indexed-tlsu-range-command-stream"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT","PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-STATE-TYPES"]}
func BundleMarkIndexedTLSURangeMaskSecondPending(first_record: boolean)
begin
    if !first_record || !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       !_BundleOperation.valid ||
       !BundleExecutionMaskGPRStreamSelected() then
        return;
    end;
    let operation = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    if operation != PTO_TILE_OPERATION_COUNT &&
       BundleOperationUsesIndexedTLSU(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
       BundleIndexedTLSURangeDescriptorPresent(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) then
        _BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous = TRUE;
    end;
end;

func BundleIndexedTLSURangeMaskCommandAllowed(
    next_is_scalar_binding: boolean) => boolean
begin
    if !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid ||
       !_BundleOperation.valid then
        return TRUE;
    end;
    let operation = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    if operation == PTO_TILE_OPERATION_COUNT ||
       !BundleOperationUsesIndexedTLSU(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) ||
       !BundleIndexedTLSURangeDescriptorPresent(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) then
        return TRUE;
    end;
    if next_is_scalar_binding && BundleMultiIORBindingIndex() == 1 then
        if !_BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous then
            SetFault(Fault_BundleControl, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !next_is_scalar_binding then
        // A lone descriptor remains legal after an unrelated command. If a
        // second B.IOR later appears, this marker makes that pair fail before
        // the second binding or any operation effect.
        _BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous = FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
