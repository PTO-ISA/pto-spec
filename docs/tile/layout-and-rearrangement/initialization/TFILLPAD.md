<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
# TFILLPAD

**Normative ASL source:** `asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl`

Copy the source and fill destination padding elements with the bound scalar.

## Normative identity {#PTO-INST-TILE-TFILLPAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TFILLPAD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFILLPAD | TEPL | 0x065 | 5 | 3 | TFILLPAD |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | padding |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractOperation_TFILLPAD() => TileOperation
begin
    return TileOperation_TFILLPAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TFILLPAD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractHandler_TFILLPAD() => TileSemanticHandler
begin
    return TileHandler_TFILLPAD;
end;

pure func InstructionContractDataTypeLegal_TFILLPAD(
    data_type: TileDataType) => boolean
begin
    return TileFillPadDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word) => boolean
begin
    return TileOperandsLegal_TFILLPAD(destination, source, padding);
end;

func InstructionContractExecute_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word)
begin
    assert InstructionContractOperandsLegal_TFILLPAD(
        destination,
        source,
        padding);
    TFILLPAD(destination, source, padding);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TFILLPAD schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TFILLPAD.

## Legality

- TFILLPAD is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TFILLPAD validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"}].

## State effects

- Copy the source and fill destination padding elements with the bound scalar.
- After complete preflight, execute TFILLPAD with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TFILLPAD, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
