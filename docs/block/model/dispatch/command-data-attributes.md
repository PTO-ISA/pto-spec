<!-- GENERATED FROM: asl/block/model/dispatch/command-data-attributes.asl -->
# Command Data Attributes

**Normative ASL source:** `asl/block/model/dispatch/command-data-attributes.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-purpose role=purpose-scope -->
## Purpose and scope

This unit connects the `B.DATR` header command to bundle state and checks its two ExecutionMask controls. `B.DATR` is the bundle data-attribute command. It carries `DataType`, `Layout`, `PadValueOrByteId`, `CMode`, `RMode`, `Sat`, `Canonicalize`, and the two mask controls `PredInv` and `Zero`.

It defines two functions:

- `SetBundleDataAttributesFromCommand` decodes the fields of one `B.DATR` and latches them.
- `BundleExecutionMaskDataAttributesLegal` decides, for a selected Tile operation, whether the ExecutionMask and its `PredInv` and `Zero` controls are legal.

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-concepts role=concepts-state -->
## Concepts and visible state

An ExecutionMask is a per-coordinate predicate that limits which destination coordinates an operation writes. It can be carried by a GPR (`execution_mask_present` on a `B.IOR` record) or by an extra PredicateCell source Tile. `PredInv` inverts that predicate. `Zero` selects zeroing instead of merging for inactive destination coordinates.

`SetBundleDataAttributesFromCommand` passes the seven data fields to `SetBundleDataAttributeState`. That helper checks the `DataType` and `Layout` codes, then writes the fields into `_BundleDataAttributes` and clears both mask controls. Only if no fault was raised does this unit then write `execution_mask_invert` and `execution_mask_zero` and set `_BundleDataAttributesPresent`.

Design point: `_BundleDataAttributesPresent` is set last and only after a fault-free decode. A reserved `DataType` or unassigned `Layout` raises `Fault_TileLegality` and leaves the data attributes unchanged and not marked present.

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-rules role=rules-interactions -->
## Rules and interactions

The command handler in the commands owner calls `SetBundleDataAttributesFromCommand` only while a bundle is in its header phase and no earlier `B.DATR` was latched. Otherwise it raises `Fault_BundleControl`.

`BundleExecutionMaskDataAttributesLegal` is a read-only check that runs later, when the bundle is validated. It rejects in two cases.

1. `PredInv` or `Zero` is nonzero and no ExecutionMask is present in any carrier.
2. A mask is present, and either the operation is not ExecutionMask-eligible, or the Local layout is not `CUBE_M16` or `CUBE_M32`, or `Zero` is set on an operation without a `destination0` operand, unless the operation is `TCMP` or `TCMPS`.

The Local layout normally comes from the bundle's current layout. A CUBE layout-conversion transport uses the CUBE layout named by its `B.DATR` conversion code instead.

Design point: `TCMP`, `TCMPS`, `TSEL`, and `TSELS` keep the `B.DATR` `Layout` field at zero, and a CUBE `TCVT` keeps it at `NORM`; for these five operations this check derives the CUBE domain from the source Tile descriptors. `TCMP` needs both sources in the same CUBE layout. `TSEL` needs its true and false sources in the same CUBE layout, and it chooses those sources differently for the PredicateCell and non-PredicateCell forms. As a result, a masked CUBE comparison is accepted even though its `B.DATR` says `NORM`.

Design point: a nonzero mask control without a mask is rejected, not ignored. Zero values keep their defined meanings: normal polarity and MERGE. A stray `PredInv=1` or `Zero=1` therefore cannot silently have no effect.

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-boundaries role=boundaries -->
## Architectural boundaries

`BundleExecutionMaskDataAttributesLegal` returns a boolean; it does not raise the rejection fault itself. Its callers, for example the Tile schema owner, the Tile execution owner, and the CUBE transport owner, map a false result to `Fault_TileLegality`.

It does not decide whether the other `B.DATR` fields apply to the operation. Per-operation applicability of `CMode`, `RMode`, `Sat`, `Canonicalize`, and padding is checked by the Tile schema owner through `TileOperationDATRFieldsLegal`. Mask capture and application belong to the ExecutionMask owners.

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Consider a `TADD` bundle whose `B.DATR` selects `Layout` `CUBE_M16` and sets `Zero=1`.

- With a third PredicateCell source Tile as the mask, `TADD` is eligible, the layout is CUBE, and `TADD` has a destination. The check passes, and inactive destination coordinates are zeroed.
- Without any mask carrier, case 1 applies and the bundle is rejected with `Fault_TileLegality` before effects.
- With a mask but `B.DATR` `Layout` `NORM` (RowMajor), case 2 applies and the bundle is also rejected.

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-related role=related-owners-navigation -->
## Related owners

- [Command dispatch](commands.md) enforces header placement and the single-`B.DATR` rule.
- [Control state](../state/control-state.md) owns `SetBundleDataAttributeState` and the current layout.
- [ExecutionMask schema](execution-mask-schema.md) detects mask carriers and captures the mask.
- [Tile schema](tile-schema.md) calls this check together with per-field applicability.
- [B.DATR](../../attributes/B.DATR.md) is the instruction page for the command.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/command-data-attributes.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","surface":"block","classification":["model","dispatch","command-data-attributes"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded_operation = TileOperationOfIndex(operation);
    let mask_present = _BundleExecutionMask.valid ||
        _BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present ||
        BundleExecutionMaskTileCarrierPresent(operation);
    if (_BundleDataAttributes.execution_mask_invert ||
        _BundleDataAttributes.execution_mask_zero) && !mask_present then
        return FALSE;
    end;
    var local_cube_layout = FALSE;
    if BundleCubeTransportSelected() then
        let transport_layout = TileDataLayoutCubeLayout(
            _BundleDataAttributes.data_layout);
        local_cube_layout = transport_layout == TileLayout_CUBE_M16 ||
            transport_layout == TileLayout_CUBE_M32;
    else
        let current_layout = CurrentBundleTileLayout();
        local_cube_layout = current_layout == TileLayout_CUBE_M16 ||
            current_layout == TileLayout_CUBE_M32;
    end;
    // TCMP and TCMPS own a closed B.DATR schema that leaves Layout zero.
    // Their Local CUBE domain comes from the comparison source tiles,
    // while DATR Layout remains independently validated as zero by the
    // operation owner.
    if decoded_operation == TileOperation_TCMP then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid && binding.source1_valid then
            let left = BundleTileSourceIndex(0, FALSE);
            let right = BundleTileSourceIndex(0, TRUE);
            local_cube_layout =
                (_Tiles[[left]].layout == TileLayout_CUBE_M16 ||
                 _Tiles[[left]].layout == TileLayout_CUBE_M32) &&
                _Tiles[[right]].layout == _Tiles[[left]].layout;
        else
            local_cube_layout = FALSE;
        end;
    elsif decoded_operation == TileOperation_TCMPS then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid then
            let source = BundleTileSourceIndex(0, FALSE);
            local_cube_layout = _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
                _Tiles[[source]].layout == TileLayout_CUBE_M32;
        else
            local_cube_layout = FALSE;
        end;
    // CUBE TCVT also keeps B.DATR Layout=NORM because the retained source
    // descriptor owns both the conversion layout and ExecutionMask domain.
    elsif decoded_operation == TileOperation_TCVT then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid then
            let source = BundleTileSourceIndex(0, FALSE);
            local_cube_layout = _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
                _Tiles[[source]].layout == TileLayout_CUBE_M32;
        else
            local_cube_layout = FALSE;
        end;
    // TSEL/TSELS also keep B.DATR Layout closed at zero.  For the
    // ExecutionMask intersection, derive the Local CUBE domain from the
    // operation's numeric input descriptors instead of DATR Layout.
    elsif decoded_operation == TileOperation_TSEL then
        let inputs = _BundleTileBindings[[0]];
        if inputs.valid && inputs.source0_valid then
            let first = BundleTileSourceIndex(0, FALSE);
            if _Tiles[[first]].storage_kind == TileStorage_PredicateCell then
                if inputs.source1_valid &&
                   _BundleTileBindings[[1]].valid &&
                   _BundleTileBindings[[1]].source0_valid then
                    let source_true = BundleTileSourceIndex(0, TRUE);
                    let source_false = BundleTileSourceIndex(1, FALSE);
                    local_cube_layout =
                        (_Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                         _Tiles[[source_true]].layout == TileLayout_CUBE_M32) &&
                        _Tiles[[source_false]].layout ==
                            _Tiles[[source_true]].layout;
                else
                    local_cube_layout = FALSE;
                end;
            elsif inputs.source1_valid then
                let source_true = BundleTileSourceIndex(0, FALSE);
                let source_false = BundleTileSourceIndex(0, TRUE);
                local_cube_layout =
                    (_Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                     _Tiles[[source_true]].layout == TileLayout_CUBE_M32) &&
                    _Tiles[[source_false]].layout ==
                        _Tiles[[source_true]].layout;
            else
                local_cube_layout = FALSE;
            end;
        else
            local_cube_layout = FALSE;
        end;
    elsif decoded_operation == TileOperation_TSELS then
        let inputs = _BundleTileBindings[[0]];
        if inputs.valid && inputs.source0_valid then
            let first = BundleTileSourceIndex(0, FALSE);
            if _Tiles[[first]].storage_kind == TileStorage_PredicateCell then
                if inputs.source1_valid then
                    let source_true = BundleTileSourceIndex(0, TRUE);
                    local_cube_layout =
                        _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                        _Tiles[[source_true]].layout == TileLayout_CUBE_M32;
                else
                    local_cube_layout = FALSE;
                end;
            else
                local_cube_layout =
                    _Tiles[[first]].layout == TileLayout_CUBE_M16 ||
                    _Tiles[[first]].layout == TileLayout_CUBE_M32;
            end;
        else
            local_cube_layout = FALSE;
        end;
    end;
    if mask_present &&
       (!TileOperationExecutionMaskEligible(operation) ||
        !local_cube_layout ||
        (_BundleDataAttributes.execution_mask_zero &&
         !TileOperandPresent(operation, TileOperand_destination0) &&
         TileOperationOfIndex(operation) != TileOperation_TCMP &&
         TileOperationOfIndex(operation) != TileOperation_TCMPS)) then
        return FALSE;
    end;
    return TRUE;
end;

func SetBundleDataAttributesFromCommand(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1})
begin
    SetBundleDataAttributeState(
        DecodeCommandOperandRaw(instruction, form,
            CommandField_DataType)[4:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_Layout)[4:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_PadValueOrByteId)[1:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_CMode)[2:0],
        DecodeCommandOperandRaw(instruction, form,
            CommandField_RMode)[2:0],
        CommandDecodedBool(instruction, form, CommandField_Sat),
        CommandDecodedBool(instruction, form, CommandField_Canonicalize));
    if _LastFault == Fault_None then
        _BundleDataAttributes.execution_mask_invert =
            CommandDecodedBool(instruction, form, CommandField_PredInv);
        _BundleDataAttributes.execution_mask_zero =
            CommandDecodedBool(instruction, form, CommandField_Zero);
        _BundleDataAttributesPresent = TRUE;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
