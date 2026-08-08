<!-- GENERATED FROM: asl/scalar/alu/HL.LIS.asl -->
# HL.LIS

**Normative ASL source:** `asl/scalar/alu/HL.LIS.asl`

Execute the HL.LIS scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-HL-LIS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lis simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lis_48_908853d6ef87 | HL48 | 48 | 0x0000000d000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lis_48_908853d6ef87 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lis_48_908853d6ef87 | simm32 | 32 | signed | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractOperation_HL_LIS() => ScalarOperation
begin
    return ScalarOperation_HL_LIS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractHandler_HL_LIS() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
