<!-- GENERATED FROM: asl/block/model/dispatch/bundle-gpr-input-count.asl -->
# Bundle GPR Input Count

**Normative ASL source:** `asl/block/model/dispatch/bundle-gpr-input-count.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

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
