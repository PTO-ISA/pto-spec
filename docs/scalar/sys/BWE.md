<!-- GENERATED FROM: asl/scalar/sys/BWE.asl -->
# BWE

**Normative ASL source:** `asl/scalar/sys/BWE.asl`

BWE - Issue this mnemonic's architecture control request.

## Normative identity {#PTO-INST-SCALAR-BWE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bwe SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bwe_32_e5a5240bdf9b | L32 | 32 | 0x0010002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bwe_32_e5a5240bdf9b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BWE.asl -->
```asl
readonly func InstructionContractOperation_BWE() => ScalarOperation
begin
    return ScalarOperation_BWE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BWE.asl -->
```asl
readonly func InstructionContractHandler_BWE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `BWE - Issue this mnemonic's architecture control request.`
- **Semantic handler:** `ExecuteControlRequest`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
