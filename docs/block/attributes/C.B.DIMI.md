<!-- GENERATED FROM: asl/block/attributes/C.B.DIMI.asl -->
# C.B.DIMI

**Normative ASL source:** `asl/block/attributes/C.B.DIMI.asl`

Writes one selected bundle-local LB from a zero-extended eight-bit immediate exactly once.

## Normative identity {#PTO-INST-BLOCK-C-B-DIMI}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.B.DIMI imm8, ->LB0
C.B.DIMI imm8, ->LB1
C.B.DIMI imm8, ->LB2
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | C16 | 16 | 0x003c / 0x003f | [{"field":"LoopNest","operator":"not-equal","value":3}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | encoding-defined | [{"instruction_lsb":14,"value_lsb":0,"width":2}] |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":8}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | 0–2 | none | 3 | encoded LB0, LB1, or LB2 selector | Code zero selects LB0. |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | 0–255 | none | none | unsigned eight-bit bundle-local dimension value | Encoded zero writes numeric zero to the selected LB. |

- `c_b_dimi_16_3f1b113c76ce.LoopNest` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| LoopNest | encoded LB0, LB1, or LB2 selector |
| imm8 | unsigned eight-bit bundle-local dimension value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/C.B.DIMI.asl -->
```asl
readonly func InstructionContractMatches_C_B_DIMI(
    operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_c_b_dimi_16_3f1b113c76ce;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. C.B.DIMI and B.DIM share one write-once presence bit for each of LB0, LB1, and LB2.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/C.B.DIMI.asl -->
```asl
pure func InstructionContractDimension_C_B_DIMI(
    loop_nest: bits(2))
    => BundleDimensionIndex
begin
    assert loop_nest != '11';
    return UInt(loop_nest) as BundleDimensionIndex;
end;

pure func InstructionContractValue_C_B_DIMI(
    immediate: bits(8))
    => Word
begin
    return ZeroExtend{PTO_XLEN}(immediate);
end;

readonly func InstructionContractHandler_C_B_DIMI()
    => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LoopNest 0, 1, and 2 select LB0, LB1, and LB2. imm8 is always present; encoded zero writes numeric zero and is not omission.

## Legality

- LoopNest codes 0..2 are assigned to LB0..LB2; code 3 is reserved.
- imm8 accepts every unsigned value 0..255 and is zero-extended to the bundle dimension word.
- Each selected LB is write-once for one block across full and compressed dimension commands.

## State effects

- Write ZeroExtend(imm8) to the selected raw LB and set its presence bit.
- LB meaning is selected by the completed operation schema; C.B.DIMI assigns no universal row, column, M, N, or K role.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Placement and duplicate checks precede the LB update. A successful update sets the presence bit and value together, then command dispatch advances TPC by two bytes.

## Exceptions

- LoopNest code 3 raises Fault_IllegalInstruction before changing TPC or bundle state.
- Execution outside an active block header or a second write to the same LB across C.B.DIMI and B.DIM raises Fault_BundleControl before changing the first value.

## Examples

- C.B.DIMI 0, ->LB0
- C.B.DIMI 255, ->LB2

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
