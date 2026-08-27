<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
# TPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TPACK.asl`

Pack two low-order raw byte fields into Local U32 CUBE words.

## Normative identity {#PTO-INST-TILE-TPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpack-purpose role=purpose -->
**Why use it.** `TPACK` joins low-order byte fields from two corresponding Local `U32` CUBE words, which is useful when the fields must be rearranged as raw storage rather than numerically converted.

<!-- PTO-READER-BLOCK: tile-tpack-mechanism role=mechanism -->
**How it works.** For every active word position, the selected low bytes of `source0` occupy the low destination bytes, the selected low bytes of `source1` follow them, and every remaining destination bit is zero.

<!-- PTO-READER-BLOCK: tile-tpack-inputs-outputs role=inputs-outputs -->
**Inputs and result.** `source0` and `source1` are matching Local `U32` `CUBE_M16` or `CUBE_M32` Tiles, `pack_control` supplies the two field widths, and `destination` is a fresh Tile with matching layout and geometry.

<!-- PTO-READER-BLOCK: tile-tpack-effects role=effects -->
**Effects.** Complete control and source validation precedes publication of the fully defined valid destination region; the sources persist, padding is `Null`, and the operation has no memory effect.

<!-- PTO-READER-BLOCK: tile-tpack-constraints role=constraints -->
**What is rejected.** Each field width must be from `1` through `3`, their sum must not exceed `4`, control bits `63:32` must be zero, and the destination must not alias either source; rejection occurs before destination effects.

<!-- PTO-READER-BLOCK: tile-tpack-example role=example -->
**Concrete example.** With corresponding source words `0x00001234` and `0x00ABCDEF`, control `0x00000202` selects two low bytes from each and produces `0xCDEF1234`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TPACK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPACK | TEPL | 0x077 | 23 | 3 | TPACK |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source0 |
| source1 | source1 |
| scalar0 | pack-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
```asl
readonly func InstructionContractOperation_TPACK() => TileOperation
begin
    return TileOperation_TPACK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPACK, U32
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source0, source1, ->destination
B.IOR pack_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
```asl
readonly func InstructionContractHandler_TPACK() => TileSemanticHandler
begin
    return TileHandler_TPACK;
end;

pure func InstructionContractDataTypeLegal_TPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U32;
end;

readonly func InstructionContractOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TPACK(destination, source0, source1, control);
end;

func InstructionContractExecute_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TPACK(
        destination, source0, source1, control);
    TPACK(destination, source0, source1, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TPACK accepts only Local U32 CUBE_M16 or CUBE_M32 sources and a fresh matching destination.
- The control selects two low-order byte fields with widths 1..3 whose sum is at most four.
- The result is raw zero-filled field assembly with no numeric conversion.

## State effects

- Pack corresponding source U32 words independently in every active CUBE word group.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Illegal field widths reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TPACK, U32; B.DATR Layout; B.IOT source0, source1, ->destination; B.IOR a0; BSTOP
