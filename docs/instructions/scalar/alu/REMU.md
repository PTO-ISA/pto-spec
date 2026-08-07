# REMU

Execute the REMU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REMU.asl -->

## Normative identity {#PTO-INST-SCALAR-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
remu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remu_32_d7a5d1ebbbf5 | L32 | 32 | 0x00005057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remu_32_d7a5d1ebbbf5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remu_32_d7a5d1ebbbf5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remu_32_d7a5d1ebbbf5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractOperation_REMU() => ScalarOperation
begin
    return ScalarOperation_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractHandler_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
