<!-- GENERATED FROM: asl/block/model/dispatch/numeric-control.asl -->
# Numeric Control

**Normative ASL source:** `asl/block/model/dispatch/numeric-control.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-purpose role=purpose-scope -->
## Purpose and scope

This unit turns the rounding and saturation request of a bundle into the concrete control that a numeric operation uses. The request comes from the `RMode` and `Sat` fields of `B.DATR`. The result is a `NumericExecutionControl` record with two fields: `rounding_mode` and `saturating`.

The unit has one function, `ResolveTileNumericExecutionControl`. It takes the decoded operation index and the decoded `TileInstructionOperands`.

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-concepts role=concepts-state -->
## Concepts and visible state

The input is `operands.numeric_control`, a `TileNumericSelection` built by `BundleTileInstructionOperands`. That builder calls `DecodeBundleRoundingSelection` on the three-bit `RMode` field and copies `Sat` into `saturating`.

`RMode` codes map as follows.

| `RMode` | Meaning |
| --- | --- |
| `000` | operation default; `use_operation_default` is true |
| `001` | `RNE`, round to nearest, ties to even |
| `010` to `111` | `RTZ`, `RTM`, `RTP`, `RNA`, `RTO`, and `RHB` |

The function only reads state. For the `TCVT` case it reads the `data_type` of the source and destination Tiles in `_Tiles`. It writes nothing and raises no fault.

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-rules role=rules-interactions -->
## Rules and interactions

The function copies `rounding_mode` and `saturating` from the selection. Then, if `use_operation_default` is true, it replaces the rounding mode.

- For `TCVT` with a floating source and a non-floating destination, the default is `RTZ`.
- For every other case, the default is `RNE`.

Saturation is never changed. It is exactly the `Sat` bit, and it is false when `B.DATR` is absent.

Two callers exist in the current ASL. The generated Tile dispatcher `ExecuteTileInstructionWithoutTimeWithAcceptedApplicabilityRules` resolves the control once for every decoded Tile operation and passes it to handlers that take `numeric_control`, such as `TCVT`; `MatrixPostProcessResult` resolves it for the CUBE matrix operation and passes it to the post-processing of each result element. Both run during execution, after preflight has succeeded and the destination is resolved.

Design point: `RMode` zero means "use the default of this operation", not a particular rounding mode. Code `001` names `RNE` explicitly. A program can therefore select `RNE` for a conversion whose own default is `RTZ`. Omitted `B.DATR` leaves the field at zero, so omission and an explicit `000` give the same result.

Design point: the `TCVT` default truncates toward zero when a floating value is converted to an integer type and rounds to nearest, ties to even, otherwise; the same rule appears in `InstructionContractDefaultRounding_TCVT` in the `TCVT` owner. In the current type enumeration every type is either floating or integer, so "non-floating destination" and "integer destination" select the same pairs.

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode `B.DATR`, check whether a rounding mode is supported for a type pair, or perform any rounding. The `TCVT` schema owner checks the resolved mode against the hardware profile during preflight, with its own copy of the `RNE` default. The numeric reference owners apply the mode.

Not every `B.DATR` field is numeric in every operation. For example, the row expansion page states that `RMode` names `BroadcastByteOffset` for `TROWEXPANDEXPDIF` on CUBE layouts.

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A `BSTART.TMATMUL` bundle with FP16 inputs carries a `B.DATR` with `RMode` `000` and `Sat` `1`, and a `B.FPATR` whose `PreQuantMode` is nonzero and not a shift mode, so `Sat` `1` is legal. The selection has `use_operation_default` true, so the function returns `rounding_mode` `RNE` and `saturating` true. Post-processing then passes this control through `MatrixFPATREffectiveControl`, which keeps `RNE` for most codes but substitutes `RHB` for `PreQuantMode` 25 and 28.

If `RMode` is `010` instead, the function returns `RTZ` without looking at the operation. The bundle is legal only when `PreQuantMode` is not a fixed-rounding code, because `BundleFPATRDATRFieldsLegal` requires `RMode` `000` for those codes.

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-related role=related-owners-navigation -->
## Related owners

- [Tile instruction operands](tile-instruction-operands.md) builds the selection from `B.DATR`.
- [Matrix postprocess execution](../../../tile/model/execution/postprocess.md) calls this function.
- [Rounding](../../../arch/data-types/rounding.md) defines `NumericExecutionControl` and the rounding modes.
- [TCVT](../../../tile/elementwise-tile-tile/format-conversion/TCVT.md) states the conversion default.
- [B.DATR](../../attributes/B.DATR.md) carries `RMode` and `Sat`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/numeric-control.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","surface":"block","classification":["model","dispatch","numeric-control"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
readonly func ResolveTileNumericExecutionControl(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    operands: TileInstructionOperands) => NumericExecutionControl
begin
    var result = NumericExecutionControl {
        rounding_mode = operands.numeric_control.rounding_mode,
        saturating = operands.numeric_control.saturating
    };
    if operands.numeric_control.use_operation_default then
        result.rounding_mode = NumericRound_RNE;
        if TileOperationOfIndex(operation) == TileOperation_TCVT &&
           TileDataTypeIsFloating(_Tiles[[operands.source0]].data_type) &&
           !TileDataTypeIsFloating(_Tiles[[operands.destination0]].data_type) then
            result.rounding_mode = NumericRound_RTZ;
        end;
    end;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
