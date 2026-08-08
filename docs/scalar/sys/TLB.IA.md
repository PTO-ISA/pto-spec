<!-- GENERATED FROM: asl/scalar/sys/TLB.IA.asl -->
# TLB.IA

**Normative ASL source:** `asl/scalar/sys/TLB.IA.asl`

TLB.IA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.

## Normative identity {#PTO-INST-SCALAR-TLB-IA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
tlb.ia SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_ia_32_e794d6bf347e | L32 | 32 | 0x0000702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_ia_32_e794d6bf347e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IA.asl -->
```asl
readonly func InstructionContractOperation_TLB_IA() => ScalarOperation
begin
    return ScalarOperation_TLB_IA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IA.asl -->
```asl
readonly func InstructionContractHandler_TLB_IA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `TLB.IA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.`
- **Semantic handler:** `ExecuteMaintenance`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
