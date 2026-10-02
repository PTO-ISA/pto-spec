<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.XOR.asl -->
# BSTART.MSCATTER.XOR

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.XOR.asl`

Starts GM indexed mscatter.xor operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-XOR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-purpose role=purpose -->
## Purpose and scope

`BSTART.MSCATTER.XOR` opens a Tile memory bundle whose operation is `MSCATTER_XOR`: an indexed reduction. For each lane it reads the GM element at a base address plus a logical element index, XORs it with a value from a Local value Tile, and writes the result back. It returns no Tile.

The command is one 32-bit word (match `0x01a11181`, mask `0x07ffffff`) with `DataType` in bits 31 to 27. It carries the fixed TLSU selector 26, which the reduction table maps to `GMReduction_XOR`. A reserved `DataType` code raises `Fault_IllegalInstruction` at the `BSTART`, before [bundle start dispatch](../model/dispatch/start.md) commits any predecessor.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-mechanism role=mechanism -->
## How to read the operation

At commit, [Tile execution](../model/dispatch/tile-execution.md) sends every function from 8 to 12 and 14 to 27 that no earlier selector claims to the [GM atomic and reduction handler](../model/dispatch/tlsu-gm-atom-red.md). Function 26 is a reduction, so the handler resolves no destination and calls `GM_RED_VALUE`.

`GM_RED_VALUE` first visits every active lane. It probes the address for read and for write, and raises `Fault_DataPage` if the two translations differ. Only after all lanes pass does it apply the updates, one lane at a time in an arbitrary order: load the old value, compute `old XOR value`, store it, and record an atomic memory event.

Design point: all probes run before the first update. A translation or permission fault on any lane therefore leaves memory unchanged. The contract states this as complete preflight before atomic effects.

Design point: each update reloads the current memory value. Two lanes with the same address both contribute, and because XOR is commutative and associative the final value does not depend on the implementation-defined lane order.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-inputs role=inputs-outputs -->
## Inputs and outputs

- `DataType` must be `U32` or `U64`; other assigned codes fault at commit.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col.
- One `B.IOT` with no destination carries the index Tile in `source0` and the value Tile in `source1`, and carries `last` when no predicate-Tile ExecutionMask is present.
- One `B.IOR BaseGPR, zero, zero, ->zero` is required; `RegSrc0` is the per-PE base address.
- The index Tile is S32, U32, S64, or U64. The value Tile has the operation `DataType`. Both have the `B.DIM` valid shape and the bundle layout.

Design point: the operand order is the opposite of plain `MSCATTER`, whose `B.IOT` carries the data Tile first. Here the index comes first, matching the `GM_RED_VALUE` argument order shared by every indexed reduction.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-effects role=effects -->
## Effects and state

On success, each active lane has updated one GM element to `old XOR value`, and one atomic event per lane is recorded with the bundle memory order. No Tile, Shared Tile, or register is written, and both source Tiles keep their contents.

The duplicate-address order is implementation-defined, but for XOR it does not change the final memory value.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-constraints role=constraints -->
## Boundaries and failures

`PE_MASK=0000` is a strict no-op before every schema, descriptor, type, or memory check.

The operation is GM-only. A `B.IOS` binding, a missing `B.IOR`, nonuniform PE masks, illegal dimensions, a wrong type, an undefined source, or a shape or layout mismatch raises `Fault_TileLegality`. A binding count rejected by the handler's own count check raises `Fault_BundleControl`. A memory fault keeps its own kind, and no rollback is needed because there is no destination.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-xor-example role=example -->
## Non-normative usage example

Treat the generated `BSTART.MSCATTER.XOR` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

```asm
BSTART.MSCATTER.XOR U32
B.DIM zero, 8, ->LB0
B.DIM zero, 8, ->LB2
B.IOT T#1, T#2, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

`LB1` is omitted, so ValidRow is 1. The index Tile `T#1` and the value Tile `T#2` are 1 x 8 `U32` Tiles. On each PE the 8 lanes are probed for read and write before any update. If two lanes both hold index `0x10` with values `0x0F` and `0xF0`, and the word at `a0 + 0x10` was `0x01`, it ends as `0x01 XOR 0x0F XOR 0xF0`, which is `0xFE`, in either lane order.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.XOR DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_xor_32_gm26 | L32 | 32 | 0x01a11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_xor_32_gm26 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mscatter_xor_32_gm26 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mscatter_xor_32_gm26.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.XOR.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_XOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_xor_32_gm26);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.XOR DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.XOR.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_XOR() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_XOR()
    => TileOperation
begin
    return TileOperation_MSCATTER_XOR;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_XOR()
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

- BSTART.MSCATTER.XOR DataType
