<!-- GENERATED FROM: asl/block/encoding/C.BSTART.SYS.asl -->
# C.BSTART.SYS

**Normative ASL source:** `asl/block/encoding/C.BSTART.SYS.asl`

Starts the fixed compressed sequential System block without a selecting branch continuation.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-sys-purpose role=purpose -->
## What C.BSTART.SYS does

`C.BSTART.SYS` is the 16-bit start command for a System block. It has one spelling, `C.BSTART.SYS FALL`, and no operand field. A block (also called a bundle) is a group of header commands and body instructions that commits as one unit at `BSTOP` or at the next block start.

A System block always continues sequentially. It has no branch target. The model pages [Bundle start dispatch](../model/dispatch/start.md) and [Begin](../model/lifecycle/begin.md) define the shared start sequence.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-mechanism role=mechanism -->
## Encoding and start sequence

The complete halfword `0x0840` is the only encoding. The mask `0xffff` fixes every bit, so there is nothing to decode beyond the form itself.

Execution follows the common start order. Any active predecessor commits first. The new System block opens only if that commit selected this `C.BSTART.SYS` address as the next PC. Header execution then continues at `P + 2`, where `P` is the address of the command.

Design point: the System kind is the block kind in which the scalar system operations, such as `FENCE.I`, `FENCE.D`, and the data-cache maintenance operations, are applicable. `ScalarOperationApplicable` accepts them only in the body of an active System block. `C.BSTART.SYS` is the compressed way to open such a block.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-inputs role=inputs-outputs -->
## Fields and BARG values

- There is no encoded operand, so there is no default and no encoded-zero meaning. The form fixes the FALL transfer and the zero `BPCN`.
- The start installs `BARG.BPC = P` and `BlockType = SYS`.
- `BARG.TYPE` is FALL, `TAKEN` is 0, and `BPCN` is 0.

Design point: `BeginBundleAt` ignores the supplied transfer for a System block and stores this fixed non-selecting value. A System `BARG` can therefore never select `BPCN` at commit. The same rule means `SETC.TGT` and `LSRGET` identifier 1 are not applicable in a System block, because only Standard and Floating blocks carry a candidate word.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-effects role=effects -->
## State effects and ordering

A successful start clears the previous header state, marks the new block active in its header phase, writes `BARG` and `BPC`, and takes a fresh execution-domain token. `C.BSTART.SYS` performs no memory access and writes no GPR.

At `BSTOP` or the next block start, the System block commits to its sequential continuation.

Design point: the predecessor commits before the System `BARG` is installed. If the predecessor commit fails, the predecessor stays authoritative and no System `BARG` is installed. If the predecessor transfers elsewhere, this command was on an unselected path and opens nothing.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-constraints role=constraints -->
## Legality and fault boundary

Any halfword other than `0x0840` belongs to another instruction or is illegal. It is not an operand variation of `C.BSTART.SYS`.

`C.BSTART.SYS` has no operand that can fail. The shared start path still checks that its sequential target `P + 2` is even, and an odd value raises `Fault_InstructionPC`. Other faults at this command come from dispatcher checks on the active predecessor, such as an incomplete TGPR2T or TIMG2COL header stream (`Fault_BundleControl`), or from the predecessor commit; in each case the predecessor stays in place.

After an `ACRC` request in the body sets the system-block terminal marker, the command dispatcher accepts only a block stop or a block start as the next command. Every other command raises `Fault_BundleControl`.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART.SYS FALL
```

If `C.BSTART.SYS FALL` sits at `0x6000`, the new block has `BPC = 0x6000`, `BlockType = SYS`, and `BPCN = 0`. Header execution continues at `0x6002`. A `BSTOP` at `0x6010` commits the block and execution continues at `0x6014`, the instruction after that 4-byte `BSTOP`.
<!-- SUPPLEMENTARY-END -->

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
