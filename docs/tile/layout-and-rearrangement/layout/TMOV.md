<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TMOV.asl -->
# TMOV

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TMOV.asl`

Copy the source Tile payload and definedness into the destination.

## Normative identity {#PTO-INST-TILE-TMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmov-purpose role=purpose -->
## What TMOV does

Local `TMOV` copies one persistent Local Tile into a newly renamed Local destination. It copies the payload and the per-element definedness exactly; it does not convert values.

Design point: `TMOV` is selected by `BSTART.TMOV` (Function 2) and has no standalone opcode. The same `BSTART.TMOV` Function 2 also carries the canonical Shared forms: Local source to Shared destination, and Shared source to Local destination, with `B.SUBVIEW` or `B.ASSEMBLE` ranges. [BSTART.TMOV](../../../block/execution/BSTART.TMOV.md) owns those modes.

<!-- PTO-READER-BLOCK: tile-tmov-mechanism role=mechanism -->
## Copy mechanism

Without an ExecutionMask, the destination receives the source payload and the source definedness record. An element that is undefined in the source stays undefined in the destination.

With an ExecutionMask, the source must be defined at the coordinates the mask requires. Each inactive valid element then receives the mask's zero or merge value, and the whole valid region is marked defined.

Design point: the `BSTART` `DataType` is only a carrier interpretation. A source backing type may differ from it only at the same element width, and the destination keeps the source backing type. `TMOV` therefore never changes element bits; use `TCVT` for a numeric conversion.

<!-- PTO-READER-BLOCK: tile-tmov-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

- `source0` is the persistent Local source.
- `destination0` is the newly renamed Local destination.

The destination must match the source exactly in physical rows and columns, valid rows and columns, layout, and storage kind, and its type must equal the source backing type.

`BSTART.TMOV` accepts `DTYPE_NONE` (code 31). When neither `B.DATR` nor `BSTART` gives a concrete type, the operation type is the source descriptor type. `B.DATR` may carry only a `Layout`, and its pad field must be zero.

Carrier compatibility excludes 4-bit types: a 4-bit backing type is accepted only when it equals the operation type.

<!-- PTO-READER-BLOCK: tile-tmov-effects role=effects -->
## Effects and ordering

The source persists unchanged. The destination payload, definedness, and descriptor become visible when the bundle completes; a rejected bundle has no destination effect.

Local `TMOV` has no global-memory effect and records no numeric status.

<!-- PTO-READER-BLOCK: tile-tmov-constraints role=constraints -->
## Legality and faults

A shape, layout, storage-kind, or carrier-width mismatch, a destination type that differs from the source backing type, or a nonzero `B.DATR` field other than `Layout` is rejected before architectural effects.

Design point: an exact shape match is required rather than a resize. A program that needs a different valid region or padding must use an operation that owns that change.

<!-- PTO-READER-BLOCK: tile-tmov-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

A source Tile holds 8 x 64 `FP32` elements in RowMajor, and element `[0,0]` holds `0x3f800000`. With the operation type `S32`, which has the same 32-bit width, the copy is legal: the destination is `FP32` 8 x 64 and element `[0,0]` still holds `0x3f800000`. With `FP16` the widths differ, and the bundle is rejected.

In macro form, the copy with the matching type is written below. The destination holds 8 x 64 x 4 = 2048 bytes.

```text
TMOV <FP32>, T#1, ->T<2KB>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TMOV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMOV | TLSU |  | 2 |  | TMOV |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TMOV.asl -->
```asl
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TLSU TMOV, DataType
B.DIM LB0
B.DIM LB1 (optional)
B.DIM LB2 (optional)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TMOV.asl -->
```asl
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;

readonly func InstructionContractOperandsLegal_TMOV(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_TMOV(destination, source);
end;

func InstructionContractExecute_TMOV(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TMOV(destination, source);
    TMOV(destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TMOV schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TMOV.

## Legality

- TMOV is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TMOV validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].
- The selected DataType is a carrier interpretation. Each non-packed source backing DataType may differ only at the same element width, and the newly allocated destination preserves the source backing DataType; multi-source operations require one common backing DataType.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Copy the source Tile payload and definedness into the destination.
- After complete preflight, execute TMOV with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- Perform only the global, Local, or Shared data movement named by the mnemonic after complete access, shape, stride, and descriptor validation; a fault produces no partial destination or memory effect.

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.TLSU TMOV, DataType; B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; BSTOP
