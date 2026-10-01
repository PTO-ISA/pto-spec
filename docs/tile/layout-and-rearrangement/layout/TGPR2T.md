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

`TGPR2T` transposes predicate bits held in four general-purpose registers (GPRs) into a newly allocated `U8` CUBE Tile. Each GPR holds whole predicate planes; each Tile row receives the bits of every plane for that row, packed into bytes.

Design point: `TGPR2T` is selected by `BSTART.SFU` with TEPL Mode 3 Function 30 (selector `0x07E`) and operation type `U8`. The result is an ordinary numeric `U8` Tile, not a PredicateCell, so its bytes may hold any value from `0x00` to `0xFF`.

<!-- PTO-READER-BLOCK: tile-tgpr2t-mechanism role=mechanism -->
## Bit mapping

First, every padding element and every active valid element is set to the effective pad value: `0x00` for `Zero` or `0xFF` for `Max`. The byte offset, the encoded `B.DATR` `RMode[16:15]` field, then selects which column receives the packed bytes.

`CUBE_M32` (32 rows by 4 columns): row r of column `offset` receives one byte whose bit b is plane b at row r. Plane p lives in GPR `p / 2` at bit `(p mod 2) x 32 + r`, so planes 0 to 7 use all 256 bits of the four GPRs.

`CUBE_M16` (16 rows by 8 columns): row r of columns `2 x offset` and `2 x offset + 1` receives planes 0 to 7 and planes 8 to 15. Plane p lives in GPR `p / 4` at bit `(p mod 4) x 16 + r`.

Under an ExecutionMask, an inactive element receives the mask's zero or merge value, and a packed byte is written only where its coordinate is active.

Design point: the columns outside the selected byte offset keep the pad pattern. A program that reads the whole Tile therefore sees a value selected by `PadValue`, never a leftover from an earlier Tile.

<!-- PTO-READER-BLOCK: tile-tgpr2t-inputs role=inputs-outputs -->
## Inputs and outputs

- `source0` to `source3` are four GPRs, GPR0 to GPR3 in the bit mapping above, named by absolute selectors from 0 to 23.
- `destination0` is a newly allocated numeric `U8` Tile in `CUBE_M32` or `CUBE_M16`.

The shape is fixed: `B.DIM` LB1 = 32 with LB0 = 4 selects `CUBE_M32`, and LB1 = 16 with LB0 = 8 selects `CUBE_M16`. Both dimensions are mandatory, LB2 must be 1 (its default value), and the encoded TSize must cover the whole descriptor.

The four GPRs come from exactly two immediately contiguous source-only `B.IOR` records split 3+1, followed by one destination `B.IOT`. [TGPR2T schema](../../../block/model/dispatch/tgpr2t-schema.md) checks that stream.

`B.DATR` is optional. Omitting it selects `Zero` padding and byte offset 0.

<!-- PTO-READER-BLOCK: tile-tgpr2t-effects role=effects -->
## Effects and state

All four GPRs and the PE mask are snapshotted before publication, and no old destination payload is read. The destination payload, descriptor, and definedness publish as one operation; every element becomes defined.

`TGPR2T` writes no GPR, records no numeric status, and has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-tgpr2t-constraints role=constraints -->
## Boundaries and failures

- `RMode[17]` must be zero, and `RMode[16:15]` is the byte offset 0 to 3; for this operation `RMode` is not a rounding mode.
- The effective `PadValue` must be `Zero` or `Max`; `Min` and `Null` are rejected before effects.
- A missing dimension, a shape other than 32 x 4 or 16 x 8, an intervening command, a wrong order or split of the `B.IOR` records, a GPR destination, or a surplus record rejects before effects.
- `PE_MASK=0000` is a strict no-op after the `B.IOT` size-code encoding check: no schema check, GPR read, allocation, or effect follows, but an illegal `B.IOT` size code still raises `Fault_IllegalInstruction`.

<!-- PTO-READER-BLOCK: tile-tgpr2t-example role=example -->
## Non-normative usage example

Treat the generated `TGPR2T` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

The header `BSTART.SFU TGPR2T, U8` with `B.DIM` LB1 = 32 and LB0 = 4 selects a `CUBE_M32` destination of 32 x 4 = 128 bytes. `B.DATR` selects `Zero` and byte offset 0. The first GPR is `0x0000000100000001`, and the other three are zero.

Bit 0 of the first GPR is plane 0 at row 0, and bit 32 is plane 1 at row 0. Row 0 of column 0 therefore receives `0x03`, and every other byte is `0x00`. With `Max` instead, columns 1 to 3 hold `0xFF`, while column 0 still holds `0x03` in row 0 and `0x00` in rows 1 to 31.
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
