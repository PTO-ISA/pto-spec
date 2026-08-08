<!-- GENERATED FROM: asl/block/attributes/B.DIM.asl -->
# B.DIM

**Normative ASL source:** `asl/block/attributes/B.DIM.asl`

Writes one of the three bundle-local dimension registers.

## Normative identity {#PTO-INST-BLOCK-B-DIM}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.DIM RegSrc, uimm, ->LB2
B.DIM RegSrc, uimm, ->LB0
B.DIM RegSrc, uimm, ->LB1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_dim_32_1caa1aa2944a | L32 | 32 | 0x00002043 / 0x0000707f | [] |
| b_dim_32_27602ab68929 | L32 | 32 | 0x00000043 / 0x0000707f | [] |
| b_dim_32_4191099a5f4d | L32 | 32 | 0x00001043 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_dim_32_1caa1aa2944a | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_1caa1aa2944a | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |
| b_dim_32_27602ab68929 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_27602ab68929 | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |
| b_dim_32_4191099a5f4d | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_4191099a5f4d | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc | encoded operand or control |
| uimm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DIM.asl -->
```asl
readonly func InstructionContractMatches_B_DIM(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_dim_32_1caa1aa2944a) ||
           (operation == CommandOperation_b_dim_32_27602ab68929) ||
           (operation == CommandOperation_b_dim_32_4191099a5f4d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DIM.asl -->
```asl
type BundleDimensionRole of enumeration {
    BundleDimension_ValidColumns,
    BundleDimension_ValidRows,
    BundleDimension_PhysicalColumns
};

pure func BundleDimensionIndexOfRole(role: BundleDimensionRole)
    => BundleDimensionIndex
begin
    case role of
        when BundleDimension_ValidColumns => return 0;
        when BundleDimension_ValidRows => return 1;
        when BundleDimension_PhysicalColumns => return 2;
    end;
end;

readonly func InstructionContractHandler_B_DIM() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Writes one of the three bundle-local dimension registers.`
- **Semantic handler:** `SetBundleDimension`

<!-- SUPPLEMENTARY-BEGIN -->
`LB0` carries valid columns, `LB1` carries valid rows, and `LB2` carries the
physical column count. For a destination allocation, LB2 must be a nonzero
power of two. The physical row count is not encoded by B.DIM; it is derived
from the destination TSize, data type, and LB2 as specified by the embedded ASL
contracts and `DerivedTileRows`.

Matrix operations use valid rows as M and valid columns as N. K comes from the
matching source descriptors and must also be a nonzero power of two. LB2 still
describes the destination physical Col; it is not a second encoding of K.
<!-- SUPPLEMENTARY-END -->
