<!-- GENERATED FROM: asl/block/execution/BSTART.TSTORE.asl -->
# BSTART.TSTORE

**Normative ASL source:** `asl/block/execution/BSTART.TSTORE.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TSTORE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.TSTORE DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tstore_32_4048b6e8b0f4 | L32 | 32 | 0x00111181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tstore_32_4048b6e8b0f4 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
| bstart_tstore_32_4048b6e8b0f4 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | source element data type | Encoded zero selects FP64. |

- `bstart_tstore_32_4048b6e8b0f4.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | source element data type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR byte row stride |
| B.DIM.LB0 | ordinary ValidCol or CUBE valid columns |
| B.DIM.LB1 | ordinary ValidRow or CUBE valid rows |
| B.DIM.LB2 | ordinary physical Col; forbidden for CUBE conversion |
| B.IOT/B.IOS | Local or Shared source and participation mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TSTORE.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TSTORE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tstore_32_4048b6e8b0f4);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local source: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM supplies ValidCol, ValidRow, and physical Col; optional B.IOR supplies each PE's GM base and byte row stride; exactly one terminating source B.IOT supplies the Local Tile; BSTOP commits.
Shared full source: the Function 1 form replaces B.IOT with one source B.IOS and requires PE_MASK=1111 for any nonzero access.
Shared partial source: the Function 14 TSTORE.SPART form uses one source B.IOS and accepts any nonzero PE subset. It has no Local form.
Local CUBE source: Function 1 encodes B.DATR Layout M322ND, M162ND, or N82ND with DataType=DTYPE_NONE; requires LB0=valid columns and LB1=valid rows, omits LB2, and uses one terminating source B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TSTORE.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TSTORE() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TSTORE()
    => TileOperation
begin
    return TileOperation_TSTORE;
end;

pure func InstructionContractStartsTileBundle_BSTART_TSTORE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TSTORE(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsStore(data_layout);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit. Optional B.DATR omission retains the default NORM layout.
- For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For an unallocated Shared source they default to 1, 1, and ValidCol.
- An unallocated Shared source derives the smallest legal 128 B through 8 KiB per-PE capacity that contains the completed shape; Rows are then derived from capacity, Col, and DataType. Every selected source element is an undefined-register value and the temporary descriptor is never written back.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride.

## Legality

- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- The Function 1 carrier accepts exactly one Local source B.IOT or one Shared source B.IOS. The Function 14 TSTORE.SPART carrier accepts exactly one Shared source B.IOS. Source/destination role mismatches and mixed Local/Shared sources are illegal.
- A nonzero Function 1 Shared store requires PE_MASK=1111. Function 14 accepts every nonzero subset. PE_MASK=0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the resolved valid rectangle must fit the source descriptor or the derived temporary descriptor.
- For an allocated Shared source, DataType, Layout, and physical Col agree with the persistent descriptor; an explicitly reduced valid rectangle may not exceed the descriptor's valid region.
- Local CUBE conversion accepts only Layout codes 24 through 26, requires explicit DTYPE_NONE, explicit nonzero LB0/LB1, absent LB2, one persistent Matrix-location CUBE source, a supported non-64-bit non-HiF4X2 dtype, and no B.IOS.

## State effects

- Reads one Local or Shared source without modifying its payload, descriptor, allocation mask, initialized mask, or lifetime.
- A Shared undefined-source read remains non-allocating and non-mutating. On success only GM and memory-event state change; the source binding is consumed by normal block completion.
- A successful CUBE form preserves the complete persistent Matrix descriptor, payload, definedness, allocation mask, and lifetime while storing only its LB1 by LB0 valid rectangle.

## Memory effects and ordering

### Memory effects

- For every selected PE and every selected element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.
- The complete selected-PE footprint is preflighted before the first GM write, so a fault produces no partial store. After successful preflight individual store beats need not be atomic or ordered to observers.

### Ordering

- Resolve and validate the complete schema, source descriptor or temporary descriptor, dimensions, masks, per-PE GPR inputs, and every memory access before the first architectural store effect.
- Selected Shared-store PEs have no architecture-defined relative issue or commit order; software avoids overlapping GM regions or establishes ordering separately.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, illegal or inconsistent PE mask, malformed binding schema, or memory translation/permission/alignment fault rejects before the first GM write.
- A completely unallocated or selected-quarter-uninitialized Shared source is not itself an exception; it supplies undefined-register values through a read-only operation-derived descriptor.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T#1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP
- BSTART.TSTORE FP16 [TSTORE.SPART form]; B.IOS S7, mask=0011; BSTOP
- BSTART.TSTORE FP16; B.DATR {M162ND, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=N; B.DIM LB1=M; B.IOT M#1, mask=1111, <last>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
