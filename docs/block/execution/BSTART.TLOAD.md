<!-- GENERATED FROM: asl/block/execution/BSTART.TLOAD.asl -->
# BSTART.TLOAD

**Normative ASL source:** `asl/block/execution/BSTART.TLOAD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TLOAD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tload-purpose role=purpose -->
## What BSTART.TLOAD contributes

`BSTART.TLOAD` opens a Tile memory bundle whose operation is `TLOAD`: a strided read from global memory (GM) into a Tile. It is one 32-bit word (match `0x00011181`, mask `0x07ffffff`). Its only field is `DataType` in bits 31 to 27. The form carries the fixed TLSU selector 0, so the bundle always runs `TLOAD`.

Four destination kinds share this start: an ordinary Local Tile, a Shared Tile, a Local CUBE Tile converted from an ordinary GM layout, and a weight-mode Shared Tile. The `B.DATR` `Layout` and the binding kind (`B.IOT` or `B.IOS`) choose among them.

Design point: the start command reads no memory. [Bundle start dispatch](../model/dispatch/start.md) checks the descriptor, commits any active predecessor, and opens the bundle with a fallthrough continuation. The load runs when the bundle is committed, for example at `BSTOP`, at a following `BSTART`, at a trace `B.HINT`, or at the architecture enter request. A reserved `DataType` code (15, 21 to 23, or 29 to 31) raises `Fault_IllegalInstruction` at the `BSTART`, before the predecessor commits.

<!-- PTO-READER-BLOCK: block-bstart-tload-mechanism role=mechanism -->
## Placement and mechanism

At commit, [Tile execution](../model/dispatch/tile-execution.md) tests its specialized selectors in a fixed order. For a `TLOAD` bundle the outcomes are:

- A `B.DATR` layout of `OHWI2NK` (code 10) or `OIHW2NK` (code 11) selects [weight-to-Shared execution](../model/dispatch/weight-to-shared-execution.md).
- A layout code from 21 to 26 selects [CUBE transport](../model/dispatch/tlsu-layout-conversion.md). A load accepts only `ND2M32` (21), `ND2M16` (22), and `ND2N8` (23).
- Any `B.IOS` binding selects [Shared TLSU](../model/dispatch/shared-tlsu.md), function 0.
- Otherwise the generic path allocates the Local destination named by `B.IOT` and calls the Tile-level [TLOAD](../../tile/memory-and-data-movement/regular/TLOAD.md).

Each selected PE reads its own `B.IOR` GPRs: `RegSrc0` is the GM base and `RegSrc1` is the byte row stride. Element (row, column) is read from `base + row * row_stride_bytes + column * element_size`. A packed four-bit column instead adds `floor(column / 2)` bytes to the row base and selects the low or high nibble by column parity.

Design point: `TLOAD` stops at the first memory fault. The Tile-level routine probes and reads one element at a time, so load events of elements read before the fault stay recorded. The generic commit path then calls `RollBackBundleTileDestinations`, which releases a destination that the bundle allocated, so no new Local Tile is published. For a Shared destination the contract lets completed reads remain in a record that is neither complete nor whole-parent-ready.

<!-- PTO-READER-BLOCK: block-bstart-tload-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` is the destination element type; codes 0 to 14, 16 to 20, and 24 to 28 are accepted. In the CUBE and weight forms it is the transfer type, and the `B.DATR` `DataType` field must be `DTYPE_NONE`.
- `B.DIM` `LB0`, `LB1`, and `LB2` give ValidCol, ValidRow, and physical Col for ordinary forms. In the CUBE form `LB0` and `LB1` are the valid columns and rows and `LB2` is not used. In weight mode they are ValidK, ValidN, and TotalK.
- The optional `B.IOR` supplies the base and byte row stride. Weight mode instead needs exactly one three-source `B.IOR GMBase, ShapeGPR, StartGPR, ->zero`.
- The destination is either one terminating destination-only `B.IOT` or one destination `B.IOS`, never both. Source Tile bindings are illegal.

Design point: omitting `B.IOR` and encoding `zero` are different. Omission gives base zero and the dense row stride `ceil(columns * element_bits / 8)`, using the resolved Col (or `LB0` in the CUBE form). An explicit `zero` selector reads the zero GPR, so it supplies a real zero base or a zero stride; with a zero stride every row reads the same GM bytes.

<!-- PTO-READER-BLOCK: block-bstart-tload-effects role=effects -->
## Pending state and completion

A Local form allocates one destination whose Rows are derived from the `B.IOT` `SizeCode`, Col, and `DataType`, fills the valid region, and publishes it when the commit succeeds.

A Shared form with a single participating PE loads and publishes the complete parent. With more than one PE in the mask, `B.ASSEMBLE` is mandatory: Tile execution rejects a multi-PE Shared destination without it with `Fault_TileLegality` before the handler runs. The parent then publishes atomically at the gap-free LAST writer.

A CUBE form installs a persistent CUBE descriptor whose geometry comes from the layout, `DataType`, `LB1`, and `LB0`; `TSize` is capacity only. A weight form writes a row-major Shared `[N][K]` window, and Cin padding lanes become raw zero without a GM access.

<!-- PTO-READER-BLOCK: block-bstart-tload-constraints role=constraints -->
## Legality and fault boundary

`PE_MASK=0000` is a strict no-op before GPR reads, allocation, memory access, or faults. Otherwise ValidCol and ValidRow must be nonzero and no greater than the derived Col and Rows, which are powers of two.

At commit, schema, shape, and type errors raise `Fault_TileLegality`. The Shared path raises `Fault_BundleControl` for an illegal `B.IOR` schema, and CUBE transport raises `Fault_TileAllocation` when no destination fits. A GM translation or permission fault keeps its own kind and stops the request.

Design point: a failed commit returns before the bundle stops, as [commit validation](../model/commit/validation.md) describes. The bundle stays active with its header intact, so a trap handler sees the whole bundle and a retry reruns the complete load.

<!-- PTO-READER-BLOCK: block-bstart-tload-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

A partial `FP32` Tile with an 8 x 64 physical shape and a 7 x 60 valid region is written in macro form as `TLOAD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32>, [base=a0, stride=a1], ->T<2KB>`. It expands to this bundle:

```asm
BSTART.TLOAD FP32
B.DIM zero, 60, ->LB0
B.DIM zero, 7, ->LB1
B.DIM zero, 64, ->LB2
B.IOR a0, a1
B.IOT mask=1111, last, ->T<5>
BSTOP
```

`SizeCode` 5 is 2048 bytes, so Rows is 2048 / (64 * 4) = 8, which covers ValidRow 7. Each PE reads 7 * 60 = 420 elements. If a PE holds `a1` equal to 256, element (6, 59) is read from `a0 + 6 * 256 + 59 * 4`, which is `a0 + 1772`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TLOAD DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tload_32_d0c18bb0ab15 | L32 | 32 | 0x00011181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tload_32_d0c18bb0ab15 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tload_32_d0c18bb0ab15 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | destination element data type | Encoded zero selects FP64. |

- `bstart_tload_32_d0c18bb0ab15.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | destination element data type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | ordinary per-PE private-GPR byte row stride; weight-mode ShapeGPR packing Cin, Cout, KernelH, and KernelW |
| B.DIM.LB0 | ordinary ValidCol or CUBE valid columns |
| B.DIM.LB1 | ordinary ValidRow or CUBE valid rows |
| B.DIM.LB2 | ordinary physical Col; forbidden for CUBE conversion |
| B.IOT/B.IOS | Local or Shared destination, per-PE TSize, and participation mask |
| B.IOR.RegSrc2 | weight-mode StartGPR packing NStart and KStart |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TLOAD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tload_32_d0c18bb0ab15);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local destination: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM supplies ValidCol, ValidRow, and physical Col; optional B.IOR supplies per-PE base and byte row stride; exactly one terminating destination B.IOT allocates the Local result; BSTOP commits.
Shared destination: replace destination B.IOT with one destination B.IOS naming S0..S63, SizeCode, and PE_MASK. One participating issuer loads the complete parent; multiple issuers require B.ASSEMBLE with explicit writer ranges.
Local CUBE destination: encode B.DATR Layout ND2M32, ND2M16, or ND2N8 with DataType=DTYPE_NONE; require LB0=valid columns and LB1=valid rows, omit LB2, and use one terminating destination B.IOT.
Weight-mode Shared destination: explicit B.DATR OHWI2NK or OIHW2NK; LB0=ValidK, LB1=ValidN, LB2=TotalK; exactly one three-source B.IOR binds GMBase, ShapeGPR, StartGPR -> zero; singleton publication omits B.ASSEMBLE and multi-participant publication uses contiguous N-row B.ASSEMBLE ranges.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TLOAD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TLOAD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TLOAD()
    => TileOperation
begin
    return TileOperation_TLOAD;
end;

pure func InstructionContractStartsTileBundle_BSTART_TLOAD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TLOAD(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsLoad(data_layout);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit. Optional B.DATR omission retains the default NORM layout.
- LB0/ValidCol and LB1/ValidRow default through the common destination-shape contract; omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must be at least ValidRow.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride.
- Weight mode uses DTYPE_NONE and zero B.DATR controls; ShapeGPR packs Cin/Cout/KernelH/KernelW, StartGPR packs NStart/KStart, and the physical Shared descriptor is row-major [N][K] with K contiguous.

## Legality

- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- Exactly one destination domain is used: a terminating destination B.IOT for Local or one destination B.IOS for Shared. Source Tile bindings and mixed Local/Shared destinations are illegal.
- ValidCol and ValidRow must be nonzero and no greater than derived physical Col and Rows; Col and Rows are powers of two under the common Tile descriptor contract.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, or descriptor changes.
- CUBE conversion accepts only Layout codes 21 through 23, requires explicit DTYPE_NONE, explicit nonzero LB0/LB1, absent LB2, one Local destination B.IOT, a supported non-64-bit non-HiF4X2 dtype, and no B.IOS.
- Weight mode accepts only OHWI2NK code 10 and OIHW2NK code 11, requires the exact fixed B.DATR fields, exactly one three-source B.IOR, equal participating-PE GMBase/ShapeGPR/StartGPR values, wide-checked Cin/Cout/kernel bounds, and aligned ValidK/KStart windows; codes 12 and 13 remain reserved for future KN forms.

## State effects

- Allocates/renames one Local destination or reallocates the named Shared destination with Rows derived from SizeCode, Col, and DataType, then fills the valid region.
- A singleton Shared issuer loads and publishes the complete logical parent. Multiple Shared issuers require B.ASSEMBLE with explicit ranges and atomic LAST publication.
- A successful CUBE form installs a persistent Matrix-location descriptor with CELL geometry derived from Layout, BSTART DataType, LB1 valid rows, and LB0 valid columns; TSize remains capacity only.
- A successful weight-mode Shared form atomically publishes the existing row-major NK descriptor; ordinary TLOAD and all non-weight layouts retain their existing behavior.

## Memory effects and ordering

### Memory effects

- For every selected PE and every element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.
- All accesses participate in PTO-RC with the block's aq/rl attributes and report the first fault while retaining prior completed reads.
- Weight mode maps OHWI/OIHW GM weights into canonical [kh][kw][c1][c0] order, defines Cin padding lanes as raw zero without GM access, and writes a row-major Shared [N][K] window without touching physical tails.

### Ordering

- Resolve and validate the full schema, dimensions, masks, per-PE GPR inputs, and destination allocation before accessing each element until the first fault.
- On success publish the complete destination atomically at block commit; on a fault retain only completed effects and do not advertise a partial destination as complete.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, capacity/shape overflow, inconsistent or illegal PE masks, malformed binding schema, allocation failure, or memory translation/permission/alignment fault rejects before destination publication.
- The request stops at the first memory fault; completed reads may remain in a partially defined Local destination or Shared generation, which is not complete or whole-parent-ready.

## Examples

- BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP
- BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0001, ->S7<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {ND2M16, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=K; B.DIM LB1=M; B.IOT mask=1111, <last>, ->M<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {OHWI2NK, DTYPE_NONE, Zero, EQ, Default, 0, 0}; B.DIM LB0=ValidK; B.DIM LB1=ValidN; B.DIM LB2=TotalK; B.IOR GMBase, ShapeGPR, StartGPR, ->zero; B.IOS mask, ->S0<SizeCode>; BSTOP
