<!-- GENERATED FROM: asl/scalar/sys/EBREAK.asl -->
# EBREAK

**Normative ASL source:** `asl/scalar/sys/EBREAK.asl`

EBREAK raises software-breakpoint trap 50 with its 4-bit immediate as cause.

## Normative identity {#PTO-INST-SCALAR-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ebreak-purpose role=purpose -->
## What EBREAK does

`EBREAK` raises a software breakpoint. Unlike a branch or a call, it publishes a fault instead of a continuation: the attempt ends with trap number 50 and the faulting instruction address, and the encoded immediate becomes the trap cause.

<!-- PTO-READER-BLOCK: scalar-ebreak-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_EBREAK` selects `ScalarHandler_SoftwareBreakpoint` (`asl/scalar/sys/EBREAK.asl:11`). The dispatcher decodes the 4-bit `imm4` field, zero-extends it to 5 bits, and calls `SoftwareBreakpoint` (`asl/scalar/model/dispatch/sys.asl:78`). That helper raises `Fault_SoftwareBreakpoint` with the current instruction address and the zero-extended cause (`asl/scalar/model/sys/semantics.asl:91`).

The fault class fixes the trap identity: `Fault_SoftwareBreakpoint` maps to trap number 50 (`asl/arch/memory-model/fault-precision.asl:80`). `InstructionContractBreakpointPublishesTrapCause_EBREAK` returns `TRUE` (`asl/scalar/sys/EBREAK.asl:36`), so the immediate is published as the cause rather than kept in a separate breakpoint register.

The instruction is applicable only in the body of an active SYS block (`asl/scalar/model/sys/semantics.asl:322`).

<!-- PTO-READER-BLOCK: scalar-ebreak-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`imm4` is a 4-bit immediate at instruction bits 27:24 (`asl/scalar/sys/EBREAK.asl:1`). All sixteen of its values are assigned, and `InstructionContractBreakpointImmediateWidth_EBREAK` reports the width as 4 (`asl/scalar/sys/EBREAK.asl:30`).

The instruction writes no register. Its outputs are architectural trap state: the trap cause and the faulting address. Encoded zero in `imm4` is a real zero cause, not an omitted operand.

<!-- PTO-READER-BLOCK: scalar-ebreak-effects role=effects -->
## Architectural effects

The attempt saves the pre-instruction context for the target ring, stores the zero-extended immediate as the trap cause, stores the faulting instruction address as the trap argument, and writes the trap vector entry into `TPC` (`asl/arch/memory-model/fault-precision.asl:63`). The new `TPC` therefore comes from the trap vector rather than from an increment of the faulting address.

Design point: the immediate is zero-extended twice on the way to the trap bank, first from 4 bits to 5 bits at the dispatcher and then into the 24-bit cause field (`asl/arch/memory-model/fault-precision.asl:70`). Every encoding stays distinguishable as a cause, and no parallel breakpoint-tag state is created.

`EBREAK` has no memory effect: no ordinary scalar memory access is performed, and no data memory changes.

<!-- PTO-READER-BLOCK: scalar-ebreak-constraints role=constraints -->
## Placement and rejection

The placement check comes first. Outside an active SYS block body the attempt raises `Fault_BundleControl` and never reaches the breakpoint handler, so the breakpoint does not update the trap bank.

Once the handler runs, the breakpoint fault is the instruction's effect rather than a rejection. There is no reserved immediate value to reject, because all sixteen are assigned, and the operation is not ring-restricted, so a properly placed `EBREAK` always produces trap number 50.

<!-- PTO-READER-BLOCK: scalar-ebreak-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Execute `ebreak 0` in a SYS block body. The attempt passes the placement check, and the trap bank then holds trap number 50 with cause 0 and the faulting instruction address as the argument, while `TPC` points at the trap vector entry. Executing `ebreak 15` behaves the same way but leaves cause 15 in the trap bank.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ebreak imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | L32 | 32 | 0x0010102b / 0xf0ffffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | 0–15 | none | none | 4-bit immediate value | Encoded zero supplies numeric zero for the 4-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm4 | 4-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractOperation_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
EBREAK executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractHandler_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_EBREAK()
    => integer {4,5}
begin
    return 4;
end;

pure func InstructionContractBreakpointPublishesTrapCause_EBREAK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every 4-bit immediate value is assigned; encoded zero is a real zero cause.

## State effects

- Raise Fault_SoftwareBreakpoint and publish trap number 50.
- Zero-extend the encoded immediate into the 24-bit trap-cause field; no parallel breakpoint-tag state exists.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- After placement and decode, atomically save the pre-instruction context, trap number, zero-extended immediate cause, and faulting-PC argument before vector transfer.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ebreak imm
