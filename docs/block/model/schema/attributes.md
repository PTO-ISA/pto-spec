<!-- GENERATED FROM: asl/block/model/schema/attributes.asl -->
# Attributes

**Normative ASL source:** `asl/block/model/schema/attributes.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-attributes-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the state writers for two header attribute commands. `B.CATR` sets the bundle control attributes. `B.FPATR` sets the fixed-point post-processing attributes of a matrix bundle.

The command dispatcher checks placement first and then calls these writers.

<!-- PTO-READER-BLOCK: block-model-schema-attributes-concepts role=concepts-state -->
## Concepts and visible state

`SetBundleControlAttributeState` sets `present` and six flags: `trap_enabled`, `atomic`, `acquire`, `release`, `far`, and `dimension_reduction`.

`SetBundleFixedPointAttributeState` sets `valid` and ten fields: `pre_quant_mode`, `relu_mode`, `group_n_code`, `row_max_en`, `group_max_en`, `row_max_init`, `max_abs_en`, `trans_a`, `trans_b`, and `c_scale_en`.

Two shorter overloads exist. The nine-argument form sets `c_scale_en` to false. The seven-argument form also sets `trans_a` and `trans_b` to false.

<!-- PTO-READER-BLOCK: block-model-schema-attributes-rules role=rules-interactions -->
## Rules and interactions

`B.CATR` is accepted only in the header of an active bundle, and only once. A second `B.CATR`, or one in the body, raises `Fault_BundleControl`.

`B.FPATR` is accepted only in the header, only once, only before any scalar, Tile, or Shared binding, and only when the operation descriptor is invalid or has class `TileMatrix`. Otherwise it raises `Fault_BundleControl`. Its fields must then pass `BundleFPATRFieldsLegal`, or it raises `Fault_TileLegality` and writes nothing. For example, `row_max_init` requires `row_max_en`, and `group_n_code` is nonzero exactly when `group_max_en` is set.

Design point: `B.FPATR` field checks run before the descriptor becomes visible. The ASL comment states this ordering. An illegal `B.FPATR` leaves `valid` false, so commit never sees a partly written post-processing descriptor.

Design point: each attribute record has its own presence flag. A second write is detected from `present` or `valid`, not from field values, so a `B.CATR` with every flag clear still counts as written.

Design point: `trap` is recorded here but acts only after a successful commit, as `Fault_BundlePostCommit`. Other flags are read when the operation runs; for example, acquire and release select the bundle memory order.

<!-- PTO-READER-BLOCK: block-model-schema-attributes-boundaries role=boundaries -->
## Architectural boundaries

`dimension_reduction` is not checked here. Commit rejects it on a block other than `TileElement` or `TileMemory`.

A `B.FPATR` descriptor on a non-matrix operation is also rejected at commit with `Fault_BundleControl`. `B.DATR` has its own writer in the control-state unit.

<!-- PTO-READER-BLOCK: block-model-schema-attributes-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A matrix bundle writes `B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0`. The fields are legal, so `valid` becomes true with every field zero. A later `B.FPATR` in the same header raises `Fault_BundleControl`, because `valid` is already set.

<!-- PTO-READER-BLOCK: block-model-schema-attributes-related role=related-owners-navigation -->
## Related owners

- [B.CATR](../../attributes/B.CATR.md) and [B.FPATR](../../attributes/B.FPATR.md) are the instruction pages.
- [Command dispatch](../dispatch/commands.md) enforces placement.
- [Commit validation](../commit/validation.md) checks `dimension_reduction` and runs the operation.
- [Enter and stop](../lifecycle/enter-stop.md) raises the post-commit trap.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/attributes.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES","surface":"block","classification":["model","schema","attributes"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-HEADER"]}
func SetBundleControlAttributeState(trap_enabled: boolean, atomic: boolean,
                                   acquire: boolean, release: boolean,
                                   far: boolean,
                                   dimension_reduction: boolean)
begin
    _BundleControlAttributes.present = TRUE;
    _BundleControlAttributes.trap_enabled = trap_enabled;
    _BundleControlAttributes.atomic = atomic;
    _BundleControlAttributes.acquire = acquire;
    _BundleControlAttributes.release = release;
    _BundleControlAttributes.far = far;
    _BundleControlAttributes.dimension_reduction = dimension_reduction;
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean,
                                       trans_a: boolean,
                                       trans_b: boolean,
                                       c_scale_en: boolean)
begin
    // Header-local field checks happen before the descriptor becomes visible.
    if !BundleFPATRFieldsLegal(pre_quant_mode, relu_mode, group_n_code,
                               row_max_en, group_max_en, row_max_init,
                               max_abs_en) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = pre_quant_mode;
    _BundleFixedPointAttributes.relu_mode = relu_mode;
    _BundleFixedPointAttributes.group_n_code = group_n_code;
    _BundleFixedPointAttributes.row_max_en = row_max_en;
    _BundleFixedPointAttributes.group_max_en = group_max_en;
    _BundleFixedPointAttributes.row_max_init = row_max_init;
    _BundleFixedPointAttributes.max_abs_en = max_abs_en;
    _BundleFixedPointAttributes.trans_a = trans_a;
    _BundleFixedPointAttributes.trans_b = trans_b;
    _BundleFixedPointAttributes.c_scale_en = c_scale_en;
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean,
                                       trans_a: boolean,
                                       trans_b: boolean)
begin
    SetBundleFixedPointAttributeState(
        pre_quant_mode, relu_mode, group_n_code,
        row_max_en, group_max_en, row_max_init, max_abs_en,
        trans_a, trans_b, FALSE);
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean)
begin
    SetBundleFixedPointAttributeState(
        pre_quant_mode, relu_mode, group_n_code,
        row_max_en, group_max_en, row_max_init, max_abs_en,
        FALSE, FALSE, FALSE);
end;
```
<!-- GENERATED-ASL-END: unit -->
