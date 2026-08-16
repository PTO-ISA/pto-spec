<!-- GENERATED FROM: asl/block/execution/BSTART.SYS.asl -->
# BSTART.SYS

**Normative ASL source:** `asl/block/execution/BSTART.SYS.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | L32 | 32 | 0x00001081 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | 0 | none | 1–131071 | fixed-zero fallthrough payload; nonzero values are extension-reserved | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_sys_32_762d9d84a6d8.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | fixed-zero fallthrough payload; nonzero values are extension-reserved |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SYS retires any active predecessor block, then opens one system block whose header commands execute sequentially until BSTOP or the next BSTART.
SYS has no candidate transfer: BPCN, TYPE, and TAKEN are inapplicable and cannot select the next PC.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_SYS()
    => BundleKind
begin
    return BundleKind_System;
end;

pure func InstructionContractStartsBundle_BSTART_SYS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The encoded simm17 field is fixed to zero; nonzero values are extension-reserved.

## Legality

- Only simm17=0 is accepted; every nonzero payload is extension-reserved.

## State effects

- On success BPC records the BSTART address and BARG.BlockType becomes SYS. BPCN, TYPE, and TAKEN are inapplicable and are canonicalized to non-selecting values.
- Header execution and the eventual block continuation are sequential.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The fixed-zero payload and form legality are checked before predecessor retirement. New SYS BARG state is installed only after successful retirement.

## Exceptions

- Any nonzero simm17 in the SYS FALL family is extension-reserved and raises before predecessor retirement or new BARG effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no system block is installed.

## Examples

- BSTART.SYS FALL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
