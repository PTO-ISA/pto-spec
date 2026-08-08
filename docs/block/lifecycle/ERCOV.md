<!-- GENERATED FROM: asl/block/lifecycle/ERCOV.asl -->
# ERCOV

**Normative ASL source:** `asl/block/lifecycle/ERCOV.asl`

Recovers the encoded execution-context range from memory.

## Normative identity {#PTO-INST-BLOCK-ERCOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ercov_32_dc0be14a2d8b | L32 | 32 | 0x00003031 / 0x06007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ercov_32_dc0be14a2d8b | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ercov_32_dc0be14a2d8b | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ercov_32_dc0be14a2d8b | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ERCOV.asl -->
```asl
readonly func InstructionContractMatches_ERCOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_ercov_32_dc0be14a2d8b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ERCOV.asl -->
```asl
readonly func InstructionContractHandler_ERCOV() => CommandSemanticHandler
begin
    return CommandHandler_RecoverExecutionContext;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
