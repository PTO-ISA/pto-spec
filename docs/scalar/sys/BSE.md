<!-- GENERATED FROM: asl/scalar/sys/BSE.asl -->
# BSE

**Normative ASL source:** `asl/scalar/sys/BSE.asl`

BSE - Issue this mnemonic's architecture control request.

## Normative identity {#PTO-INST-SCALAR-BSE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bse SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | L32 | 32 | 0x0000002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractOperation_BSE() => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractHandler_BSE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `BSE - Issue this mnemonic's architecture control request.`
- **Semantic handler:** `ExecuteControlRequest`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
