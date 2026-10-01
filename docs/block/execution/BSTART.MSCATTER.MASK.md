<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.MASK.asl -->
# BSTART.MSCATTER.MASK

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.MASK.asl`

Masked scatter using explicit byte displacements.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-purpose role=purpose -->
## What BSTART.MSCATTER.MASK contributes

`BSTART.MSCATTER.MASK` opens a Tile memory block whose operation is `MSCATTER_MASK`: an indexed store in which a Local predicate Tile decides, lane by lane, whether that lane stores. For each active lane whose predicate element is `0x01`, one transfer element of the data Tile is written to global memory (GM) at the base address plus that lane's byte displacement. A lane whose predicate element is `0x00` is skipped.

The command is one 32-bit word with match `0x00711181` under mask `0x07ffffff`, so `DataType` occupies bits 31 to 27 and the fixed low bits carry TLSU selector 7. `BundleMSCATTERMASKSelected` matches that selector and `ExecuteBundleMSCATTERMASKOperation` runs the operation `TileOperation_MSCATTER_MASK`. No Tile is allocated by this block and no source Tile is consumed or modified.

Design point: the mask is always a separate operand record here, because a scatter has no destination that a second record could describe. A gather spends its second record on the destination when a predicate-Tile ExecutionMask is present, while this block spends it on the predicate Tile and never has a destination at all.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-mechanism role=mechanism -->
## Placement and mechanism

The handler declines a `PE_MASK=0000` block as a strict no-op, decodes the selector, and validates the schema, the two-record binding shape, the predicate values, the type matrix, the layout and physical shape rules, and the relation between the data Tile, the index Tile, and the predicate Tile.

The Tile-level body `MSCATTER_MASK` computes an address and probes it for write only when the predicate element is `0x01`. It then commits one store per enabled lane in an `ARBITRARY` order and records one store event for each.

Design point: a false predicate performs no address generation and no probe, so a wild index under a false predicate cannot fault and cannot touch memory. That is what makes a masked scatter usable with a data-dependent index Tile whose unused entries are never initialized.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` is the transfer element type and must equal the data Tile's element type.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col. The values must describe the data Tile exactly: its valid columns, its valid rows, and its physical columns.
- The first `B.IOT` carries the data Tile in `source0` and the index Tile in `source1`, with no destination, no size code, and no `last`.
- The second `B.IOT` carries the predicate Tile in `source0` and `last`, and a predicate-Tile ExecutionMask, when present, in `source1`. There is no destination record.
- The index Tile is `S32`, `U32`, `S64`, or `U64` with byte displacements and the bundle layout. The predicate Tile is an ordinary Local `U8` carrier with the index Tile's valid shape and the bundle layout.
- `B.IOR BaseGPR, zero, zero, ->zero` is required: `RegSrc0` selects the per-PE base GPR, and the other three selectors must encode zero.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-effects role=effects -->
## Pending state and completion

Each enabled lane stores one transfer element. For a packed four-bit `DataType`, one index names one byte, which receives the low nibble of data column `2 * c` and the high nibble of column `2 * c + 1`, and one predicate element controls that complete byte pair. The data valid columns must then be exactly twice the index valid columns, so no pair is incomplete.

The block publishes no Tile and leaves both source Tiles unchanged. On success each enabled lane has written GM once and recorded one store event; memory ordering is unchanged apart from the implementation-defined order among duplicate addresses.

Design point: because a skipped lane writes nothing, the GM element keeps whatever value it had. Unlike a masked gather, whose skipped lanes are visible as padded destination elements, a masked scatter leaves no trace of a skipped lane, so the program must keep the predicate Tile if it later needs to know which elements it stored.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-constraints role=constraints -->
## Legality and fault boundary

- `PE_MASK=0000` is a strict no-op before every schema, source, GPR, dimension, address, predicate, and memory check.
- A reserved `DataType` code or an unknown TLSU selector raises `Fault_IllegalInstruction`.
- A predicate element other than `0x00` or `0x01`, a predicate Tile whose valid shape differs from the index Tile's, a `B.IOS` binding, a missing `B.IOR`, a nonzero unused `B.IOR` selector, a binding shape other than the two records above, an undefined source, or a type, shape, layout, or dimension mismatch raises `Fault_TileLegality` before the first probe.
- The layout is `ROWMAJOR`, `CUBE_M16`, or `CUBE_M32`; `CUBE_N8` is rejected. For `ROWMAJOR` the physical columns must be a nonzero power of two and may not be smaller than the valid columns.
- An enabled lane that cannot be written raises its own memory fault. There is no destination to roll back, so such a fault leaves the bundle active with nothing published.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MSCATTER.MASK U32
B.DIM zero, 4, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 4, ->LB2
B.IOT T#2, T#1, mask=1111
B.IOT T#3, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#2` is a 1 by 4 `U32` data Tile holding `7`, `8`, `9`, and `10`, `T#1` is the 1 by 4 `S32` index Tile holding `0`, `4`, `8`, and `12`, `T#3` is the 1 by 4 `U8` predicate Tile holding `1`, `1`, `0`, and `0`, and `a0` holds `0x1000`. Only the first two lanes store, writing `7` at `0x1000` and `8` at `0x1004`. The indices `8` and `12` are never turned into addresses, and the memory they name keeps its previous contents.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.MASK DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | L32 | 32 | 0x00711181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | memory transfer element type selector | Encoded zero supplies numeric zero for the memory transfer element type selector. |

- `bstart_mscatter_mask_32_2a33eed646f7.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | memory transfer element type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_mask_32_2a33eed646f7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_MASK()
    => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.
- IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.

## Legality

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 7 with encoded DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
