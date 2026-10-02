<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.MASK.asl -->
# BSTART.MGATHER.MASK

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.MASK.asl`

Masked gather using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-purpose role=purpose -->
## What BSTART.MGATHER.MASK contributes

`BSTART.MGATHER.MASK` opens a Tile memory block whose operation is `MGATHER_MASK`: an indexed load in which a Local predicate Tile decides, lane by lane, whether that lane is loaded. For each active lane whose predicate element is `0x01`, one transfer element is read from global memory (GM) at the base address plus that lane's logical element index and written into the destination Tile. A lane whose predicate element is `0x00` is skipped.

The command is one 32-bit word with match `0x00611181` under mask `0x07ffffff`, so `DataType` occupies bits 31 to 27 and the fixed low bits carry TLSU selector 6. `BundleMGATHERMASKSelected` matches that selector and `ExecuteBundleMGATHERMASKOperation` runs the operation `TileOperation_MGATHER_MASK`.

Design point: the `B.IOT` `PE_MASK` and the predicate Tile select different things. `PE_MASK` selects which PEs take part at all, while the predicate Tile selects individual coordinates inside each participating PE. The predicate is therefore an operand Tile, not an encoding field, and it can be produced by an earlier operation in the same program.

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-mechanism role=mechanism -->
## Placement and mechanism

The handler declines a `PE_MASK=0000` block as a strict no-op, decodes the selector, and validates the schema, the layout and physical shape rules, and the relation between the bundle dimensions, the index Tile, and the predicate Tile. The predicate Tile must be an ordinary Local `U8` carrier whose valid shape equals the index Tile's valid shape, and every predicate element must be `0x00` or `0x01`; any other value raises `Fault_TileLegality` before effects.

The Tile-level body `MGATHER_MASK` computes an address and probes it for read only when both the predicate element is `0x01` and the ExecutionMask leaves that coordinate active. It then loads exactly those lanes and records one load event for each.

Design point: a false predicate performs no address generation at all, so no translation, permission check, probe, event, or data-access fault can come from that lane. A skipped lane keeps the padding value in its destination element, which is what makes the mask usable for sparse patterns without a separate clearing step.

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` is the transfer element type, and it need not match the predicate Tile's element type.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col (default `LB0`). The valid rows and valid columns must equal the index Tile's valid shape, and the predicate Tile must have the same valid rows and valid columns as the index Tile.
- One terminating `B.IOT` carries the index Tile in `source0`, the predicate Tile in `source1`, the `PE_MASK`, `last`, and a destination with a size code. With a predicate-Tile ExecutionMask the destination moves to a second `B.IOT`.
- The index Tile is `S32`, `U32`, `S64`, or `U64` with the bundle layout and logical element indices. The predicate Tile uses the bundle layout.
- `B.IOR BaseGPR, zero, zero, ->zero` is required, with `RegSrc0` as the per-PE base GPR and the other three selectors encoding zero.

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-effects role=effects -->
## Pending state and completion

Each enabled lane writes one loaded element into the destination element at the same row and column. For a packed four-bit type, one indexed byte supplies two adjacent logical nibbles and one predicate element controls the whole byte pair, so the destination valid columns are exactly twice the index valid columns.

Before the loads, the complete physical destination region is defined: coordinates the ExecutionMask deactivates take the mask's zero or merge value, and every other element, including lanes skipped by the predicate, takes the bundle `PadValue`. On success the whole physical destination region is defined; a failing attempt publishes no destination.

Design point: the padded and the skipped elements are indistinguishable in the published result, because both receive the same `PadValue`. A program that needs to know whether a lane was masked must keep the predicate Tile, not read the destination.

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-constraints role=constraints -->
## Legality and fault boundary

- `PE_MASK=0000` is a strict no-op before every schema, source, GPR, dimension, allocation, predicate, address, and fault check.
- A reserved `DataType` code or an unknown TLSU selector raises `Fault_IllegalInstruction`.
- A predicate element other than `0x00` or `0x01`, a predicate Tile whose valid shape differs from the index Tile's, a `B.IOS` binding, a missing `B.IOR`, a nonzero unused `B.IOR` selector, a malformed binding schema, a wrong index type, an undefined source, or a shape, layout, or dimension mismatch raises `Fault_TileLegality` before the first probe.
- The layout is `ROWMAJOR`, `CUBE_M16`, or `CUBE_M32`; `CUBE_N8` is rejected, and record counts must match the presence of a predicate-Tile ExecutionMask.
- If no free Local destination exists, resolution raises `Fault_TileAllocation`. An enabled lane whose address cannot be accessed raises its own memory fault, and the destination is rolled back.

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MGATHER.MASK U32
B.DIM zero, 4, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 4, ->LB2
B.IOT T#1, T#2, mask=1111, last, ->T<16B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` is a 1 by 4 `S32` index Tile holding `0`, `4`, `8`, and `12`, `T#2` is a 1 by 4 `U8` predicate Tile holding `1`, `1`, `0`, and `0`, and `a0` holds `0x1000`. Only the first two lanes are probed and loaded, from `0x1000` and `0x1004`. The last two indices are never turned into addresses, so they cannot fault, and their destination elements keep the pad value.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.MASK DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_mask_32_5573241cd944 | L32 | 32 | 0x00611181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_mask_32_5573241cd944 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_mask_32_5573241cd944 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer and destination element type | Encoded zero supplies numeric zero for the transfer and destination element type. |

- `bstart_mgather_mask_32_5573241cd944.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer and destination element type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_mask_32_5573241cd944);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.MASK DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_MASK()
    => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault and leaves the corresponding destination value(s) at PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
