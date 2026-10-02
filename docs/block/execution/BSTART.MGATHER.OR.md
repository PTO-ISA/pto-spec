<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.OR.asl -->
# BSTART.MGATHER.OR

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.OR.asl`

Starts GM indexed mgather.or operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-OR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-or-purpose role=purpose -->
## Purpose and scope

`BSTART.MGATHER.OR` opens a Tile memory block whose operation is `MGATHER_OR`: one atomic read-modify-write per lane that replaces a global memory (GM) element with the bitwise OR of that element and a value Tile element, and returns the observed old value in a new Local destination Tile.

The command is one 32-bit word with match `0x01111181` under mask `0x07ffffff`, so `DataType` occupies bits 31 to 27 and the fixed low bits carry TLSU selector 17. `ExecuteBundleGMAtomRedOperation` maps selector 17 through `GMAtomicOperationFromFunction` to `GMAtomic_OR` and calls `GM_ATOM_VALUE(...)`. A reserved `DataType` code raises `Fault_IllegalInstruction` at the `BSTART`, before the block commits.

Design point: the sibling `BSTART.MSCATTER.OR` performs the same bit setting but publishes no Tile. Because an OR only adds set bits, the atom form's returned old value is what tells a program which bits were already set before this block ran.

<!-- PTO-READER-BLOCK: block-bstart-mgather-or-mechanism role=mechanism -->
## How to read the operation

At commit the block runs the Tile-level body through `GM_ATOM_VALUE`, which calls the shared atom body `GMRunAtomic`. That body visits every active lane, computes the address as `BaseGPR` plus the lane's logical element index, and probes it for read and then for write; two probes whose translations differ raise `Fault_DataPage`. Only after all lanes pass does it update them one at a time in an `ARBITRARY` order: load the old element, compute the new element, store it, publish the old value into the destination, and record one atomic event.

`GMAtomicResult` computes the new element as the raw bitwise `old OR value` of the two element-width words, with no numeric interpretation of either operand.

Design point: a lane whose value element is zero leaves its element unchanged yet still publishes the old value and still records an update event. A zero mask is therefore an atomic observation of an element rather than a no-op in the event stream.

Design point: `OR` is commutative, associative, and idempotent, so two lanes that name the same address produce the same element value in either commit order. A program that needs a defined result can rely on the memory value even where it must not rely on the destination contents.

<!-- PTO-READER-BLOCK: block-bstart-mgather-or-inputs role=inputs-outputs -->
## Inputs and outputs

- `DataType` must be `U32` or `U64`; every other code, including the floating, signed, and packed four-bit types, is rejected for this operation.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col. All three must equal the index Tile's and the value Tile's valid columns, valid rows, and the destination's physical columns.
- `B.IOR BaseGPR, zero, zero, ->zero` is required: `RegSrc0` selects the per-PE base GPR, the other three selectors encode zero, and a `RegSrc0` of `zero` supplies base address zero.
- Without a predicate-Tile ExecutionMask, one terminating `B.IOT` carries the index Tile, the value Tile, and the destination. With one, the first `B.IOT` carries the two sources with no destination and no `last`, and a second `B.IOT` carries the mask Tile, the destination, and `last`.
- The index Tile is `S32`, `U32`, `S64`, or `U64` with logical element indices. The value Tile uses the operation `DataType` and the same valid shape as the index Tile.

<!-- PTO-READER-BLOCK: block-bstart-mgather-or-effects role=effects -->
## Effects and state

Each active lane leaves the updated element in one GM element and publishes the old value into the destination element at the same row and column. The complete physical destination region is defined before those results: coordinates the ExecutionMask deactivates take the mask's zero or merge value, and every other element outside the active lanes takes the bundle `PadValue`.

On success each active lane has performed one atomic update and recorded one atomic event, and the destination is fully defined. The GM results stay visible; the atom form does not roll memory back.

<!-- PTO-READER-BLOCK: block-bstart-mgather-or-constraints role=constraints -->
## Boundaries and failures

`PE_MASK=0000` exits at the start of the atom/red dispatcher, before its schema, GPR, descriptor, type, and memory checks.

An unknown TLSU code raises `Fault_IllegalInstruction`. A binding count other than the one or two records above raises `Fault_BundleControl`. A missing `B.IOR`, a Shared binding, a nonzero unused `B.IOR` selector, a dimension outside `1..65535`, a `DataType` other than `U32` or `U64`, a wrong layout or shape, or an undefined active index or value element raises `Fault_TileLegality` before the first probe. A failed destination allocation raises `Fault_TileAllocation`, and a memory fault keeps its own kind.

<!-- PTO-READER-BLOCK: block-bstart-mgather-or-example role=example -->
## Non-normative usage example

Treat the generated `BSTART.MGATHER.OR` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

```asm
BSTART.MGATHER.OR U32
B.DIM zero, 2, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 2, ->LB2
B.IOT T#1, T#2, mask=1111, last, ->T<8B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` is a 1 by 2 `S32` index Tile holding `0` and `4`, `T#2` is the 1 by 2 `U32` value Tile holding the masks `0x30` and `0x0F`, and `a0` holds `0x1000`. If GM holds `0x0F` at `0x1000` and `0xF0` at `0x1004`, the results are `0x0F OR 0x30`, which is `0x3F`, and `0xF0 OR 0x0F`, which is `0xFF`. The destination receives the old values `0x0F` and `0xF0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.OR DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_or_32_gm17 | L32 | 32 | 0x01111181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_or_32_gm17 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mgather_or_32_gm17 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mgather_or_32_gm17.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.OR.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_OR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_or_32_gm17);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.OR DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.OR.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_OR() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_OR()
    => TileOperation
begin
    return TileOperation_MGATHER_OR;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_OR()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- PE_MASK=0000 is a strict no-effect case; B.IOR and valid dimensions are required otherwise.
- LB0 supplies ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.

## Legality

- GM-only operation; Shared and vector forms are excluded.

## State effects

- Opens a complete GM indexed block.

## Memory effects and ordering

### Memory effects

- Complete preflight precedes atomic effects.

### Ordering

- Duplicate effective addresses serialize in implementation-defined order.

## Exceptions

- Reserved DataTypes fault IllegalInstruction; unsupported operation/type tuples fault TileLegality; access faults are preflighted.

## Examples

- BSTART.MGATHER.OR DataType
