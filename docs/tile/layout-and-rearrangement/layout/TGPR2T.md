<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
# TGPR2T

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TGPR2T.asl`

Re-encode four GPR predicate planes into an ordinary CUBE U8 Tile.

## Normative identity {#PTO-INST-TILE-TGPR2T}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgpr2t-purpose role=purpose -->
## Purpose and scope

`TGPR2T` is the stable reader entry point for this accepted operation. The normative `ASL` source and the generated contract sections on this page remain the only owners of architectural behavior.

<!-- PTO-READER-BLOCK: tile-tgpr2t-mechanism role=mechanism -->
## How to read the operation

Read the generated Decode and Operation sections together to locate the selected form and semantic handler. This guide adds no alternate execution algorithm.

<!-- PTO-READER-BLOCK: tile-tgpr2t-inputs role=inputs-outputs -->
## Inputs and outputs

Use the generated Operands and results table and Block composition section as the complete map of encoded and architectural roles. Do not infer an omitted operand or result from this summary.

<!-- PTO-READER-BLOCK: tile-tgpr2t-effects role=effects -->
## Effects and state

Use the generated State effects and Memory effects and ordering sections for the complete effect boundary. Executable points are evidence that the owner is exercised, not another source of meaning.

<!-- PTO-READER-BLOCK: tile-tgpr2t-constraints role=constraints -->
## Boundaries and failures

Defaults, Legality, and Exceptions below define the accepted domain and failure boundary. Reserved values and unsupported combinations remain governed by those generated sections.

<!-- PTO-READER-BLOCK: tile-tgpr2t-example role=example -->
## Non-normative usage example

Treat the generated `TGPR2T` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TGPR2T <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGPR2T | TEPL | 0x07E | 30 | 3 | TGPR2T |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | ordinary numeric U8 CUBE destination |
| source0 | ordered source-only GPR0 |
| source1 | ordered source-only GPR1 |
| source2 | ordered source-only GPR2 |
| source3 | ordered source-only GPR3 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
```asl
readonly func InstructionContractOperation_TGPR2T() => TileOperation
begin
    return TileOperation_TGPR2T;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGPR2T, U8
B.DATR PadValueOrByteId, RMode (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow
B.IOR GPR0, GPR1, GPR2
B.IOR GPR3
B.IOT mask=PE_MASK, <last>, ->destination<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TGPR2T.asl -->
```asl
readonly func InstructionContractHandler_TGPR2T() => TileSemanticHandler
begin
    return TileHandler_TGPR2T;
end;

pure func InstructionContractDataTypeLegal_TGPR2T(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8;
end;

readonly func InstructionContractOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    return TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
end;

func InstructionContractExecute_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    TGPR2T(destination, source0, source1, source2, source3);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects Zero padding and ByteOffset0.
- LB1/LB0=32/4 selects CUBE_M32; LB1/LB0=16/8 selects CUBE_M16. Both dimensions are mandatory and LB2 is absent.

## Legality

- TGPR2T uses TEPL Mode 3 Function 30 (0x07E) with U8 operation type.
- Exact dimensions 32x4 select an ordinary numeric CUBE_M32 destination and 16x8 select CUBE_M16; LB2 is absent and the encoded TSize must cover the complete descriptor.
- Four ordered source-only 64-bit GPRs are supplied by exactly two contiguous B.IOR records with arity 3+1; selectors are absolute GPR0..GPR23.
- Zero and Max are the only padding values. PE_MASK=0000 is a strict no-op before schema, GPR reads, allocation, or effects.

## State effects

- Pack M32 rows as eight predicate bits into one selected U8 byte; pack M16 rows as sixteen bits into two selected U8 bytes.
- PadValue is independent of ByteOffset; the operation does not change GPRs or status.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All four GPR sources and PE mask are snapshotted before destination publication.
- No old destination payload is read; successful publication is atomic.

## Exceptions

- RMode[17] must be zero. PadValue accepts only Zero or Max; Min and Null reject before effects.
- Exactly two immediately contiguous source-only B.IOR records split 3+1 are required, followed by one destination B.IOT. Missing dimensions, an intervening command, wrong order/split, GPR destination, or surplus record rejects before effects.

## Examples

- BSTART.SFU TGPR2T, U8; B.DATR PadValueOrByteId, RMode; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow; B.IOR a0, a1, a2; B.IOR a3; B.IOT mask=1111, <last>, ->T0<TSize>; BSTOP
