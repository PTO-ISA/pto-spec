<!-- GENERATED FROM: asl/block/encoding/C.BSTART.SYS.asl -->
# C.BSTART.SYS

**Normative ASL source:** `asl/block/encoding/C.BSTART.SYS.asl`

Starts the fixed compressed sequential System block without a selecting branch continuation.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_sys_16_ec213ce96eb7 | C16 | 16 | 0x0840 / 0xffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_sys_16_ec213ce96eb7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.SYS opens one System block. Its header commands execute sequentially until BSTOP or the next BSTART.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.SYS.asl -->
```asl
pure func InstructionContractKind_C_BSTART_SYS() => BundleKind
begin
    return BundleKind_System;
end;

readonly func InstructionContractHandler_C_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no operand field. FALL and zero displacement are fixed by its complete 16-bit encoding.

## Legality

- The complete 16-bit pattern 0x0840 is the only accepted C.BSTART.SYS encoding.
- System blocks have only sequential fallthrough and expose no BPCN, TYPE, or TAKEN continuation.

## State effects

- Installs BARG.BPC=P and BlockType=SYS, advances header execution to P+2, and keeps BPCN zero with canonical non-selecting fallthrough state.
- BSTOP or the next BSTART commits to the sequential continuation.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The predecessor block commits before the new System BARG is installed. C.BSTART.SYS itself performs no memory access.

## Exceptions

- Any different bit pattern belongs to another instruction or is illegal; it is not a C.BSTART.SYS operand variation.
- If predecessor commit fails, the retiring block remains authoritative and no System BARG is installed.

## Examples

- C.BSTART.SYS FALL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
