<!-- GENERATED FROM: asl/block/execution/BSTART.TEPL.asl -->
# BSTART.TEPL

**Normative ASL source:** `asl/block/execution/BSTART.TEPL.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TEPL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tepl-purpose role=purpose -->
## What BSTART.TEPL contributes

`BSTART.TEPL` is the only 32-bit encoding whose `Mode` and `Function` fields select the operation, and every operation it selects runs on the VEC or SFU engine. Its `Mode` and `Function` fields form a seven-bit selector that names the operation, and its `DataType` field names the element type.

Canonical assembly never prints `BSTART.TEPL`. It prints [BSTART.VEC](BSTART.VEC.md) or [BSTART.SFU](BSTART.SFU.md) with an operation name, and both aliases produce exactly these bits. `BSTART.TEPL` remains accepted as compatibility input.

<!-- PTO-READER-BLOCK: block-bstart-tepl-mechanism role=mechanism -->
## Placement and mechanism

[Decode](../model/dispatch/decode.md) builds the operation descriptor: class Tile element, `mode` from `Mode`, selector bits `4:0` from `Function`, and the data type. The Tile decode code is `Mode` in bits `6:5` and `Function` in bits `4:0`.

[Bundle start dispatch](../model/dispatch/start.md) then checks the descriptor with [descriptor legality](../model/dispatch/descriptor-legality.md) before it commits any predecessor. The code must name an assigned operation in the TEPL family, and the data type must be concrete. If both hold, dispatch commits the predecessor, opens the block, and installs the descriptor.

The operation itself runs later. At `BSTOP` or the next `BSTART`, [commit validation](../model/commit/validation.md) calls [Tile execution dispatch](../model/dispatch/tile-execution.md), which validates the bundle and runs the operation, for example `ExecuteTileBinary` for `TADD`.

Design point: operation identity lives in one selector, while shape, attributes, and operands come from the shared header commands `B.DIM`, `B.DATR`, and `B.IOT`. Every VEC and SFU operation therefore shares one start encoding, one descriptor format, and one commit path.

<!-- PTO-READER-BLOCK: block-bstart-tepl-inputs role=inputs-outputs -->
## Operands and header roles

- `Mode`, bits `26:25`, is the high part of the selector.
- `Function`, bits `24:20`, is the low part of the selector. `TADD` is `Mode` 0 `Function` 0, and `TEXP` is `Mode` 0 `Function` 18.
- `DataType`, bits `31:27`, is the element type. Codes 0 to 21 and 24 to 28 are accepted; 22, 23, and 29 to 31 are reserved. Code zero selects `FP64`.

The rest of the block schema belongs to the selected operation's own page. For example, `TADD` needs `B.DIM LB0` and one terminating `B.IOT` with two sources and a destination.

<!-- PTO-READER-BLOCK: block-bstart-tepl-effects role=effects -->
## Pending state and completion

After the predecessor commits, the start writes `BPC`, a `BARG` whose block kind is Tile element with transfer `Fallthrough`, and the operation descriptor. `TPC` moves to the next instruction. The start itself allocates no Tile, reads no source, and has no memory effect.

At commit, a failed operation leaves the block active with its header intact, and the Tile-execution owner has already rolled back its destinations. A successful operation publishes its destination, and the block continues at the sequential continuation.

<!-- PTO-READER-BLOCK: block-bstart-tepl-constraints role=constraints -->
## Legality and fault boundary

- A reserved `DataType` code fails operand legality and raises `Fault_IllegalInstruction`.
- An unassigned `Mode:Function` selector fails descriptor legality and raises `Fault_IllegalInstruction`.

Both checks precede predecessor commit and `BARG` changes, so a rejected `BSTART.TEPL` leaves the active predecessor untouched.

Design point: `DTYPE_NONE` (code 31) is reserved in this encoding. Only `TMOV` can infer its type from a source, and `TMOV` is not a TEPL operation, so the `BSTART.TEPL` start of every VEC or SFU block names a concrete type.

Operation-specific legality, such as an unsupported type for the selected operation or a malformed `B.IOT`, is checked at commit and faults there.

<!-- PTO-READER-BLOCK: block-bstart-tepl-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.TEPL 0, 0, FP32
```

`Mode` 0, `Function` 0 selects `TADD`, and `DataType` 1 selects `FP32`. With match `0x00019181`, `DataType` 1 in bits `31:27` gives the word `0x08019181`. Canonical disassembly prints the same word as `BSTART.VEC TADD, FP32`. Changing `Function` to 18 gives `0x09219181`, which selects `TEXP` and disassembles as `BSTART.SFU TEXP, FP32`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TEPL Mode, Function, DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

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
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | 0–21, 24–28 | none | 22–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | 0–3 | none | none | execution mode selector | Encoded zero supplies numeric zero for the execution mode selector. |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | 0–31 | none | none | tile operation function selector | Encoded zero supplies numeric zero for the tile operation function selector. |

- `bstart_tepl_32_d022db6dacb3.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |
| Mode | execution mode selector |
| Function | tile operation function selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TEPL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tepl_32_d022db6dacb3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL is the unchanged Mode:Function carrier. It retires any active predecessor, installs one Tile-element block descriptor, and accepts either the VEC or SFU operation assigned to that selector.
BSTART.TEPL remains accepted compatibility input, but canonical assembly and disassembly select BSTART.VEC or BSTART.SFU from the operation's execution engine.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TEPL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractAcceptsEngineAlias_BSTART_TEPL(
    engine: TileExecutionEngine) => boolean
begin
    return TileEngineHasCanonicalBundleStartAlias(engine);
end;

pure func InstructionContractAcceptsTileOperation_BSTART_TEPL(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_TEPL, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No operand field is omitted; every encoded field has the value carried by the selected form.

## Legality

- Mode:Function is a seven-bit selector with Mode in bits 6:5 and Function in bits 4:0.
- Only assigned TEPL-carried operations are legal; unassigned selector holes reject before effects.
- DataType accepts 0..14, 15..21, and 24..28; 22, 23, and 29..31 are reserved.
- BSTART.TEPL is compatibility input only; canonical output uses the operation's VEC or SFU alias.

## State effects

- After successful predecessor retirement, installs the selected Tile-element descriptor and a BARG whose BlockType denotes the Tile-element block.
- The selected operation executes only when BSTOP or the next BSTART commits the completed block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Carrier field, selector, operation, engine, and descriptor legality precede predecessor retirement and BARG publication.

## Exceptions

- Reserved DataType codes, unassigned Mode:Function selectors, non-TEPL operations, or invalid descriptors raise before predecessor retirement or new BARG effects.
- An accepted selector whose operation is not assigned to VEC or SFU is illegal for this carrier.

## Examples

- BSTART.TEPL 0, 0, FP32
