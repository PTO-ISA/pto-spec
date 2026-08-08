<!-- GENERATED FROM: asl/block/encoding/HL.BSTART.FP.asl -->
# HL.BSTART.FP

**Normative ASL source:** `asl/block/encoding/HL.BSTART.FP.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-HL-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
HL.BSTART.FP COND, <label>
HL.BSTART.FP FALL<, fixup_label>
HL.BSTART.FP CALL, <label>
HL.BSTART.FP DIRECT, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bstart_fp_48_038e2e96cf64 | HL48 | 48 | 0x00003101000e / 0x00007fff000f | [] |
| hl_bstart_fp_48_43530d2ebfae | HL48 | 48 | 0x00001101000e / 0x00007fff000f | [] |
| hl_bstart_fp_48_81b457553844 | HL48 | 48 | 0x00004101000e / 0x00007fff000f | [] |
| hl_bstart_fp_48_eb938e9200eb | HL48 | 48 | 0x00002101000e / 0x00007fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bstart_fp_48_038e2e96cf64 | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |
| hl_bstart_fp_48_43530d2ebfae | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |
| hl_bstart_fp_48_81b457553844 | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |
| hl_bstart_fp_48_eb938e9200eb | simm | 30 | signed | [{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_fp_48_038e2e96cf64) ||
           (operation == CommandOperation_hl_bstart_fp_48_43530d2ebfae) ||
           (operation == CommandOperation_hl_bstart_fp_48_81b457553844) ||
           (operation == CommandOperation_hl_bstart_fp_48_eb938e9200eb);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_FP() => CommandSemanticHandler
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
