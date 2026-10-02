<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.CAS.asl -->
# BSTART.MGATHER.CAS

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.CAS.asl`

atomic compare-and-swap gather using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-purpose role=purpose -->
## What BSTART.MGATHER.CAS contributes

`BSTART.MGATHER.CAS` opens a Tile memory block whose operation is `MGATHER_CAS`: an atomic compare-and-swap per lane. For each active lane it reads the global memory (GM) element at the base address plus that lane's logical element index, compares it with the lane's expected value, and stores that lane's replacement value only when the two match. The observed old value is written into the destination Tile either way.

The command is one 32-bit word with match `0x00811181` under mask `0x07ffffff`, so `DataType` occupies bits 31 to 27 and the fixed low bits carry TLSU selector 8. `BundleMGATHERCASSelected` matches that selector before the atom and reduction selectors, and `ExecuteBundleMGATHERCASOperation` runs the operation `TileOperation_MGATHER_CAS`.

Design point: the other gather forms carry all their operands in one binding, while a compare-and-swap needs two. This block therefore has two `B.IOT` records: the first carries the index and expected Tiles without a destination, and the second carries the replacement Tile with the destination and `last`.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-mechanism role=mechanism -->
## Placement and mechanism

The handler declines a `PE_MASK=0000` block as a strict no-op, decodes the selector, and validates the schema, the two-record binding shape, the type matrix, the layout and physical shape rules, and the shape relation between the index, expected, and replacement Tiles and the destination.

The Tile-level body `MGATHER_CAS` then probes every active lane for read and for write, and requires the two translations of each address to agree. Only after all probes succeed does it visit the lanes in an `ARBITRARY` order, compare, store, publish the old value into the destination, and record one atomic event.

Design point: the comparison uses the element-width raw old value, so for `U16`, `U32`, and `U64` the swap is a full-width bit comparison with no numeric conversion. A lane whose comparison fails stores nothing and records an event that reports no write, so the memory contents can be reconstructed from the event stream.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` must be `U16`, `U32`, or `U64`; every other type, including each packed four-bit type, is rejected.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col. The index, expected, and replacement Tiles and the destination must all have that valid shape and the bundle layout.
- The first `B.IOT` carries the index Tile in `source0` and the expected Tile in `source1`, with no destination, no size code, and no `last`.
- The second `B.IOT` carries the replacement Tile in `source0`, the destination with a size code, and `last`. With a predicate-Tile ExecutionMask the destination record also carries that mask as `source1`.
- The index Tile is `S32`, `U32`, `S64`, or `U64` with logical element indices, and `B.IOR BaseGPR, zero, zero, ->zero` is required with the same rules as a plain gather.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-effects role=effects -->
## Pending state and completion

Each active lane publishes its observed old value into the destination element at the same row and column, whether or not the comparison succeeded. The complete physical destination region is initialized before those results: coordinates the ExecutionMask deactivates take the mask's zero or merge value, and every other element outside the active lanes takes the bundle `PadValue`. On success the full physical destination region is defined.

A matching lane replaces one GM element atomically and records one atomic event; a mismatching lane records an event that reports no write. If any probe faults, the dispatcher calls `RollBackBundleTileDestinations`, so no destination is published and no GM element of this attempt has been modified.

Design point: publishing the old value in both outcomes is what makes the operation useful as a lock primitive. After the block commits, a lane whose destination element still equals its expected value failed to acquire, and no second read of GM is needed to find that out.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-constraints role=constraints -->
## Legality and fault boundary

- `PE_MASK=0000` is a strict no-op before every schema, source, GPR, dimension, allocation, and memory check.
- A reserved `DataType` code or an unknown TLSU selector raises `Fault_IllegalInstruction`; a type outside `U16`, `U32`, and `U64` raises `Fault_TileLegality`.
- A binding count other than two, a first record with a destination or with `last`, a second record without a destination, a missing `B.IOR`, a nonzero unused `B.IOR` selector, an undefined source, or a shape or layout mismatch raises `Fault_TileLegality` before the first probe.
- The layout is `ROWMAJOR`, `CUBE_M16`, or `CUBE_M32`; `CUBE_N8` is rejected. A read probe, a write probe, or a pair of translations that disagree raises the corresponding memory fault, with `Fault_DataPage` for the disagreeing case.
- If no free Local destination exists, resolution raises `Fault_TileAllocation`.

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MGATHER.CAS U32
B.DIM zero, 2, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 2, ->LB2
B.IOT T#1, T#2, mask=1111
B.IOT T#3, mask=1111, last, ->T<8B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` holds the logical element indices `0` and `4`, `T#2` holds the expected values `10` and `99`, `T#3` holds the replacements `20` and `0`, and `a0` holds `0x1000`. Suppose GM holds `10` at `0x1000` and `5` at `0x1004`. Lane 0 matches, so it stores `20`; lane 1 does not match `99`, so `0x1004` keeps `5`. The destination receives the observed values `10` and `5`, both elements defined, in 8 bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.CAS DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | L32 | 32 | 0x00811181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer, comparison, replacement, and destination element type | Encoded zero supplies numeric zero for the transfer, comparison, replacement, and destination element type. |

- `bstart_mgather_cas_32_fd8c8a3b720a.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer, comparison, replacement, and destination element type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_CAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_cas_32_fd8c8a3b720a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.DATR PadValue, Layout (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_CAS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_CAS()
    => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_CAS()
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

- Only U16, U32, and U64 transfer DataTypes are accepted; packed four-bit and every other existing unsupported atomic DataType remain illegal.
- Index, Expected, Replacement, and destination have equal logical valid shape and layout class.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each valid coordinate performs one atomic compare-and-swap at BaseGPR plus the sign- or zero-extended logical element index scaled by the transfer element width.
- All read/write probes complete before the first atomic effect; observed old values publish in the destination and non-valid physical elements contain PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
