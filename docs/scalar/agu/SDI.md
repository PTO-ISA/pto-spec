<!-- GENERATED FROM: asl/scalar/agu/SDI.asl -->
# SDI

**Normative ASL source:** `asl/scalar/agu/SDI.asl`

SDI - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sdi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sdi_32_fab563230a66 | L32 | 32 | 0x00003059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sdi_32_fab563230a66 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sdi_32_fab563230a66 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sdi_32_fab563230a66 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractOperation_SDI() => ScalarOperation
begin
    return ScalarOperation_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractHandler_SDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SDI - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
