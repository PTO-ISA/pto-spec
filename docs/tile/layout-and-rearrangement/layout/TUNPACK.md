<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
# TUNPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TUNPACK.asl`

Extract and zero-extend a raw byte field from Local U32 CUBE words.

## Normative identity {#PTO-INST-TILE-TUNPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tunpack-purpose role=purpose -->
**Why use it.** `TUNPACK` extracts a contiguous raw byte field from each Local `U32` CUBE word and places that field in a zero-extended `U32` result.

<!-- PTO-READER-BLOCK: tile-tunpack-mechanism role=mechanism -->
**How it works.** The low control byte gives the source byte offset, the next control byte gives the count, and the selected bytes are copied down to destination byte zero while all higher result bits remain zero.

<!-- PTO-READER-BLOCK: tile-tunpack-inputs-outputs role=inputs-outputs -->
**Inputs and result.** `source` is a Local `U32` `CUBE_M16` or `CUBE_M32` Tile, `unpack_control` selects the field, and `destination` is a fresh Local `U32` Tile with matching layout and geometry.

<!-- PTO-READER-BLOCK: tile-tunpack-effects role=effects -->
**Effects.** Control and source validation precedes publication of the fully defined valid destination region; the source persists, destination padding is `Null`, and the operation has no memory effect.

<!-- PTO-READER-BLOCK: tile-tunpack-constraints role=constraints -->
**What is rejected.** The offset must be from `0` through `3`, the count from `1` through `4`, their sum must not exceed `4`, control bits `63:32` must be zero, and source and destination must not alias; rejection has no destination effect.

<!-- PTO-READER-BLOCK: tile-tunpack-example role=example -->
**Concrete example.** Source word `0x44332211` with control `0x00000201` selects two bytes starting at byte offset `1` and produces `0x00003322`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TUNPACK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TUNPACK | TEPL | 0x078 | 24 | 3 | TUNPACK |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | unpack-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
```asl
readonly func InstructionContractOperation_TUNPACK() => TileOperation
begin
    return TileOperation_TUNPACK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TUNPACK, U32
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source, ->destination
B.IOR unpack_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
```asl
readonly func InstructionContractHandler_TUNPACK() => TileSemanticHandler
begin
    return TileHandler_TUNPACK;
end;

pure func InstructionContractDataTypeLegal_TUNPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U32;
end;

readonly func InstructionContractOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TUNPACK(destination, source, control);
end;

func InstructionContractExecute_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TUNPACK(destination, source, control);
    TUNPACK(destination, source, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TUNPACK accepts only Local U32 CUBE_M16 or CUBE_M32 sources and a fresh matching destination.
- The control selects one contiguous byte field with offset 0..3 and count 1..4 within a U32 word.
- The result is zero-extended raw extraction.

## State effects

- Extract and zero-extend one byte field in each active CUBE word group.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Illegal offset/count fields reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TUNPACK, U32; B.DATR Layout; B.DIM LB0; B.IOT source, ->destination; B.IOR a0; BSTOP
