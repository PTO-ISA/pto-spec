<!-- GENERATED FROM: asl/scalar/agu/SDI.U.asl -->
# SDI.U

**Normative ASL source:** `asl/scalar/agu/SDI.U.asl`

SDI.U - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-SDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sdi.u SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sdi_u_32_cba5a4a04e7b | L32 | 32 | 0x00007059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sdi_u_32_cba5a4a04e7b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sdi_u_32_cba5a4a04e7b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sdi_u_32_cba5a4a04e7b | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractOperation_SDI_U() => ScalarOperation
begin
    return ScalarOperation_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractHandler_SDI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SDI.U - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
