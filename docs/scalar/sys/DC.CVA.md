<!-- GENERATED FROM: asl/scalar/sys/DC.CVA.asl -->
# DC.CVA

**Normative ASL source:** `asl/scalar/sys/DC.CVA.asl`

DC.CVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.

## Normative identity {#PTO-INST-SCALAR-DC-CVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.cva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_cva_32_166d5a076f0e | L32 | 32 | 0x0020602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_cva_32_166d5a076f0e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CVA() => ScalarOperation
begin
    return ScalarOperation_DC_CVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `DC.CVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.`
- **Semantic handler:** `ExecuteMaintenance`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
