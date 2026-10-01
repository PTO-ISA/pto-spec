<!-- GENERATED FROM: asl/block/execution/BSTART.TPREFETCH.asl -->
# BSTART.TPREFETCH

**Normative ASL source:** `asl/block/execution/BSTART.TPREFETCH.asl`

Prefetches one typed, strided GM rectangle for each of the four PEs without a Tile destination.

## Normative identity {#PTO-INST-BLOCK-BSTART-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tprefetch-purpose role=purpose -->
## What BSTART.TPREFETCH does

`BSTART.TPREFETCH` opens a Tile memory bundle whose operation is `TPREFETCH`: a typed, strided read of global memory (GM) on all four PEs that produces no Tile. It is one 32-bit word (match `0x00311181`, mask `0x07ffffff`) with `DataType` in bits 31 to 27. The form carries the fixed TLSU selector 3.

The successful architectural result is limited to load events and their ordering. No Tile or Shared descriptor, allocation, payload, definedness, or publication changes. Cache level, placement, and retention are not architectural results.

Design point: the start command reads no memory. [Bundle start dispatch](../model/dispatch/start.md) validates the descriptor and commits any active predecessor, and the prefetch runs when the bundle is committed, for example at `BSTOP`, at a following `BSTART`, at a trace `B.HINT`, or at the architecture enter request. A reserved `DataType` code raises `Fault_IllegalInstruction` at the `BSTART`.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-mechanism role=mechanism -->
## Placement and execution mechanism

At commit, [Tile execution](../model/dispatch/tile-execution.md) reaches the [TPREFETCH handler](../model/dispatch/tlsu-prefetch.md) after every earlier specialized selector declines. The handler checks the type, the absence of Tile bindings, the `B.IOR` record, the dimensions, and the data attributes, and then calls `TPREFETCHCore`.

For each of the four PEs and each element in `ValidRow x ValidCol`, the address is `base + (row * row_stride_elements + column) * element_size`. Packed four-bit types use the same logical-element byte addressing as `TLOAD`.

Design point: `TPREFETCHCore` probes every element of every PE before it records the first load event. A translation or permission fault on any PE therefore leaves no load event from any PE. The contract calls the four footprints one combined attempt, and recovery reissues the complete footprint.

Design point: there is no Tile binding to carry a `PE_MASK`, so participation is implicitly `1111`. Every PE computes its own footprint from its own base and stride GPRs, and the four footprints are checked together.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DataType` is the prefetched element type; codes 0 to 14, 16 to 20, and 24 to 28 are accepted.
- `B.DIM` `LB0`, `LB1`, and `LB2` give ValidCol, ValidRow, and physical Col. Omitted `LB0` and `LB1` default to one, and omitted `LB2` defaults to the resolved ValidCol.
- The optional `B.IOR` gives each PE's base in `RegSrc0` and row stride in `RegSrc1`, read from that PE's own GPRs. Omitted, the base is zero and the stride is Col.
- `B.IOT` and `B.IOS` are not members of a `TPREFETCH` bundle.

Design point: the row stride here counts elements, not bytes. `TPREFETCHCore` multiplies `row * row_stride_elements + column` by the element size, while `TLOAD` and `TSTORE` treat `RegSrc1` as a byte stride. The same GPR value therefore describes different footprints for the two operations.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-effects role=effects -->
## State effects and ordering

On success each PE records one typed load event per valid element, with the same event decomposition as `TLOAD`. All accesses participate in PTO-RC with the bundle's `aq` and `rl` attributes, exactly as for `TLOAD`.

No register is written. With no Tile binding, the final `FinalizeBundleTileAttempt` publishes nothing.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-constraints role=constraints -->
## Legality, faults, and atomicity

Each dimension must be in 1 to 65535, ValidCol may not exceed Col, Col must be a nonzero power of two, and `ValidRow * ValidCol` may not exceed `PTO_MODEL_TILE_ELEMENTS`. These failures, an unsupported type, a malformed `B.IOR`, or any `B.IOT` or `B.IOS` raise `Fault_TileLegality` before the first probe.

Design point: omission and an encoded zero differ. An omitted `B.DIM` has effective value one, but an explicit zero stays a value and faults. Because omitted `LB2` equals ValidCol, a bundle with ValidCol 48 and no `LB2` has Col 48, which is not a power of two, and also faults.

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.TPREFETCH FP16
B.DIM zero, 64, ->LB0
B.DIM zero, 4, ->LB1
B.DIM zero, 64, ->LB2
B.IOR zero, a0
BSTOP
```

Each PE prefetches 4 x 64 = 256 `FP16` elements, so the bundle records 1024 load events after all 1024 probes succeed. `RegSrc0` is `zero`, a real zero base. On a PE whose `a0` is 64, element (3, 63) is at `(3 * 64 + 63) * 2`, which is byte 510.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TPREFETCH DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | L32 | 32 | 0x00311181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | prefetched element data type | Encoded zero selects FP64. |

- `bstart_tprefetch_32_d5f83e5aadf6.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | prefetched element data type |
| B.IOR.RegSrc0 | each PE's private-GPR GM base |
| B.IOR.RegSrc1 | each PE's private-GPR logical row stride in elements |
| B.DIM.LB0 | ValidCol |
| B.DIM.LB1 | ValidRow |
| B.DIM.LB2 | physical Col |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TPREFETCH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tprefetch_32_d5f83e5aadf6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TPREFETCH DataType; optional B.DATR Layout; optional B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col; optional B.IOR base,row_stride; BSTOP
B.IOT and B.IOS are not members of a TPREFETCH block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TPREFETCH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TPREFETCH()
    => TileOperation
begin
    return TileOperation_TPREFETCH;
end;

pure func InstructionContractStartsTileBundle_BSTART_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit and B.DATR omission selects NORM layout.
- Omitted LB0 and LB1 each default to one; omitted LB2 defaults to resolved ValidCol.
- Omitted B.IOR supplies base zero and row stride equal to resolved Col independently for every PE. Explicit zero selectors read the architectural zero GPR and therefore supply actual zero values.

## Legality

- bstart_tprefetch_32_d5f83e5aadf6.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile binding.
- ValidCol and ValidRow are positive, Col is a nonzero power of two, and ValidCol does not exceed Col.

## State effects

- Starts a destination-free TLSU block whose successful architectural effects are limited to its defined typed memory accesses and ordering events.
- No Tile or Shared descriptor, allocation, payload, definedness, publication, or lifetime state changes.

## Memory effects and ordering

### Memory effects

- For every PE and every element in ValidRow x ValidCol, access GM at base + ((row * row_stride_elements + column) * element_size), with packed four-bit types using the same logical-element byte addressing as TLOAD.
- The operation produces the same typed-element load-event decomposition as TLOAD but allocates and writes no destination Tile. Cache level, placement, and retention are not architectural results.

### Ordering

- The four PE footprints are one combined preflighted block attempt; no request or event becomes effective until every address, translation, permission, and access check succeeds.
- All successful accesses participate in PTO-RC using the block aq/rl attributes exactly as TLOAD.

## Exceptions

- Reserved DataType, unsupported Layout, explicit zero or out-of-range dimensions, non-power-of-two Col, malformed B.IOR, any B.IOT/B.IOS, or any participating-PE memory fault rejects before the first request or memory event.
- A memory fault is precise for the complete four-PE block and recovery reissues the complete combined footprint.

## Examples

- BSTART.TPREFETCH FP16; B.DIM zero, 64, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 64, ->LB2; B.IOR zero, a0; BSTOP
