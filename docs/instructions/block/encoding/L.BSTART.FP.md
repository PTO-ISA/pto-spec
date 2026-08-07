# L.BSTART.FP

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/L.BSTART.FP.asl -->

## Assembly

```asm
L.BSTART.FP COND, <label>
L.BSTART.FP DIRECT, <label>
L.BSTART.FP CALL, <label>
L.BSTART.FP FALL<, fixup_label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| l_bstart_fp_64_098e57019d7b | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_098e57019d7b | L64 | 32 | 0x00003081 / 0x00007fff | [] |
| l_bstart_fp_64_0cac9941f7d4 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_0cac9941f7d4 | L64 | 32 | 0x00002081 / 0x00007fff | [] |
| l_bstart_fp_64_2067ad6667ed | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_2067ad6667ed | L64 | 32 | 0x00004081 / 0x00007fff | [] |
| l_bstart_fp_64_8115c042ef26 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_8115c042ef26 | L64 | 32 | 0x00001081 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| l_bstart_fp_64_098e57019d7b | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_fp_64_0cac9941f7d4 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_fp_64_2067ad6667ed | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_fp_64_8115c042ef26 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/L.BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_L_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstart_fp_64_098e57019d7b) ||
           (operation == CommandOperation_l_bstart_fp_64_0cac9941f7d4) ||
           (operation == CommandOperation_l_bstart_fp_64_2067ad6667ed) ||
           (operation == CommandOperation_l_bstart_fp_64_8115c042ef26);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/L.BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_L_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
