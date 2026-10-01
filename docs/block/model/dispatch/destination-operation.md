<!-- GENERATED FROM: asl/block/model/dispatch/destination-operation.asl -->
# Destination Operation

**Normative ASL source:** `asl/block/model/dispatch/destination-operation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-purpose role=purpose-scope -->
## Purpose and scope

This unit defines `ResolveBundleTileDestinationsForOperation`, the router that chooses how a Tile bundle's Local destinations get their shape and data type. A Local destination is a `B.IOT` destination written as `->DstTile<Size>`: the bundle names a relative hand and a size, and dispatch allocates a Local Tile register for it.

The router does not allocate by itself. It picks one resolver, computes the shape and type arguments for it, and returns that resolver's result.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-concepts role=concepts-state -->
## Concepts and visible state

The router reads `_BundleOperation`, the bundle dimensions `_BundleDimensions`, the Tile bindings, and the descriptors in `_Tiles` of bound sources. It writes state only through the resolver it calls and through `SetFault`.

The bundle dimension slots map to shape fields. `LB0` is the valid column count, `LB1` is the valid row count, and `LB2` is the physical column count.

An explicit shape means the router passes exact valid rows, valid columns, and physical columns to the shared resolver. An explicit type means it also passes the primary destination data type.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-rules role=rules-interactions -->
## Rules and interactions

The router tests these cases in order and uses the first match.

1. A Tile matrix bundle returns true at once and leaves its destination unresolved.
2. `TPERMUTE`, `TSHUF`, `TPACK`, and `TUNPACK` use the cell-rearrangement resolver.
3. `TMOV` keeps the shape from dimensions and takes its type from the first source's descriptor.
4. `TCVT` with a `CUBE_M16` or `CUBE_M32` source uses the CUBE `TCVT` resolver.
5. A row or column reduction takes its shape from the source. A row reduction gives `valid_rows` by 1; a column reduction gives 1 by `valid_columns`. Index-returning reductions produce `U32`; the others keep the source type.
6. `TCMP` and `TCMPS` resolve the effective data type and use the predicate destination resolver.
7. `TSEL` and `TSELS` whose true source is CUBE use the CUBE select resolver.
8. `TEXPDIF`, `TROWEXPANDEXPDIF`, and `TCOLEXPANDEXPDIF` take the destination type from the exponential-difference type pair.
9. An operation outside the binary, unary, `TFMA`, generation, expansion, `TCVT`, comparison, and Tile-scalar closed schemas uses the generic resolver with no explicit shape.
10. Every remaining closed schema operation takes an explicit shape from `LB0`, `LB1`, and the physical column rule, with the effective data type.

Cases 6 and 8 raise `Fault_TileLegality` when the type cannot be resolved or the type pair is illegal.

Design point: a matrix bundle exits before any generic resolution. The ASL comment gives the reason: the CUBE matrix handler owns the primary destination's M, N, layout, and type. Generic RowMajor resolution would mark the destination allocated and prevent the handler from converting it to CUBE state.

Design point: `TEXPDIF` is also a closed binary operation, but case 8 catches it first. That case takes the destination type from `SelectedBundleExponentialDifferenceTypes`, which checks the source and destination type pair again and raises `Fault_TileLegality` if the pair is illegal.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-boundaries role=boundaries -->
## Architectural boundaries

The only caller is Tile execution dispatch. It calls the router after the operand count, closed schema, PE mask, and execution-mask merge checks, and before local generation writers are validated. If the router fails, dispatch aborts the bundle's local generations and discards subview materializations. The router does not validate the source operands; the closed schema checks did that earlier.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

```text
TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>
```

`TADD` is a closed binary operation and matches none of cases 1 to 9. In case 10, `LB0` gives 64 valid columns and `LB1` gives 8 valid rows. The physical column count is 64. The resolver receives shape 8 by 64 with type `FP32`.

A `TROWMAX` over an 8 by 64 `FP32` source matches case 5 instead. Its destination is 8 by 1 with type `FP32`, and its physical column count is 1.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-operation-related role=related-owners-navigation -->
## Related owners

- [Destination shape](destination-shape.md) owns the shared resolver that allocates the destinations.
- [Tile execution dispatch](tile-execution.md) calls this router and handles its failure.
- [Predicate destination](predicate-destination.md) owns the comparison and CUBE select resolvers.
- [Exponential difference schema](expdif-schema.md) selects the `TEXPDIF` type pair.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-operation.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","destination-operation"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION","surface":"block"}
func ResolveBundleTileDestinationsForOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // CUBE matrix handlers own the primary CUBE destination and allocation; leave it unresolved for the authoritative M/N/layout/type handler because generic RowMajor resolution would mark it allocated and prevent conversion.
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix then
        return TRUE;
    end;
    let decoded_operation = TileOperationOfIndex(operation);
    if decoded_operation == TileOperation_TPERMUTE ||
       decoded_operation == TileOperation_TSHUF ||
       decoded_operation == TileOperation_TPACK ||
       decoded_operation == TileOperation_TUNPACK then
        return ResolveBundleCellRearrangementDestination(operation);
    end;
    if TileOperationUsesSourceBackingDestination(decoded_operation) then
        let source = BundleTileSourceIndex(0, FALSE);
        return ResolveBundleTileDestinationsWithShapeAndType(FALSE, 0, 0, 0,
            TRUE, _Tiles[[source]].data_type);
    end;
    if TileOperationUsesClosedTCVTSchema(operation) then
        let source = BundleTileSourceIndex(0, FALSE);
        if _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
           _Tiles[[source]].layout == TileLayout_CUBE_M32 then
            return ResolveBundleTCVTCubeDestination();
        end;
    end;
    if TileOperationUsesClosedReductionSchema(operation) then
        let source = _BundleTileBindings[[0]].source0;
        let source_tile = _Tiles[[source]];
        let row_reduction =
            TileOperationUsesClosedRowReductionSchema(operation);
        let destination_type =
            if TileReductionOperationReturnsIndex(operation) then
                TileDataType_U32
            else
                source_tile.data_type;
        let valid_rows =
            if row_reduction then source_tile.valid_rows else 1;
        let valid_columns =
            if row_reduction then 1 else source_tile.valid_columns;
        let columns =
            if row_reduction then 1 else source_tile.columns;
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE,
            valid_rows,
            valid_columns,
            columns,
            TRUE,
            destination_type);
    end;
    if TileOperationUsesClosedTCMPSchema(operation) ||
       TileOperationUsesClosedTCMPSSchema(operation) then
        let (operation_type_valid, operation_type) =
            ResolveBundleEffectiveDataType();
        if !operation_type_valid then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return ResolveBundlePredicateDestination(operation_type);
    end;
    if (TileOperationUsesClosedTSELSchema(operation) ||
        TileOperationUsesClosedTSELSSchema(operation)) &&
       SelectedBundleComparisonCUBE(
           BundleComparisonSelectTrueSource(operation)) then
        return ResolveBundleCUBESelectDestination(operation);
    end;
    if decoded_operation == TileOperation_TEXPDIF then
        let (types_legal, -, destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = BundleDestinationValidColumns(FALSE, 0)
            as integer {1..65535};
        let valid_rows = BundleDestinationValidRows(FALSE, 0)
            as integer {1..65535};
        let columns = BundleDestinationPhysicalColumns(FALSE, 0)
            as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if TileExpansionOperationIsExponentialDifference(operation) then
        let (types_legal, -, destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
        let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if !TileOperationUsesClosedBinarySchema(operation) &&
       !TileOperationUsesClosedUnarySchema(operation) &&
       !TileOperationUsesClosedTFMASchema(operation) &&
       !TileOperationUsesClosedGenerationSchema(operation) &&
       !TileOperationUsesClosedExpansionSchema(operation) &&
       !TileOperationUsesClosedTCVTSchema(operation) &&
       !TileOperationUsesClosedComparisonSchema(operation) &&
       !TileOperationUsesClosedTileScalarSchema(operation) then
        return ResolveBundleTileDestinations();
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = BundleDestinationPhysicalColumns(FALSE, 0)
        as integer {1..65535};
    return ResolveBundleTileDestinationsWithShape(TRUE, valid_rows, valid_columns, columns);
end;
```
<!-- GENERATED-ASL-END: unit -->
