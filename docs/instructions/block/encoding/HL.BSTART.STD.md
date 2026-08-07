# HL.BSTART.STD

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/HL.BSTART.STD.asl -->

## Assembly

```asm
HL.BSTART.STD CALL, <label>
HL.BSTART.STD FALL<, fixup_label>
HL.BSTART.STD COND, <label>
HL.BSTART.STD DIRECT, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bstart_std_48_51f78942222e | HL48 | 48 | 0x00004001000e / 0x00007fff000f | [] |
| hl_bstart_std_48_9ba705800872 | HL48 | 48 | 0x00001001000e / 0x00007fff000f | [] |
| hl_bstart_std_48_b13f22c7c4a3 | HL48 | 48 | 0x00003001000e / 0x00007fff000f | [] |
| hl_bstart_std_48_d814d26508a4 | HL48 | 48 | 0x00002001000e / 0x00007fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bstart_std_48_51f78942222e | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |
| hl_bstart_std_48_9ba705800872 | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |
| hl_bstart_std_48_b13f22c7c4a3 | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |
| hl_bstart_std_48_d814d26508a4 | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_std_48_51f78942222e) ||
           (operation == CommandOperation_hl_bstart_std_48_9ba705800872) ||
           (operation == CommandOperation_hl_bstart_std_48_b13f22c7c4a3) ||
           (operation == CommandOperation_hl_bstart_std_48_d814d26508a4);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_STD() => CommandSemanticHandler
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
