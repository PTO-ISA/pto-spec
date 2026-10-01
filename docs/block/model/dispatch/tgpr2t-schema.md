<!-- GENERATED FROM: asl/block/model/dispatch/tgpr2t-schema.asl -->
# Tgpr2t Schema

**Normative ASL source:** `asl/block/model/dispatch/tgpr2t-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the closed bundle schema for `TGPR2T`. `TGPR2T` reads four general-purpose registers (GPRs) and writes their bits into a small U8 CUBE Tile. `SelectedBundleClosedTGPR2TSchemaLegal` returns true for every other operation, and for `TGPR2T` it returns true only when the complete bundle matches this schema.

The tile-execution owner calls it through `SelectedBundleClosedSchemasLegal`. A false result there raises `Fault_TileLegality` before destination allocation or any register read by the operation.

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-concepts role=concepts-state -->
## Concepts and visible state

The NDF clause `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001` fixes the operand carriers:

- Two scalar bindings (`B.IOR` records) supply the four GPR selectors. The first supplies three sources and the second supplies one, a "3+1" split. Neither may name a destination register.
- One Tile binding (`B.IOT`) names the destination and ends the binding list.
- The shape is given by `B.DIM`: dimension 1 is the valid row count and dimension 0 is the valid column count. Dimension 2 must keep its default value 1.

The schema reads the bindings, the three dimensions, the execution mask, the descriptor data type, and the `B.DATR` rounding and pad fields. It writes no state.

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-rules role=rules-interactions -->
## Rules and interactions

The schema passes only when all of these hold:

- Exactly one Tile binding, no Shared binding, and dimension 2 equal to 1.
- Rows and columns are 32 and 4, or 16 and 8.
- The binding names a destination that the bundle has not already allocated, with a legal size code, and is marked last.
- `source0` is present only when the execution mask is a predicate Tile, and then that mask is source ordinal 0. `source1` is never present.
- The descriptor data type is `U8`.
- `BundleOperationGPRBindingValuesLegal` accepts the scalar bindings.
- `TileTGPR2TRModeLegal` accepts the rounding field: bit 2 must be 0. For this operation the low two bits select a byte offset, not a rounding mode.
- `TileTGPR2TPadLegal` accepts the pad value: zero or max. When `B.DATR` is absent, the pad is zero.

Design point: the NDF clause `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001` pairs 32 by 4 with `CUBE_M32` and 16 by 8 with `CUBE_M16`. This schema accepts only those two shapes, so any other shape is rejected before allocation; the pairing with a layout is checked later by the handler's operand check `TileOperandsLegal_TGPR2T`.

Design point: the NDF clause `PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001` says the result is an ordinary numeric U8 CUBE Tile. It is not a PredicateCell and not an implicit mask for `TSEL` or `TSELS`. That is why the data type is fixed to `U8` and why whole-tile checks belong to this schema, before the handler runs and the result is published.

The command stream is checked earlier, as commands arrive. After the first `B.IOR` of a `TGPR2T` bundle, the next command must be the second `B.IOR` or a zero-participation `B.IOT`, unless zero participation was already seen; otherwise `Fault_BundleControl` is raised. A non-zero-participation `B.IOT` before both records are present also raises `Fault_BundleControl`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit returns a boolean and raises no fault itself. The command-time stream and placement rules belong to the scalar-schema and commands owners. The mapping of the four selectors into operands belongs to the Tile instruction operands owner. The bit packing of GPR values into the Tile belongs to the Tile predicate-carrier execution owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A bundle selects `TGPR2T` with data type `U8`. It sets dimension 0 to 4 and dimension 1 to 32 and leaves dimension 2 at 1. The first `B.IOR` names GPRs 5, 6, and 7, and the second names GPR 8, both with destination 0. One `B.IOT` names a destination and is marked last. With no `B.DATR`, the pad is zero and the rounding field is `000`. The schema passes. If dimension 0 were 8 with 32 rows, the schema would fail.

<!-- PTO-READER-BLOCK: block-model-dispatch-tgpr2t-schema-related role=related-owners-navigation -->
## Related owners

- [Scalar schema](scalar-schema.md) enforces the two-record `B.IOR` stream.
- [Tile instruction operands](tile-instruction-operands.md) maps the four selectors to operands.
- [Tile execution](tile-execution.md) calls this schema.
- [TGPR2T](../../../tile/layout-and-rearrangement/layout/TGPR2T.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tgpr2t-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA","surface":"block","classification":["model","dispatch","tgpr2t-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
// NDF-BEGIN: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// TGPR2T MUST consume exactly two contiguous source-only B.IOR records (3+1),
// one terminating destination B.IOT, and one exact shape pair: LB1/LB0 is
// 32/4 for CUBE_M32 or 16/8 for CUBE_M16. LB2 MUST have its default value one.
// Wrong-split, surplus, or destination-bearing forms reject before allocation,
// source reads, or publication.
// NDF-END: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001

readonly func SelectedBundleClosedTGPR2TSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if TileOperationOfIndex(operation) != TileOperation_TGPR2T then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       UInt(_BundleDimensions[[2]]) != 1 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let rows = UInt(_BundleDimensions[[1]]);
    let columns = UInt(_BundleDimensions[[0]]);
    let shape_legal = (rows == 32 && columns == 4) ||
        (rows == 16 && columns == 8);
    return shape_legal && binding.destination_valid &&
           !binding.destination_allocated_by_bundle &&
           BundleTileDestinationSizeLegal(0) &&
           (binding.source0_valid == execution_mask_tile) &&
           !binding.source1_valid &&
           (!execution_mask_tile ||
            _BundleExecutionMask.predicate_source_ordinal == 0) &&
           binding.last &&
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding) == TileDataType_U8 &&
           BundleOperationGPRBindingValuesLegal(operation) &&
           TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) &&
           TileTGPR2TPadLegal();
end;
```
<!-- GENERATED-ASL-END: unit -->
