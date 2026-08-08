<!-- GENERATED FROM: asl/scalar/bru/C.CMP.EQI.asl -->
# C.CMP.EQI

**Normative ASL source:** `asl/scalar/bru/C.CMP.EQI.asl`

Execute the C.CMP.EQI scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-C-CMP-EQI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.cmp.eqi t#1, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_cmp_eqi_16_e34367883ba1 | C16 | 16 | 0x002c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_cmp_eqi_16_e34367883ba1 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.EQI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_EQI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.EQI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
