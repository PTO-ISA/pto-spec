<!-- GENERATED FROM: asl/scalar/sys/IC.IVA.asl -->
# IC.IVA

**Normative ASL source:** `asl/scalar/sys/IC.IVA.asl`

IC.IVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.

## Normative identity {#PTO-INST-SCALAR-IC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ic.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iva_32_11b9a61dd8b5 | L32 | 32 | 0x0000502b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ic_iva_32_11b9a61dd8b5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractOperation_IC_IVA() => ScalarOperation
begin
    return ScalarOperation_IC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractHandler_IC_IVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `IC.IVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.`
- **Semantic handler:** `ExecuteMaintenance`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
