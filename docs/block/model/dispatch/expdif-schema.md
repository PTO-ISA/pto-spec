<!-- GENERATED FROM: asl/block/model/dispatch/expdif-schema.asl -->
# Expdif Schema

**Normative ASL source:** `asl/block/model/dispatch/expdif-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit resolves the two data types of an exponential-difference bundle. The operations are `TEXPDIF`, which computes the natural exponential of the difference of two source elements, and the expansion forms `TROWEXPANDEXPDIF` and `TCOLEXPANDEXPDIF`. The source operation type is the type in which the sources are read. The destination type is the element type of the published result.

The unit has one function, `SelectedBundleExponentialDifferenceTypes`. It returns a legality flag, the source operation type, and the destination type.

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-concepts role=concepts-state -->
## Concepts and visible state

The function reads three pieces of bundle state and writes none.

- `_BundleOperation.data_type_valid` and the `DataType` field of the `BSTART` form. This field is always the source operation type.
- `_BundleDataAttributesPresent`, which records whether a `B.DATR` command appeared in the bundle.
- `_BundleDataAttributes.data_type`, the `DataType` field of that `B.DATR`.

When the result is illegal, both returned types are the placeholder `FP64`. Callers ignore them in that case.

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-rules role=rules-interactions -->
## Rules and interactions

The function applies these steps in order.

1. If the `BSTART` form carried no data type, return illegal.
2. Decode the source operation type from the `BSTART` field. Start with the destination type equal to it.
3. If `B.DATR` is present and its type is `DTYPE_NONE`, keep the destination type equal to the source type.
4. If `B.DATR` is present and its type is neither `DTYPE_NONE` nor a concrete type, return illegal.
5. If `B.DATR` is present with a concrete type, use that type as the destination type.
6. Return the result of `TileExpdifTypePairLegal` for the pair, with both types.

`TileExpdifTypePairLegal` accepts exactly five pairs: `FP16` to `FP16` or `FP32`, `BF16` to `BF16` or `FP32`, and `FP32` to `FP32`.

The function is called, for example, from three dispatch owners. The Tile schema check for `TEXPDIF` and the expansion schema check use the legality flag during preflight. Destination resolution uses the destination type to allocate the result Tile, and raises `Fault_TileLegality` if the flag is false. All of these calls occur before any source snapshot or payload write.

Design point: `DTYPE_NONE` and an encoded zero mean different things. `DTYPE_NONE` is the code `11111` and asks for inheritance. Code zero is the concrete type `FP64`. A `B.DATR` that is present only to set `Layout` or `PadValue` can therefore leave the destination type unchanged by encoding `DTYPE_NONE`. An encoded zero selects `FP64`, which no legal pair accepts, so it is rejected before effects rather than read as absence.

Design point: the destination type can be wider than the source type, but never narrower. The only mixed pairs widen `FP16` or `BF16` to `FP32`. The result of the exponential is therefore never rounded to a smaller format than the one the sources were read in.

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not check layouts, shapes, bindings, or the sources' own descriptors: for `TEXPDIF` the Tile schema owner and `TileExpdifSourcesLegal` do that, and for the expansion forms the expansion schema does. It does not compute the exponential or set numeric status.

It does not decide whether a reserved `B.DATR` code can be stored. `SetBundleDataAttributeState` rejects such a code when the command executes, so step 4 is a defensive check.

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

```text
TEXPDIF <Row=16, Col=64, FP16>, T#1, T#2, ->T<2KB>
```

No destination type is written, so no `B.DATR` data type is supplied and the destination is `FP16`. The pair `FP16` to `FP16` is legal. A 2 KB destination of 64 `FP16` columns holds 16 rows.

If the bundle instead carries a `B.DATR` whose `DataType` is `FP32`, the pair `FP16` to `FP32` is also legal and the destination is allocated as `FP32`; it then needs 16 x 64 x 4 = 4096 bytes, so its size must be 4 KB rather than 2 KB. If that field is `S32`, the pair is illegal, and the bundle raises `Fault_TileLegality` before any destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-related role=related-owners-navigation -->
## Related owners

- [Tile schema](tile-schema.md) checks `TEXPDIF` bindings and calls this function.
- [Expansion schema](expansion-schema.md) calls it for the row and column expansion forms.
- [Destination operation](destination-operation.md) uses the destination type to allocate the result.
- [Data type and layout legality](../../../tile/model/legality/dtype-layout.md) defines `TileExpdifTypePairLegal`.
- [TEXPDIF](../../../tile/elementwise-tile-tile/transcendental/TEXPDIF.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/expdif-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","surface":"block","classification":["model","dispatch","expdif-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func SelectedBundleExponentialDifferenceTypes()
    => (boolean, TileDataType, TileDataType)
begin
    let default_type = TileDataType_FP64;
    if !_BundleOperation.data_type_valid then
        return (FALSE, default_type, default_type);
    end;
    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    var destination_type = source_type;
    if _BundleDataAttributesPresent then
        if _BundleDataAttributes.data_type == DTYPE_NONE then
            destination_type = source_type;
        elsif !BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
            return (FALSE, default_type, default_type);
        else
            destination_type = BundleTileDataType(
                _BundleDataAttributes.data_type);
        end;
    end;
    return (
        TileExpdifTypePairLegal(source_type, destination_type),
        source_type,
        destination_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
