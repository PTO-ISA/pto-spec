<!-- GENERATED FROM: asl/block/model/dispatch/bundle-gpr-input-count.asl -->
# Bundle GPR Input Count

**Normative ASL source:** `asl/block/model/dispatch/bundle-gpr-input-count.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-purpose role=purpose-scope -->
## Purpose and scope

This unit counts the GPR-backed inputs that a complete Tile bundle consumes. The count lets command assembly keep the scalar-input stream dense while operations expose different operand shapes.

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-concepts role=concepts-state -->
## Counted inputs

The count includes each present address, scalar, diagonal, or flag operand. Matrix fixed-point modes may add scalar pre-quantization and ReLU parameters, while an indexed TLSU range descriptor contributes its minimum and maximum bounds.

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-rules role=rules-interactions -->
## Counting rule

Each present ordinary input contributes one slot. The two fixed-point parameters contribute only when their selected modes use scalar values. A present indexed range contributes two slots as one ordered pair.

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-boundaries role=boundaries -->
## Boundaries

This helper reports a count from zero through seven. It does not validate the values in those GPRs or decide whether an operation, descriptor, or range is legal.

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-example role=example-usage -->
## Example

An indexed gather with an address input and a range descriptor consumes three GPR inputs: one address plus the two signed bounds.

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-related role=related-owners-navigation -->
## Related owners

- [Indexed TLSU range schema](indexed-tlsu-range-schema.md) decides when the two-bound descriptor is present.
- [Control state](../state/control-state.md) owns the captured bundle operation and scalar bindings.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/bundle-gpr-input-count.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","bundle-gpr-input-count"],"depends_on":["PTO-BLOCK-B-FPATR","PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"],"id":"PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT","surface":"block"}
// Complete-bundle GPR inputs pack present address, scalar0, diagonal, and flag0 operands densely.
readonly func BundleOperationGPRInputCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..7}
begin
    var count: integer {0..7} = 0;
    if TileOperandPresent(operation, TileOperand_address) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        count = (count + 1) as integer {0..7};
    end;
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid then
        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            count = (count + 1) as integer {0..7};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            count = (count + 1) as integer {0..7};
        end;
    end;
    if BundleIndexedTLSURangeDescriptorPresent(operation) then
        count = (count + 2) as integer {0..7};
    end;
    return count;
end;
```
<!-- GENERATED-ASL-END: unit -->
